import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/main.dart';
import 'package:meetmern/view/controllers/chat_controller/chat_screen_controller.dart';
import 'package:meetmern/view/controllers/chat_controller/message_screen_controller.dart';

class UserMeetupInfoController extends GetxController {
  final Strings _strings = const Strings();

  Meetup? meetup;
  bool isConfirmed = true;
  bool isCancelling = false;
  String meetupStatus = '';
  String? errorMessage;

  // Set by the caller (ChatDetailScreen) so we know which chat to update.
  String? chatId;
  String? requestId;

  void init(Meetup initialMeetup, {String? chatId, String? requestId}) {
    meetup = initialMeetup;
    meetupStatus = initialMeetup.status;
    this.chatId = chatId;
    this.requestId = requestId;
    isConfirmed =
        meetupStatus.toLowerCase() != _strings.cancelledLabel.toLowerCase() &&
            meetupStatus.toLowerCase() != 'cancelled';
    errorMessage = null;
    update();
  }

  Future<bool> cancelMeetup() async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) return false;

    isCancelling = true;
    errorMessage = null;
    update();

    try {
      // Resolve requestId if not provided — find the latest for this chat.
      String? resolvedRequestId = requestId;
      String? resolvedChatId = chatId;

      if ((resolvedRequestId == null || resolvedChatId == null) &&
          meetup != null) {
        // Try to find the chat for this meetup via the meetup_requests table.
        final rows = await supabase
            .from('meetup_requests')
            .select('id, chat_id')
            .eq('meetup_id', meetup!.id)
            .inFilter('status', ['requested', 'accepted'])
            .order('created_at', ascending: false)
            .limit(1);
        if (rows.isNotEmpty) {
          resolvedRequestId ??= rows.first['id']?.toString();
          resolvedChatId ??= rows.first['chat_id']?.toString();
        }
      }

      if (resolvedRequestId == null || resolvedChatId == null) {
        errorMessage = 'Could not find the meetup request to cancel.';
        return false;
      }

      // Fetch the cancelling user's name for the system message.
      final profile = await MeetupService.fetchOwnerProfile(uid);
      final userName = profile?['name']?.toString().trim().isNotEmpty == true
          ? profile!['name'].toString().trim()
          : 'A user';

      await MeetupService.cancelMeetupRequest(
        requestId: resolvedRequestId,
        chatId: resolvedChatId,
        cancelledByUserId: uid,
        cancelledByUserName: userName,
      );

      isConfirmed = false;
      meetupStatus = _strings.cancelledLabel;

      // Refresh the message thread and chat list.
      if (Get.isRegistered<MessageController>(tag: resolvedChatId)) {
        await Get.find<MessageController>(tag: resolvedChatId).reloadMessages();
      }
      if (Get.isRegistered<ChatListController>()) {
        await Get.find<ChatListController>().loadChats(showLoader: false);
      }

      return true;
    } catch (e) {
      errorMessage = 'Failed to cancel meetup: $e';
      return false;
    } finally {
      isCancelling = false;
      update();
    }
  }
}
