import 'package:get/get.dart';

class OnboardingScreensPagesInterestsPageController extends GetxController {
  final Set<String> selectedInterests = <String>{};
  final Set<String> selectedPassions = <String>{};

  bool get isStepValid =>
      selectedInterests.isNotEmpty || selectedPassions.isNotEmpty;

  void toggleInterest(String value, bool selected) {
    if (selected) {
      selectedInterests.add(value);
    } else {
      selectedInterests.remove(value);
    }
    update();
  }

  void togglePassion(String value, bool selected) {
    if (selected) {
      selectedPassions.add(value);
    } else {
      selectedPassions.remove(value);
    }
    update();
  }
}
