import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meetmern/core/services/notification_service.dart';
import 'package:meetmern/core/widgets/app_snackbar.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/core/routes/route_names.dart';

class Splash2Controller extends GetxController {
  bool isBusy = false;
  bool isGoogleLoading = false;

  void setBusy(bool value) {
    isBusy = value;
    update();
  }

  Future<void> signInWithGoogle() async {
    isGoogleLoading = true;
    update();
    try {
      await AuthService.signInWithGoogle();
      await NotificationService.instance.syncTokenWithSupabase();

      final profile = await AuthService.loadProfile();

      if (profile != null && profile.isDisabled) {
        await AuthService.signOut();
        AppSnackbar.error(
          'Your account has been disabled due to repeated reports.',
        );
        Get.offAllNamed(Routes.login);
        return;
      }

      // New Google user (no profile yet) → onboarding; returning → explore.
      if (profile == null || profile.showOnboarding) {
        Get.offAllNamed(Routes.onboarding);
      } else {
        Get.offAllNamed(Routes.explore);
      }
    } on GoogleSignInException catch (e) {
      // User dismissed the account picker — not an error, stay on splash.
      debugPrint('GoogleSignInException: code=${e.code} details=${e.description}');
      if (e.code != GoogleSignInExceptionCode.canceled) {
        AppSnackbar.error('Google sign-in failed: ${e.code.name}');
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      AppSnackbar.error('Google sign-in error: $e');
    } finally {
      isGoogleLoading = false;
      update();
    }
  }
}
