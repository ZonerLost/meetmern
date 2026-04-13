import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/extensions/validation_extention.dart';

class ForgotPasswordController extends GetxController {
  final Strings _strings = const Strings();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return _strings.pleaseEnterYourEmailText;
    if (!value.isValidEmail) return _strings.enterValidEmailText;
    return null;
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
