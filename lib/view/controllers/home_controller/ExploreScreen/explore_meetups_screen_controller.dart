import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/models/profile_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/discovery_service.dart';
import 'package:meetmern/data/service/favorite_service.dart';
import 'package:meetmern/data/service/meetup_store.dart';
import 'package:meetmern/data/service/profile_service.dart';
import 'package:meetmern/view/screens/onboardingscreens/dummy_data/onboarding_mock_data.dart';

class ExploreController extends GetxController {
  final MeetupStore _store = MeetupStore.instance;
  final Map<String, dynamic> _activeFilters = <String, dynamic>{};
  final Map<String, dynamic> _filterOptions = <String, dynamic>{};
  final List<Nearby> _activeUsers = <Nearby>[];

  ProfileModel? _viewerProfile;
  _GeoPoint? _viewerCoordinates;

  bool loading = true;
  String? error;

  List<Meetup> get meetups {
    final base = _store.meetups
        .where((m) => !isOwnMeetup(m))
        .where(_isAvailableMeetup)
        .toList(growable: false);
    final filtered = base.where(_matchesFilters).toList(growable: false);
    final ranked = List<Meetup>.from(filtered);
    ranked.sort((a, b) {
      final scoreCompare = _rankingScore(b).compareTo(_rankingScore(a));
      if (scoreCompare != 0) return scoreCompare;
      return a.time.compareTo(b.time);
    });
    return ranked;
  }

  Map<String, dynamic> get activeFilters =>
      Map<String, dynamic>.unmodifiable(_activeFilters);
  Map<String, dynamic> get filterOptions {
    if (_filterOptions.isEmpty) return OnboardingMockData.filterOptions;
    return Map<String, dynamic>.unmodifiable(_filterOptions);
  }

  List<Nearby> get activeUsers => List<Nearby>.unmodifiable(_activeUsers);

  List<Nearby> get filteredActiveUsers {
    return _activeUsers.where(_matchesFilters).toList(growable: false);
  }
  bool get hasActiveFilters => _activeFilters.isNotEmpty;
  int get activeFilterCount => _activeFilters.length;
  String? get currentUserId => AuthService.currentUser?.id;

  bool isOwnMeetup(Meetup m) => m.userId != null && m.userId == currentUserId;

