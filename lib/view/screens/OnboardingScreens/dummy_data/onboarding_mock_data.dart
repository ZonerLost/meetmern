class OnboardingMockData {
  static const List<String> _defaultGenders = [
    "Any",
    "Male",
    "Female",
    "Non-binary",
    "Prefer not to say"
  ];
  static const List<String> _defaultOrientations = [
    "Any",
    "Straight",
    "Gay",
    "Lesbian",
    "Bisexual",
    "Transgender",
    "Queer",
    "Other"
  ];
  static const List<String> _defaultEthnicities = [
    "Asian",
    "Black",
    "Hispanic",
    "White",
    "Middle Eastern",
    "Other"
  ];
  static const List<String> _defaultLanguages = [
    "English",
    "Spanish",
    "French",
    "German",
    "Arabic",
    "Urdu",
    "Portuguese"
  ];
  static const List<String> _defaultChildren = [
    "No",
    "Yes",
    "Prefer not to say"
  ];
  static const List<String> _defaultRelationshipStatus = [
    "Any",
    "Single",
    "In a relationship",
    "Divorced",
    "Widowed",
    "Married"
  ];
  static const List<String> _defaultReligion = [
    "Any",
    "Christian",
    "Muslim",
    "Jewish",
    "Hindu",
    "Other",
    "None"
  ];
  static const List<String> _defaultInterests = [
    "Cooking",
    "Foodie",
    "Gaming",
    "Travel",
    "Fitness",
    "Music",
    "Art",
    "Reading",
    "Photography",
    "Movies",
    "Board Games",
    "Meditation",
    "Football",
    "Coding",
    "Climbing",
    "Watching Sport"
  ];
  static const List<String> _defaultPassionTopics = [
    "Self Development",
    "Investing",
    "Technology",
    "Politics",
    "Mindfulness",
    "Education",
    "Nature",
    "History"
  ];
  static const List<String> _defaultDietaryPreferences = [
    "Halal",
    "Vegetarian",
    "Vegan",
    "Kosher",
    "No preference"
  ];

  static const List<String> _defaultHostRatings = [
    "Any",
    "Highly responsive",
    "Responsive",
    "Not responsive"
  ];

  static const List<String> _defaultReportReason = [
    "Harrassment or abuse",
    "Spam or irrelevant",
    "other",
  ];

  static final Map<String, List<String>> _runtimeByTraitKey =
      <String, List<String>>{};

  static List<String> _valuesFor(String traitKey, List<String> fallback) {
    final runtime = _runtimeByTraitKey[traitKey];
    if (runtime == null || runtime.isEmpty) return List<String>.from(fallback);
    return List<String>.from(runtime);
  }

  static void applyRuntimeTraitOptions(
      Map<String, List<String>> valuesByTrait) {
    _runtimeByTraitKey.clear();
    valuesByTrait.forEach((key, values) {
      final cleaned = <String>[];
      final seen = <String>{};
      for (final value in values) {
        final v = value.trim();
        if (v.isEmpty) continue;
        final k = v.toLowerCase();
        if (!seen.add(k)) continue;
        cleaned.add(v);
      }
      if (cleaned.isNotEmpty) {
        _runtimeByTraitKey[key] = cleaned;
      }
    });
  }

  static List<String> get genders => _valuesFor('gender', _defaultGenders);
  static List<String> get orientations =>
      _valuesFor('orientation', _defaultOrientations);
  static List<String> get ethnicities =>
      _valuesFor('ethnicity', _defaultEthnicities);
  static List<String> get languages =>
      _valuesFor('languages', _defaultLanguages);
  static List<String> get children => _valuesFor('children', _defaultChildren);
  static List<String> get relationshipStatus =>
      _valuesFor('relationship_status', _defaultRelationshipStatus);
  static List<String> get religion => _valuesFor('religion', _defaultReligion);
  static List<String> get interests =>
      _valuesFor('interests', _defaultInterests);
  static List<String> get passionTopics =>
      _valuesFor('passion_topics', _defaultPassionTopics);
  static List<String> get dietaryPreferences =>
      _valuesFor('dietary_preferences', _defaultDietaryPreferences);
  static List<String> get hostRatings =>
      _valuesFor('host_ratings', _defaultHostRatings);
  static List<String> get reportReason =>
      _valuesFor('report_reason', _defaultReportReason);

  static Map<String, dynamic> get filterOptions => <String, dynamic>{
        'genders': genders,
        'orientations': orientations,
        'ethnicities': ethnicities,
        'languages': languages,
        'relationship_status': relationshipStatus,
        'religion': religion,
        'interests': interests,
        'passion_topics': passionTopics,
        'Dietarypreferences': dietaryPreferences,
        'dietary_preferences': dietaryPreferences,
        'host_ratings': hostRatings,
      };
}
