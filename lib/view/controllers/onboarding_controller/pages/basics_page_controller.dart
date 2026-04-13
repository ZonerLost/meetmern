import 'package:get/get.dart';

class OnboardingScreensPagesBasicsPageController extends GetxController {
  bool isStepValid({
    required String dob,
    required String? gender,
    required String? ethnicity,
    required String? orientation,
  }) {
    final dobOk = dob.trim().isNotEmpty;
    final genderOk = gender != null;
    final ethnicityOk = ethnicity != null;
    final orientationOk = orientation != null;
    return dobOk && genderOk && ethnicityOk && orientationOk;
  }
}
