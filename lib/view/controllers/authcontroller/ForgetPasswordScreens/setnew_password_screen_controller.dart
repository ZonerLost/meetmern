import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';

class AuthScreensForgetPasswordScreensSetnewPasswordScreenController
    extends GetxController {
  final Strings _strings = const Strings();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isObscure1 = true;
  bool isObscure2 = true;

  void toggleNewPasswordVisibility() {
    isObscure1 = !isObscure1;
    update();
  }

  void toggleConfirmPasswordVisibility() {
    isObscure2 = !isObscure2;
    update();
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _strings.pleaseEnterPasswordText;
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return _strings.pleaseEnterPasswordText;
    }
    if (value != newPasswordController.text) {
      return _strings.passwordNotMatch;
    }
    return null;
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
