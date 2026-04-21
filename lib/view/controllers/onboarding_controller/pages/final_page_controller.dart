import 'package:get/get.dart';
import 'package:meetmern/core/widgets/app_snackbar.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/profile_service.dart';
import 'package:meetmern/view/controllers/onboarding_controller/OnboardingScreen/onboarding_screen_controller.dart';
import 'package:meetmern/core/routes/route_names.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_model.dart';

class FinalPageController extends GetxController {
  bool isSubmitting = false;

  Future<void> finish(OnboardingModel model) async {
    final user = AuthService.currentUser;
    if (user == null) {
      AppSnackbar.error('User not authenticated');
      return;
    }

    isSubmitting = true;
    update();

    try {
      final onboardingController = Get.find<OnboardingController>();

      final updates = <String, dynamic>{};
      if (onboardingController.locationCoords != null) {
        updates['location'] = onboardingController.locationCoords;
      }

      if (updates.isNotEmpty) {
        await ProfileService.updateProfile(user.id, updates);
      }

      await ProfileService.markOnboardingComplete(user.id);
      await AuthService.loadProfile();

      AppSnackbar.success('Profile completed successfully!');
      Get.offAllNamed(Routes.viewProfile);
    } catch (e) {
      AppSnackbar.error('Failed to complete onboarding: ${e.toString()}');
    } finally {
      isSubmitting = false;
      update();
    }
  }
}
