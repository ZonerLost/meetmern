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
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';

class ProfileDetailsController extends GetxController {
  final Strings _strings = const Strings();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? gender;
  String? ethnicity;
  List<String> languages = <String>[];

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
    languages = profile.languages ?? [];
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

  void setGender(String? value) { gender = value; update(); }
  void setEthnicity(String? value) { ethnicity = value; update(); }
  void setLanguages(List<String> values) { languages = values; update(); }
  void setDobText(String value) { dobController.text = value; update(); }

  bool validateForm() => formKey.currentState?.validate() ?? false;

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
        'languages': languages,
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
