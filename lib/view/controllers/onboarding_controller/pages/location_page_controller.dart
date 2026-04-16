import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meetmern/view/controllers/onboarding_controller/OnboardingScreen/onboarding_screen_controller.dart';

class LocationPageController extends GetxController {
  bool loading = false;

  Future<void> enableLocation() async {
    loading = true;
    update();
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        loading = false;
        update();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          loading = false;
          update();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        loading = false;
        update();
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final coords = '${position.latitude},${position.longitude}';
      
      final onboardingController = Get.find<OnboardingController>();
      onboardingController.setLocation(coords);
    } catch (e) {
      // Location capture failed, continue anyway
    } finally {
      loading = false;
      update();
    }
  }
}
