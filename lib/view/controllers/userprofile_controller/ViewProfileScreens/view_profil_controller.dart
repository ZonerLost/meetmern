import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/api_s.dart';
import 'package:meetmern/data/service/auth_service.dart';
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
  String photoUrl = '';
  List<String> languages = <String>[];
  List<String> passionTopics = <String>[];
  List<String> interests = <String>[];

  List<Meetup> allMeetups = <Meetup>[];
  bool loading = true;
  bool profileLoading = true;

  @override
  void onInit() {
    super.onInit();
    refreshProfile();
    loadMeetups();
  }

  Future<void> refreshProfile() async {
    profileLoading = true;
    update();
    await AuthService.loadProfile();
    _applyProfile();
    profileLoading = false;
    update();
  }

  void _applyProfile() {
    final profile = AuthService.currentProfile.value;
    if (profile != null) {
      profileName = profile.name?.isNotEmpty == true ? profile.name! : '';
      email = profile.email ?? '';
      bio = profile.shortBio ?? '';
      gender = profile.gender ?? '';
      relationship = profile.relationshipStatus ?? '';
      dob = profile.dob ?? '';
      children = profile.children == null ? '' : (profile.children! ? 'Yes' : 'No');
      religion = profile.religion ?? '';
      photoUrl = profile.photoUrl ?? '';
      languages = profile.languages ?? [];
      passionTopics = profile.passionTopics ?? [];
      interests = profile.interests ?? [];
    }
    update();
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
}
