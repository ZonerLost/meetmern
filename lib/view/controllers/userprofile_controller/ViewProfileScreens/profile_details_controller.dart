import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/widgets/app_snackbar.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/profile_service.dart';
import 'package:meetmern/data/service/storage_service.dart';
import 'package:meetmern/data/service/user_traits_service.dart';
import 'package:meetmern/view/screens/onboardingscreens/dummy_data/onboarding_mock_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDetailsController extends GetxController {
  final Strings _strings = const Strings();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? gender;
  String? ethnicity;
  String? orientation;
  String? children;
  String? relationshipStatus;
  List<String> dietaryPreferences = <String>[];
  String? religion;
  List<String> languages = <String>[];
  Set<String> interests = <String>{};
  Set<String> passionTopics = <String>{};

  // Holds newly picked image bytes for preview
  Uint8List? imageBytes;
  // Holds the actual File for upload
  File? _pickedFile;
  // Existing remote photo URL
  String? existingPhotoUrl;

  bool isSaving = false;

  @override
  void onInit() {
    super.onInit();
    _loadFromProfile();
    _loadTraitOptions();
  }

  Future<void> _loadTraitOptions() async {
    final traits = await UserTraitsService.fetchTraitOptions();
    if (traits.isEmpty) return;
    OnboardingMockData.applyRuntimeTraitOptions(traits);
    if (gender == null || !OnboardingMockData.genders.contains(gender)) {
      gender = OnboardingMockData.genders.isNotEmpty
          ? OnboardingMockData.genders.first
          : null;
    }
    if (ethnicity == null ||
        !OnboardingMockData.ethnicities.contains(ethnicity)) {
      ethnicity = OnboardingMockData.ethnicities.isNotEmpty
          ? OnboardingMockData.ethnicities.first
          : null;
    }
    update();
  }

  void _loadFromProfile() {
    final profile = AuthService.currentProfile.value;
    if (profile == null) return;
    nameController.text = profile.name ?? '';
    emailController.text = profile.email ?? '';
    bioController.text = profile.shortBio ?? '';
    dobController.text = profile.dob ?? '';
    gender = profile.gender?.isNotEmpty == true
        ? profile.gender
        : OnboardingMockData.genders.first;
    ethnicity = profile.ethnicity?.isNotEmpty == true
        ? profile.ethnicity
        : OnboardingMockData.ethnicities.first;
    orientation = profile.orientation?.isNotEmpty == true ? profile.orientation : null;
    children = profile.children != null ? (profile.children! ? 'Yes' : 'No') : null;
    relationshipStatus = profile.relationshipStatus?.isNotEmpty == true
        ? profile.relationshipStatus
        : null;
    dietaryPreferences = profile.dietaryPreferences ?? [];
    religion = profile.religion?.isNotEmpty == true ? profile.religion : null;
    languages = profile.languages ?? [];
    interests = Set<String>.from(profile.interests ?? []);
    passionTopics = Set<String>.from(profile.passionTopics ?? []);
    existingPhotoUrl = profile.photoUrl;
    update();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    _pickedFile = File(file.path);
    imageBytes = await file.readAsBytes();
    update();
  }

  void setGender(String? value) {
    gender = value;
    update();
  }

  void setEthnicity(String? value) {
    ethnicity = value;
    update();
  }

  void setOrientation(String? value) {
    orientation = value;
    update();
  }

  void setChildren(String? value) {
    children = value;
    update();
  }

  void setRelationshipStatus(String? value) {
    relationshipStatus = value;
    update();
  }

  void setDietaryPreferences(List<String> values) {
    dietaryPreferences = values;
    update();
  }

  void setReligion(String? value) {
    religion = value;
    update();
  }

  void setLanguages(List<String> values) {
    languages = values;
    update();
  }

  void toggleInterest(String value, bool selected) {
    if (selected) {
      interests.add(value);
    } else {
      interests.remove(value);
    }
    update();
  }

  void togglePassionTopic(String value, bool selected) {
    if (selected) {
      passionTopics.add(value);
    } else {
      passionTopics.remove(value);
    }
    update();
  }

  void setDobText(String value) {
    dobController.text = value;
    update();
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  /// Returns null on success, or an error message string on failure.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return 'Not authenticated.';
    final email = user.email;
    if (email == null || email.isEmpty) return 'No email on account.';
    try {
      // Re-authenticate to verify current password.
      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: currentPassword);
      // Update to the new password.
      await Supabase.instance.client.auth
          .updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> saveProfile() async {
    if (!validateForm()) return false;

    final user = AuthService.currentUser;
    if (user == null) {
      AppSnackbar.error('Not authenticated');
      return false;
    }

    isSaving = true;
    update();

    try {
      final updates = <String, dynamic>{
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'short_bio': bioController.text.trim(),
        'dob': dobController.text.trim(),
        'gender': gender,
        'ethnicity': ethnicity,
        'orientation': orientation,
        if (children != null) 'children': children == 'Yes',
        'relationship_status': relationshipStatus,
        'dietary_preferences': dietaryPreferences,
        'religion': religion,
        'languages': languages,
        'interests': interests.toList(),
        'passion_topics': passionTopics.toList(),
      };

      // Upload new image if one was picked
      if (_pickedFile != null) {
        final url =
            await StorageService.uploadProfileImage(user.id, _pickedFile!);
        if (url != null) updates['photo_url'] = url;
      }

      await ProfileService.updateProfile(user.id, updates);
      await AuthService.loadProfile();
      AppSnackbar.success(_strings.profileUpdatedSnackText);
      return true;
    } catch (e) {
      AppSnackbar.error('Failed to save profile: $e');
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
