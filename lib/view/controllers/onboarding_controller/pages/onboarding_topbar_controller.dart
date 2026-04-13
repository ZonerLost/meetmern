import 'package:get/get.dart';

class OnboardingScreensPagesOnboardingTopbarController extends GetxController {
  int current = 0;
  int total = 6;

  void setProgress({required int currentPage, required int totalPages}) {
    current = currentPage;
    total = totalPages;
    update();
  }
}