  Future<void> loadData() async {
    loading = true;
    error = null;
    update();

    try {
      await Future.wait([
        _store.load(forceReload: true),
        _loadDiscoveryInputs(),
      ]);
      error = _store.lastError;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    update();
  }

  Future<void> _loadDiscoveryInputs() async {
    final options = await DiscoveryService.fetchFilterOptions();
    _filterOptions
      ..clear()
      ..addAll(
        options.isNotEmpty ? options : OnboardingMockData.filterOptions,
      );

    final activeUsers = await DiscoveryService.fetchActiveUsers(
      limit: 20,
      excludeUserId: currentUserId,
    );
    _activeUsers
      ..clear()
      ..addAll(activeUsers);

    final uid = currentUserId;
    if (uid != null && uid.isNotEmpty) {
      _viewerProfile = await ProfileService.getProfile(uid);
    }
    _viewerProfile ??= AuthService.currentProfile.value;
    _viewerCoordinates = await _resolveCoordinatesFromText(_viewerLocation);
  }

  void applyFilters(Map<String, dynamic>? rawFilters) {
    final normalized = _normalizeFilters(rawFilters ?? <String, dynamic>{});
    _activeFilters
      ..clear()
      ..addAll(normalized);
    update();
    _refreshActiveUsers();
  }

  Future<void> _refreshActiveUsers() async {
    final users = await DiscoveryService.fetchActiveUsers(
      limit: 20,
      excludeUserId: currentUserId,
    );
    _activeUsers
      ..clear()
      ..addAll(users);
    update();
  }

  void clearFilters() {
    if (_activeFilters.isEmpty) return;
    _activeFilters.clear();
    update();
  }

  Future<void> toggleFavorite(String meetupId) async {
    await FavoriteService.instance.toggle(meetupId);
  }

  void refreshUi() => update();

  String approximateLocationForFeed(Meetup meetup) {
    final approx = _approximateLocationCore(meetup.location);
    return approx.isEmpty ? 'Near your area' : 'Near $approx';
  }

  bool _isAvailableMeetup(Meetup meetup) {
    // Hide meetups the current user has already requested or completed.
    if (_store.hiddenMeetupIds.contains(meetup.id)) return false;

    // Only show meetups that are open/active and not expired.
    final status = meetup.status.trim().toLowerCase();
    final isAvailableStatus = status.isEmpty ||
        status == 'open' ||
        status == 'active';
    if (!isAvailableStatus) return false;

    return meetup.time
        .isAfter(DateTime.now().subtract(const Duration(hours: 4)));
  }

  double _rankingScore(Meetup meetup) {
    final proximityScore = _proximityScore(meetup);
    final timeScore = _timeRelevanceScore(meetup.time);
    final sharedScore = _sharedInterestScore(meetup);
    return (0.50 * proximityScore) + (0.30 * timeScore) + (0.20 * sharedScore);
  }

  double _proximityScore(Meetup meetup) {
    final distance = _estimatedDistanceKm(meetup);
    if (distance == null) return 0.20;

    final limit = _distanceLimitKmForRanking;
    final normalized = 1 - (distance / limit).clamp(0.0, 1.0);
    return normalized.clamp(0.0, 1.0);
  }

  double _timeRelevanceScore(DateTime meetupTime) {
    final now = DateTime.now();
    if (meetupTime.isBefore(now.subtract(const Duration(hours: 4)))) {
      return 0.0;
    }

    if (_isSameDay(now, meetupTime)) {
      final minutes = meetupTime.difference(now).inMinutes.abs();
      if (minutes <= 90) return 1.0; // now
      return 0.88; // today
    }

    final dayDiff = meetupTime.difference(now).inDays;
    if (dayDiff < 0) return 0.0;
    if (_isWeekend(meetupTime) && dayDiff <= 7) return 0.78;
    if (dayDiff <= 2) return 0.62;
    if (dayDiff <= 7) return 0.42;
    return 0.20;
  }

  double _sharedInterestScore(Meetup meetup) {
    final viewerInterests = _viewerInterests;
    if (viewerInterests.isEmpty) return 0.35;

    final meetupTopics = <String>{
      ...meetup.interests.map((item) => item.trim().toLowerCase()),
      ...meetup.languages.map((item) => item.trim().toLowerCase()),
      meetup.type.trim().toLowerCase(),
    }..removeWhere((item) => item.isEmpty);

    if (meetupTopics.isEmpty) return 0.10;

    final overlapCount =
        viewerInterests.intersection(meetupTopics).length.toDouble();
    final ratio = overlapCount / viewerInterests.length.toDouble();
    return ratio.clamp(0.0, 1.0);
  }

  Set<String> get _viewerInterests {
    final profile = _viewerProfile ?? AuthService.currentProfile.value;
    if (profile == null) return const <String>{};
    return <String>{
      ...?profile.interests,
      ...?profile.passionTopics,
    }
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  String? get _viewerLocation {
    final loaded = _viewerProfile?.location?.trim();
    if (loaded != null && loaded.isNotEmpty) return loaded;
    final current = AuthService.currentProfile.value?.location?.trim();
    if (current != null && current.isNotEmpty) return current;
    return null;
  }

  // Always a valid, sane radius — ProfileModel.discoveryRadiusKm falls back
  // to its own default whenever the profile has no radius set yet, or an
  // invalid/absurdly large value (e.g. a fresh-install placeholder), so the
  // discovery radius filter is never effectively unlimited.
  double get _viewerRadiusKm {
    final profile = _viewerProfile ?? AuthService.currentProfile.value;
    return profile?.discoveryRadiusKm ?? ProfileModel.defaultDiscoveryRadiusKm;
  }

  double get _distanceLimitKmForRanking {
    final filterDistance = _asDouble(_activeFilters['distanceKm']);
    if (filterDistance != null && filterDistance > 0) return filterDistance;
    return _viewerRadiusKm;
  }

  double? _estimatedDistanceKm(Meetup meetup) {
    if (meetup.distanceKm > 0) return meetup.distanceKm;

    final viewerCoordinates = _viewerCoordinates;
    if (viewerCoordinates != null) {
      final meetupCoordinates = _coordinatesForMeetup(meetup);
      if (meetupCoordinates != null) {
        return _distanceBetweenKm(
          viewerCoordinates.latitude,
          viewerCoordinates.longitude,
          meetupCoordinates.latitude,
          meetupCoordinates.longitude,
        );
      }
    }

    final userLocation = _viewerLocation;
    if (userLocation == null || userLocation.isEmpty) return null;

    final meetupApprox = _approximateLocationCore(meetup.location);
    if (meetupApprox.isEmpty) return null;

    final similarity = _locationSimilarityScore(userLocation, meetupApprox);
    if (similarity >= 0.95) return 3.0;
    if (similarity >= 0.80) return 10.0;
    if (similarity >= 0.60) return 35.0;
    if (similarity >= 0.40) return 90.0;
    return 220.0;
  }

  String _approximateLocationCore(String raw) {
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

  double _locationSimilarityScore(String left, String right) {
    final leftParts = _LocationParts.fromText(left);
    final rightParts = _LocationParts.fromText(right);

    final sameCity = leftParts.city.isNotEmpty &&
        rightParts.city.isNotEmpty &&
        leftParts.city == rightParts.city;
    final sameCountry = leftParts.country.isNotEmpty &&
        rightParts.country.isNotEmpty &&
        leftParts.country == rightParts.country;

    if (sameCity && sameCountry) return 1.0;
    if (sameCity) return 0.85;
    if (sameCountry) return 0.60;

    final tokenOverlap =
        leftParts.tokens.intersection(rightParts.tokens).length;
    if (tokenOverlap > 0) return 0.40;
    return 0.15;
  }

  _GeoPoint? _coordinatesForMeetup(Meetup meetup) {
    final lat = meetup.latitude;
    final lng = meetup.longitude;
    if (lat != null && lng != null) {
      return _GeoPoint(latitude: lat, longitude: lng);
    }
    return _tryParseCoordinates(meetup.location);
  }

  Future<_GeoPoint?> _resolveCoordinatesFromText(String? raw) async {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return null;

    final parsed = _tryParseCoordinates(text);
    if (parsed != null) return parsed;

    try {
      final locations = await locationFromAddress(text);
      if (locations.isEmpty) return null;
      return _GeoPoint(
        latitude: locations.first.latitude,
        longitude: locations.first.longitude,
      );
    } catch (_) {
      return null;
    }
  }

  _GeoPoint? _tryParseCoordinates(String raw) {
    final match = RegExp(
      r'^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$',
    ).firstMatch(raw);
    if (match == null) return null;

    final latitude = double.tryParse(match.group(1)!);
    final longitude = double.tryParse(match.group(2)!);
    if (latitude == null || longitude == null) return null;

    return _GeoPoint(latitude: latitude, longitude: longitude);
  }

  double _distanceBetweenKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final meters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return meters / 1000.0;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isWeekend(DateTime value) {
    return value.weekday == DateTime.saturday ||
        value.weekday == DateTime.sunday;
  }

  bool _matchesFilters(Meetup meetup) {
    final maxDistance = _asDouble(_activeFilters['distanceKm']);
    final effectiveDistance = _estimatedDistanceKm(meetup);

    final hasExplicitDistanceFilter = maxDistance != null && maxDistance > 0;
    if (hasExplicitDistanceFilter) {
      if (effectiveDistance == null || effectiveDistance > maxDistance) {
        return false;
      }
    } else {
      final profileRadius = _viewerRadiusKm;
      if (effectiveDistance == null || effectiveDistance > profileRadius) {
        return false;
      }
    }

    final minAge = _asInt(_activeFilters['ageMin']);
    final maxAge = _asInt(_activeFilters['ageMax']);
    if (minAge != null || maxAge != null) {
      final age = _ageFromDob(meetup.ownerDob);
      if (age != null) {
        if (minAge != null && age < minAge) return false;
        if (maxAge != null && age > maxAge) return false;
      }
    }

    final gender = _asString(_activeFilters['gender']);
    if (gender != null &&
        meetup.ownerGender != null &&
        !_equalsIgnoreCase(meetup.ownerGender, gender)) {
      return false;
    }

    final religions = _asString(_activeFilters['religion']);
    if (religions != null &&
        meetup.ownerReligion != null &&
        !_equalsIgnoreCase(meetup.ownerReligion, religions)) {
      return false;
    }

    final relationship = _asString(_activeFilters['relationship']);
    if (relationship != null &&
        meetup.ownerRelationshipStatus != null &&
        !_equalsIgnoreCase(meetup.ownerRelationshipStatus, relationship)) {
      return false;
    }

    final orientationFilters = _asStringList(_activeFilters['orientation']);
    if (orientationFilters.isNotEmpty) {
      final ownerOrientation = _asString(meetup.ownerOrientation);
      if (ownerOrientation != null &&
          !orientationFilters
              .any((value) => _equalsIgnoreCase(value, ownerOrientation))) {
        return false;
      }
    }

    final languageFilters = _asStringList(_activeFilters['languages']);
    if (languageFilters.isNotEmpty &&
        !_hasOverlap(meetup.languages, languageFilters)) {
      return false;
    }

    final interestFilters = _asStringList(_activeFilters['interests']);
    if (interestFilters.isNotEmpty &&
        !_hasOverlap(meetup.interests, interestFilters)) {
      return false;
    }

    final dateRange = _activeFilters['dateRange'];
    if (dateRange is Map) {
      final start = DateTime.tryParse(dateRange['start']?.toString() ?? '');
      final end = DateTime.tryParse(dateRange['end']?.toString() ?? '');
      if (start != null && meetup.time.isBefore(start)) return false;
      if (end != null) {
        final inclusiveEnd =
            DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
        if (meetup.time.isAfter(inclusiveEnd)) return false;
      }
    }

    return true;
  }

  Map<String, dynamic> _normalizeFilters(Map<String, dynamic> raw) {
    final map = <String, dynamic>{};

    void putIfNotNull(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is List && value.isEmpty) return;
      map[key] = value;
    }

    final distance = _asDouble(raw['distanceKm']);
    if (distance != null && distance > 0 && distance != 15.0) {
      map['distanceKm'] = distance;
    }

    final minAge = _asInt(raw['ageMin']);
    final maxAge = _asInt(raw['ageMax']);
    if (minAge != null && maxAge != null && !(minAge == 20 && maxAge == 45)) {
      map['ageMin'] = minAge;
      map['ageMax'] = maxAge;
    }

    final gender = _normalizeAnyValue(raw['gender']);
    putIfNotNull('gender', gender);

    final religion = _normalizeAnyValue(raw['religion']);
    putIfNotNull('religion', religion);

    final relationship = _normalizeAnyValue(raw['relationship']);
    putIfNotNull('relationship', relationship);

    final orientations = _normalizeStringList(raw['orientation']);
    if (orientations.isNotEmpty) {
      map['orientation'] = orientations;
    }

    final languages = _normalizeStringList(raw['languages']);
    if (languages.isNotEmpty) {
      map['languages'] = languages;
    }

    final interests = _normalizeStringList(raw['interests']);
    if (interests.isNotEmpty) {
      map['interests'] = interests;
    }

    final hostRating = _normalizeAnyValue(raw['hostRating']);
    putIfNotNull('hostRating', hostRating);

    final dateRange = raw['dateRange'];
    if (dateRange is Map) {
      final start = dateRange['start']?.toString();
      final end = dateRange['end']?.toString();
      if ((start ?? '').isNotEmpty && (end ?? '').isNotEmpty) {
        map['dateRange'] = {
          'start': start,
          'end': end,
        };
      }
    }

    return map;
  }

  String? _normalizeAnyValue(dynamic value) {
    final text = _asString(value);
    if (text == null) return null;
    if (text.toLowerCase() == 'any') return null;
    return text;
  }

  List<String> _normalizeStringList(dynamic value) {
    final items = _asStringList(value);
    return items.where((item) => item.toLowerCase() != 'any').toList();
  }

  int? _ageFromDob(String? dob) {
    final parsed = _tryParseDate(dob);
    if (parsed == null) return null;
    final now = DateTime.now();
    int age = now.year - parsed.year;
    final birthdayThisYear = DateTime(now.year, parsed.month, parsed.day);
    if (birthdayThisYear.isAfter(now)) {
      age -= 1;
    }
    return age;
  }

  DateTime? _tryParseDate(String? input) {
    final raw = input?.trim() ?? '';
    if (raw.isEmpty) return null;

    final direct = DateTime.tryParse(raw);
    if (direct != null) return direct;

    final slashParts = raw.split('/');
    if (slashParts.length == 3) {
      final day = int.tryParse(slashParts[0]);
      final month = int.tryParse(slashParts[1]);
      final year = int.tryParse(slashParts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    final dashParts = raw.split('-');
    if (dashParts.length == 3) {
      final first = int.tryParse(dashParts[0]);
      final second = int.tryParse(dashParts[1]);
      final third = int.tryParse(dashParts[2]);
      if (first != null && second != null && third != null) {
        if (dashParts[0].length == 4) return DateTime(first, second, third);
        return DateTime(third, second, first);
      }
    }

    return null;
  }

  bool _hasOverlap(List<String> source, List<String> filters) {
    if (source.isEmpty || filters.isEmpty) return false;
    final sourceLower = source.map((e) => e.trim().toLowerCase()).toSet();
    return filters.any((f) => sourceLower.contains(f.trim().toLowerCase()));
  }

  bool _equalsIgnoreCase(String? a, String? b) {
    if (a == null || b == null) return false;
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  List<String> _asStringList(dynamic value) {
    if (value == null) return const <String>[];
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }
}

class _GeoPoint {
  final double latitude;
  final double longitude;

  const _GeoPoint({
    required this.latitude,
    required this.longitude,
  });
}

class _LocationParts {
  final String city;
  final String country;
  final Set<String> tokens;

  const _LocationParts({
    required this.city,
    required this.country,
    required this.tokens,
  });

  factory _LocationParts.fromText(String raw) {
    final parts = raw
        .split(',')
        .map((part) => part.trim().toLowerCase())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    final city = parts.length >= 2
        ? parts[parts.length - 2]
        : (parts.isNotEmpty ? parts.first : '');
    final country = parts.isNotEmpty ? parts.last : '';

    return _LocationParts(
      city: city,
      country: country,
      tokens: parts.toSet(),
    );
  }
}
