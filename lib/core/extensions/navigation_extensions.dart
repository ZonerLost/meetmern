import 'package:flutter/material.dart';

import 'package:get/get.dart';

extension NavigationExtension on BuildContext {
  Future<T?> navigateToScreen<T>(Widget screen) {
    return Navigator.push<T>(
      this,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

extension NavigationHelpers on BuildContext {
  Future<T?> navigateToScreen1<T>(
    Widget screen, {
    Object? arguments,
  }) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(
        builder: (_) => screen,
        settings: RouteSettings(arguments: arguments),
      ),
    );
  }
}

extension NavigationExtension1 on BuildContext {
  Future<bool> maybePopScreen() {
    return Navigator.of(this).maybePop();
  }

  void popScreen<T extends Object?>([T? result]) {
    Navigator.of(this).pop(result);
  }
}

// Navigate to a named route, pushing it onto the stack
void navigateTo(String name) {
  Get.toNamed(name);
}

// Navigate to a named route, replacing the current route in the stack
void navigateToReplacement(String name) {
  Get.offNamed(name);
}

// Navigate to a named route, removing all previous routes from the stack
void navigateToReplacementAll(String name) {
  Get.offAllNamed(name);
}

// Navigate back to the previous screen
void navigateBack() {
  Get.back();
}

// Navigate back to the previous screen with a custom result
void navigateBackWithResult(dynamic result) {
  Get.back(result: result);
}

// Navigate to the initial route, clearing the entire stack
void navigateToInitial() {
  Get.offAllNamed('/');
}
