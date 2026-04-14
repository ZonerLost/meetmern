import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(String message) {
    _show(
      message: message,
      backgroundColor: appTheme.accentsgreen,
      icon: Icons.check_circle_outline,
    );
  }

  static void error(String message) {
    _show(
      message: message,
      backgroundColor: appTheme.red,
      icon: Icons.error_outline,
    );
  }

  static void info(String message) {
    _show(
      message: message,
      backgroundColor: appTheme.b_Primary,
      icon: Icons.info_outline,
    );
  }

  static void _show({
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          Icon(icon, color: appTheme.coreWhite, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: appTheme.coreWhite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOut,
    );
  }
}
