import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';

class SplashController extends GetxController {
  Timer? _timer;

  void startTimer(VoidCallback onDone) {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), onDone);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
