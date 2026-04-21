import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/extensions/validation_extention.dart';
import 'package:meetmern/core/widgets/app_snackbar.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/core/routes/route_names.dart';

class ForgotPasswordController extends GetxController {
  static const _strings = Strings();

  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty)
      return _strings.pleaseEnterYourEmailText;
    if (!value.isValidEmail) return _strings.enterValidEmailText;
    return null;
  }

  Future<void> sendResetLink(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    update();
    try {
      await AuthService.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      AppSnackbar.success('Reset link sent! Check your email.');
      Get.toNamed(Routes.otpVerify);
    } on Exception catch (e) {
      AppSnackbar.error(_parseError(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  String _parseError(Exception e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('user not found'))
      return 'No account found with this email.';
    if (msg.contains('network')) return 'Network error. Check your connection.';
    return 'Failed to send reset link. Please try again.';
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
