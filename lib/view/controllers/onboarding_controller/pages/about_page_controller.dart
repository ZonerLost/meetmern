import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreensPagesAboutPageController extends GetxController {
  bool isStepValid({
    required String? children,
    required String? relationship,
  }) {
    return (children != null && children.trim().isNotEmpty) &&
        (relationship != null && relationship.trim().isNotEmpty);
  }

  String? validateBio(String? value, {required bool showErrors}) {
    if (!showErrors) return null;
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < 10) return 'Bio should be at least 10 characters';
    return null;
  }

  void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }
}
