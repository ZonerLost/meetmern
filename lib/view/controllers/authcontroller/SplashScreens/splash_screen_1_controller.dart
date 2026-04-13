import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';

class AuthScreensSplashScreensSplashScreen1Controller extends GetxController {
  final DimensionResource _constants = DimensionResource();

  Timer? _timer;
  bool didTimeout = false;

  int get splashSeconds => 5;

  void startTimer(VoidCallback onDone) {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: splashSeconds), () {
      didTimeout = true;
      update();
      onDone();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
