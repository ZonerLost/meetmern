import 'dart:async';

import 'package:get/get.dart';
import 'package:meetmern/view/controllers/authcontroller/OTPScreens/verify_otp_controller_widget_controller.dart';

class OtpVerifyController extends GetxController {
  late final OtpWidgetController otpWidgetController;

  Timer? _timer;
  int resendSeconds = 30;
  bool isVerifying = false;

  bool get canResend => resendSeconds == 0;
  bool get canVerify => otpWidgetController.isComplete && !isVerifying;

  @override
  void onInit() {
    super.onInit();
    otpWidgetController = Get.find<OtpWidgetController>();
    _startResendCountdown();
  }

  void _startResendCountdown() {
    _timer?.cancel();
    resendSeconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
      } else {
        resendSeconds -= 1;
        update();
      }
    });
    update();
  }

  Future<bool> verifyOtp() async {
    if (!canVerify) return false;
    isVerifying = true;
    update();
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final isValid = otpWidgetController.otp.length == otpWidgetController.length;
    otpWidgetController.setError(!isValid);
    isVerifying = false;
    update();
    return isValid;
  }

  void resendCode() {
    otpWidgetController.reset();
    _startResendCountdown();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
