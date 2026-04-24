import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/service/profile_service.dart';
import 'package:meetmern/main.dart';

class LocationScreenController extends GetxController {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController radiusController =
      TextEditingController(text: _defaultRadiusKm);

  bool isLoading = false;
  bool isSaving = false;
  bool isLocating = false;
  String? errorMessage;

  static const String _defaultRadiusKm = '10';

  bool get hasValidLocation => locationController.text.trim().isNotEmpty;
  bool get hasValidRadius {
    final radiusKm = int.tryParse(radiusController.text.trim());
    return radiusKm != null && radiusKm > 0;
  }

  bool get canSave => hasValidLocation && hasValidRadius;

  @override
  void onInit() {
    super.onInit();
    locationController.addListener(_onChanged);
    radiusController.addListener(_onChanged);
    _loadFromProfile();
  }

  void _onChanged() => update();

  Future<void> _loadFromProfile() async {
    isLoading = true;
    update();

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final profile = await ProfileService.getLocationAndRadius(userId);
      if (profile != null) {
        if (profile.location != null && profile.location!.isNotEmpty) {
          locationController.text = profile.location!;
        }

        final savedRadius = _extractRadiusKm(profile.discoveryRadius);
        if (savedRadius != null) {
          radiusController.text = savedRadius;
        }
      }

      // Auto-fill location from phone if profile has no location yet.
      if (!hasValidLocation) {
        await getCurrentLocation(silent: true);
      }
    } catch (_) {
      // silently fall back to defaults
    } finally {
      isLoading = false;
      update();
    }
  }

  static String? _extractRadiusKm(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final match = RegExp(r'\d+').firstMatch(value);
    return match?.group(0);
  }

  String? _formatCityCountry(Placemark placemark) {
    final cityCandidates = <String?>[
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
      placemark.subLocality,
    ];

    final city = cityCandidates.map((item) => item?.trim()).firstWhere(
        (item) => item != null && item.isNotEmpty,
        orElse: () => null);
    final country = placemark.country?.trim();

    if ((country == null || country.isEmpty) &&
        (city == null || city.isEmpty)) {
      return null;
    }

    if (country == null || country.isEmpty) return city;
    if (city == null || city.isEmpty) return country;
    if (city.toLowerCase() == country.toLowerCase()) return city;

    return '$city, $country';
  }

  Future<Position?> _resolvePosition() async {
    try {
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return current;
    } on TimeoutException {
      // Fall back below.
    } catch (_) {
      // Fall back below.
    }

    return Geolocator.getLastKnownPosition();
  }

  Future<String?> _resolveLocationLabel(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        final formattedLocation = _formatCityCountry(placemarks.first);
        if (formattedLocation != null && formattedLocation.isNotEmpty) {
          return formattedLocation;
        }
      }
    } catch (_) {
      // Fall back to coordinates text below.
    }

    return '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
  }

  Future<void> getCurrentLocation({bool silent = false}) async {
    if (isLocating) return;

    isLocating = true;
    if (!silent) {
      errorMessage = null;
    }
    update();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!silent) {
          errorMessage = 'Please enable location services.';
        }
        return;
      }

      // Check & request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (!silent) {
          errorMessage = 'Location permission denied.';
        }
        return;
      }

      final position = await _resolvePosition();
      if (position == null) {
        if (!silent) {
          errorMessage = 'Could not get GPS location. Please enter manually.';
        }
        return;
      }

      final label = await _resolveLocationLabel(position);
      if (label != null && label.isNotEmpty) {
        locationController.text = label;
        // If we had to fall back to coordinates, guide user to optionally edit.
        if (!silent && label.contains(',')) {
          final parts = label.split(',');
          final looksLikeCoordinates =
              parts.length == 2 && double.tryParse(parts[0].trim()) != null;
          if (looksLikeCoordinates) {
            errorMessage = 'City lookup timed out. Coordinates filled instead.';
          }
        }
      } else if (!silent) {
        errorMessage = 'Could not detect city and country.';
      }
    } catch (e) {
      if (!silent) {
        errorMessage = 'Could not get location. Please enter manually.';
      }
    } finally {
      isLocating = false;
      update();
    }
  }

  Future<bool> saveLocationAndRadius() async {
    final location = locationController.text.trim();
    if (location.isEmpty) {
      errorMessage = 'Please enter a location';
      update();
      return false;
    }
    if (!hasValidRadius) {
      errorMessage = 'Please enter a valid radius in km';
      update();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    update();

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        errorMessage = 'You need to sign in again.';
        return false;
      }

      await ProfileService.updateLocationAndRadius(
        userId,
        location,
        '${radiusController.text.trim()} km',
      );
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  @override
  void onClose() {
    locationController.removeListener(_onChanged);
    radiusController.removeListener(_onChanged);
    locationController.dispose();
    radiusController.dispose();
    super.onClose();
  }
}
