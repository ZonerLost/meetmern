import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/main.dart';
import 'package:meetmern/view/controllers/chat_controller/chat_screen_controller.dart';

class ChatMessageItem {
  final String id;
  final String text;
  final bool isMe;
  final String messageType;
  final String? requestStatus;
  final String? meetupRequestId;
  final String? meetupId;

  const ChatMessageItem({
    required this.id,
    required this.text,
    required this.isMe,
    this.messageType = 'text',
    this.requestStatus,
    this.meetupRequestId,
    this.meetupId,
  });
}

class MessageController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final List<ChatMessageItem> messages = <ChatMessageItem>[];

  Chat? chat;
  bool canSend = false;
  bool isLoading = false;
  bool _isBlockedConversation = false;
  String _blockedConversationText = '';

  // Supabase-backed state
  String? _chatId;
  String?
      _chatStatus; // 'requested' | 'accepted' | 'rejected' | 'completed' | 'cancelled' | 'closed'
  String? _chatType; // 'meetup' | 'direct'
  // Latest request metadata (refreshed on every load)
  String? _latestRequestId;
  String? _latestRequestMessageId;
  String? _latestRequestSenderId; // meetup_requests.requester_id
  String? _latestRequestReceiverId; // meetup_requests.meetup_owner_id
  StreamSubscription<List<Map<String, dynamic>>>? _chatSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;
  bool _isLoadInProgress = false;
  bool _hasPendingLoad = false;
  bool _pendingLoadWantsLoader = false;
  Timer? _realtimeReloadDebounce;

  String? get currentUserId => AuthService.currentUser?.id;

  /// Exposes the latest request ID so the UI can match per-message buttons.
  String? get latestRequestId => _latestRequestId;

  /// The effective chat status (normalised, never null).
  String get effectiveChatStatus => _chatStatus ?? 'requested';

  /// True when the current user is the meetup owner (user_one) for this chat.
  bool get isOwner {
    final uid = currentUserId;
    if (uid == null || chat == null) return false;
    return chat!.userOne == uid;
  }

  /// True when current user sent the latest meetup request.
  bool get isLatestRequestSender {
    final uid = currentUserId;
    if (uid == null) return false;
    if (_latestRequestSenderId != null && _latestRequestSenderId!.isNotEmpty) {
      return _latestRequestSenderId == uid;
    }
    // Fallback for old rows where requester_id may be missing in payload.
    return chat?.userTwo == uid;
  }

  /// True when current user received the latest meetup request (host side).
  bool get isLatestRequestReceiver {
    final uid = currentUserId;
    if (uid == null) return false;
    if (_latestRequestReceiverId != null &&
        _latestRequestReceiverId!.isNotEmpty) {
      return _latestRequestReceiverId == uid;
    }
    // Fallback for old rows where meetup_owner_id may be missing in payload.
    return chat?.userOne == uid;
  }

  /// True when the owner can respond to the LATEST pending request.
  bool get canRespondToLatestRequest {
    if (_chatType != 'meetup') return false;
    if (_latestRequestId == null) return false;
    if (!isLatestRequestReceiver) return false;
    // Allow responding when chat is in requested/pending state.
    return _chatStatus == 'requested' || _chatStatus == 'pending';
  }

  /// True when normal messaging is allowed.
  bool get messagingAllowed {
    if (_isBlockedConversation) return false;
    if (_chatType == 'meetup') {
      // Allow chatting when accepted, or when cancelled/rejected
      // (meetup is gone but the conversation stays open).
      return _chatStatus == 'accepted' ||
          _chatStatus == 'cancelled' ||
          _chatStatus == 'rejected';
    }
    return true;
  }

  bool get isBlockedConversation => _isBlockedConversation;
  String get blockedConversationText => _blockedConversationText.isNotEmpty
      ? _blockedConversationText
      : 'You cannot message this user because one of you has blocked the other.';

  String get statusText {
    switch (_chatStatus) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'requested':
        return 'Request Pending';
      case 'completed':
        return 'Meetup Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'closed':
        return 'Closed';
      default:
        switch (chat?.status) {
          case RequestStatus.accepted:
            return 'Accepted';
          case RequestStatus.rejected:
            return 'Rejected';
          case RequestStatus.requested:
            return 'Request Pending';
          case RequestStatus.completed:
            return 'Meetup Completed';
          case RequestStatus.cancelled:
            return 'Cancelled';
          default:
            return '';
        }
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
    _latestRequestId = null;
    _latestRequestMessageId = null;
    _latestRequestSenderId = null;
    _latestRequestReceiverId = null;
    _isBlockedConversation = false;
    _blockedConversationText = '';
    _isLoadInProgress = false;
    _hasPendingLoad = false;
    _pendingLoadWantsLoader = false;
    _realtimeReloadDebounce?.cancel();
    _realtimeReloadDebounce = null;
    isLoading = true;

    chat = initialChat;
    _chatId = initialChat.id;
    _chatStatus = initialChat.dbStatus;
    if (_chatStatus == 'pending') _chatStatus = 'requested';
    _chatType = initialChat.chatType;

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

    _chatSubscription?.cancel();
    _messageSubscription?.cancel();

    print(
        '🔵 [MessageController] Setting up realtime listeners for chat: $_chatId');

    // Supabase .stream() always emits once immediately on subscribe — skip it.
    bool chatFirstEmit = true;
    bool messageFirstEmit = true;

    _chatSubscription = supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('id', _chatId!)
        .listen((data) {
          if (chatFirstEmit) {
            chatFirstEmit = false;
            return;
          }
          _queueRealtimeReload();
        });

    _messageSubscription = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', _chatId!)
        .listen((data) {
          if (messageFirstEmit) {
            messageFirstEmit = false;
            return;
          }
          _queueRealtimeReload();
        });

    print('🔵 [MessageController] Realtime listeners active');
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
        print('🔵 [MessageController] Fetching chat by ID from Supabase');
        final chatRow = await MeetupService.getChatById(_chatId!);
        if (chatRow != null) {
          _chatType = chatRow['chat_type']?.toString();
          var dbStatus = chatRow['status']?.toString() ?? 'requested';
          if (dbStatus == 'pending') dbStatus = 'requested';
          _chatStatus = dbStatus;
          chat = Chat.fromSupabase(
            chatRow,
            otherUserName: chat?.name ?? '',
            otherUserAvatar: chat?.avatarUrl ?? '',
            lastMessage: chat?.message ?? '',
          );
          print(
              '🔵 [MessageController] Chat loaded - Status: $_chatStatus, Type: $_chatType');
        }
      } catch (e) {
        print('🔴 [MessageController] Error fetching chat: $e');
      }

      // 2. Auto-complete if meetup date passed.
      if (_chatStatus == 'accepted') {
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
      }

      // 3. Block state.
      try {
        await _refreshBlockState();
      } catch (e) {
        print('🔴 [MessageController] Error refreshing block state: $e');
      }

      // 4. Latest request metadata.
      try {
        final reqRow = await MeetupService.getLatestRequestForChat(_chatId!);
        _latestRequestId = reqRow?['id']?.toString();
        _latestRequestSenderId = reqRow?['requester_id']?.toString();
        _latestRequestReceiverId = reqRow?['meetup_owner_id']?.toString();
        if (_latestRequestId != null) {
          final reqMsg = await MeetupService.getRequestMessageForRequest(
            _latestRequestId!,
          );
          _latestRequestMessageId = reqMsg?['id']?.toString();
          print(
              '🔵 [MessageController] Latest request ID: $_latestRequestId, sender: $_latestRequestSenderId, receiver: $_latestRequestReceiverId');
        } else {
          _latestRequestMessageId = null;
          _latestRequestSenderId = null;
          _latestRequestReceiverId = null;
        }
      } catch (e) {
        print('🔴 [MessageController] Error fetching request metadata: $e');
      }

      // 5. Load all messages.
      try {
        print('🔵 [MessageController] Fetching messages from Supabase');
        final rows = await MeetupService.fetchMessages(_chatId!);
        print('🔵 [MessageController] Fetched ${rows.length} messages');
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

            if (messageType == 'meetup_request') {
              if (requestStatus == 'pending') requestStatus = 'requested';
              if (msgRequestId == _latestRequestId &&
                  requestStatus == 'accepted' &&
                  _chatStatus == 'completed') {
                requestStatus = 'completed';
              }
              if (text.trim().toLowerCase() == 'sent you a meetup request') {
                text = isMe
                    ? 'You sent a meetup request'
                    : 'Sent you a meetup request';
              }
            }

            return ChatMessageItem(
              id: _readString(r, const ['id']),
              text: text,
              isMe: isMe,
              messageType: messageType,
              requestStatus: requestStatus,
              meetupRequestId: msgRequestId,
              meetupId: _readString(r, const ['meetup_id']),
            );
          }));
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
        await MeetupService.sendTextMessage(
          chatId: _chatId!,
          senderId: uid,
          text: text,
          chatStatus: _chatStatus ?? 'requested',
        );
        print('💬 [MessageController] Message sent to backend successfully');
        print('💬 [MessageController] Reloading messages from backend');
        await _loadFromSupabase(showLoader: false);
      } catch (e) {
        print('🔴 [MessageController] Error sending message: $e');
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

  Future<void> acceptRequest() async {
    print('🟡 [MessageController] acceptRequest called');
    if (_chatId == null || _latestRequestId == null) {
      print(
          '🔴 [MessageController] Cannot accept - missing chat ID or request ID');
      return;
    }

    _chatStatus = 'accepted';
    print(
        '🟡 [MessageController] Status changed to accepted, calling update()');
    update();
    print(
        '🟡 [MessageController] update() called - UI should show accepted status now');

    try {
      print('🟡 [MessageController] Calling backend acceptRequest');
      await MeetupService.acceptRequest(
        requestId: _latestRequestId!,
        chatId: _chatId!,
        requestMessageId: _latestRequestMessageId ?? '',
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

  Future<void> rejectRequest() async {
    print('🟠 [MessageController] rejectRequest called');
    if (_chatId == null || _latestRequestId == null) {
      print(
          '🔴 [MessageController] Cannot reject - missing chat ID or request ID');
      return;
    }

    _chatStatus = 'rejected';
    print(
        '🟠 [MessageController] Status changed to rejected, calling update()');
    update();
    print(
        '🟠 [MessageController] update() called - UI should show rejected status now');

    try {
      print('🟠 [MessageController] Calling backend rejectRequest');
      await MeetupService.rejectRequest(
        requestId: _latestRequestId!,
        chatId: _chatId!,
        requestMessageId: _latestRequestMessageId ?? '',
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

  void clearConversation() {
    messages.clear();
    update();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  Future<void> reloadMessages() => _loadFromSupabase(showLoader: false);

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
    _chatSubscription?.cancel();
    _messageSubscription?.cancel();
    _realtimeReloadDebounce?.cancel();
    messageController.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
