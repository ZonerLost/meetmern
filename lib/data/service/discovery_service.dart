import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/main.dart';

class DiscoveryService {
  DiscoveryService._();

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  static List<String> _dedupeOrdered(Iterable<String> values) {
    final seen = <String>{};
    final output = <String>[];
    for (final raw in values) {
      final value = raw.trim();
      if (value.isEmpty) continue;
      final key = value.toLowerCase();
      if (!seen.add(key)) continue;
      output.add(value);
    }
    return output;
  }

  static List<String> _withAnyPrefix(List<String> values) {
    final trimmed = _dedupeOrdered(values);
    final hasAny =
        trimmed.any((value) => value.toLowerCase() == 'any'.toLowerCase());
    if (hasAny) return trimmed;
    return <String>['Any', ...trimmed];
  }

  static String _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'drink':
      case 'drinks':
        return 'assets/icons/drinks_icon.png';
      case 'meal':
      case 'meals':
        return 'assets/icons/meals_icon.png';
      default:
        return 'assets/icons/coffe_icon.png';
    }
  }

  static String _approximateLocation(String raw) {
    final parts = raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}, ${parts.last}';
    }
    if (parts.isNotEmpty) return parts.first;
    return 'Nearby area';
  }

  static bool _isAvailableStatus(String status) {
    final value = status.trim().toLowerCase();
    if (value.isEmpty) return true;
    return value == 'open' || value == 'active' || value == 'requested';
  }

  static Future<Map<String, dynamic>> fetchFilterOptions() async {
    final genders = <String>[];
    final orientations = <String>[];
    final religions = <String>[];
    final relationships = <String>[];
    final languages = <String>[];
    final interests = <String>[];

    try {
      dynamic profileRows;
      try {
        profileRows = await supabase
            .from('profiles')
            .select(
              'gender, orientation, relationship_status, religion, languages, interests',
            )
            .limit(500);
      } catch (_) {
        profileRows = await supabase
            .from('profiles')
            .select(
              'gender, orientation, relationship_status, religion, languages',
            )
            .limit(500);
      }

      for (final raw in List<Map<String, dynamic>>.from(profileRows)) {
        final row = Map<String, dynamic>.from(raw);
        final gender = row['gender']?.toString().trim() ?? '';
        final orientation = row['orientation']?.toString().trim() ?? '';
        final religion = row['religion']?.toString().trim() ?? '';
        final relationship =
            row['relationship_status']?.toString().trim() ?? '';

        if (gender.isNotEmpty) genders.add(gender);
        if (orientation.isNotEmpty) orientations.add(orientation);
        if (religion.isNotEmpty) religions.add(religion);
        if (relationship.isNotEmpty) relationships.add(relationship);

        languages.addAll(_asStringList(row['languages']));
        interests.addAll(_asStringList(row['interests']));
      }
    } catch (_) {
      // Keep fallback defaults below.
    }

    return <String, dynamic>{
      'genders': _withAnyPrefix(genders),
      'orientations': _withAnyPrefix(orientations),
      'religion': _withAnyPrefix(religions),
      'relationship_status': _withAnyPrefix(relationships),
      'languages': _dedupeOrdered(languages),
      'interests': _dedupeOrdered(interests),
      // No host rating table yet, keep a simple option list fetched by app.
      'host_ratings': const <String>['Any', 'Highly responsive', 'Responsive'],
    };
  }

  static Future<List<Nearby>> fetchActiveUsers({int limit = 8}) async {
    try {
      final meetupRowsRaw = await supabase
          .from('meetups')
          .select('id, user_id, type, address, status, created_at')
          .order('created_at', ascending: false)
          .limit(120);

      final meetupRows = List<Map<String, dynamic>>.from(meetupRowsRaw);
      final latestByUser = <String, Map<String, dynamic>>{};
      for (final raw in meetupRows) {
        final row = Map<String, dynamic>.from(raw);
        final userId = row['user_id']?.toString().trim() ?? '';
        if (userId.isEmpty) continue;
        if (!_isAvailableStatus(row['status']?.toString() ?? '')) continue;
        latestByUser.putIfAbsent(userId, () => row);
      }

      if (latestByUser.isEmpty) return const <Nearby>[];

      final userIds = latestByUser.keys.toList(growable: false);
      dynamic profileRowsRaw;
      try {
        profileRowsRaw = await supabase
            .from('profiles')
            .select('id, name, photo_url, location, interests, languages')
            .inFilter('id', userIds);
      } catch (_) {
        profileRowsRaw = await supabase
            .from('profiles')
            .select('id, name, photo_url, location')
            .inFilter('id', userIds);
      }

      final profileById = <String, Map<String, dynamic>>{};
      for (final raw in List<Map<String, dynamic>>.from(profileRowsRaw)) {
        final row = Map<String, dynamic>.from(raw);
        final id = row['id']?.toString().trim() ?? '';
        if (id.isEmpty) continue;
        profileById[id] = row;
      }

      final items = <Nearby>[];
      for (final userId in userIds) {
        final meetup = latestByUser[userId];
        if (meetup == null) continue;
        final profile = profileById[userId] ?? const <String, dynamic>{};

        final type = meetup['type']?.toString().trim().isNotEmpty == true
            ? meetup['type'].toString().trim()
            : 'Coffee';
        final name = profile['name']?.toString().trim().isNotEmpty == true
            ? profile['name'].toString().trim()
            : 'User';
        final profileLocation = profile['location']?.toString().trim() ?? '';
        final meetupAddress = meetup['address']?.toString().trim() ?? '';
        final locationShort = _approximateLocation(
            profileLocation.isNotEmpty ? profileLocation : meetupAddress);
        final photoUrl = profile['photo_url']?.toString().trim() ?? '';
        final createdAtText = meetup['created_at']?.toString() ?? '';
        final createdAt = DateTime.tryParse(createdAtText) ?? DateTime.now();

        items.add(
          Nearby(
            id: meetup['id']?.toString() ?? userId,
            title: 'Active user',
            hostName: name,
            time: createdAt,
            location: locationShort,
            distanceKm: 0,
            type: type,
            status: meetup['status']?.toString() ?? 'open',
            image: photoUrl.isNotEmpty ? photoUrl : 'assets/images/img9.jpg',
            description: '',
            icon: _iconForType(type),
            languages: _asStringList(profile['languages']),
            interests: _asStringList(profile['interests']),
            name: name,
            locationShort: locationShort,
            favMeetupType: type,
          ),
        );
      }

      return items.take(limit).toList(growable: false);
    } catch (_) {
      return const <Nearby>[];
    }
  }
}
