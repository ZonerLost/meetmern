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

  String? chatId;
  String? requestId;

  void init(Meetup initialMeetup, {String? chatId, String? requestId}) {
    meetup = initialMeetup;
    this.chatId = chatId;
    this.requestId = requestId;
    errorMessage = null;
    // Optimistic state from the passed meetup — will be overridden by DB fetch.
    meetupStatus = initialMeetup.status;
    isConfirmed = true;
    update();
    _loadLatestStatus();
  }

  Future<void> _loadLatestStatus() async {
    final m = meetup;
    if (m == null) return;

    try {
      // Resolve chatId if not provided.
      String? resolvedChatId = chatId;
      String? resolvedRequestId = requestId;

      if (resolvedChatId == null || resolvedRequestId == null) {
        final rows = await supabase
            .from('meetup_requests')
            .select('id, chat_id, status')
            .eq('meetup_id', m.id)
            .order('created_at', ascending: false)
            .limit(1);
        if (rows.isNotEmpty) {
          resolvedRequestId ??= rows.first['id']?.toString();
          resolvedChatId ??= rows.first['chat_id']?.toString();
          final dbStatus = rows.first['status']?.toString().toLowerCase() ?? '';
          _applyRequestStatus(dbStatus);
          return;
        }
      } else {
        // Fetch the latest request for this chat.
        final row = await MeetupService.getLatestRequestForChat(resolvedChatId);
        if (row != null) {
          resolvedRequestId = row['id']?.toString();
          final dbStatus = row['status']?.toString().toLowerCase() ?? '';
          _applyRequestStatus(dbStatus);
          return;
        }
      }
    } catch (_) {}

    // Fallback: use the meetup object's own status.
    _applyRequestStatus(meetup?.status.toLowerCase() ?? '');
  }

  void _applyRequestStatus(String status) {
    meetupStatus = status.isEmpty ? 'active' : status;
    isConfirmed = status != 'cancelled' && status != 'rejected' && status != 'completed';
    update();
  }

  Future<bool> cancelMeetup() async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) return false;

    isCancelling = true;
    errorMessage = null;
    update();

    try {
      String? resolvedRequestId = requestId;
      String? resolvedChatId = chatId;

      // Always resolve from DB to get the true latest active request.
      // Prefer chatId lookup (most accurate) over meetup_id lookup.
      if (resolvedChatId != null) {
        final row = await MeetupService.getLatestRequestForChat(resolvedChatId);
        if (row != null) {
          final rowStatus = row['status']?.toString().toLowerCase() ?? '';
          // Only cancel if it's actually active.
          if (rowStatus == 'requested' || rowStatus == 'accepted') {
            resolvedRequestId = row['id']?.toString();
          } else {
            // Already terminal — nothing to cancel.
            isConfirmed = false;
            meetupStatus = rowStatus;
            update();
            return true;
          }
        }
      } else if (meetup != null) {
        // Fallback: find any active request for this meetup.
        final rows = await supabase
            .from('meetup_requests')
            .select('id, chat_id, status')
            .eq('meetup_id', meetup!.id)
            .inFilter('status', ['requested', 'accepted'])
            .order('created_at', ascending: false)
            .limit(1);
        if (rows.isNotEmpty) {
          resolvedRequestId = rows.first['id']?.toString();
          resolvedChatId = rows.first['chat_id']?.toString();
        }
      }

      if (resolvedRequestId == null || resolvedChatId == null) {
        errorMessage = 'Could not find the meetup request to cancel.';
        return false;
      }

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
      meetupStatus = 'cancelled';
      update();

      if (Get.isRegistered<MessageController>(tag: resolvedChatId)) {
        await Get.find<MessageController>(tag: resolvedChatId).reloadMessages();
      }
      if (Get.isRegistered<ChatListController>()) {
        Get.find<ChatListController>().loadChats(showLoader: false);
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
