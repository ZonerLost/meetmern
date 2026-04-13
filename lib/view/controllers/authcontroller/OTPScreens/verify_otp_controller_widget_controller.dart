import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpWidgetController extends GetxController {
  final int length;

  OtpWidgetController({this.length = 5});

  late final List<TextEditingController> otpControllers;
  late final List<FocusNode> focusNodes;

  bool hasError = false;

  @override
  void onInit() {
    super.onInit();
    otpControllers = List.generate(length, (_) => TextEditingController());
    focusNodes = List.generate(length, (_) => FocusNode());
  }

  String get otp => otpControllers.map((c) => c.text).join();
  bool get isComplete => otp.length == length;

  void setError(bool value) {
    hasError = value;
    update();
  }

  void reset() {
    for (final c in otpControllers) c.clear();
    hasError = false;
    update();
  }

  void onOtpChanged(String value, int index, BuildContext context) {
    if (value.length > 1) {
      final pasted = value.replaceAll(RegExp(r'\s+'), '');
      for (int i = 0; i < length; i++) {
        otpControllers[i].text = i < pasted.length ? pasted[i] : '';
      }
      final nextIndex = pasted.length >= length ? length - 1 : pasted.length;
      if (nextIndex < focusNodes.length) {
        focusNodes[nextIndex].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
      update();
      return;
    }
    if (value.isNotEmpty) {
      if (index + 1 < focusNodes.length) {
        focusNodes[index + 1].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
    } else if (index - 1 >= 0) {
      focusNodes[index - 1].requestFocus();
    }
    update();
  }

  @override
  void onClose() {
    for (final c in otpControllers) c.dispose();
    for (final f in focusNodes) f.dispose();
    super.onClose();
  }
}
