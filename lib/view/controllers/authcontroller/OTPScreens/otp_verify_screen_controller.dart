import 'dart:async';

import 'package:get/get.dart';
import 'package:meetmern/view/controllers/authcontroller/OTPScreens/verify_otp_controller_widget_controller.dart';

class AuthScreensOTPScreensOtpVerifyScreenController extends GetxController {
  late final AuthScreensOTPScreensVerifyOtpControllerWidgetController
      otpController;

  Timer? _timer;
  int resendSeconds = 30;
  bool isVerifying = false;

  bool get canResend => resendSeconds == 0;
  bool get canVerify => otpController.isComplete && !isVerifying;

  @override
  void onInit() {
    super.onInit();
    otpController =
        Get.find<AuthScreensOTPScreensVerifyOtpControllerWidgetController>();
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

    final isValid = otpController.otp.length == otpController.length;
    otpController.setError(!isValid);

    isVerifying = false;
    update();

    return isValid;
  }

  void resendCode() {
    otpController.reset();
    _startResendCountdown();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
