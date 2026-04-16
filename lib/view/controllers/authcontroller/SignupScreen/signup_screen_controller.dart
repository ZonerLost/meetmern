import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/extensions/validation_extention.dart';
import 'package:meetmern/core/widgets/app_snackbar.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/view/routes/route_names.dart';

class SignupController extends GetxController {
  static const _strings = Strings();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isObscure = true;
  bool isLoading = false;

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

  Future<void> signUp(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    update();
    try {
      // Store signup data so LoginController can save it after confirmed login
      AuthService.pendingName = nameController.text.trim();
      AuthService.pendingPhone = phoneController.text.trim();

      await AuthService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      AppSnackbar.success('Account created! Please check your email to confirm.');
      Get.toNamed(Routes.login);
    } on Exception catch (e) {
      AuthService.pendingName = null;
      AuthService.pendingPhone = null;
      AppSnackbar.error(_parseError(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  String _parseError(Exception e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('already registered')) return 'This email is already registered.';
    if (msg.contains('weak password')) return 'Password is too weak.';
    if (msg.contains('network')) return 'Network error. Check your connection.';
    return 'Sign up failed. Please try again.';
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
