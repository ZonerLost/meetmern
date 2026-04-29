import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
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
  String distanceText = '';
  String? errorMessage;

  String? chatId;
  String? requestId;

  // ── Formatted time (matches ViewMeetupController) ─────────────────────────
  String get formattedTime {
    final dt = meetup?.time;
    if (dt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final dayDiff = target.difference(today).inDays;
    final dayLabel = dayDiff == 0
        ? 'Today'
        : dayDiff == 1
            ? 'Tomorrow'
            : '${dt.day}/${dt.month}/${dt.year}';
    return '$dayLabel · ${_formatHour(dt)} – ${_formatHour(dt.add(const Duration(hours: 1)))}';
  }

  String _formatHour(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void init(Meetup initialMeetup, {String? chatId, String? requestId}) {
    meetup = initialMeetup;
    this.chatId = chatId;
    this.requestId = requestId;
    errorMessage = null;
    distanceText = '';
    meetupStatus = initialMeetup.status;
    isConfirmed = true;
    update();
    _loadLatestStatus();
    _computeDistance();
  }

  Future<void> _computeDistance() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { _setFallbackDistance(); update(); return; }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _setFallbackDistance(); update(); return;
      }
      await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 10),
          onTimeout: () => throw Exception('timeout'));
    } catch (_) {}
    _setFallbackDistance();
    update();
  }

  void _setFallbackDistance() {
    final km = meetup?.distanceKm ?? 0.0;
    distanceText = km > 0 ? '${km.toStringAsFixed(1)} km away' : 'Nearby';
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
