import 'package:get/get.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_model.dart';

class OnboardingScreensPagesFinalPageController extends GetxController {
  bool isSubmitting = false;

  Future<void> finish(OnboardingModel model) async {
    isSubmitting = true;
    update();

    await Future<void>.delayed(const Duration(milliseconds: 250));

    isSubmitting = false;
    update();
  }
}
