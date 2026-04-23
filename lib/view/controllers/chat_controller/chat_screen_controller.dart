import 'dart:async';

import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/data/service/api_s.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/main.dart';

class ChatListController extends GetxController {
  final Strings _strings = const Strings();

  List<Chat> items = <Chat>[];
  bool isLoading = true;
  String? error;

  StreamSubscription<List<Map<String, dynamic>>>? _chatSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;
  bool _isLoadInProgress = false;
  bool _hasPendingLoad = false;
  bool _pendingLoadWantsLoader = false;
  Timer? _realtimeReloadDebounce;

  List<Chat> get pendingRequestItems => items
      .where((c) => c.status == RequestStatus.requested)
      .toList(growable: false);

  List<Chat> get regularItems => items
      .where((c) => c.status != RequestStatus.requested)
      .toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  @override
  void onClose() {
    _chatSubscription?.cancel();
    _messageSubscription?.cancel();
    _realtimeReloadDebounce?.cancel();
    super.onClose();
  }

  void _startRealtimeListeners() {
    final uid = AuthService.currentUser?.id;
    if (uid == null) return;

    _chatSubscription?.cancel();
    _messageSubscription?.cancel();

    print(
        '🔵 [ChatListController] Setting up realtime listeners for user: $uid');
    bool chatFirstEmit = true;
    bool messageFirstEmit = true;

    // Listen to chat changes - but we can't filter by user in stream, so we reload on any change
    _chatSubscription =
        supabase.from('chats').stream(primaryKey: ['id']).listen((data) {
      if (chatFirstEmit) {
        chatFirstEmit = false;
        return;
      }
      print('🔔 [ChatListController] Chat realtime update received');
      _queueRealtimeReload();
    });

    _messageSubscription =
        supabase.from('messages').stream(primaryKey: ['id']).listen((data) {
      if (messageFirstEmit) {
        messageFirstEmit = false;
        return;
      }
      print('🔔 [ChatListController] Message realtime update received');
      _queueRealtimeReload();
    });

    print('🔵 [ChatListController] Realtime listeners active');
  }

  void _queueRealtimeReload() {
    _realtimeReloadDebounce?.cancel();
    _realtimeReloadDebounce = Timer(
      const Duration(milliseconds: 250),
      () => unawaited(loadChats(showLoader: false)),
    );
  }

