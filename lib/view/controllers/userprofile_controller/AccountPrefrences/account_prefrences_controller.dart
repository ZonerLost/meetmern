import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/profile_service.dart';

class AccountPreferencesController extends GetxController {
  final Set<String> interests = <String>{};
  final Set<String> passions = <String>{};
  List<String> dietary = <String>[];

  String? relationship;
  String? children;
  String? religion;

  final TextEditingController shortBioController = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  /// Maps backend bool? → display string
  static String childrenBoolToString(bool? value) {
    if (value == null) return 'Prefer not to say';
    return value ? 'Yes' : 'No';
  }

  /// Maps display string → backend bool?
  static bool? childrenStringToBool(String? value) {
    if (value == 'Yes') return true;
    if (value == 'No') return false;
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _loadFromProfile();
  }

  void _loadFromProfile() {
    isLoading.value = true;
    final profile = AuthService.currentProfile.value;
    if (profile != null) {
      interests
        ..clear()
        ..addAll(profile.interests ?? []);
      passions
        ..clear()
        ..addAll(profile.passionTopics ?? []);
      dietary = List<String>.from(profile.dietaryPreferences ?? []);
      relationship = profile.relationshipStatus;
      children = childrenBoolToString(profile.children);
      religion = profile.religion;
      shortBioController.text = profile.shortBio ?? '';
    }
    isLoading.value = false;
    update();
  }

  bool get canSave =>
      interests.isNotEmpty ||
      passions.isNotEmpty ||
      dietary.isNotEmpty ||
      relationship != null ||
      children != null ||
      religion != null ||
      shortBioController.text.trim().isNotEmpty;

  void toggleInterest(String value) {
    if (interests.contains(value)) {
      interests.remove(value);
    } else {
      interests.add(value);
    }
    update();
  }

  void togglePassion(String value) {
    if (passions.contains(value)) {
      passions.remove(value);
    } else {
      passions.add(value);
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
  void clearReligion() => setReligion(null);
  void clearDietary() => setDietary([]);

  void clearBio() {
    shortBioController.clear();
    update();
  }

  Future<bool> save() async {
    final userId = AuthService.currentUser?.id;
    if (userId == null) return false;
    isSaving.value = true;
    try {
      await ProfileService.updateProfile(userId, {
        'interests': interests.toList(),
        'passion_topics': passions.toList(),
        'dietary_preferences': dietary,
        'relationship_status': relationship,
        'children': childrenStringToBool(children),
        'religion': religion,
        'short_bio': shortBioController.text.trim(),
      });
      await AuthService.loadProfile();
      return true;
    } catch (_) {
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void resetAllFields() {
    interests.clear();
    passions.clear();
    dietary = [];
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
