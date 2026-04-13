import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';

class UserProfileScreensLocationScreenLocationScreenController
    extends GetxController {
  final Strings strings = const Strings();

  final TextEditingController locationController =
      TextEditingController(text: 'Berlin, Mitte');

  late String selectedRadius;

  @override
  void onInit() {
    super.onInit();
    selectedRadius = strings.radiusOptions.first;
  }

  bool get hasValidLocation => locationController.text.trim().isNotEmpty;

  void onLocationChanged(String _) => update();

  void setRadius(String? value) {
    if (value == null) return;
    selectedRadius = value;
    update();
  }

  String currentLocationText() => locationController.text.trim();

  @override
  void onClose() {
    locationController.dispose();
    super.onClose();
  }
}
