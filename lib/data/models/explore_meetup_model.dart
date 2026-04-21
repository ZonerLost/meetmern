import 'package:flutter/foundation.dart';

class Meetup {
  final String id;
  final String title;
  final String hostName;
  final DateTime time;
  final String location;
  final double distanceKm;
  final String type;
  final String status;
  final String icon;
  final String image;
  final String description;
  final List<String> languages;
  final List<String> interests;
  final String? ownerGender;
  final String? ownerOrientation;
  final String? ownerReligion;
  final String? ownerRelationshipStatus;
  final String? ownerDob;
  bool isFavorite;
  bool joinRequested;
  // Supabase user_id of the meetup owner (null for mock/local data)
  final String? userId;

  final List<Nearby>? nearby;

  Meetup({
    required this.id,
    required this.title,
    required this.hostName,
    required this.time,
    required this.location,
    required this.distanceKm,
    required this.type,
    required this.status,
    required this.image,
    required this.description,
    required this.icon,
    required this.languages,
    required this.interests,
    this.ownerGender,
    this.ownerOrientation,
    this.ownerReligion,
    this.ownerRelationshipStatus,
    this.ownerDob,
    this.isFavorite = false,
    this.joinRequested = false,
    this.userId,
    this.nearby,
  });

  factory Meetup.fromJson(Map<String, dynamic> j) => Meetup(
        id: j['id']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        hostName: j['hostName']?.toString() ?? '',
        time: j['time'] != null ? DateTime.parse(j['time']) : DateTime.now(),
        location: j['location']?.toString() ?? '',
        distanceKm: (j['distanceKm'] as num?)?.toDouble() ?? 0.0,
        type: j['type']?.toString() ?? '',
        status: j['status']?.toString() ?? '',
        image: j['image']?.toString() ?? '',
        icon: j['icon']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        languages: List<String>.from(j['languages'] ?? []),
        interests: List<String>.from(j['interests'] ?? []),
        ownerGender: j['ownerGender']?.toString() ??
            j['owner_gender']?.toString(),
        ownerOrientation: j['ownerOrientation']?.toString() ??
            j['owner_orientation']?.toString(),
        ownerReligion: j['ownerReligion']?.toString() ??
            j['owner_religion']?.toString(),
        ownerRelationshipStatus: j['ownerRelationshipStatus']?.toString() ??
            j['owner_relationship_status']?.toString(),
        ownerDob: j['ownerDob']?.toString() ?? j['owner_dob']?.toString(),
        isFavorite: j['isFavorite'] ?? false,
        joinRequested: j['joinRequested'] ?? false,
        userId: j['userId']?.toString() ?? j['user_id']?.toString(),
        nearby: j['nearby'] != null
            ? (j['nearby'] as List)
                .map((e) => Nearby.fromMap(Map<String, dynamic>.from(e)))
                .toList()
            : null,
      );

  /// Build a Meetup from a Supabase `meetups` row (already profile-joined).
  factory Meetup.fromSupabase(Map<String, dynamic> row) {
    final type = row['type']?.toString() ?? 'Coffee';
    final owner = row['owner_profile'] is Map
        ? Map<String, dynamic>.from(row['owner_profile'] as Map)
        : const <String, dynamic>{};
    final profilePicUrl = row['profile_pic_url']?.toString();
    final ownerPhotoUrl = owner['photo_url']?.toString();
    final ownerName = owner['name']?.toString();
    final ownerLanguages =
        (owner['languages'] as List?)?.map((e) => e.toString()).toList() ??
            const <String>[];
    final ownerInterests =
        (owner['interests'] as List?)?.map((e) => e.toString()).toList() ??
            const <String>[];
    debugPrint(
        '[Meetup.fromSupabase] id=${row['id']} user_id=${row['user_id']} host_name=${row['host_name']} profile_pic_url=$profilePicUrl type=$type');
    return Meetup(
      id: row['id']?.toString() ?? '',
      userId: row['user_id']?.toString(),
      title: 'Meet me for $type',
      hostName: (ownerName != null && ownerName.trim().isNotEmpty)
          ? ownerName
          : (row['host_name']?.toString() ?? ''),
      time: _parseDateTime(row),
      location: row['address']?.toString() ?? '',
      distanceKm: 0.0,
      type: type,
      status: row['status']?.toString() ?? 'open',
      image: (ownerPhotoUrl != null && ownerPhotoUrl.isNotEmpty)
          ? ownerPhotoUrl
          : (profilePicUrl != null && profilePicUrl.isNotEmpty)
              ? profilePicUrl
          : 'assets/images/img9.jpg',
      icon: _iconForType(type),
      description: '',
      languages: ownerLanguages,
      interests: ownerInterests,
      ownerGender: owner['gender']?.toString(),
      ownerOrientation: owner['orientation']?.toString(),
      ownerReligion: owner['religion']?.toString(),
      ownerRelationshipStatus: owner['relationship_status']?.toString(),
      ownerDob: owner['dob']?.toString(),
      isFavorite: false,
      joinRequested: false,
    );
  }

