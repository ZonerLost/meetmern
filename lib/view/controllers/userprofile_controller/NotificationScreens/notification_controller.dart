import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/services/notification_service.dart';
import 'package:meetmern/data/models/app_notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationController extends GetxController {
  final List<AppNotification> notifications = <AppNotification>[];
  bool isLoading = false;
  String? error;
  int unreadCount = 0;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      notifications.clear();
      unreadCount = 0;
      error = null;
      update();
      return;
    }

    isLoading = true;
    error = null;
    update();

    try {
      final rows = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      notifications
        ..clear()
        ..addAll(
          List<Map<String, dynamic>>.from(rows)
              .map(AppNotification.fromMap)
              .toList(),
        );
      unreadCount = notifications.where((item) => !item.isRead).length;
    } catch (e) {
      error = 'Unable to load notifications.';
      if (kDebugMode) {
        debugPrint('[NotificationController] loadNotifications error: $e');
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || notificationId.trim().isEmpty) return;

    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', user.id);

      final index = notifications.indexWhere((item) => item.id == notificationId);
      if (index >= 0) {
        final item = notifications[index];
        notifications[index] = AppNotification(
          id: item.id,
          userId: item.userId,
          actorId: item.actorId,
          type: item.type,
          title: item.title,
          body: item.body,
          data: item.data,
          isRead: true,
          createdAt: item.createdAt,
          sentAt: item.sentAt,
        );
      }

      unreadCount = notifications.where((item) => !item.isRead).length;
      update();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationController] markAsRead error: $e');
      }
    }
  }

  Future<void> markAllAsRead() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    if (notifications.isEmpty) return;

    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);

      for (var i = 0; i < notifications.length; i++) {
        final item = notifications[i];
        notifications[i] = AppNotification(
          id: item.id,
          userId: item.userId,
          actorId: item.actorId,
          type: item.type,
          title: item.title,
          body: item.body,
          data: item.data,
          isRead: true,
          createdAt: item.createdAt,
          sentAt: item.sentAt,
        );
      }

      unreadCount = 0;
      update();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationController] markAllAsRead error: $e');
      }
    }
  }

  Future<void> openNotification(AppNotification notification) async {
    if (!notification.isRead) {
      await markAsRead(notification.id);
    }

    final payload = <String, dynamic>{
      ...notification.data,
      'type': notification.type,
      'notification_id': notification.id,
    };
    NotificationService.instance.handleNotificationNavigation(payload);
  }
}
