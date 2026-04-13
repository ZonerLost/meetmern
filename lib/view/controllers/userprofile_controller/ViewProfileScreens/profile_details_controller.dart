import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';

class ProfileDetailsController extends GetxController {
  final Strings _strings = const Strings();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? gender;
  String? ethnicity;
  List<String> languages = <String>[];

  Uint8List? imageBytes;
  bool isObscure = true;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  void initialize({
    String? initialName,
    String? initialEmail,
    String? initialBio,
    String? initialDob,
    String? initialGender,
    String? initialEthnicity,
    List<String>? initialLanguages,
  }) {
    nameController.text = initialName ?? _strings.initialProfileNameText;
    emailController.text = initialEmail ?? _strings.initialProfileEmailText;
    bioController.text = initialBio ?? '';
    dobController.text = initialDob ?? _strings.initialProfileDobText;
    passwordController.text = '123456';
    gender = initialGender ?? OnboardingMockData.genders.first;
    ethnicity = initialEthnicity ?? OnboardingMockData.ethnicities.first;
    languages = initialLanguages ?? <String>['English', 'Spanish'];
    update();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return _strings.pleaseEnterYourNameText;
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return _strings.pleaseEnterYourEmailText;
    if (!value.contains('@')) return _strings.enterValidEmailText;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return _strings.pleaseEnterPasswordText;
    if (value.length < 6) return _strings.passwordMinLengthText;
    return null;
  }

  void setImageBytes(Uint8List? bytes) { imageBytes = bytes; update(); }
  void togglePasswordVisibility() { isObscure = !isObscure; update(); }
  void setDobText(String value) { dobController.text = value; update(); }
  void setGender(String? value) { gender = value; update(); }
  void setEthnicity(String? value) { ethnicity = value; update(); }
  void setLanguages(List<String> values) { languages = values; update(); }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  Map<String, dynamic> buildResultMap() => <String, dynamic>{
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'bio': bioController.text.trim(),
        'dob': dobController.text.trim(),
        'gender': gender,
        'ethnicity': ethnicity,
        'languages': List<String>.from(languages),
        'relationship': _strings.initialProfileRelationshipText,
        'password': passwordController.text.trim(),
        'imageBytes': imageBytes,
      };

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    dobController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
