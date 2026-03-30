class OnboardingMockData {
  static const genders = [
    "Any",
    "Male",
    "Female",
    "Non-binary",
    "Prefer not to say"
  ];
  static const orientations = [
    "Any",
    "Straight",
    "Gay",
    "Lesbian",
    "Bisexual",
    "Transgender",
    "Queer",
    "Other"
  ];
  static const ethnicities = [
    "Asian",
    "Black",
    "Hispanic",
    "White",
    "Middle Eastern",
    "Other"
  ];
  static const languages = [
    "English",
    "Spanish",
    "French",
    "German",
    "Arabic",
    "Urdu",
    "Portuguese"
  ];
  static const children = ["No", "Yes", "Prefer not to say"];
  static const relationshipStatus = [
    "Any",
    "Single",
    "In a relationship",
    "Divorced",
    "Widowed",
    "Married"
  ];
  static const religion = [
    "Any",
    "Christian",
    "Muslim",
    "Jewish",
    "Hindu",
    "Other",
    "None"
  ];
  static const interests = [
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
  static const passionTopics = [
    "Self Development",
    "Investing",
    "Technology",
    "Politics",
    "Mindfulness",
    "Education",
    "Nature",
    "History"
  ];
  static const dietaryPreferences = [
    "Halal",
    "Vegetarian",
    "Vegan",
    "Kosher",
    "No preference"
  ];

  static const hostRatings = [
    "Any",
    "Highly responsive",
    "Responsive",
    "Not responsive"
  ];

  static const reportReason = [
    "Harrassment or abuse",
    "Spam or irrelevant",
    "other",
  ];
  static const Map<String, dynamic> filterOptions = {
    'genders': genders,
    'orientations': orientations,
    'ethnicities': ethnicities,
    'languages': languages,
    'relationship_status': relationshipStatus,
    'religion': religion,
    'interests': interests,
    'passion_topics': passionTopics,
    'Dietarypreferences': dietaryPreferences,
    'host_ratings': hostRatings,
  };
}
