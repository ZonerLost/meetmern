import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/notification_types.dart';
import 'package:meetmern/core/routes/route_names.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/firebase_options.dart';
import 'package:meetmern/view/screens/chatscreens/message_screen.dart';
import 'package:meetmern/view/screens/homescreens/ViewMeetupScreen/view_meetup_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const AndroidNotificationChannel _highImportanceChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important app notifications',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  bool _initialized = false;
  bool _localNotificationsInitialized = false;
  bool _permissionRequested = false;
  bool _pendingInitialNavigationHandled = false;
  Map<String, dynamic>? _pendingInitialNavigationData;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (!_isFirebaseReady) return;
    if (_initialized) {
      await syncTokenWithSupabase();
      return;
    }

    await _initializeLocalNotifications();
    await requestPermission();
    await _createAndroidNotificationChannel();
    await _setIosForegroundOptions();
    await syncTokenWithSupabase();
    listenForTokenRefresh();
    setupForegroundMessageListener();
    setupNotificationTapListeners();
    await _captureInitialMessage();

    WidgetsBinding.instance
        .addObserver(_AppResumeObserver(syncTokenWithSupabase));
    _initialized = true;
  }

  Future<void> requestPermission() async {
    if (!_isFirebaseReady) return;
    if (_permissionRequested) return;
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _permissionRequested = true;
      _debugLog(
        'Notification permission status: ${settings.authorizationStatus.name}',
      );
    } catch (e) {
      _debugLog('requestPermission failed: $e');
    }
  }

  Future<String?> getFcmToken() async {
    if (!_isFirebaseReady) return null;
    try {
      if (!kIsWeb && Platform.isIOS) {
        final apnsReady = await _waitForApnsToken();
        if (!apnsReady) {
          _debugLog('APNs token not ready yet; delaying FCM token sync.');
          return null;
        }
      }

      final token = await _messaging.getToken();
      if (token == null || token.trim().isEmpty) {
        _debugLog('FCM token is null/empty.');
        return null;
      }
      _debugLog('FCM token: $token');
      return token;
    } catch (e) {
      _debugLog('Failed to get FCM token: $e');
      return null;
    }
  }

  Future<void> syncTokenWithSupabase() async {
    if (!_isFirebaseReady) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final token = await getFcmToken();
    if (token == null) {
      _scheduleTokenSyncRetry();
      return;
    }

    await _upsertToken(
      userId: user.id,
      token: token,
    );
  }

  Future<void> deactivateCurrentToken() async {
    if (!_isFirebaseReady) return;
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    final token = await getFcmToken();
    if (token == null) return;

    try {
      await client
          .from('user_fcm_tokens')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('token', token);
    } catch (e) {
      _debugLog('Failed to deactivate FCM token on logout: $e');
    }
  }

  void listenForTokenRefresh() {
    if (!_isFirebaseReady) return;
    _tokenRefreshSubscription ??=
        _messaging.onTokenRefresh.listen((String newToken) async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      if (newToken.trim().isEmpty) return;
      await _upsertToken(userId: user.id, token: newToken);
    });
  }

  void setupForegroundMessageListener() {
    if (!_isFirebaseReady) return;
    _foregroundMessageSubscription ??=
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final data = Map<String, dynamic>.from(message.data);
      final type = (data['type'] ?? '').toString();
      final chatId = (data['chat_id'] ?? '').toString();
      if (type == NotificationTypes.chatMessage &&
          chatId.isNotEmpty &&
          ActiveChatTracker.activeChatId == chatId) {
        return;
      }

      await showLocalNotification(message);
      await syncTokenWithSupabase();
    });
  }

  void setupNotificationTapListeners() {
    if (!_isFirebaseReady) return;
    _openedAppSubscription ??=
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationNavigation(Map<String, dynamic>.from(message.data));
    });
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    try {
      final data = Map<String, dynamic>.from(message.data);
      final type = (data['type'] ?? '').toString();

      final fallback = _fallbackContentForType(type);
      final title = (message.notification?.title ?? '').trim().isNotEmpty
          ? message.notification!.title!.trim()
          : fallback.$1;
      final body = (message.notification?.body ?? '').trim().isNotEmpty
          ? message.notification!.body!.trim()
          : fallback.$2;

      final payloadMap = <String, dynamic>{
        ...data,
        '_title': title,
        '_body': body,
      };

      await _localNotifications.show(
        _stableNotificationId(payloadMap),
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'Used for important app notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_stat_notification',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: jsonEncode(payloadMap),
      );
    } catch (e) {
      _debugLog('Failed to show local notification: $e');
    }
  }

  Future<void> handleBackgroundRemoteMessage(RemoteMessage message) async {
    if (!_isFirebaseReady) return;

    await _ensureBackgroundNotificationSetup();

    // Let the OS render normal notification payloads in the background.
    // We only bridge data-only messages into a visible local notification.
    if (message.notification != null) return;

    final data = Map<String, dynamic>.from(message.data);
    if (data.isEmpty) return;

    await showLocalNotification(message);
  }

  void handleNotificationNavigation(Map<String, dynamic> data) {
    Future<void>(() async {
      final normalized = <String, dynamic>{};
      data.forEach((key, value) {
        normalized[key] = value;
      });

      final type = (normalized['type'] ?? '').toString().trim();
      final chatId = (normalized['chat_id'] ?? '').toString().trim();
      final meetupId = (normalized['meetup_id'] ?? '').toString().trim();
      final requestId = (normalized['request_id'] ?? '').toString().trim();
      final postId = (normalized['post_id'] ?? '').toString().trim();
      final boostId = (normalized['boost_id'] ?? '').toString().trim();
      final explicitRoute = (normalized['route'] ?? '').toString().trim();

      if (explicitRoute.isNotEmpty && _routeExists(explicitRoute)) {
        Get.toNamed(explicitRoute, arguments: normalized);
        return;
      }

      switch (type) {
        case NotificationTypes.chatMessage:
          if (chatId.isNotEmpty) {
            final opened = await _openChatById(chatId);
            if (opened) return;
          }
          _openNotificationsFallback();
          return;

        case NotificationTypes.meetupRequest:
          if (chatId.isNotEmpty) {
            final opened = await _openChatById(chatId);
            if (opened) return;
          }
          if (requestId.isNotEmpty || meetupId.isNotEmpty) {
            _openMeetupRequestFallback(arguments: normalized);
            return;
          }
          _openNotificationsFallback();
          return;

        case NotificationTypes.meetupRequestAccepted:
          if (chatId.isNotEmpty) {
            final opened = await _openChatById(chatId);
            if (opened) return;
          }
          if (meetupId.isNotEmpty) {
            final opened = await _openMeetupById(meetupId);
            if (opened) return;
          }
          _openNotificationsFallback();
          return;

        case NotificationTypes.meetupRequestDeclined:
          if (meetupId.isNotEmpty) {
            final opened = await _openMeetupById(meetupId);
            if (opened) return;
          }
          _openNotificationsFallback();
          return;

        case NotificationTypes.favoriteUserPost:
          if (postId.isNotEmpty) {
            _openNotificationsFallback(arguments: normalized);
            return;
          }
          _openNotificationsFallback();
          return;

        case NotificationTypes.meetupUpdated:
          if (chatId.isNotEmpty) {
            final opened = await _openChatById(chatId);
            if (opened) return;
          }
          if (meetupId.isNotEmpty) {
            final opened = await _openMeetupById(meetupId);
            if (opened) return;
          }
          _openNotificationsFallback();
          return;

        case NotificationTypes.boostStatus:
          if (boostId.isNotEmpty) {
            _openNotificationsFallback(arguments: normalized);
            return;
          }
          _openNotificationsFallback();
          return;

        default:
          _openNotificationsFallback();
      }
    });
  }

  Future<void> processPendingInitialNavigation() async {
    if (_pendingInitialNavigationHandled) return;
    final data = _pendingInitialNavigationData;
    if (data == null || data.isEmpty) return;
    _pendingInitialNavigationHandled = true;
    handleNotificationNavigation(data);
  }

  Future<void> _captureInitialMessage() async {
    if (!_isFirebaseReady) return;
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage == null) return;
      _pendingInitialNavigationData =
          Map<String, dynamic>.from(initialMessage.data);
    } catch (e) {
      _debugLog('Failed to read initial notification message: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;

    const androidInit = AndroidInitializationSettings(
      '@drawable/ic_stat_notification',
    );
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload == null || payload.trim().isEmpty) {
          _openNotificationsFallback();
          return;
        }
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map<String, dynamic>) {
            handleNotificationNavigation(decoded);
            return;
          }
          if (decoded is Map) {
            handleNotificationNavigation(decoded.cast<String, dynamic>());
            return;
          }
        } catch (e) {
          _debugLog('Local notification payload decode failed: $e');
        }
        _openNotificationsFallback();
      },
    );

    _localNotificationsInitialized = true;
  }

  Future<void> _ensureBackgroundNotificationSetup() async {
    await _initializeLocalNotifications();
    await _createAndroidNotificationChannel();
  }

  Future<void> _createAndroidNotificationChannel() async {
    if (!Platform.isAndroid) return;
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_highImportanceChannel);
  }

  Future<void> _setIosForegroundOptions() async {
    if (!_isFirebaseReady) return;
    if (!Platform.isIOS) return;
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _upsertToken({
    required String userId,
    required String token,
  }) async {
    final client = Supabase.instance.client;

    final platform = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : defaultTargetPlatform.name;

    final deviceInfo = await _readDeviceDetails();
    final packageInfo = await PackageInfo.fromPlatform();
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

    final payload = <String, dynamic>{
      'user_id': userId,
      'token': token,
      'platform': platform,
      'device_id': deviceInfo.$1,
      'device_name': deviceInfo.$2,
      'app_version': appVersion,
      'is_active': true,
      'last_seen_at': nowIso,
      'updated_at': nowIso,
    };

    try {
      await client.from('user_fcm_tokens').upsert(
            payload,
            onConflict: 'user_id,token',
          );
    } catch (e) {
      _debugLog('Token upsert failed: $e');
    }
  }

  Future<bool> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 8; attempt++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null && apnsToken.trim().isNotEmpty) {
        _debugLog('APNs token ready.');
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }

  Future<(String, String)> _readDeviceDetails() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfoPlugin.androidInfo;
        final deviceId = info.id;
        final deviceName = '${info.manufacturer} ${info.model}'.trim();
        return (
          deviceId.isNotEmpty ? deviceId : info.model,
          deviceName.isNotEmpty ? deviceName : info.model,
        );
      }
      if (Platform.isIOS) {
        final info = await _deviceInfoPlugin.iosInfo;
        final id = info.identifierForVendor ?? info.name;
        final name = info.name.isNotEmpty ? info.name : info.model;
        return (id, name);
      }
    } catch (e) {
      _debugLog('Device info read failed: $e');
    }
    return ('unknown_device', 'Unknown Device');
  }

  bool _routeExists(String route) {
    if (route.isEmpty) return false;
    try {
      final match = Get.routeTree.matchRoute(route);
      return match.route != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _openChatById(String chatId) async {
    final chat = await _buildChatFromId(chatId);
    if (chat == null) {
      if (_routeExists(Routes.chat)) {
        Get.toNamed(Routes.chat);
        return true;
      }
      return false;
    }

    Get.to(() => MessageScreen(chat: chat));
    return true;
  }

  Future<Chat?> _buildChatFromId(String chatId) async {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId == null) return null;

    try {
      final row = await MeetupService.getChatById(chatId);
      if (row == null) return null;

      final userOne = (row['user_one'] ?? '').toString();
      final userTwo = (row['user_two'] ?? '').toString();
      final otherUserId = userOne == currentUserId ? userTwo : userOne;
      if (otherUserId.isEmpty) return null;

      final profileRow = await client
          .from('profiles')
          .select('id,name,photo_url')
          .eq('id', otherUserId)
          .maybeSingle();

      final latestMessageRows = await client
          .from('messages')
          .select('text,message_type,sender_id')
          .eq('chat_id', chatId)
          .order('created_at', ascending: false)
          .limit(1);

      final latestMessage = latestMessageRows.isNotEmpty
          ? Map<String, dynamic>.from(latestMessageRows.first)
          : <String, dynamic>{};

      final messageType = (latestMessage['message_type'] ?? '').toString();
      final senderId = (latestMessage['sender_id'] ?? '').toString();
      String preview = (latestMessage['text'] ?? '').toString();
      if (messageType == 'meetup_request') {
        preview = senderId == currentUserId
            ? 'You sent a meetup request'
            : 'Sent you a meetup request';
      }

      final otherName = (profileRow?['name'] ?? '').toString().trim().isNotEmpty
          ? (profileRow?['name'] ?? '').toString().trim()
          : 'User';
      final avatarUrl = (profileRow?['photo_url'] ?? '').toString();

      final chat = Chat.fromSupabase(
        Map<String, dynamic>.from(row),
        otherUserName: otherName,
        otherUserAvatar: avatarUrl,
        lastMessage: preview,
      );
      return chat;
    } catch (e) {
      _debugLog('Failed to build chat model from chat id: $e');
      return null;
    }
  }

  Future<bool> _openMeetupById(String meetupId) async {
    try {
      final row = await MeetupService.fetchMeetupById(meetupId);
      if (row == null) return false;
      final meetup = Meetup.fromSupabase(row);
      Get.to(() => ViewMeetupScreen(meetup: meetup));
      return true;
    } catch (e) {
      _debugLog('Failed to open meetup by id: $e');
      return false;
    }
  }

  void _openMeetupRequestFallback({Map<String, dynamic>? arguments}) {
    if (_routeExists(Routes.requestMeetup)) {
      Get.toNamed(Routes.requestMeetup, arguments: arguments);
      return;
    }
    _openNotificationsFallback(arguments: arguments);
  }

  void _openNotificationsFallback({Map<String, dynamic>? arguments}) {
    if (_routeExists(Routes.notifications)) {
      Get.toNamed(Routes.notifications, arguments: arguments);
      return;
    }
    if (_routeExists(Routes.explore)) {
      Get.toNamed(Routes.explore);
      return;
    }
  }

  (String, String) _fallbackContentForType(String type) {
    switch (type) {
      case NotificationTypes.meetupRequest:
        return ('New meetup request', 'Someone sent you a meetup request');
      case NotificationTypes.meetupRequestAccepted:
        return (
          'Meetup request accepted',
          'Your meetup request was accepted',
        );
      case NotificationTypes.meetupRequestDeclined:
        return (
          'Meetup request declined',
          'Your meetup request was declined',
        );
      case NotificationTypes.favoriteUserPost:
        return ('New post', 'A favorite user added a new post');
      case NotificationTypes.chatMessage:
        return ('New message', 'You received a new chat message');
      case NotificationTypes.meetupUpdated:
        return (
          'Meetup updated',
          'Meetup time or location has changed',
        );
      case NotificationTypes.boostStatus:
        return (
          'Boost status updated',
          'Your boost status has been updated',
        );
      default:
        return ('New notification', 'You have a new notification');
    }
  }

  int _stableNotificationId(Map<String, dynamic> payload) {
    final id =
        (payload['notification_id'] ?? payload['message_id'] ?? '').toString();
    if (id.isNotEmpty) return id.hashCode;
    return DateTime.now().millisecondsSinceEpoch.remainder(1000000);
  }

  void _scheduleTokenSyncRetry() {
    Future<void>.delayed(const Duration(seconds: 10), () async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      await syncTokenWithSupabase();
    });
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[NotificationService] $message');
    }
  }

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;
}

class ActiveChatTracker {
  ActiveChatTracker._();

  static String? activeChatId;
}

class _AppResumeObserver extends WidgetsBindingObserver {
  _AppResumeObserver(this.onResume);

  final Future<void> Function() onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(onResume());
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.handleBackgroundRemoteMessage(message);
}
