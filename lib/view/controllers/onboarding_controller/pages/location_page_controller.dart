import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meetmern/view/controllers/onboarding_controller/OnboardingScreen/onboarding_screen_controller.dart';

class LocationPageController extends GetxController {
  bool loading = false;

  String? _formatCityCountry(Placemark placemark) {
    final cityCandidates = <String?>[
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
      placemark.subLocality,
    ];

    final city = cityCandidates.map((value) => value?.trim()).firstWhere(
        (value) => value != null && value.isNotEmpty,
        orElse: () => null);
    final country = placemark.country?.trim();

    if ((city == null || city.isEmpty) &&
        (country == null || country.isEmpty)) {
      return null;
    }
    if (city == null || city.isEmpty) return country;
    if (country == null || country.isEmpty) return city;
    if (city.toLowerCase() == country.toLowerCase()) return city;

    return '$city, $country';
  }

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
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? locationText;
      if (placemarks.isNotEmpty) {
        locationText = _formatCityCountry(placemarks.first);
      }
      locationText ??= '${position.latitude},${position.longitude}';

      final onboardingController = Get.find<OnboardingController>();
      onboardingController.setLocation(locationText);
    } catch (e) {
      // Location capture failed, continue anyway
    } finally {
      loading = false;
      update();
    }
  }
}
