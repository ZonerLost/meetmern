import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/main.dart';
import 'package:meetmern/core/widgets/app_snackbar.dart';
import 'package:meetmern/view/controllers/chat_controller/chat_screen_controller.dart';

class ChatMessageItem {
  final String id;
  final String text;
  final bool isMe;
  final String messageType;
  final String? requestStatus;
  final String? meetupRequestId;
  final String? meetupId;

  /// True when this card is a pending request addressed to the current user,
  /// so it should show its own Accept / Decline pair. Each request card in a
  /// thread answers independently.
  final bool canRespond;

  /// Venue detail for an agreed meetup card: "Coffee", the formatted
  /// "Tue · 5–6 PM", the address, and coordinates for the directions button.
  /// Only populated once the request is accepted — the exact venue stays
  /// hidden until both sides have agreed, matching the meetup detail screen.
  final String meetupType;
  final String meetupWhen;
  final String meetupAddress;
  final double? meetupLatitude;
  final double? meetupLongitude;

  bool get hasMeetupDetail =>
      meetupType.isNotEmpty ||
      meetupWhen.isNotEmpty ||
      meetupAddress.isNotEmpty;

  const ChatMessageItem({
    required this.id,
    required this.text,
    required this.isMe,
    this.messageType = 'text',
    this.requestStatus,
    this.meetupRequestId,
    this.meetupId,
    this.canRespond = false,
    this.meetupType = '',
    this.meetupWhen = '',
    this.meetupAddress = '',
    this.meetupLatitude,
    this.meetupLongitude,
  });
}

class MessageController extends GetxController with WidgetsBindingObserver {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final List<ChatMessageItem> messages = <ChatMessageItem>[];

  Chat? chat;
  bool canSend = false;
  bool isLoading = false;
  bool _isBlockedConversation = false;
  String _blockedConversationText = '';
  // When true the text composer is shown even after completion.
  bool _continueChatMode = false;

  // Supabase-backed state
  String? _chatId;
  String? _chatStatus;
  String? _chatType;
  String _meetupSubtitle = '';
  String? _latestRequestId;
  String? _latestRequestMessageId;
  String? _latestRequestSenderId;
  String? _latestRequestReceiverId;

  /// Every meetup_request in this thread, keyed by request id. A thread can
  /// hold several independent requests at once (one per meetup ad), so each
  /// card reads its status from here rather than from the shared chat status.
  final Map<String, Map<String, dynamic>> _requestsById =
      <String, Map<String, dynamic>>{};

  /// Meetup rows for the ads those requests point at, keyed by meetup id.
  final Map<String, Map<String, dynamic>> _meetupsById =
      <String, Map<String, dynamic>>{};

  /// True once any request in the thread has been agreed. This — not the
  /// transient chat status — is what keeps the conversation open, so declining
  /// a later request never closes a chat an earlier one opened.
  bool _hasAcceptedRequest = false;
  StreamSubscription<List<Map<String, dynamic>>>? _chatSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;
  bool _isLoadInProgress = false;
  bool _hasPendingLoad = false;
  bool _pendingLoadWantsLoader = false;
  Timer? _realtimeReloadDebounce;
  Timer? _realtimeReconnectTimer;

  String? get currentUserId => AuthService.currentUser?.id;
  String? get latestRequestId => _latestRequestId;
  String get effectiveChatStatus => _chatStatus ?? 'requested';
  bool get continueChatMode => _continueChatMode;

  /// The formatted subtitle shown in the appbar: "Fri · 5–6 PM · Near Soho, London"
  /// Built from the cached meetup row; falls back to chat.subtitle.
  String get appBarSubtitle {
    print('[AppBarSubtitle] _meetupSubtitle="$_meetupSubtitle" chat.subtitle="${chat?.subtitle}"');
    if (_meetupSubtitle.isNotEmpty) return _meetupSubtitle;
    return chat?.subtitle ?? '';
  }

  bool get isOwner {
    final uid = currentUserId;
    if (uid == null || chat == null) return false;
    return chat!.userOne == uid;
  }

  bool get isLatestRequestSender {
    final uid = currentUserId;
    if (uid == null) return false;
    if (_latestRequestSenderId?.isNotEmpty == true) {
      return _latestRequestSenderId == uid;
    }
    return chat?.userTwo == uid;
  }

