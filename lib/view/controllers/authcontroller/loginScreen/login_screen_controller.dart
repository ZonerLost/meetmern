import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/extensions/validation_extention.dart';
import 'package:meetmern/core/widgets/app_snackbar.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/core/routes/route_names.dart';

class LoginController extends GetxController {
  static const _strings = Strings();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isObscure = true;
  bool isLoading = false;

  void togglePasswordVisibility() {
    isObscure = !isObscure;
    update();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _strings.pleaseEnterYourEmailText;
    }
    if (!value.isValidEmail) return _strings.enterValidEmailText;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return _strings.pleaseEnterPasswordText;
    if (value.length < 6) return _strings.passwordMinLengthText;
    return null;
  }

  Future<void> signIn(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    update();
    try {
      await AuthService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final profile = await AuthService.loadProfile();

      if (profile == null || profile.showOnboarding) {
        Get.offAllNamed(Routes.onboarding);
      } else {
        Get.offAllNamed(Routes.explore);
      }
    } on Exception catch (e) {
      AppSnackbar.error(_parseError(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  String _parseError(Exception e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login')) return 'Invalid email or password.';
    if (msg.contains('email not confirmed'))
      return 'Please confirm your email first.';
    if (msg.contains('network')) return 'Network error. Check your connection.';
    return 'Login failed. Please try again.';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
