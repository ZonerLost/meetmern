import 'package:flutter/material.dart';
import 'package:meetmern/utils/constants/constants.dart';

class VerifyOtpController {
  final constants = Constants();

  late final int length;
  late final List<TextEditingController> otpControllers;
  late final List<FocusNode> focusNodes;

  bool hasError = false;

  void init() {
    length = constants.s5;

    otpControllers = List.generate(length, (_) => TextEditingController());

    focusNodes = List.generate(length, (_) => FocusNode());
  }

  void dispose() {
    for (final c in otpControllers) {
      c.dispose();
    }

    for (final f in focusNodes) {
      f.dispose();
    }
  }

  String getOtp() {
    return otpControllers.map((c) => c.text).join();
  }

  void onOtpChanged(String value, int index, BuildContext context) {
    if (value.length > 1) {
      final pasted = value.replaceAll(RegExp(r'\s+'), '');

      for (int i = 0; i < length; i++) {
        otpControllers[i].text = i < pasted.length ? pasted[i] : '';
      }

      final lastFilled = pasted.length >= length ? length - 1 : pasted.length;

      if (lastFilled < length) {
        focusNodes[lastFilled].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }

      return;
    }

    if (value.isNotEmpty) {
      if (index + 1 < focusNodes.length) {
        focusNodes[index + 1].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
    } else {
      if (index - 1 >= 0) {
        focusNodes[index - 1].requestFocus();
      }
    }
  }
}