  bool get isLatestRequestReceiver {
    final uid = currentUserId;
    if (uid == null) return false;
    if (_latestRequestReceiverId?.isNotEmpty == true) {
      return _latestRequestReceiverId == uid;
    }
    // Meetup owner is always user_one.
    return chat?.userOne == uid;
  }

  bool get canRespondToLatestRequest {
    final type = _chatType ?? 'meetup';
    if (type != 'meetup') return false;
    if (_latestRequestId == null) return false;
    if (!isLatestRequestReceiver) return false;
    return _chatStatus == 'requested' || _chatStatus == 'pending';
  }

  /// Messaging is allowed once any request in the thread has been agreed, or in
  /// continue-chat mode after completion.
  ///
  /// Keyed off [_hasAcceptedRequest] rather than the chat status so that a
  /// later request being declined or cancelled cannot silence a conversation
  /// an earlier accepted request opened.
  bool get messagingAllowed {
    if (_isBlockedConversation) return false;
    if (_hasAcceptedRequest) return true;
    final status = _chatStatus ?? 'requested';
    if (status == 'accepted') return true;
    if (_continueChatMode && status == 'completed') return true;
    return false;
  }

  bool get isBlockedConversation => _isBlockedConversation;
  String get blockedConversationText => _blockedConversationText.isNotEmpty
      ? _blockedConversationText
      : 'You cannot message this user because one of you has blocked the other.';

  bool get isCompletedMeetup => _chatStatus == 'completed';

  bool get canSendNewRequest {
    if (_isBlockedConversation) return false;
    final type = _chatType ?? 'meetup';
    if (type != 'meetup') return false;
    return _chatStatus == 'completed' ||
        _chatStatus == 'rejected' ||
        _chatStatus == 'cancelled';
  }

  String get statusText {
    switch (_chatStatus) {
      case 'accepted': return 'Accepted';
      case 'rejected': return 'Rejected';
      case 'requested': return 'Request Pending';
      case 'completed': return 'Meetup Completed';
      case 'cancelled': return 'Cancelled';
      case 'closed': return 'Closed';
      default:
        switch (chat?.status) {
          case RequestStatus.accepted: return 'Accepted';
          case RequestStatus.rejected: return 'Rejected';
          case RequestStatus.requested: return 'Request Pending';
          case RequestStatus.completed: return 'Meetup Completed';
          case RequestStatus.cancelled: return 'Cancelled';
          default: return '';
        }
    }
  }

