import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/data/service/meetup_store.dart';

class ViewMeetupController extends GetxController {
  final MeetupStore _store = MeetupStore.instance;

  Meetup? meetup;
  String _ownerName = '';
  String _ownerPhotoUrl = '';

  bool isRequested = false;
  bool isLoading = false;
  bool isProfileLoading = false;
  String? errorMessage;
  String distanceText = '';

  String? get currentUserId => AuthService.currentUser?.id;

  bool get isOwnMeetup =>
      meetup?.userId != null && meetup!.userId == currentUserId;

  String get _fallbackHostName {
    final raw = meetup?.hostName.trim() ?? '';
    return raw.isNotEmpty ? raw : 'Host';
  }

  String get _fallbackPhotoUrl {
    final raw = meetup?.image.trim() ?? '';
    return raw;
  }

  String get hostName => _ownerName.isNotEmpty ? _ownerName : _fallbackHostName;

  String get hostPhotoUrl =>
      _ownerPhotoUrl.isNotEmpty ? _ownerPhotoUrl : _fallbackPhotoUrl;

  // ── Formatted time ────────────────────────────────────────────────────────

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

  void init(Meetup initialMeetup) {
    debugPrint(
      '[ViewMeetup] init — meetupId=${initialMeetup.id} userId=${initialMeetup.userId} hostName=${initialMeetup.hostName} image=${initialMeetup.image}',
    );

    meetup = initialMeetup;
    _ownerName = '';
    _ownerPhotoUrl = initialMeetup.image.startsWith('http')
        ? initialMeetup.image.trim()
        : '';

    distanceText = '';
    isRequested = initialMeetup.joinRequested;
    isProfileLoading = false;
    errorMessage = null;
    update();

    _loadOwnerProfile();
    _checkExistingRequest();
    _computeDistance();

    Future.delayed(const Duration(seconds: 12), () {
      if (distanceText.isEmpty) {
        _setFallbackDistance();
        update();
      }
    });
  }

  Future<void> _loadOwnerProfile() async {
    final uid = meetup?.userId;
    debugPrint('[ViewMeetup] _loadOwnerProfile — userId=$uid');

    if (uid == null || uid.trim().isEmpty) {
      debugPrint(
        '[ViewMeetup] _loadOwnerProfile — userId missing, falling back to meetup values',
      );
      _ownerName = _fallbackHostName;
      _ownerPhotoUrl = _fallbackPhotoUrl;
      isProfileLoading = false;
      update();
      return;
    }

    isProfileLoading = true;
    update();

    try {
      final row = await MeetupService.fetchOwnerProfile(uid);
      debugPrint('[ViewMeetup] _loadOwnerProfile — raw row=$row');

      if (row != null && meetup?.userId == uid) {
        final fetchedName = row['name']?.toString().trim() ?? '';
        final fetchedPhoto = row['photo_url']?.toString().trim() ?? '';

        _ownerName = fetchedName.isNotEmpty ? fetchedName : _fallbackHostName;

        _ownerPhotoUrl =
            fetchedPhoto.isNotEmpty ? fetchedPhoto : _fallbackPhotoUrl;

        debugPrint(
          '[ViewMeetup] _loadOwnerProfile — resolved name=$_ownerName photoUrl=$_ownerPhotoUrl',
        );
      } else {
        debugPrint(
          '[ViewMeetup] _loadOwnerProfile — profile not found, falling back to meetup values',
        );
        _ownerName = _fallbackHostName;
        _ownerPhotoUrl = _fallbackPhotoUrl;
      }
    } catch (e, st) {
      debugPrint('[ViewMeetup] _loadOwnerProfile — ERROR: $e\n$st');
      _ownerName = _fallbackHostName;
      _ownerPhotoUrl = _fallbackPhotoUrl;
    }

    isProfileLoading = false;
    update();
  }

  Future<void> _computeDistance() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setFallbackDistance();
        update();
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _setFallbackDistance();
        update();
        return;
      }

      await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('timeout'),
      );

      _setFallbackDistance();
    } catch (_) {
      _setFallbackDistance();
    }

    update();
  }

  void _setFallbackDistance() {
    final km = meetup?.distanceKm ?? 0.0;
    distanceText = km > 0 ? '${km.toStringAsFixed(1)} km away' : 'Nearby';
  }

  Future<void> _checkExistingRequest() async {
    final uid = currentUserId;
    final m = meetup;
    if (uid == null || m == null || m.userId == null) return;

    try {
      final existing = await MeetupService.getExistingRequest(
        meetupId: m.id,
        requesterId: uid,
      );

      if (existing != null && meetup?.id == m.id) {
        isRequested = true;
        m.joinRequested = true;
        update();
      }
    } catch (e, st) {
      debugPrint('[ViewMeetup] _checkExistingRequest — ERROR: $e\n$st');
    }
  }

  Meetup get currentMeetup {
    final m = meetup;
    if (m == null) {
      throw StateError('ViewMeetupController not initialized');
    }
    return m;
  }

  Future<Chat?> requestToJoin() async {
    final uid = currentUserId;
    final m = meetup;

    if (uid == null || m == null || isOwnMeetup || isRequested) return null;

    isLoading = true;
    errorMessage = null;
    update();

    try {
      if (await MeetupService.isProfileDisabled(uid)) {
        errorMessage = 'Your account is disabled.';
        return null;
      }

      if (await MeetupService.isProfileDisabled(m.userId!)) {
        errorMessage = 'This user account is disabled.';
        return null;
      }

      final blocked = await MeetupService.areUsersBlocked(
        userA: uid,
        userB: m.userId!,
      );
      if (blocked) {
        errorMessage =
            'Cannot request meetup because one of you has blocked the other.';
        return null;
      }

      // Guard: block if there is already an active meetup between them.
      final hasActive = await MeetupService.hasActiveMeetupRequestBetween(
        userA: uid,
        userB: m.userId!,
      );
      if (hasActive) {
        errorMessage =
            'A meetup is already active between you. Wait for it to complete first.';
        return null;
      }

      final chatRow = await MeetupService.sendMeetupRequest(
        meetupId: m.id,
        meetupOwnerId: m.userId!,
        requesterId: uid,
      );

      isRequested = true;
      m.joinRequested = true;
      _store.setJoinRequested(m.id, true);

      final chat = Chat.fromSupabase(
        chatRow,
        otherUserName: hostName,
        otherUserAvatar: hostPhotoUrl.startsWith('http') ? hostPhotoUrl : '',
        lastMessage: 'sent you a meetup request',
      );
      chat.type = m.type;
      chat.time = formattedTime;
      final normalizedLocation = m.location.trim();
      chat.subtitle = normalizedLocation.isEmpty
          ? formattedTime
          : '$formattedTime · Near $normalizedLocation';
      return chat;
    } catch (e, st) {
      debugPrint('[ViewMeetup] requestToJoin — ERROR: $e\n$st');
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading = false;
      update();
    }
  }

  void markRequested() {
    if (meetup == null) return;
    isRequested = true;
    meetup!.joinRequested = true;
    _store.setJoinRequested(meetup!.id, true);
    update();
  }
}
