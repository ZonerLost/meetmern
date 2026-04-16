import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/view/routes/route_names.dart';

class SplashController extends GetxController {
  Timer? _timer;

  void startTimer(VoidCallback onDone) {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), onDone);
  }

  Future<void> checkAuthAndNavigate() async {
    if (!AuthService.isLoggedIn) {
      Get.offAllNamed(Routes.splash2);
      return;
    }

    final profile = await AuthService.loadProfile();

    if (profile == null) {
      Get.offAllNamed(Routes.onboarding);
    } else if (profile.showOnboarding) {
      Get.offAllNamed(Routes.onboarding);
    } else {
      Get.offAllNamed(Routes.explore);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
