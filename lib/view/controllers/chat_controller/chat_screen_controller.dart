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

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  Future<void> loadChats() async {
    isLoading = true;
    error = null;
    update();

    final uid = AuthService.currentUser?.id;

    if (uid == null) {
      // Not logged in – fall back to mock data
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
      final List<Chat> loaded = [];

      for (final row in rows) {
        final userOne = row['user_one'] as String? ?? '';
        final userTwo = row['user_two'] as String? ?? '';
        final otherUserId = userOne == uid ? userTwo : userOne;

        // Resolve other user's display name from profiles
        String otherName = 'User';
        String otherAvatar = '';
        try {
          final profile = await supabase
              .from('profiles')
              .select('name, photo_url')
              .eq('id', otherUserId)
              .maybeSingle();
          if (profile != null) {
            otherName = profile['name']?.toString() ?? 'User';
            otherAvatar = profile['photo_url']?.toString() ?? '';
          }
        } catch (_) {}

        // Get last text message for preview
        String lastMessage = '';
        try {
          final msgs = await supabase
              .from('messages')
              .select('text, message_type')
              .eq('chat_id', row['id'] as String)
              .order('created_at', ascending: false)
              .limit(1);
          if (msgs.isNotEmpty) {
            final m = msgs.first;
            lastMessage = m['message_type'] == 'meetup_request'
                ? 'Meetup request'
                : (m['text']?.toString() ?? '');
          }
        } catch (_) {}

        loaded.add(Chat.fromSupabase(
          row,
          otherUserName: otherName,
          otherUserAvatar: otherAvatar,
          lastMessage: lastMessage,
        ));
      }

      items = loaded;
    } catch (_) {
      // Fallback to mock on error
      try {
        items = await MockApi.fetchChats();
      } catch (__) {
        error = _strings.failedToLoadChats;
      }
    }

    isLoading = false;
    update();
  }

  /// Accept a meetup request – persists to Supabase then updates local state.
  Future<void> acceptRequest(Chat item) async {
    if (item.id == null) {
      // Mock chat – local only
      item.status = RequestStatus.accepted;
      update();
      return;
    }
    try {
      final requestRow =
          await MeetupService.getRequestForChat(item.id!);
      final requestMsgRow =
          await MeetupService.getRequestMessage(item.id!);
      if (requestRow != null && requestMsgRow != null) {
        await MeetupService.acceptRequest(
          requestId: requestRow['id'] as String,
          chatId: item.id!,
          requestMessageId: requestMsgRow['id'] as String,
        );
      }
      item.status = RequestStatus.accepted;
      // Update dbStatus so canSendMessages returns true
      final idx = items.indexOf(item);
      if (idx != -1) {
        items[idx] = Chat.fromSupabase(
          {
            'id': item.id,
            'chat_type': item.chatType ?? 'meetup',
            'status': 'accepted',
            'meetup_id': item.meetupId,
            'meetup_request_id': item.meetupRequestId,
            'user_one': item.userOne,
            'user_two': item.userTwo,
            'updated_at': DateTime.now().toIso8601String(),
          },
          otherUserName: item.name,
          otherUserAvatar: item.avatarUrl,
          lastMessage: item.message,
        );
      }
    } catch (_) {
      item.status = RequestStatus.accepted;
    }
    update();
  }

  /// Reject a meetup request – persists to Supabase then updates local state.
  Future<void> rejectRequest(Chat item) async {
    if (item.id == null) {
      item.status = RequestStatus.rejected;
      update();
      return;
    }
    try {
      final requestRow =
          await MeetupService.getRequestForChat(item.id!);
      final requestMsgRow =
          await MeetupService.getRequestMessage(item.id!);
      if (requestRow != null && requestMsgRow != null) {
        await MeetupService.rejectRequest(
          requestId: requestRow['id'] as String,
          chatId: item.id!,
          requestMessageId: requestMsgRow['id'] as String,
        );
      }
      item.status = RequestStatus.rejected;
    } catch (_) {
      item.status = RequestStatus.rejected;
    }
    update();
  }

  void removeConversation(Chat item) {
    items.remove(item);
    update();
  }
}
