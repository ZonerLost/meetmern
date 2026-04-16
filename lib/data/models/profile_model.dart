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
  final String? location;
  final bool showOnboarding;
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
    this.location,
    this.showOnboarding = true,
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
      languages: (json['languages'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      photoUrl: json['photo_url'] as String?,
      children: json['children'] as bool?,
      relationshipStatus: json['relationship_status'] as String?,
      dietaryPreferences: (json['dietary_preferences'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      religion: json['religion'] as String?,
      shortBio: json['short_bio'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      passionTopics: (json['passion_topics'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      location: json['location'] as String?,
      showOnboarding: json['show_onboarding'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
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
      if (dietaryPreferences != null && dietaryPreferences!.isNotEmpty) 'dietary_preferences': dietaryPreferences,
      if (religion != null) 'religion': religion,
      if (shortBio != null) 'short_bio': shortBio,
      if (interests != null && interests!.isNotEmpty) 'interests': interests,
      if (passionTopics != null && passionTopics!.isNotEmpty) 'passion_topics': passionTopics,
      if (location != null) 'location': location,
      'show_onboarding': showOnboarding,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
