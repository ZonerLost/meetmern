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
  bool isFavorite;
  bool joinRequested;

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
    this.isFavorite = false,
    this.joinRequested = false,
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
        isFavorite: j['isFavorite'] ?? false,
        joinRequested: j['joinRequested'] ?? false,
        nearby: j['nearby'] != null
            ? (j['nearby'] as List)
                .map((e) => Nearby.fromMap(Map<String, dynamic>.from(e)))
                .toList()
            : null,
      );

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
        'isFavorite': isFavorite,
        'joinRequested': joinRequested,
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

    final title = m['title']?.toString() ?? favMeetupType ?? name ?? '';
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
