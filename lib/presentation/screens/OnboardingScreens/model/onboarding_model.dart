class OnboardingModel {
  String? dob;
  String? gender;
  String? orientation;
  String? ethnicity;

  List<String> languages = [];

  String? photoPath;
  String? bio;

  String? children;
  String? relationshipStatus;
  String? religion;

  List<String> dietaryPreferences = [];

  List<String> interests = [];
  List<String> passionTopics = [];

  bool locationEnabled = false;

  Map<String, dynamic> toJson() => {
        'dob': dob,
        'gender': gender,
        'orientation': orientation,
        'ethnicity': ethnicity,
        'languages': languages,
        'photoPath': photoPath,
        'bio': bio,
        'children': children,
        'relationshipStatus': relationshipStatus,
        'religion': religion,
        'dietaryPreferences': dietaryPreferences,
        'interests': interests,
        'passionTopics': passionTopics,
        'locationEnabled': locationEnabled,
      };
}
