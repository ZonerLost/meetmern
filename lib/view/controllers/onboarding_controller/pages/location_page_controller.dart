import 'package:get/get.dart';

class OnboardingScreensPagesLocationPageController extends GetxController {
  bool loading = false;

  Future<void> enableLocation() async {
    loading = true;
    update();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
    } finally {
      loading = false;
      update();
    }
  }
}
