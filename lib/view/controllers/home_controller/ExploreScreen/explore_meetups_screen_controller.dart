import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/data/service/meetup_store.dart';

class ExploreController extends GetxController {
  final MeetupStore _store = MeetupStore.instance;
  final Map<String, dynamic> _activeFilters = <String, dynamic>{};

  bool loading = true;
  String? error;

  List<Meetup> get meetups {
    final base = _store.meetups
        .where((m) => !isOwnMeetup(m))
        .toList(growable: false);
    if (_activeFilters.isEmpty) return base;
    return base.where(_matchesFilters).toList(growable: false);
  }
  Map<String, dynamic> get activeFilters =>
      Map<String, dynamic>.unmodifiable(_activeFilters);
  bool get hasActiveFilters => _activeFilters.isNotEmpty;
  int get activeFilterCount => _activeFilters.length;
  String? get currentUserId => AuthService.currentUser?.id;

  bool isOwnMeetup(Meetup m) =>
      m.userId != null && m.userId == currentUserId;

  @override
  void onInit() {
    super.onInit();
    _store.addListener(_onStoreChanged);
  }

  @override
  void onClose() {
    _store.removeListener(_onStoreChanged);
    super.onClose();
  }

  void _onStoreChanged() => update();

  Future<void> loadData() async {
    loading = true;
    error = null;
    update();
    await _store.load(forceReload: true);
    error = _store.lastError;
    loading = false;
    update();
  }

  void applyFilters(Map<String, dynamic>? rawFilters) {
    final normalized = _normalizeFilters(rawFilters ?? <String, dynamic>{});
    _activeFilters
      ..clear()
      ..addAll(normalized);
    update();
  }

  void clearFilters() {
    if (_activeFilters.isEmpty) return;
    _activeFilters.clear();
    update();
  }

  Future<void> toggleFavorite(String meetupId) async {
    final uid = AuthService.currentUser?.id;
    final meetup = _store.meetups.firstWhereOrNull((m) => m.id == meetupId);
    if (meetup == null) return;

    final newValue = !meetup.isFavorite;
    _store.setFavorite(meetupId, newValue); // optimistic
    update();

    if (uid == null) return;
    try {
      if (newValue) {
        await MeetupService.addFavourite(userId: uid, meetupId: meetupId);
      } else {
        await MeetupService.removeFavourite(userId: uid, meetupId: meetupId);
      }
    } catch (_) {
      // Revert on failure
      _store.setFavorite(meetupId, !newValue);
      update();
    }
  }

  void refreshUi() => update();

  bool _matchesFilters(Meetup meetup) {
    final maxDistance = _asDouble(_activeFilters['distanceKm']);
    if (maxDistance != null && maxDistance > 0 && meetup.distanceKm > 0) {
      if (meetup.distanceKm > maxDistance) return false;
    }

    final minAge = _asInt(_activeFilters['ageMin']);
    final maxAge = _asInt(_activeFilters['ageMax']);
    if (minAge != null || maxAge != null) {
      final age = _ageFromDob(meetup.ownerDob);
      if (age == null) return false;
      if (minAge != null && age < minAge) return false;
      if (maxAge != null && age > maxAge) return false;
    }

    final gender = _asString(_activeFilters['gender']);
    if (gender != null && !_equalsIgnoreCase(meetup.ownerGender, gender)) {
      return false;
    }

    final religions = _asString(_activeFilters['religion']);
    if (religions != null &&
        !_equalsIgnoreCase(meetup.ownerReligion, religions)) {
      return false;
    }

    final relationship = _asString(_activeFilters['relationship']);
    if (relationship != null &&
        !_equalsIgnoreCase(meetup.ownerRelationshipStatus, relationship)) {
      return false;
    }

    final orientationFilters = _asStringList(_activeFilters['orientation']);
    if (orientationFilters.isNotEmpty) {
      final ownerOrientation = _asString(meetup.ownerOrientation);
      if (ownerOrientation == null ||
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
