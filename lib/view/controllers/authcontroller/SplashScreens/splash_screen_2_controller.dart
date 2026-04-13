import 'package:get/get.dart';

class Splash2Controller extends GetxController {
  bool isBusy = false;

  void setBusy(bool value) {
    isBusy = value;
    update();
  }
}