  static DateTime _parseDateTime(Map<String, dynamic> row) {
    final dateStr = row['date']?.toString() ?? row['meetup_date']?.toString();
    final timeStr = row['time']?.toString() ?? row['meetup_time']?.toString();
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    try {
      final combined = timeStr != null && timeStr.isNotEmpty
          ? '${dateStr}T$timeStr'
          : dateStr;
      return DateTime.tryParse(combined) ?? DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'hostName': hostName,
        'time': time.toIso8601String(),
        'location': location,
        'distanceKm': distanceKm,
        'type': type,
        'status': status,
        'image': image,
        'icon': icon,
        'description': description,
        'languages': languages,
        'interests': interests,
        if (ownerGender != null) 'ownerGender': ownerGender,
        if (ownerOrientation != null) 'ownerOrientation': ownerOrientation,
        if (ownerReligion != null) 'ownerReligion': ownerReligion,
        if (ownerRelationshipStatus != null)
          'ownerRelationshipStatus': ownerRelationshipStatus,
        if (ownerDob != null) 'ownerDob': ownerDob,
        'isFavorite': isFavorite,
        'joinRequested': joinRequested,
        if (userId != null) 'userId': userId,
        if (nearby != null) 'nearby': nearby!.map((n) => n.toMap()).toList(),
      };
}

class Nearby extends Meetup {
  final String name;
  final String? locationShort;
  final String? favMeetupType;

  Nearby({
    required super.id,
    required super.title,
    required super.hostName,
    required super.time,
    required super.location,
    required super.distanceKm,
    required super.type,
    required super.status,
    required super.image,
    required super.description,
    required super.icon,
    required super.languages,
    required super.interests,
    super.isFavorite,
    super.joinRequested,
    super.nearby,
    // nearby-specific:
    required this.name,
    this.locationShort,
    this.favMeetupType,
  });

  factory Nearby.fromMap(Map<String, dynamic> m) {
    final id = m['id']?.toString() ?? '';
    final name = m['name']?.toString() ?? m['hostName']?.toString() ?? '';
    final favMeetupType = m['favMeetupType']?.toString();
    final locationShort = m['locationShort']?.toString();

    final title = m['title']?.toString() ?? favMeetupType ?? name;
    final hostName = m['hostName']?.toString() ?? name;

    final image = m['image']?.toString() ?? '';
    final icon = m['icon']?.toString() ?? '';
    final description = m['description']?.toString() ?? '';

    final time = m['time'] != null
        ? DateTime.tryParse(m['time'].toString()) ?? DateTime.now()
        : null;

    final location =
        m['location']?.toString() ?? m['locationShort']?.toString() ?? '';
    final distanceKm = (m['distanceKm'] as num?)?.toDouble() ?? 0.0;
    final type = m['type']?.toString() ?? favMeetupType ?? '';
    final status = m['status']?.toString() ?? '';
    final isFavorite = m['isFavorite'] as bool? ?? false;

    final languages =
        m['languages'] != null ? List<String>.from(m['languages']) : <String>[];
    final interests =
        m['interests'] != null ? List<String>.from(m['interests']) : <String>[];

    return Nearby(
      id: id,
      title: title,
      hostName: hostName,
      time: time ?? DateTime.now(),
      location: location,
      distanceKm: distanceKm,
      type: type,
      status: status,
      image: image,
      description: description,
      icon: icon,
      languages: languages,
      interests: interests,
      isFavorite: isFavorite,
      joinRequested: m['joinRequested'] as bool? ?? false,
      name: name,
      locationShort: locationShort,
      favMeetupType: favMeetupType,
    );
  }

  Map<String, dynamic> toMap() {
    final base = super.toJson();
    base.remove('nearby');
    base.addAll({
      'name': name,
      if (locationShort != null) 'locationShort': locationShort,
      if (favMeetupType != null) 'favMeetupType': favMeetupType,
    });
    return base;
  }
}
