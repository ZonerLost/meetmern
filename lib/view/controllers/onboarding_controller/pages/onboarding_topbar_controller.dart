import 'package:get/get.dart';

class OnboardingTopbarController extends GetxController {
  int current = 0;
  int total = 6;

  void setProgress({required int currentPage, required int totalPages}) {
    current = currentPage;
    total = totalPages;
    update();
  }
}
