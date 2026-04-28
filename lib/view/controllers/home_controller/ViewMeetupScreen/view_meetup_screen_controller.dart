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
  bool isLocationExactVisible = false;
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

  String get visibleLocation {
    final raw = meetup?.location.trim() ?? '';
    if (raw.isEmpty) return '';
    if (isLocationExactVisible) return raw;
    final approx = _approximateLocation(raw);
    return approx.isEmpty ? 'Near your area' : 'Near $approx';
  }

  String get locationPrivacyHint {
    if (isOwnMeetup || isLocationExactVisible) return '';
    return 'Exact location is shared after both users confirm the meetup.';
  }

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
    // Always start as false — _checkExistingRequest will set the real value
    // from the DB so stale store state never shows a wrong button label.
    isRequested = false;
    isLocationExactVisible = isOwnMeetup;
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

  String _approximateLocation(String raw) {
    final parts = raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}, ${parts.last}';
    }
    if (parts.isNotEmpty) return parts.first;
    return '';
  }

  Future<void> _checkExistingRequest() async {
    final uid = currentUserId;
    final m = meetup;
    if (uid == null || m == null) return;

    try {
      final existing = await MeetupService.getExistingRequest(
        meetupId: m.id,
        requesterId: uid,
      );

      if (meetup?.id != m.id) return; // meetup changed while loading

      if (existing != null) {
        final status = existing['status']?.toString().trim().toLowerCase() ?? '';
        // Terminal statuses: request is over, button should be available again.
        final isTerminal = status == 'rejected' ||
            status == 'cancelled' ||
            status == 'completed';
        final isConfirmed = status == 'accepted';

        isRequested = !isTerminal;
        isLocationExactVisible = isOwnMeetup || isConfirmed;
        m.joinRequested = isRequested;
      } else {
        // No request exists — button is available.
        isRequested = false;
        isLocationExactVisible = isOwnMeetup;
        m.joinRequested = false;
      }
      update();
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

    print('[ViewMeetup] requestToJoin — uid=$uid meetupId=${m?.id} ownerId=${m?.userId} isOwnMeetup=$isOwnMeetup isRequested=$isRequested');

    if (uid == null) {
      print('[ViewMeetup] requestToJoin — aborted: not logged in');
      return null;
    }
    if (m == null) {
      print('[ViewMeetup] requestToJoin — aborted: meetup is null');
      return null;
    }
    if (isOwnMeetup) {
      print('[ViewMeetup] requestToJoin — aborted: own meetup');
      return null;
    }
    if (isRequested) {
      print('[ViewMeetup] requestToJoin — aborted: already requested');
      return null;
    }
    if (m.userId == null || m.userId!.trim().isEmpty) {
      print('[ViewMeetup] requestToJoin — aborted: meetup has no owner userId');
      errorMessage = 'Cannot send request: meetup owner is unknown.';
      update();
      return null;
    }

    isLoading = true;
    errorMessage = null;
    update();

    try {
      print('[ViewMeetup] requestToJoin — checking profile disabled for uid=$uid');
      if (await MeetupService.isProfileDisabled(uid)) {
        errorMessage = 'Your account is disabled.';
        print('[ViewMeetup] requestToJoin — aborted: requester disabled');
        return null;
      }

      print('[ViewMeetup] requestToJoin — checking profile disabled for ownerId=${m.userId}');
      if (await MeetupService.isProfileDisabled(m.userId!)) {
        errorMessage = 'This user account is disabled.';
        print('[ViewMeetup] requestToJoin — aborted: owner disabled');
        return null;
      }

      print('[ViewMeetup] requestToJoin — checking block status');
      final blocked = await MeetupService.areUsersBlocked(
        userA: uid,
        userB: m.userId!,
      );
      if (blocked) {
        errorMessage = 'Cannot request meetup because one of you has blocked the other.';
        print('[ViewMeetup] requestToJoin — aborted: users blocked');
        return null;
      }

      print('[ViewMeetup] requestToJoin — checking active request between users');
      final hasActive = await MeetupService.hasActiveMeetupRequestBetween(
        userA: uid,
        userB: m.userId!,
      );
      if (hasActive) {
        errorMessage = 'A meetup is already active between you. Wait for it to complete first.';
        print('[ViewMeetup] requestToJoin — aborted: active request exists');
        return null;
      }

      print('[ViewMeetup] requestToJoin — sending request...');
      final chatRow = await MeetupService.sendMeetupRequest(
        meetupId: m.id,
        meetupOwnerId: m.userId!,
        requesterId: uid,
      );
      print('[ViewMeetup] requestToJoin — request sent, chatId=${chatRow['id']}');

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
      final normalizedLocation = _approximateLocation(m.location.trim());
      chat.subtitle = _buildSubtitle(m);
      return chat;
    } catch (e, st) {
      print('[ViewMeetup] requestToJoin — ERROR: $e\n$st');
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading = false;
      update();
    }
  }

  String _buildSubtitle(Meetup m) {
    final dt = m.time;
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final day = weekdays[dt.weekday - 1];
    final end = dt.add(const Duration(hours: 1));
    final sh = dt.hour == 0 || dt.hour == 12 ? 12 : dt.hour % 12;
    final eh = end.hour == 0 || end.hour == 12 ? 12 : end.hour % 12;
    final sp = dt.hour >= 12 ? 'PM' : 'AM';
    final ep = end.hour >= 12 ? 'PM' : 'AM';
    final timeRange = sp == ep ? '$sh–$eh $ep' : '$sh $sp–$eh $ep';
    final approx = _approximateLocation(m.location.trim());
    final parts = [day, timeRange, if (approx.isNotEmpty) 'Near $approx'];
    return parts.join(' · ');
  }

  void markRequested() {
    if (meetup == null) return;
    isRequested = true;
    meetup!.joinRequested = true;
    _store.setJoinRequested(meetup!.id, true);
    update();
  }
}
