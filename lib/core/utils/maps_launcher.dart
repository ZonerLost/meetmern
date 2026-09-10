import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens walking directions to a meetup venue in the Google Maps app.
///
/// Prefers exact coordinates and falls back to the written address, so a
/// meetup saved before coordinates were captured still routes correctly.
/// Shared by the meetup detail screen and the agreed-meetup cards in chat so
/// the two can't drift apart.
class MapsLauncher {
  MapsLauncher._();

  static bool canOpen({double? latitude, double? longitude, String? address}) {
    if (latitude != null && longitude != null) return true;
    return (address?.trim().isNotEmpty ?? false);
  }

  static Future<bool> openDirections({
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    final Uri uri;
    if (latitude != null && longitude != null) {
      uri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=walking');
    } else if (address != null && address.trim().isNotEmpty) {
      final encoded = Uri.encodeComponent(address.trim());
      uri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$encoded&travelmode=walking');
    } else {
      return false;
    }

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[MapsLauncher] openDirections failed: $e');
      return false;
    }
  }
}
