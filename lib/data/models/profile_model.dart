class ProfileModel {
  final String id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? dob;
  final String? gender;
  final String? ethnicity;
  final String? orientation;
  final List<String>? languages;
  final String? photoUrl;
  final bool? children;
  final String? relationshipStatus;
  final List<String>? dietaryPreferences;
  final String? religion;
  final String? shortBio;
  final List<String>? interests;
  final List<String>? passionTopics;
  final List<String>? photos;
  final String? location;
  final String? discoveryRadius;

  /// Sane product default used whenever no valid discovery radius has been
  /// set yet — e.g. a fresh profile before the user ever visits Location
  /// settings. Every screen/filter should read [discoveryRadiusKm] rather
  /// than parsing [discoveryRadius] itself, so they all agree on this.
  static const double defaultDiscoveryRadiusKm = 10.0;

  /// Anything above this is treated as bogus/unset rather than trusted as a
  /// real radius. Guards against a raw placeholder value from a fresh
  /// profile row (observed as ~1,000,000 km) leaking straight into the UI
  /// and into nearby/active-user filtering as an effectively unlimited
  /// distance.
  static const double _maxReasonableDiscoveryRadiusKm = 500.0;

  /// [discoveryRadius] parsed to km, clamped to [defaultDiscoveryRadiusKm]
  /// whenever it's missing, non-positive, unparsable, or absurdly large.
  double get discoveryRadiusKm {
    final raw = discoveryRadius?.trim() ?? '';
    if (raw.isEmpty) return defaultDiscoveryRadiusKm;
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(raw);
    final parsed = match != null ? double.tryParse(match.group(0)!) : null;
    if (parsed == null ||
        parsed <= 0 ||
        parsed > _maxReasonableDiscoveryRadiusKm) {
      return defaultDiscoveryRadiusKm;
    }
    return parsed;
  }

  final bool showOnboarding;
  final int reportCount;
  final bool isDisabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.dob,
    this.gender,
    this.ethnicity,
    this.orientation,
    this.languages,
    this.photoUrl,
    this.children,
    this.relationshipStatus,
    this.dietaryPreferences,
    this.religion,
    this.shortBio,
    this.interests,
    this.passionTopics,
    this.photos,
    this.location,
    this.discoveryRadius,
    this.showOnboarding = true,
    this.reportCount = 0,
    this.isDisabled = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      ethnicity: json['ethnicity'] as String?,
      orientation: json['orientation'] as String?,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      photoUrl: json['photo_url'] as String?,
      children: json['children'] as bool?,
      relationshipStatus: json['relationship_status'] as String?,
      dietaryPreferences: (json['dietary_preferences'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      religion: json['religion'] as String?,
      shortBio: json['short_bio'] as String?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      passionTopics: (json['passion_topics'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      location: json['location'] as String?,
      discoveryRadius: (json['discovery_radius'] ??
              json['radius'] ??
              json['radius_km'] ??
              json['search_radius'])
          as String?,
      showOnboarding: json['show_onboarding'] as bool? ?? true,
      reportCount: (json['report_count'] as num?)?.toInt() ?? 0,
      isDisabled: json['is_disabled'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (dob != null) 'dob': dob,
      if (gender != null) 'gender': gender,
      if (ethnicity != null) 'ethnicity': ethnicity,
      if (orientation != null) 'orientation': orientation,
      if (languages != null && languages!.isNotEmpty) 'languages': languages,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (children != null) 'children': children,
      if (relationshipStatus != null) 'relationship_status': relationshipStatus,
      if (dietaryPreferences != null && dietaryPreferences!.isNotEmpty)
        'dietary_preferences': dietaryPreferences,
      if (religion != null) 'religion': religion,
      if (shortBio != null) 'short_bio': shortBio,
      if (interests != null && interests!.isNotEmpty) 'interests': interests,
      if (passionTopics != null && passionTopics!.isNotEmpty)
        'passion_topics': passionTopics,
      if (photos != null && photos!.isNotEmpty) 'photos': photos,
      if (location != null) 'location': location,
      if (discoveryRadius != null) 'discovery_radius': discoveryRadius,
      'show_onboarding': showOnboarding,
      if (reportCount > 0) 'report_count': reportCount,
      if (isDisabled) 'is_disabled': isDisabled,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
