import 'package:flutter/material.dart';

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
