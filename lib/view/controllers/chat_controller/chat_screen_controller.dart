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

  List<Chat> get pendingRequestItems => items
      .where((c) => c.status == RequestStatus.requested)
      .toList(growable: false);

  List<Chat> get regularItems => items
      .where((c) => c.status != RequestStatus.requested)
      .toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    _startRealtimeListeners();
    loadChats();
  }

  @override
  void onClose() {
    _chatSubscription?.cancel();
    _messageSubscription?.cancel();
    super.onClose();
  }

  void _startRealtimeListeners() {
    final uid = AuthService.currentUser?.id;
    if (uid == null) return;

    _chatSubscription?.cancel();
    _messageSubscription?.cancel();

    _chatSubscription = supabase.from('chats').stream(
        primaryKey: const ['id']).listen((_) => loadChats(showLoader: false));

    _messageSubscription = supabase.from('messages').stream(
        primaryKey: const ['id']).listen((_) => loadChats(showLoader: false));
  }

  Future<void> loadChats({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      error = null;
      update();
    } else {
      error = null;
    }

    final uid = AuthService.currentUser?.id;
    if (uid != null &&
        (_chatSubscription == null || _messageSubscription == null)) {
      _startRealtimeListeners();
    }

    if (uid == null) {
      try {
        items = await MockApi.fetchChats();
      } catch (_) {
        error = _strings.failedToLoadChats;
      }
      isLoading = false;
      update();
      return;
    }

    try {
      final rows = await MeetupService.fetchChatsForUser(uid);
      if (rows.isEmpty) {
        items = <Chat>[];
        isLoading = false;
        update();
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

      final profileRows = await _fetchProfiles(otherUserIds);
      final messageRows = await _fetchLatestMessages(chatIds);
      final meetupRows = await _fetchMeetupRows(meetupIds);

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
    } catch (_) {
      error = _strings.failedToLoadChats;
      items = <Chat>[];
    }

    isLoading = false;
    update();
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
    if (item.id == null) {
      item.status = RequestStatus.accepted;
      update();
      return;
    }
    try {
      final requestRow = await MeetupService.getRequestForChat(item.id!);
      final requestMsgRow = await MeetupService.getRequestMessage(item.id!);
      if (requestRow != null && requestMsgRow != null) {
        await MeetupService.acceptRequest(
          requestId: requestRow['id'] as String,
          chatId: item.id!,
          requestMessageId: requestMsgRow['id'] as String,
        );
      }
      item.status = RequestStatus.accepted;
      await loadChats(showLoader: false);
    } catch (_) {
      item.status = RequestStatus.accepted;
      update();
    }
  }

  Future<void> rejectRequest(Chat item) async {
    if (item.id == null) {
      item.status = RequestStatus.rejected;
      update();
      return;
    }
    try {
      final requestRow = await MeetupService.getRequestForChat(item.id!);
      final requestMsgRow = await MeetupService.getRequestMessage(item.id!);
      if (requestRow != null && requestMsgRow != null) {
        await MeetupService.rejectRequest(
          requestId: requestRow['id'] as String,
          chatId: item.id!,
          requestMessageId: requestMsgRow['id'] as String,
        );
      }
      item.status = RequestStatus.rejected;
      await loadChats(showLoader: false);
    } catch (_) {
      item.status = RequestStatus.rejected;
      update();
    }
  }

  void removeConversation(Chat item) {
    items.remove(item);
    update();
  }
}
