import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';

class UserProfileScreensAccountPrefrencesAccountPrefrencesController
    extends GetxController {
  final Set<String> interests = <String>{};
  final Set<String> passions = <String>{};
  List<String> dietary = <String>[];

  String? relationship;
  String? children;
  String? religion;

  final TextEditingController shortBioController = TextEditingController();

  String keyOf(String value) => value.trim();

  @override
  void onInit() {
    super.onInit();
    initializeDefaults();
  }

  void initializeDefaults() {
    interests
      ..clear()
      ..addAll(OnboardingMockData.interests.take(2).map(keyOf));

    passions
      ..clear()
      ..addAll(OnboardingMockData.passionTopics.take(2).map(keyOf));

    dietary = OnboardingMockData.dietaryPreferences.take(1).toList();

    relationship = OnboardingMockData.relationshipStatus.isNotEmpty
        ? OnboardingMockData.relationshipStatus.first
        : null;

    children = OnboardingMockData.children.isNotEmpty
        ? OnboardingMockData.children.first
        : null;

    religion = OnboardingMockData.religion.isNotEmpty
        ? OnboardingMockData.religion.first
        : null;

    shortBioController.text =
        'I like meaningful meetups, long walks, and great coffee talks.';

    update();
  }

  bool get canSave {
    return interests.isNotEmpty ||
        passions.isNotEmpty ||
        dietary.isNotEmpty ||
        relationship != null ||
        children != null ||
        religion != null ||
        shortBioController.text.trim().isNotEmpty;
  }

  void toggleInterest(String value) {
    final key = keyOf(value);
    if (interests.contains(key)) {
      interests.remove(key);
    } else {
      interests.add(key);
    }
    update();
  }

  void togglePassion(String value) {
    final key = keyOf(value);
    if (passions.contains(key)) {
      passions.remove(key);
    } else {
      passions.add(key);
    }
    update();
  }

  void setDietary(List<String> values) {
    dietary = values;
    update();
  }

  void setRelationship(String? value) {
    relationship = value;
    update();
  }

  void setChildren(String? value) {
    children = value;
    update();
  }

  void setReligion(String? value) {
    religion = value;
    update();
  }

  void onBioChanged(String _) => update();

  void clearReligion() {
    religion = null;
    update();
  }

  void clearDietary() {
    dietary = <String>[];
    update();
  }

  void clearBio() {
    shortBioController.clear();
    update();
  }

  void resetAllFields() {
    interests.clear();
    passions.clear();
    dietary = <String>[];
    relationship = null;
    children = null;
    religion = null;
    shortBioController.clear();
    update();
  }

  @override
  void onClose() {
    shortBioController.dispose();
    super.onClose();
  }
}
