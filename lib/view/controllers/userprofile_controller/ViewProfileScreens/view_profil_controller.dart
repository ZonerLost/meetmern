import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/api_s.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';

class ViewProfileController extends GetxController {
  final Strings strings = const Strings();

  String profileName = '';
  String email = '';
  String bio = '';
  String gender = '';
  String relationship = '';
  String dob = '';
  String children = '';
  String religion = '';
  List<String> languages = <String>[];
  String passionTopics = '';
  List<String> interests = <String>[];

  List<Meetup> allMeetups = <Meetup>[];
  bool loading = true;

  @override
  void onInit() {
    super.onInit();
    profileName = strings.initialProfileNameText;
    email = strings.initialProfileEmailText;
    bio = strings.initialProfileBioText;
    gender = strings.initialProfileGenderText;
    relationship = strings.initialProfileRelationshipText;
    dob = strings.initialProfileDobText;
    children = strings.initialProfileChildrenText;
    religion = strings.initialProfileReligionText;
    languages = List<String>.from(strings.initialProfileLanguages);
    passionTopics = strings.initialProfilePassionTopicsText;
    interests = OnboardingMockData.interests.take(6).toList();
    loadMeetups();
  }

  Future<void> loadMeetups() async {
    loading = true;
    update();
    try {
      allMeetups = await MockApi.fetchMeetups();
    } finally {
      loading = false;
      update();
    }
  }

  List<Meetup> get visibleMeetups {
    final hostMeetups = allMeetups
        .where((m) => m.hostName.toLowerCase().trim() == profileName.toLowerCase().trim())
        .toList();
    return hostMeetups.isNotEmpty ? hostMeetups : allMeetups;
  }

  void toggleFavorite(String id) {
    final idx = allMeetups.indexWhere((m) => m.id == id);
    if (idx < 0) return;
    allMeetups[idx].isFavorite = !allMeetups[idx].isFavorite;
    update();
  }

  void removeMeetupById(String id) {
    allMeetups.removeWhere((m) => m.id == id);
    update();
  }

  void applyProfileEditResult(Map<String, dynamic> result) {
    profileName = result['name']?.toString() ?? profileName;
    email = result['email']?.toString() ?? email;
    bio = result['bio']?.toString() ?? bio;
    dob = result['dob']?.toString() ?? dob;
    gender = result['gender']?.toString() ?? gender;
    relationship = result['relationship']?.toString() ?? relationship;
    children = result['children']?.toString() ?? children;
    passionTopics = result['passionTopics']?.toString() ?? passionTopics;

    final langs = result['languages'];
    if (langs is List<String>) { languages = langs; }
    else if (langs is List<dynamic>) { languages = langs.map((e) => e.toString()).toList(); }

    final ints = result['interests'];
    if (ints is List<String>) { interests = ints; }
    else if (ints is List<dynamic>) { interests = ints.map((e) => e.toString()).toList(); }

    update();
  }
}
