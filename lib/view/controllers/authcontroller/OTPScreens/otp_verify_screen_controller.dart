import 'dart:async';
import 'package:get/get.dart';
import 'package:meetmern/core/services/notification_service.dart';
import 'package:meetmern/core/widgets/app_snackbar.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/view/controllers/authcontroller/OTPScreens/verify_otp_controller_widget_controller.dart';
import 'package:meetmern/core/routes/route_names.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum OtpFlow { signup, passwordReset }

class OtpVerifyController extends GetxController {
  late final OtpWidgetController otpWidgetController;
  String email = '';
  OtpFlow flow = OtpFlow.passwordReset;

  Timer? _timer;
  int resendSeconds = 60;
  bool isVerifying = false;
  bool get canResend => resendSeconds == 0;
  bool get canVerify => otpWidgetController.isComplete && !isVerifying;

  @override
  void onInit() {
    super.onInit();
    otpWidgetController = Get.find<OtpWidgetController>();
  }

  /// Re-reads the email/flow for this screen visit. The controller is a
  /// fenix singleton reused across app sessions, so onInit only fires once —
  /// call this from the screen every time it's opened instead.
  void configure(Map<String, dynamic> args) {
    email = (args['email'] as String? ?? '').trim();
    flow = args['flow'] as OtpFlow? ?? OtpFlow.passwordReset;
    otpWidgetController.reset();
    _startResendCountdown();
  }

  void _startResendCountdown() {
    _timer?.cancel();
    resendSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
        update();
      } else {
        resendSeconds -= 1;
        update();
      }
    });
    update();
  }

  Future<void> verifyOtp() async {
    if (!canVerify) return;
    isVerifying = true;
    update();
    try {
      await AuthService.verifyOtp(
        email: email,
        token: otpWidgetController.otp,
        type: flow == OtpFlow.signup ? OtpType.signup : OtpType.email,
      );
      otpWidgetController.setError(false);

      if (flow == OtpFlow.signup) {
        AppSnackbar.success('Account verified!');
        await NotificationService.instance.syncTokenWithSupabase();
        final profile = await AuthService.loadProfile();
        if (profile == null || profile.showOnboarding) {
          Get.offAllNamed(Routes.onboarding);
        } else {
          Get.offAllNamed(Routes.explore);
        }
      } else {
        AppSnackbar.success('Verified! Set your new password.');
        Get.toNamed(Routes.resetPassword);
      }
    } on Exception catch (e) {
      otpWidgetController.setError(true);
      AppSnackbar.error(_parseError(e));
    } finally {
      isVerifying = false;
      update();
    }
  }

  Future<void> resendCode() async {
    try {
      if (flow == OtpFlow.signup) {
        await AuthService.resendSignupOtp(email: email);
      } else {
        await AuthService.sendPasswordResetEmail(email: email);
      }
      otpWidgetController.reset();
      _startResendCountdown();
      AppSnackbar.info('Code resent. Use the latest code from your email.');
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