  Future<void> loadChats({bool showLoader = true}) async {
    print('🔵 [ChatListController] loadChats called - showLoader: $showLoader');
    if (_isLoadInProgress) {
      print('⚠️ [ChatListController] loadChats already in progress, queueing');
      _hasPendingLoad = true;
      _pendingLoadWantsLoader = _pendingLoadWantsLoader || showLoader;
      return;
    }

    _isLoadInProgress = true;
    try {
      if (showLoader) {
        isLoading = true;
        error = null;
        print(
            '🔵 [ChatListController] Setting isLoading = true, calling update()');
        if (!isClosed) {
          update();
        }
      } else {
        error = null;
      }

      final uid = AuthService.currentUser?.id;
      print('🔵 [ChatListController] Current user ID: $uid');
      if (uid != null &&
          (_chatSubscription == null || _messageSubscription == null)) {
        print('🔵 [ChatListController] Starting realtime listeners');
        _startRealtimeListeners();
      }

      if (uid == null) {
        print('🔵 [ChatListController] No user ID, loading mock data');
        try {
          items = await MockApi.fetchChats();
          print(
              '🔵 [ChatListController] Mock data loaded: ${items.length} items');
        } catch (_) {
          error = _strings.failedToLoadChats;
          print('🔴 [ChatListController] Error loading mock data');
        }
        isLoading = false;
        print(
            '🔵 [ChatListController] Setting isLoading = false, calling update()');
        if (!isClosed) {
          update();
        }
        return;
      }

      try {
        print('🔵 [ChatListController] Fetching chats from Supabase');
        final rows = await MeetupService.fetchChatsForUser(uid);
        print('🔵 [ChatListController] Fetched ${rows.length} chat rows');
        if (rows.isEmpty) {
          items = <Chat>[];
          isLoading = false;
          print(
              '🔵 [ChatListController] No chats found, setting isLoading = false, calling update()');
          if (!isClosed) {
            update();
          }
          return;
        }

        final chatIds = rows
            .map((r) => r['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList(growable: false);

        final otherUserIds = rows
            .map((r) {
              final userOne = r['user_one']?.toString() ?? '';
              final userTwo = r['user_two']?.toString() ?? '';
              return userOne == uid ? userTwo : userOne;
            })
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList(growable: false);

        final meetupIds = rows
            .map((r) => r['meetup_id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList(growable: false);

        print(
            '🔵 [ChatListController] Fetching profiles, messages, and meetups');
        final profileRows = await _fetchProfiles(otherUserIds);
        final messageRows = await _fetchLatestMessages(chatIds);
        final meetupRows = await _fetchMeetupRows(meetupIds);
        print(
            '🔵 [ChatListController] Fetched ${profileRows.length} profiles, ${messageRows.length} messages, ${meetupRows.length} meetups');

        final profileById = <String, Map<String, dynamic>>{};
        for (final raw in profileRows) {
          final row = Map<String, dynamic>.from(raw);
          final id = row['id']?.toString() ?? '';
          if (id.isNotEmpty) {
            profileById[id] = row;
          }
        }

        final latestMessageByChatId = <String, Map<String, dynamic>>{};
        for (final raw in messageRows) {
          final row = Map<String, dynamic>.from(raw);
          final chatId = row['chat_id']?.toString() ?? '';
          if (chatId.isEmpty || latestMessageByChatId.containsKey(chatId)) {
            continue;
          }
          latestMessageByChatId[chatId] = row;
        }

        final meetupById = <String, Map<String, dynamic>>{};
        for (final raw in meetupRows) {
          final row = Map<String, dynamic>.from(raw);
          final id = row['id']?.toString() ?? '';
          if (id.isNotEmpty) {
            meetupById[id] = row;
          }
        }

        print('🔵 [ChatListController] Building chat list');
        final loaded = <Chat>[];
        for (final row in rows) {
          final userOne = row['user_one']?.toString() ?? '';
          final userTwo = row['user_two']?.toString() ?? '';
          final otherUserId = userOne == uid ? userTwo : userOne;
          final profile = profileById[otherUserId];
          final rawName = profile?['name']?.toString().trim() ?? '';
          final otherName = rawName.isNotEmpty ? rawName : 'User';
          final otherAvatar = profile?['photo_url']?.toString() ?? '';

          final chatId = row['id']?.toString() ?? '';
          final latest = latestMessageByChatId[chatId];
          final latestMessageType = latest?['message_type']?.toString() ?? '';
          final latestSenderId = latest?['sender_id']?.toString() ?? '';
          final lastMessage = latest == null
              ? ''
              : latestMessageType == 'meetup_request'
                  ? (latestSenderId == uid
                      ? 'You sent a meetup request'
                      : 'Sent you a meetup request')
                  : (latest['text']?.toString() ?? '');

          final chat = Chat.fromSupabase(
            row,
            otherUserName: otherName,
            otherUserAvatar: otherAvatar,
            lastMessage: lastMessage,
          );

          // Normalise 'pending' status to 'requested' for display.
          if (chat.dbStatus == 'pending') {
            chat.status = RequestStatus.requested;
          }

          final meetupId = row['meetup_id']?.toString() ?? '';
          final meetup = meetupById[meetupId];
          if (meetup != null) {
            final meetupType = meetup['type']?.toString().trim() ?? '';
            if (meetupType.isNotEmpty) {
              chat.type = meetupType;
            }

            final scheduleText = _formatMeetupSchedule(meetup);
            if (scheduleText.isNotEmpty) {
              chat.time = scheduleText;
            }

            final subtitleText = _buildChatSubtitle(meetup);
            if (subtitleText.isNotEmpty) {
              chat.subtitle = subtitleText;
            }
          }

          if (chat.message.isEmpty && chat.status == RequestStatus.requested) {
            chat.message = row['user_two']?.toString() == uid
                ? 'You sent a meetup request'
                : 'Sent you a meetup request';
          }

          loaded.add(chat);
        }

        items = loaded;
        print(
            '🔵 [ChatListController] Chat list built with ${items.length} items');
      } catch (e) {
        error = _strings.failedToLoadChats;
        items = <Chat>[];
        print('🔴 [ChatListController] Error loading chats: $e');
      }

      isLoading = false;
      print(
          '🟢 [ChatListController] ✅ LOADING COMPLETE - Setting isLoading = false, calling update()');
      if (!isClosed) {
        update();
      }
      print(
          '🟢 [ChatListController] ✅ update() called - UI should rebuild now');
    } finally {
      _isLoadInProgress = false;
      if (_hasPendingLoad) {
        final nextShowLoader = _pendingLoadWantsLoader;
        _hasPendingLoad = false;
        _pendingLoadWantsLoader = false;
        unawaited(loadChats(showLoader: nextShowLoader));
      }
    }
  }

  Future<List<dynamic>> _fetchProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return const <dynamic>[];
    try {
      return await supabase
          .from('profiles')
          .select('id, name, photo_url')
          .inFilter('id', userIds);
    } catch (_) {
      return const <dynamic>[];
    }
  }

  Future<List<dynamic>> _fetchLatestMessages(List<String> chatIds) async {
    if (chatIds.isEmpty) return const <dynamic>[];
    try {
      return await supabase
          .from('messages')
          .select('chat_id, sender_id, text, message_type, created_at')
          .inFilter('chat_id', chatIds)
          .order('created_at', ascending: false);
    } catch (_) {
      return const <dynamic>[];
    }
  }

  Future<List<dynamic>> _fetchMeetupRows(List<String> meetupIds) async {
    if (meetupIds.isEmpty) return const <dynamic>[];

    try {
      return await supabase
          .from('meetups')
          .select('id, type, address, date, time, meetup_date, meetup_time')
          .inFilter('id', meetupIds);
    } catch (_) {
      try {
        return await supabase
            .from('meetups')
            .select('id, type, address, meetup_date, meetup_time')
            .inFilter('id', meetupIds);
      } catch (_) {
        return const <dynamic>[];
      }
    }
  }

  String _formatMeetupSchedule(Map<String, dynamic> meetup) {
    final date =
        meetup['date']?.toString() ?? meetup['meetup_date']?.toString();
    final time =
        meetup['time']?.toString() ?? meetup['meetup_time']?.toString();
    final cleanDate = date?.trim() ?? '';
    final cleanTime = time?.trim() ?? '';

    if (cleanDate.isEmpty && cleanTime.isEmpty) return '';
    if (cleanDate.isEmpty) return cleanTime;
    if (cleanTime.isEmpty) return cleanDate;
    return '$cleanDate ${_strings.dotSeparator} $cleanTime';
  }

  String _buildChatSubtitle(Map<String, dynamic> meetup) {
    final dt = _parseMeetupDateTime(meetup);
    final address = meetup['address']?.toString().trim() ?? '';

    final parts = <String>[];
    if (dt != null) {
      parts.add(_weekdayShort(dt));
      parts.add(_hourRangeLabel(dt));
    } else {
      final scheduleRaw = _formatMeetupSchedule(meetup);
      if (scheduleRaw.isNotEmpty) {
        parts.add(scheduleRaw);
      }
    }
    if (address.isNotEmpty) {
      final normalized =
          address.toLowerCase().startsWith('near ') ? address : 'Near $address';
      parts.add(normalized);
    }

    return parts
        .where((p) => p.trim().isNotEmpty)
        .join(' ${_strings.dotSeparator} ');
  }

  DateTime? _parseMeetupDateTime(Map<String, dynamic> meetup) {
    final dateRaw = meetup['date']?.toString().trim() ??
        meetup['meetup_date']?.toString().trim() ??
        '';
    final timeRaw = meetup['time']?.toString().trim() ??
        meetup['meetup_time']?.toString().trim() ??
        '';

    if (dateRaw.isEmpty && timeRaw.isEmpty) return null;

    if (dateRaw.isNotEmpty && timeRaw.isNotEmpty) {
      final parsed = DateTime.tryParse('${dateRaw}T$timeRaw');
      if (parsed != null) return parsed;
    }

    if (dateRaw.isNotEmpty) {
      final parsed = DateTime.tryParse(dateRaw);
      if (parsed != null) return parsed;
    }

    return null;
  }

  String _weekdayShort(DateTime dt) {
    const names = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[dt.weekday - 1];
  }

  String _hourRangeLabel(DateTime start) {
    final end = start.add(const Duration(hours: 1));
    final startHour12 = _hour12(start.hour);
    final endHour12 = _hour12(end.hour);
    final startPeriod = start.hour >= 12 ? 'PM' : 'AM';
    final endPeriod = end.hour >= 12 ? 'PM' : 'AM';

    if (startPeriod == endPeriod) {
      return '$startHour12-$endHour12 $endPeriod';
    }
    return '$startHour12 $startPeriod-$endHour12 $endPeriod';
  }

  int _hour12(int hour24) {
    if (hour24 == 0 || hour24 == 12) return 12;
    return hour24 % 12;
  }

  Future<void> acceptRequest(Chat item) async {
    print('🟡 [ChatListController] acceptRequest called for chat: ${item.id}');
    item.status = RequestStatus.accepted;
    print(
        '🟡 [ChatListController] Status changed to accepted, calling update()');
    update();
    print(
        '🟡 [ChatListController] update() called - UI should show accepted status now');

    if (item.id == null) {
      print('🟡 [ChatListController] No chat ID, returning');
      return;
    }

    try {
      print('🟡 [ChatListController] Fetching request from backend');
      final requestRow = await MeetupService.getLatestRequestForChat(item.id!);
      if (requestRow != null) {
        final reqId = requestRow['id'] as String;
        final reqMsg = await MeetupService.getRequestMessageForRequest(reqId);
        print('🟡 [ChatListController] Calling backend acceptRequest');
        await MeetupService.acceptRequest(
          requestId: reqId,
          chatId: item.id!,
          requestMessageId: reqMsg?['id'] as String? ?? '',
        );
        print('🟡 [ChatListController] Backend accept successful');
      }
      print('🟡 [ChatListController] Reloading chats from backend');
      await loadChats(showLoader: false);
      print('🟡 [ChatListController] Chats reloaded');
    } catch (e) {
      print('🔴 [ChatListController] Error in acceptRequest: $e');
    }
  }

  Future<void> rejectRequest(Chat item) async {
    print('🟠 [ChatListController] rejectRequest called for chat: ${item.id}');
    item.status = RequestStatus.rejected;
    print(
        '🟠 [ChatListController] Status changed to rejected, calling update()');
    update();
    print(
        '🟠 [ChatListController] update() called - UI should show rejected status now');

    if (item.id == null) {
      print('🟠 [ChatListController] No chat ID, returning');
      return;
    }

    try {
      print('🟠 [ChatListController] Fetching request from backend');
      final requestRow = await MeetupService.getLatestRequestForChat(item.id!);
      if (requestRow != null) {
        final reqId = requestRow['id'] as String;
        final reqMsg = await MeetupService.getRequestMessageForRequest(reqId);
        print('🟠 [ChatListController] Calling backend rejectRequest');
        await MeetupService.rejectRequest(
          requestId: reqId,
          chatId: item.id!,
          requestMessageId: reqMsg?['id'] as String? ?? '',
        );
        print('🟠 [ChatListController] Backend reject successful');
      }
      print('🟠 [ChatListController] Reloading chats from backend');
      await loadChats(showLoader: false);
      print('🟠 [ChatListController] Chats reloaded');
    } catch (e) {
      print('🔴 [ChatListController] Error in rejectRequest: $e');
    }
  }

  void removeConversation(Chat item) {
    items.remove(item);
    update();
  }
}
