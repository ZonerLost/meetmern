import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_model.dart';

class OnboardingScreensOnboardingScreenOnboardingScreenController
    extends GetxController {
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

  File? pickedImage;

  final Map<String, dynamic> options = <String, dynamic>{
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
  };

  bool showErrors = false;
  int currentPage = 0;
  static const int pages = 6;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      pickedImage = File(file.path);
      update();
    }
  }

  void removeImage() {
    pickedImage = null;
    update();
  }

  bool isValidForPage(int page) {
    if (page == 0) {
      final dobOk = dobController.text.trim().isNotEmpty;
      final genderOk = selectedGender != null;
      final ethnicityOk = selectedEthnicity != null;
      final orientationOk = selectedOrientation != null;
      return dobOk && genderOk && ethnicityOk && orientationOk;
    }

    if (page == 1) return true;

    if (page == 2) {
      final relationshipOk = selectedRelationship != null;
      final childrenOk = selectedChildren != null;
      return relationshipOk && childrenOk;
    }

    if (page == 3) {
      return selectedInterests.isNotEmpty || selectedPassions.isNotEmpty;
    }

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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    showErrors = false;
    update();
  }

  void onNextPressed() {
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
    } else if (currentPage == 1) {
      model.photoPath = pickedImage?.path;
    } else if (currentPage == 2) {
      model.bio = bioController.text;
      model.children = selectedChildren;
      model.relationshipStatus = selectedRelationship;
      model.dietaryPreferences = selectedDietary;
      model.religion = selectedReligion;
    } else if (currentPage == 3) {
      model.interests = selectedInterests.toList();
      model.passionTopics = selectedPassions.toList();
    }

    if (currentPage < pages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    update();
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
