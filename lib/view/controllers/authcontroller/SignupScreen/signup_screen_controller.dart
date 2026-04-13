import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/extensions/validation_extention.dart';

class SignupController extends GetxController {
  final Strings _strings = const Strings();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isObscure = true;

  void togglePasswordVisibility() {
    isObscure = !isObscure;
    update();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return _strings.pleaseEnterYourNameText;
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return _strings.pleaseEnterYourEmailText;
    if (!value.isValidEmail) return _strings.enterValidEmailText;
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return _strings.pleaseEnterYourPhoneText;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return _strings.pleaseEnterPasswordText;
    if (value.length < 6) return _strings.passwordMinLengthText;
    return null;
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