  /// Persists continue-chat mode by setting chat status back to 'accepted'
  /// in the DB so both sides see the text field on every open.
  Future<void> enableContinueChatMode() async {
    if (_chatId == null) return;
    _continueChatMode = true;
    canSend = messageController.text.trim().isNotEmpty;
    update();
    try {
      await MeetupService.setChatContinueMode(_chatId!);
    } catch (e) {
      print('🔴 [MessageController] enableContinueChatMode error: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-establish the realtime socket (dropped while backgrounded) and refetch
    // so messages that arrived while away show without a manual refresh.
    if (state == AppLifecycleState.resumed && _chatId != null) {
      _startRealtimeListeners();
      unawaited(_loadFromSupabase(showLoader: false));
    }
  }

  Future<void> init(Chat initialChat,
      {String? incoming, String? outgoing}) async {
    print('🔵 [MessageController] init called for chat: ${initialChat.id}');
    // Cancel stale subscriptions from any previous chat session.
    _chatSubscription?.cancel();
    _messageSubscription?.cancel();
    _chatSubscription = null;
    _messageSubscription = null;

    // Reset all state so a previous chat's data never bleeds through.
    messages.clear();
    _requestsById.clear();
    _meetupsById.clear();
    _hasAcceptedRequest = false;
    _latestRequestId = null;
    _latestRequestMessageId = null;
    _latestRequestSenderId = null;
    _latestRequestReceiverId = null;
    _isBlockedConversation = false;
    _blockedConversationText = '';
    _isLoadInProgress = false;
    _hasPendingLoad = false;
    _pendingLoadWantsLoader = false;
    _continueChatMode = false;
    _meetupSubtitle = '';
    _realtimeReloadDebounce?.cancel();
    _realtimeReloadDebounce = null;
    _realtimeReconnectTimer?.cancel();
    _realtimeReconnectTimer = null;
    isLoading = true;

    chat = initialChat;
    _chatId = initialChat.id;
    _chatStatus = initialChat.dbStatus;
    if (_chatStatus == 'pending') _chatStatus = 'requested';
    _chatType = (initialChat.chatType?.isNotEmpty == true)
        ? initialChat.chatType
        : 'meetup';
    // Seed subtitle immediately so appbar shows it before DB load.
    if (initialChat.subtitle.isNotEmpty) {
      _meetupSubtitle = initialChat.subtitle;
    }

    print(
        '🔵 [MessageController] Chat initialized - ID: $_chatId, Status: $_chatStatus, Type: $_chatType');
    print('🔵 [MessageController] Setting isLoading = true, calling update()');

    // Remove then re-add listeners to avoid duplicates on reuse.
    messageController.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    messageController.addListener(_onTextChanged);
    focusNode.addListener(_onFocusChanged);

    update();
    print('🔵 [MessageController] update() called - UI should show loading');

    if (_chatId != null) {
      await _loadFromSupabase();
      _startRealtimeListeners();
    } else {
      print('🔵 [MessageController] No chat ID, using mock messages');
      messages
        ..clear()
        ..add(ChatMessageItem(
            id: '1',
            text: incoming ?? 'Hi, nice to connect with you.',
            isMe: false))
        ..add(ChatMessageItem(
            id: '2',
            text: outgoing ?? 'Great, looking forward to meetup.',
            isMe: true));
      isLoading = false;
      print(
          '🟢 [MessageController] ✅ Mock messages loaded, setting isLoading = false, calling update()');
      update();
    }
  }

  void _startRealtimeListeners() {
    if (_chatId == null) return;

    _realtimeReconnectTimer?.cancel();
    _chatSubscription?.cancel();
    _messageSubscription?.cancel();

    _chatSubscription = supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('id', _chatId!)
        .listen(
          (_) => _queueRealtimeReload(),
          onError: (Object e) {
            print('🔴 [MessageController] Chat stream error: $e');
            _scheduleRealtimeReconnect();
          },
          onDone: _scheduleRealtimeReconnect,
          cancelOnError: true,
        );

    _messageSubscription = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', _chatId!)
        .listen(
          (_) => _queueRealtimeReload(),
          onError: (Object e) {
            print('🔴 [MessageController] Message stream error: $e');
            _scheduleRealtimeReconnect();
          },
          onDone: _scheduleRealtimeReconnect,
          cancelOnError: true,
        );
  }

  void _scheduleRealtimeReconnect() {
    if (isClosed || _chatId == null) return;
    _realtimeReconnectTimer?.cancel();
    _realtimeReconnectTimer = Timer(const Duration(seconds: 3), () {
      if (isClosed || _chatId == null) return;
      print('🔁 [MessageController] Reconnecting realtime listeners');
      _startRealtimeListeners();
      unawaited(_loadFromSupabase(showLoader: false));
    });
  }

  void _queueRealtimeReload() {
    print('🔔 [MessageController] Realtime update received, scheduling reload');
    _realtimeReloadDebounce?.cancel();
    _realtimeReloadDebounce = Timer(
      const Duration(milliseconds: 250),
      () => unawaited(_loadFromSupabase(showLoader: false)),
    );
  }

  Future<void> _loadFromSupabase({bool showLoader = true}) async {
    if (_chatId == null) return;
    print(
        '🔵 [MessageController] _loadFromSupabase called - showLoader: $showLoader');
    if (_isLoadInProgress) {
      print(
          '⚠️ [MessageController] Load already in progress, queuing follow-up reload');
      _hasPendingLoad = true;
      _pendingLoadWantsLoader = _pendingLoadWantsLoader || showLoader;
      return;
    }

    _isLoadInProgress = true;
    try {
      if (showLoader) {
        isLoading = true;
        print(
            '🔵 [MessageController] Setting isLoading = true, calling update()');
        if (!isClosed) {
          update();
        }
      }

      // 1. Refresh chat row — source of truth for _chatStatus.
      try {
        final chatRow = await MeetupService.getChatById(_chatId!);
        if (chatRow != null) {
          _chatType = (chatRow['chat_type']?.toString().isNotEmpty == true)
              ? chatRow['chat_type'].toString()
              : 'meetup';
          var dbStatus = chatRow['status']?.toString() ?? 'requested';
          if (dbStatus == 'pending') dbStatus = 'requested';
          _chatStatus = dbStatus;
          if (dbStatus == 'continue_chat') {
            _chatStatus = 'completed';
            _continueChatMode = true;
          } else {
            // Reset continue-chat mode if the chat moved to a new state
            // (e.g. a new request was sent after completion).
            if (dbStatus == 'requested' || dbStatus == 'rejected' || dbStatus == 'cancelled') {
              _continueChatMode = false;
            }
          }

          // Build subtitle from the linked meetup row.
          // Try chat.meetup_id first, then fall back to latest request's meetup_id.
          final chatMeetupId = chatRow['meetup_id']?.toString() ?? '';
          print('[AppBarSubtitle] chatRow meetup_id="$chatMeetupId" chat_type="${chatRow['chat_type']}"');
          String builtSubtitle = chat?.subtitle ?? '';
          String builtType = chat?.type ?? '';

          // A thread can hold several agreed meetups; the header shows whichever
          // comes next. Falls back to chat.meetup_id, then to any linked
          // request, for threads with nothing accepted yet.
          String resolvedMeetupId = '';
          try {
            resolvedMeetupId =
                await MeetupService.nextUpcomingAcceptedMeetupId(_chatId!) ?? '';
            print('[AppBarSubtitle] next upcoming accepted meetup: "$resolvedMeetupId"');
          } catch (_) {}

          if (resolvedMeetupId.isEmpty) resolvedMeetupId = chatMeetupId;

          if (resolvedMeetupId.isEmpty && _chatId != null) {
            try {
              resolvedMeetupId =
                  await MeetupService.resolveMeetupIdForChat(_chatId!) ?? '';
              print('[AppBarSubtitle] resolved meetup_id from requests: "$resolvedMeetupId"');
            } catch (_) {}
          }

          if (resolvedMeetupId.isNotEmpty) {
            try {
              final meetupRow = await MeetupService.getMeetupRowForSubtitle(resolvedMeetupId);
              print('[AppBarSubtitle] meetupRow=$meetupRow');
              if (meetupRow != null) {
                builtSubtitle = _buildSubtitleFromMeetup(meetupRow);
                final mt = meetupRow['type']?.toString().trim() ?? '';
                if (mt.isNotEmpty) builtType = mt;
                print('[AppBarSubtitle] builtSubtitle="$builtSubtitle" builtType="$builtType"');
              }
            } catch (e) {
              print('[AppBarSubtitle] ERROR fetching meetup row: $e');
            }
          } else {
            print('[AppBarSubtitle] meetup_id is empty — cannot build subtitle');
          }
          if (builtSubtitle.isNotEmpty) _meetupSubtitle = builtSubtitle;

          // Re-fetch the other user's profile so name/avatar stay current.
          final uid = currentUserId ?? '';
          final uOne = chatRow['user_one']?.toString() ?? '';
          final uTwo = chatRow['user_two']?.toString() ?? '';
          final otherId = uOne == uid ? uTwo : uOne;

          String otherName = chat?.name ?? '';
          String otherAvatar = chat?.avatarUrl ?? '';

          if (otherId.isNotEmpty) {
            try {
              final profileRow = await supabase
                  .from('profiles')
                  .select('name, photo_url')
                  .eq('id', otherId)
                  .maybeSingle();
              if (profileRow != null) {
                final fetchedName = profileRow['name']?.toString().trim() ?? '';
                final fetchedAvatar = profileRow['photo_url']?.toString() ?? '';
                if (fetchedName.isNotEmpty) otherName = fetchedName;
                if (fetchedAvatar.isNotEmpty) otherAvatar = fetchedAvatar;
              }
            } catch (_) {}
          }

          chat = Chat.fromSupabase(
            chatRow,
            otherUserName: otherName,
            otherUserAvatar: otherAvatar,
            lastMessage: chat?.message ?? '',
            subtitle: builtSubtitle,
          );
          // Restore the meetup type (fromSupabase sets type = chat_type = 'meetup').
          if (builtType.isNotEmpty) chat!.type = builtType;
        }
      } catch (e) {
        print('🔴 [MessageController] Error fetching chat: $e');
      }

      // 2. Retire any accepted meetup whose date has passed. Runs before the
      //    requests are read so step 4 sees the retired statuses. It is safe to
      //    call unconditionally — it only writes for accepted-and-past rows,
      //    and it leaves the thread open while any agreed meetup is upcoming.
      try {
        final resolved =
            await MeetupService.resolveLatestRequestStatus(_chatId!);
        if (resolved == 'completed') {
          _chatStatus = 'completed';
          print('🔵 [MessageController] Chat status auto-completed');
        }
      } catch (e) {
        print('🔴 [MessageController] Error resolving status: $e');
      }

      // 3. Block state.
      try {
        await _refreshBlockState();
      } catch (e) {
        print('🔴 [MessageController] Error refreshing block state: $e');
      }

      // 4. Every request in the thread — each card renders from its own row.
      try {
        final reqRows = await MeetupService.fetchRequestsForChat(_chatId!);
        _requestsById
          ..clear()
          ..addEntries(reqRows
              .where((r) => (r['id']?.toString() ?? '').isNotEmpty)
              .map((r) => MapEntry(r['id'].toString(), r)));

        // Only a live 'accepted' request holds the thread open. A thread whose
        // meetups have all completed still falls through to the completed
        // actions bar, as before.
        _hasAcceptedRequest = reqRows.any(
            (r) => (r['status']?.toString().toLowerCase() ?? '') == 'accepted');

        final latest = reqRows.isNotEmpty ? reqRows.last : null;
        _latestRequestId = latest?['id']?.toString();
        _latestRequestSenderId = latest?['requester_id']?.toString();
        _latestRequestReceiverId = latest?['meetup_owner_id']?.toString();

        if (_latestRequestId != null) {
          final reqMsg =
              await MeetupService.getRequestMessageForRequest(_latestRequestId!);
          _latestRequestMessageId = reqMsg?['id']?.toString();
        } else {
          _latestRequestMessageId = null;
          _latestRequestSenderId = null;
          _latestRequestReceiverId = null;
        }
        // The requests are the source of truth for the thread's state, not the
        // chats row. That row can lag behind (a failed write, a trigger firing
        // after us, data from an older build), and trusting it is what let a
        // single declined request close a conversation an earlier accepted one
        // had opened. Continue-chat is a user choice, so it still wins.
        if (!_continueChatMode && reqRows.isNotEmpty) {
          final derived = MeetupService.deriveChatStatus(
              reqRows.map((r) => r['status']?.toString() ?? ''));
          if (derived.isNotEmpty && derived != _chatStatus) {
            print(
                '🔵 [MessageController] Chat status $_chatStatus -> $derived (derived from requests)');
            _chatStatus = derived;
          }
        }

        // Venue detail for the agreed cards, in one query rather than per card.
        _meetupsById
          ..clear()
          ..addAll(await MeetupService.fetchMeetupsByIds(reqRows
              .map((r) => r['meetup_id']?.toString() ?? '')
              .toList(growable: false)));

        print(
            '🔵 [MessageController] ${reqRows.length} request(s) in thread, hasAccepted=$_hasAcceptedRequest');
      } catch (e) {
        print('🔴 [MessageController] Error fetching request metadata: $e');
      }

      // 5. Load all messages.
      try {
        print('🔵 [MessageController] Fetching messages from Supabase');
        final rows = await MeetupService.fetchMessages(_chatId!);
        print('🔵 [MessageController] Fetched ${rows.length} messages');
        print('🔵 [MessageController] Chat status: $_chatStatus, Latest request ID: $_latestRequestId');
        final uid = currentUserId ?? '';
        messages
          ..clear()
          ..addAll(rows.map((r) {
            final isMe = _readString(r, const ['sender_id']) == uid;
            final rawMessageType =
                _readString(r, const ['message_type', 'type']).toLowerCase();
            final messageType =
                rawMessageType.isEmpty ? 'text' : rawMessageType;
            String text = _readString(r, const ['text', 'message', 'content']);
            String? requestStatus = r['request_status']?.toString();
            final msgRequestId = _readString(r, const ['meetup_request_id']);

            bool canRespond = false;
            var meetupType = '';
            var meetupWhen = '';
            var meetupAddress = '';
            double? meetupLat;
            double? meetupLng;

            if (messageType == 'meetup_request') {
              // Every request card stays in the thread — a pair may agree
              // several meetups, and each keeps its own box. Status comes from
              // that request's own row, never from the shared chat status, so
              // declining one card cannot restamp the others.
              final reqRow =
                  msgRequestId.isNotEmpty ? _requestsById[msgRequestId] : null;
              final rowStatus = reqRow?['status']?.toString().toLowerCase();
              if (rowStatus != null && rowStatus.isNotEmpty) {
                requestStatus = rowStatus;
              }
              if (requestStatus == 'pending') requestStatus = 'requested';

              // The requester is always the sender, so the other side is the
              // host who answers it.
              canRespond = !isMe &&
                  requestStatus == 'requested' &&
                  !_isBlockedConversation;

              if (text.trim().toLowerCase() == 'sent you a meetup request') {
                text = isMe
                    ? 'You sent a meetup request'
                    : 'Sent you a meetup request';
              }

              // Venue detail rides along only once the meetup is agreed. Before
              // that the exact address stays hidden, exactly as it is on the
              // meetup detail screen.
              final isAgreed =
                  requestStatus == 'accepted' || requestStatus == 'completed';

              var mId = _readString(r, const ['meetup_id']);
              if (mId.isEmpty) {
                mId = reqRow?['meetup_id']?.toString() ?? '';
              }
              final meetupRow =
                  isAgreed && mId.isNotEmpty ? _meetupsById[mId] : null;

              if (meetupRow != null) {
                meetupType = meetupRow['type']?.toString().trim() ?? '';
                meetupAddress = meetupRow['address']?.toString().trim() ?? '';
                meetupLat = (meetupRow['latitude'] as num?)?.toDouble();
                meetupLng = (meetupRow['longitude'] as num?)?.toDouble();
                meetupWhen = _buildSubtitleFromMeetup(<String, dynamic>{
                  'meetup_date': meetupRow['date'],
                  'meetup_time': meetupRow['time'],
                  // Address is rendered on its own line, so keep it out of the
                  // "Tue · 5–6 PM" line.
                  'address': '',
                });
              }
            }

            if (messageType == 'system' &&
                text.trim() == MeetupService.requestDeclinedMarker) {
              // Stored as a stable marker; phrased per viewer here.
              text = isMe
                  ? 'You declined a meetup request'
                  : 'Sorry, your meetup request was rejected';
            }

            return ChatMessageItem(
              id: _readString(r, const ['id']),
              text: text,
              isMe: isMe,
              messageType: messageType,
              requestStatus: requestStatus,
              meetupRequestId: msgRequestId,
              meetupId: _readString(r, const ['meetup_id']),
              canRespond: canRespond,
              meetupType: meetupType,
              meetupWhen: meetupWhen,
              meetupAddress: meetupAddress,
              meetupLatitude: meetupLat,
              meetupLongitude: meetupLng,
            );
          }).whereType<ChatMessageItem>());
        print(
            '🔵 [MessageController] Messages list built with ${messages.length} items');
      } catch (e) {
        print('🔴 [MessageController] Error fetching messages: $e');
      }

      // Always clear loader and rebuild regardless of showLoader flag.
      isLoading = false;
      canSend = messageController.text.trim().isNotEmpty && messagingAllowed;
      print(
          '🟢 [MessageController] ✅ LOADING COMPLETE - Setting isLoading = false, calling update()');
      print(
          '🟢 [MessageController] 📊 State before update: isLoading=$isLoading, messages=${messages.length}, canSend=$canSend');
      if (!isClosed) {
        update();
      }
      print(
          '🟢 [MessageController] ✅ update() called - UI should show messages now');
      print(
          '🟢 [MessageController] ✅ messagingAllowed: $messagingAllowed, canSend: $canSend');
      if (!isClosed) {
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
      }
    } finally {
      _isLoadInProgress = false;
      if (_hasPendingLoad) {
        final nextShowLoader = _pendingLoadWantsLoader;
        _hasPendingLoad = false;
        _pendingLoadWantsLoader = false;
        unawaited(_loadFromSupabase(showLoader: nextShowLoader));
      }
    }
  }

  void _onTextChanged() {
    final hasText =
        messageController.text.trim().isNotEmpty && messagingAllowed;
    if (hasText != canSend) {
      canSend = hasText;
      print(
          '📝 [MessageController] Text changed - canSend: $canSend, text length: ${messageController.text.length}');
      update();
    }
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    print('💬 [MessageController] sendMessage called - text: "$text"');
    if (text.isEmpty || !messagingAllowed) {
      print(
          '🔴 [MessageController] Cannot send - empty text or messaging not allowed');
      return;
    }

    final uid = currentUserId;
    print(
        '💬 [MessageController] Clearing text field and disabling send button');
    messageController.clear();
    canSend = false;

    // Optimistic UI update
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    messages.add(ChatMessageItem(id: tempId, text: text, isMe: true));
    print(
        '🟢 [MessageController] ✅ Message added to UI optimistically (ID: $tempId), calling update()');
    update();
    print(
        '🟢 [MessageController] ✅ update() called - message should appear in UI now');
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());

    if (_chatId != null && uid != null) {
      try {
        print('💬 [MessageController] Sending message to backend');
        // When _chatStatus is 'completed' but _continueChatMode is true, the DB
        // status is actually 'continue_chat' — pass that to satisfy the backend guard.
        // A thread held open by an earlier accepted request may carry a chat
        // status of 'requested' for a moment while a newer request is pending;
        // messagingAllowed is the authority here.
        final effectiveStatus = (_continueChatMode && _chatStatus == 'completed')
            ? 'continue_chat'
            : _hasAcceptedRequest
                ? 'accepted'
                : (_chatStatus ?? 'requested');
        await MeetupService.sendTextMessage(
          chatId: _chatId!,
          senderId: uid,
          text: text,
          chatStatus: effectiveStatus,
          userOne: chat?.userOne,
          userTwo: chat?.userTwo,
        );
        print('💬 [MessageController] Message sent to backend successfully');
        print('💬 [MessageController] Reloading messages from backend');
        await _loadFromSupabase(showLoader: false);
      } catch (e) {
        print('🔴 [MessageController] Error sending message: $e');
        // Remove the optimistic message and restore the input text so the user
        // knows the send failed (block, status change, network error, etc.)
        messages.removeWhere((m) => m.id == tempId);
        messageController.text = text;
        canSend = text.isNotEmpty;
        update();
        AppSnackbar.error(e.toString().replaceAll('Exception: ', ''));
      }
    }

    if (!focusNode.hasFocus) focusNode.requestFocus();
  }

  Future<void> _refreshBlockState() async {
    final uid = currentUserId;
    final c = chat;

    _isBlockedConversation = false;
    _blockedConversationText = '';

    if (uid == null || c == null) return;

    final otherId = c.userOne == uid ? c.userTwo : c.userOne;
    if (otherId == null || otherId.isEmpty) return;

    try {
      final blocked =
          await MeetupService.areUsersBlocked(userA: uid, userB: otherId);
      _isBlockedConversation = blocked;
      if (blocked) {
        _blockedConversationText =
            'You cannot message this user because one of you has blocked the other.';
      }
    } catch (_) {
      _isBlockedConversation = false;
    }

    canSend = messageController.text.trim().isNotEmpty && messagingAllowed;
  }

  /// Accepts one specific request card. [requestId] defaults to the newest
  /// request so older call sites keep working.
  Future<void> acceptRequest([String? requestId]) async {
    final targetId = requestId ?? _latestRequestId;
    print('🟡 [MessageController] acceptRequest called for $targetId');
    if (_chatId == null || targetId == null) {
      print(
          '🔴 [MessageController] Cannot accept - missing chat ID or request ID');
      return;
    }

    try {
      print('🟡 [MessageController] Calling backend acceptRequest');
      await MeetupService.acceptRequest(
        requestId: targetId,
        chatId: _chatId!,
        requestMessageId: await _messageIdForRequest(targetId),
      );
      print('🟡 [MessageController] Backend accept successful');
      await _loadFromSupabase(showLoader: false);
      if (Get.isRegistered<ChatListController>()) {
        print('🟡 [MessageController] Updating chat list controller');
        Get.find<ChatListController>().loadChats(showLoader: false);
      }
    } catch (e) {
      print('🔴 [MessageController] Error in acceptRequest: $e');
    }
  }

  /// Declines one specific request card, leaving every other request — and the
  /// conversation itself — untouched.
  Future<void> rejectRequest([String? requestId]) async {
    final targetId = requestId ?? _latestRequestId;
    print('🟠 [MessageController] rejectRequest called for $targetId');
    if (_chatId == null || targetId == null) {
      print(
          '🔴 [MessageController] Cannot reject - missing chat ID or request ID');
      return;
    }

    try {
      print('🟠 [MessageController] Calling backend rejectRequest');
      await MeetupService.rejectRequest(
        requestId: targetId,
        chatId: _chatId!,
        requestMessageId: await _messageIdForRequest(targetId),
      );
      print('🟠 [MessageController] Backend reject successful');
      await _loadFromSupabase(showLoader: false);
      if (Get.isRegistered<ChatListController>()) {
        print('🟠 [MessageController] Updating chat list controller');
        Get.find<ChatListController>().loadChats(showLoader: false);
      }
    } catch (e) {
      print('🔴 [MessageController] Error in rejectRequest: $e');
    }
  }

  /// The id of the meetup_request message for [requestId], preferring the
  /// already-loaded thread so no extra round trip is needed.
  Future<String> _messageIdForRequest(String requestId) async {
    for (final m in messages) {
      if (m.messageType == 'meetup_request' && m.meetupRequestId == requestId) {
        return m.id;
      }
    }
    if (requestId == _latestRequestId && _latestRequestMessageId != null) {
      return _latestRequestMessageId!;
    }
    try {
      final row = await MeetupService.getRequestMessageForRequest(requestId);
      return row?['id']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  void clearConversation() {
    messages.clear();
    update();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  Future<void> reloadMessages() => _loadFromSupabase(showLoader: false);

  /// Sends a new meetup request for [meetupId] reusing the existing chat.
  Future<void> sendNewMeetupRequest(String meetupId) async {
    final uid = currentUserId;
    final c = chat;
    if (uid == null || c == null || _chatId == null) return;

    final otherUserId = c.userOne == uid ? c.userTwo : c.userOne;
    if (otherUserId == null || otherUserId.isEmpty) return;

    try {
      await MeetupService.sendMeetupRequest(
        meetupId: meetupId,
        meetupOwnerId: otherUserId,
        requesterId: uid,
      );
      await _loadFromSupabase(showLoader: false);
      if (Get.isRegistered<ChatListController>()) {
        Get.find<ChatListController>().loadChats(showLoader: false);
      }
    } catch (e) {
      print('🔴 [MessageController] sendNewMeetupRequest error: $e');
      rethrow;
    }
  }

  String _buildSubtitleFromMeetup(Map<String, dynamic> meetup) {
    final dateRaw = meetup['meetup_date']?.toString().trim() ?? '';
    final timeRaw = meetup['meetup_time']?.toString().trim() ?? '';
    final address = meetup['address']?.toString().trim() ?? '';
    print('[AppBarSubtitle] _buildSubtitleFromMeetup: date="$dateRaw" time="$timeRaw" address="$address"');

    final parts = <String>[];

    DateTime? dt;
    if (dateRaw.isNotEmpty && timeRaw.isNotEmpty) {
      dt = DateTime.tryParse('${dateRaw}T$timeRaw');
    }
    dt ??= dateRaw.isNotEmpty ? DateTime.tryParse(dateRaw) : null;

    if (dt != null) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      parts.add(weekdays[dt.weekday - 1]);
      final end = dt.add(const Duration(hours: 1));
      final sh = dt.hour == 0 || dt.hour == 12 ? 12 : dt.hour % 12;
      final eh = end.hour == 0 || end.hour == 12 ? 12 : end.hour % 12;
      final sp = dt.hour >= 12 ? 'PM' : 'AM';
      final ep = end.hour >= 12 ? 'PM' : 'AM';
      parts.add(sp == ep ? '$sh–$eh $ep' : '$sh $sp–$eh $ep');
    }

    if (address.isNotEmpty) {
      final addrParts = address.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      final approx = addrParts.length >= 2
          ? '${addrParts[addrParts.length - 2]}, ${addrParts.last}'
          : addrParts.isNotEmpty ? addrParts.first : address;
      parts.add('Near $approx');
    }

    final result = parts.where((p) => p.isNotEmpty).join(' · ');
    print('[AppBarSubtitle] _buildSubtitleFromMeetup result="$result"');
    return result;
  }

  String _readString(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;
    try {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } catch (_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatSubscription?.cancel();
    _messageSubscription?.cancel();
    _realtimeReloadDebounce?.cancel();
    _realtimeReconnectTimer?.cancel();
    messageController.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
