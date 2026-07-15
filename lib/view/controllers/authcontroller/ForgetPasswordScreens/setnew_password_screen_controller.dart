import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/extensions/validation_extention.dart';
import 'package:meetmern/core/widgets/app_snackbar.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/core/routes/route_names.dart';

class ResetPasswordController extends GetxController {
  static const _strings = Strings();

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isObscure1 = true;
  bool isObscure2 = true;
  bool isLoading = false;

  void toggleNewPasswordVisibility() {
    isObscure1 = !isObscure1;
    update();
  }

  void toggleConfirmPasswordVisibility() {
    isObscure2 = !isObscure2;
    update();
  }

  String? validatePassword(String? value) {
    return PasswordRules.validateNewPassword(value);
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return _strings.pleaseEnterPasswordText;
    final passwordError = PasswordRules.validateNewPassword(
      newPasswordController.text,
    );
    if (passwordError != null) return passwordError;
    if (value != newPasswordController.text) return _strings.passwordNotMatch;
    return null;
  }

  Future<void> resetPassword(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    update();
    try {
      await AuthService.updatePassword(
        newPassword: newPasswordController.text,
      );
      AppSnackbar.success('Password updated successfully!');
      Get.toNamed(Routes.login);
    } on Exception catch (e) {
      AppSnackbar.error(_parseError(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  String _parseError(Exception e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('weak password') || msg.contains('password')) {
      return 'Password must be at least ${PasswordRules.minLength} characters and use only supported characters.';
    }
    if (msg.contains('network')) return 'Network error. Check your connection.';
    return e.toString().replaceFirst('Exception: ', '');
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
