import 'dart:async';
import 'package:get/get.dart';
import 'package:meetmern/core/widgets/app_snackbar.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/view/controllers/authcontroller/OTPScreens/verify_otp_controller_widget_controller.dart';
import 'package:meetmern/view/routes/route_names.dart';

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

  Future<void> verifyOtp(String email) async {
    if (!canVerify) return;
    isVerifying = true;
    update();
    try {
      await AuthService.verifyOtp(
        email: email,
        token: otpWidgetController.otp,
      );
      otpWidgetController.setError(false);
      AppSnackbar.success('Verified! Set your new password.');
      Get.toNamed(Routes.resetPassword);
    } on Exception catch (e) {
      otpWidgetController.setError(true);
      AppSnackbar.error(_parseError(e));
    } finally {
      isVerifying = false;
      update();
    }
  }

  Future<void> resendCode(String email) async {
    try {
      await AuthService.sendPasswordResetEmail(email: email);
      otpWidgetController.reset();
      _startResendCountdown();
      AppSnackbar.info('A new code has been sent to your email.');
    } on Exception catch (e) {
      AppSnackbar.error(_parseError(e));
    }
  }

  String _parseError(Exception e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid') || msg.contains('expired'))
      return 'Invalid or expired code.';
    if (msg.contains('network')) return 'Network error. Check your connection.';
    return 'Verification failed. Please try again.';
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
