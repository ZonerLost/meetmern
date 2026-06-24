import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/profile_service.dart';
import 'package:meetmern/data/service/storage_service.dart';
import 'package:meetmern/data/service/user_traits_service.dart';
import 'package:meetmern/view/screens/onboardingscreens/dummy_data/onboarding_mock_data.dart';
import 'package:meetmern/view/screens/onboardingscreens/dummy_data/onboarding_model.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final OnboardingModel model = OnboardingModel();

  final TextEditingController dobController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String? selectedGender;
  String? selectedOrientation;
  String? selectedEthnicity;
  String? selectedChildren;
  String? selectedRelationship;
  String? selectedReligion;

  List<String> selectedLanguages = <String>[];
  List<String> selectedDietary = <String>[];

  final Set<String> selectedInterests = <String>{};
  final Set<String> selectedPassions = <String>{};

  List<File> pickedImages = <File>[];
  List<String> existingPhotoUrls = <String>[];
  String? locationCoords;

  final Map<String, dynamic> options = <String, dynamic>{};

  bool showErrors = false;
  int currentPage = 0;
  static const int pages = 6;

  @override
  void onInit() {
    super.onInit();
    _syncOptions();
    _loadTraitOptions();
    loadExistingProfile();
  }

  void _syncOptions() {
    options
      ..clear()
      ..addAll(<String, dynamic>{
        'gender': OnboardingMockData.genders,
        'orientation': OnboardingMockData.orientations,
        'ethnicity': OnboardingMockData.ethnicities,
        'languages': OnboardingMockData.languages,
        'children': OnboardingMockData.children,
        'relationship_status': OnboardingMockData.relationshipStatus,
        'religion': OnboardingMockData.religion,
        'interests': OnboardingMockData.interests,
        'passion_topics': OnboardingMockData.passionTopics,
        'Dietarypreferences': OnboardingMockData.dietaryPreferences,
        'dietary_preferences': OnboardingMockData.dietaryPreferences,
      });
  }

  Future<void> _loadTraitOptions() async {
    final traits = await UserTraitsService.fetchTraitOptions();
    if (traits.isEmpty) return;
    OnboardingMockData.applyRuntimeTraitOptions(traits);
    _syncOptions();
    update();
  }

  Future<void> loadExistingProfile() async {
    final profile = AuthService.currentProfile.value;
    if (profile == null) return;

    dobController.text = profile.dob ?? '';
    bioController.text = profile.shortBio ?? '';
    selectedGender = profile.gender;
    selectedOrientation = profile.orientation;
    selectedEthnicity = profile.ethnicity;
    selectedChildren =
        profile.children != null ? (profile.children! ? 'Yes' : 'No') : null;
    selectedRelationship = profile.relationshipStatus;
    selectedReligion = profile.religion;
    selectedLanguages = profile.languages ?? [];
    selectedDietary = profile.dietaryPreferences ?? [];
    if (profile.interests != null) selectedInterests.addAll(profile.interests!);
    if (profile.passionTopics != null)
      selectedPassions.addAll(profile.passionTopics!);
    locationCoords = profile.location;
    existingPhotoUrls = profile.photos ??
        (profile.photoUrl?.isNotEmpty == true ? [profile.photoUrl!] : []);
    update();
  }

  void addImage(File file) {
    pickedImages.add(file);
    update();
  }

  void removeImage(int index) {
    if (index >= 0 && index < pickedImages.length) {
      pickedImages.removeAt(index);
      update();
    }
  }

  bool isValidForPage(int page) {
    if (page == 0) {
      final dob = dobController.text.trim();
      if (dob.isEmpty) return false;
      final dt = DateTime.tryParse(dob);
      if (dt == null) return false;
      final minAge = DateTime(
        DateTime.now().year - 13,
        DateTime.now().month,
        DateTime.now().day,
      );
      if (dt.isAfter(minAge)) return false;
      return selectedGender != null &&
          selectedEthnicity != null &&
          selectedOrientation != null;
    }
    if (page == 1) return true;
    if (page == 2)
      return selectedRelationship != null && selectedChildren != null;
    if (page == 3)
      return selectedInterests.isNotEmpty && selectedPassions.isNotEmpty;
    return true;
  }

  void setCurrentPage(int index) {
    currentPage = index;
    showErrors = false;
    update();
  }

  void enableErrors() {
    showErrors = true;
    update();
  }

  void onBack() {
    if (currentPage == 0) return;
    pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    showErrors = false;
    update();
  }

  Future<void> onNextPressed() async {
    showErrors = true;
    if (!isValidForPage(currentPage)) {
      update();
      return;
    }

    if (currentPage == 0) {
      model.dob = dobController.text;
      model.gender = selectedGender;
      model.ethnicity = selectedEthnicity;
      model.orientation = selectedOrientation;
      model.languages = selectedLanguages;
      await saveProfileData();
    } else if (currentPage == 1) {
      model.photoPath = pickedImages.isNotEmpty ? pickedImages.first.path : null;
      await uploadImageIfNeeded();
    } else if (currentPage == 2) {
      model.bio = bioController.text;
      model.children = selectedChildren;
      model.relationshipStatus = selectedRelationship;
      model.dietaryPreferences = selectedDietary;
      model.religion = selectedReligion;
      await saveProfileData();
    } else if (currentPage == 3) {
      model.interests = selectedInterests.toList();
      model.passionTopics = selectedPassions.toList();
      await saveProfileData();
    }

    if (currentPage < pages - 1) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
    update();
  }

  Future<void> uploadImageIfNeeded() async {
    final user = AuthService.currentUser;
    if (user == null || pickedImages.isEmpty) return;

    try {
      final startIndex = existingPhotoUrls.length;
      final newUrls = <String>[];

      for (int i = 0; i < pickedImages.length; i++) {
        final url = await StorageService.uploadProfilePhotoAtIndex(
            user.id, pickedImages[i], startIndex + i);
        if (url != null) newUrls.add(url);
      }

      if (newUrls.isNotEmpty) {
        final allPhotos = [...existingPhotoUrls, ...newUrls];

        // Always save photo_url first (guaranteed column), then photos array.
        await ProfileService.updateProfile(user.id, {
          'photo_url': allPhotos.first,
        });
        try {
          await ProfileService.updateProfile(user.id, {
            'photos': allPhotos,
          });
        } catch (e) {
          debugPrint(
              'OnboardingController: photos column may not exist yet — run: ALTER TABLE profiles ADD COLUMN IF NOT EXISTS photos text[] DEFAULT \'{}\'; Error: $e');
        }

        existingPhotoUrls = allPhotos;
        pickedImages.clear();
      }
    } catch (e) {
      print('OnboardingController: Error uploading images: $e');
    }
  }

  Future<void> saveProfileData() async {
    final user = AuthService.currentUser;
    if (user == null) {
      print('OnboardingController: No authenticated user found');
      return;
    }

    try {
      print('OnboardingController: Saving profile data for user: ${user.id}');
      final updates = <String, dynamic>{};

      if (dobController.text.isNotEmpty) {
        updates['dob'] = dobController.text;
        print('OnboardingController: Adding dob: ${dobController.text}');
      }
      if (selectedGender != null) {
        updates['gender'] = selectedGender;
        print('OnboardingController: Adding gender: $selectedGender');
      }
      if (selectedEthnicity != null) {
        updates['ethnicity'] = selectedEthnicity;
        print('OnboardingController: Adding ethnicity: $selectedEthnicity');
      }
      if (selectedOrientation != null) {
        updates['orientation'] = selectedOrientation;
        print('OnboardingController: Adding orientation: $selectedOrientation');
      }
      if (selectedLanguages.isNotEmpty) {
        updates['languages'] = selectedLanguages;
        print('OnboardingController: Adding languages: $selectedLanguages');
      }
      if (bioController.text.isNotEmpty) {
        updates['short_bio'] = bioController.text;
        print('OnboardingController: Adding bio: ${bioController.text}');
      }
      if (selectedChildren != null) {
        updates['children'] = selectedChildren == 'Yes';
        print(
            'OnboardingController: Adding children: ${selectedChildren == "Yes"}');
      }
      if (selectedRelationship != null) {
        updates['relationship_status'] = selectedRelationship;
        print(
            'OnboardingController: Adding relationship: $selectedRelationship');
      }
      if (selectedDietary.isNotEmpty) {
        updates['dietary_preferences'] = selectedDietary;
        print('OnboardingController: Adding dietary: $selectedDietary');
      }
      if (selectedReligion != null) {
        updates['religion'] = selectedReligion;
        print('OnboardingController: Adding religion: $selectedReligion');
      }
      if (selectedInterests.isNotEmpty) {
        updates['interests'] = selectedInterests.toList();
        print(
            'OnboardingController: Adding interests: ${selectedInterests.toList()}');
      }
      if (selectedPassions.isNotEmpty) {
        updates['passion_topics'] = selectedPassions.toList();
        print(
            'OnboardingController: Adding passions: ${selectedPassions.toList()}');
      }

      if (updates.isNotEmpty) {
        print(
            'OnboardingController: Calling ProfileService.updateProfile with ${updates.length} fields');
        await ProfileService.updateProfile(user.id, updates);
        print('OnboardingController: Profile data saved successfully');
      } else {
        print('OnboardingController: No updates to save');
      }
    } catch (e) {
      print('OnboardingController: Error saving profile data: $e');
    }
  }

  void setGender(String? value) {
    selectedGender = value;
    update();
  }

  void setOrientation(String? value) {
    selectedOrientation = value;
    update();
  }

  void setEthnicity(String? value) {
    selectedEthnicity = value;
    update();
  }

  void setChildren(String? value) {
    selectedChildren = value;
    update();
  }

  void setRelationship(String? value) {
    selectedRelationship = value;
    update();
  }

  void setReligion(String? value) {
    selectedReligion = value;
    update();
  }

  void setLanguages(List<String> values) {
    selectedLanguages = values;
    update();
  }

  void setDietary(List<String> values) {
    selectedDietary = values;
    update();
  }

  void setLocation(String coords) {
    locationCoords = coords;
    update();
  }

  void toggleInterest(String interest, bool selected) {
    if (selected) {
      selectedInterests.add(interest);
    } else {
      selectedInterests.remove(interest);
    }
    update();
  }

  void togglePassion(String passion, bool selected) {
    if (selected) {
      selectedPassions.add(passion);
    } else {
      selectedPassions.remove(passion);
    }
    update();
  }

  @override
  void onClose() {
    pageController.dispose();
    dobController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
