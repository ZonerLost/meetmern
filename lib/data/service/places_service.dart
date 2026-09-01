import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A cafe / restaurant / bar / pub returned by Google Places API (New).
class PlaceVenue {
  final String id;
  final String name;

  /// Normalised to one of: cafe | restaurant | bar | pub.
  final String amenity;
  final String address;
  final double latitude;
  final double longitude;

  const PlaceVenue({
    required this.id,
    required this.name,
    required this.amenity,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

/// A forward-geocoded point (place name / address -> coordinates).
class GeoPoint {
  final double latitude;
  final double longitude;
  final String address;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class PlacesException implements Exception {
  final String message;
  const PlacesException(this.message);
  @override
  String toString() => 'PlacesException: $message';
}

/// Wrapper over Google **Places API (New)** — the single mapping/geocoding
/// backend for the app (there is no OpenStreetMap / Nominatim / Overpass / OS
/// geocoder anywhere).
///
/// - venue search .... `places:searchNearby`
/// - place search .... `places:searchText`
/// - forward geocode . `places:searchText`
/// - area label ...... `places:searchNearby` (rank by distance) + addressComponents
///
/// The key comes from `--dart-define-from-file=env.json` (`PLACES_API_KEY`).
class PlacesService {
  PlacesService._();

  static const String _apiKey = String.fromEnvironment('PLACES_API_KEY');

  static const String _searchNearbyUrl =
      'https://places.googleapis.com/v1/places:searchNearby';
  static const String _searchTextUrl =
      'https://places.googleapis.com/v1/places:searchText';

  /// The four venue categories a meetup location may be.
  static const List<String> includedTypes = <String>[
    'restaurant',
    'cafe',
    'bar',
    'pub',
  ];

  static bool get isConfigured => _apiKey.trim().isNotEmpty;

  static Future<Map<String, dynamic>> _post(
    String url,
    String fieldMask,
    Map<String, dynamic> body,
  ) async {
    if (!isConfigured) {
      throw const PlacesException('PLACES_API_KEY is not set');
    }

    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': _apiKey,
              'X-Goog-FieldMask': fieldMask,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw PlacesException('request failed: $e');
    }

    if (response.statusCode != 200) {
      debugPrint('[PlacesService] $url ${response.statusCode}: ${response.body}');
      throw PlacesException('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  // ── Venue search (Create Meetup) ───────────────────────────────────────────

  static Future<List<PlaceVenue>> searchNearbyVenues({
    required double latitude,
    required double longitude,
    double radiusMeters = 1600,
    int maxResults = 20,
  }) async {
    final decoded = await _post(
      _searchNearbyUrl,
      <String>[
        'places.id',
        'places.displayName',
        'places.location',
        'places.formattedAddress',
        'places.primaryType',
        'places.types',
        'places.businessStatus',
      ].join(','),
      <String, dynamic>{
        'includedTypes': includedTypes,
        'maxResultCount': maxResults.clamp(1, 20),
        'rankPreference': 'DISTANCE',
        'locationRestriction': <String, dynamic>{
          'circle': <String, dynamic>{
            'center': <String, dynamic>{
              'latitude': latitude,
              'longitude': longitude,
            },
            'radius': radiusMeters,
          },
        },
      },
    );

    return _parseVenues(decoded);
  }

  /// Free-text place search, biased toward [latitude]/[longitude] when given.
  /// Used by the venue picker's search box to move the map to an area.
  static Future<List<PlaceVenue>> searchText(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'textQuery': query,
      'maxResultCount': 10,
    };
    if (latitude != null && longitude != null) {
      body['locationBias'] = <String, dynamic>{
        'circle': <String, dynamic>{
          'center': <String, dynamic>{
            'latitude': latitude,
            'longitude': longitude,
          },
          'radius': 20000.0,
        },
      };
    }

    final decoded = await _post(
      _searchTextUrl,
      <String>[
        'places.id',
        'places.displayName',
        'places.location',
        'places.formattedAddress',
        'places.primaryType',
        'places.types',
      ].join(','),
      body,
    );

    return _parseVenues(decoded, requireFoodVenue: false);
  }

  // ── Geocoding ──────────────────────────────────────────────────────────────

  /// Forward geocode: resolves an address / place name / "City, Country" string
  /// to coordinates. Replaces the old `locationFromAddress` (OS geocoder).
  static Future<GeoPoint?> geocode(
    String query, {
    double? biasLatitude,
    double? biasLongitude,
  }) async {
    final text = query.trim();
    if (text.isEmpty) return null;

    final body = <String, dynamic>{'textQuery': text, 'maxResultCount': 1};
    if (biasLatitude != null && biasLongitude != null) {
      body['locationBias'] = <String, dynamic>{
        'circle': <String, dynamic>{
          'center': <String, dynamic>{
            'latitude': biasLatitude,
            'longitude': biasLongitude,
          },
          'radius': 50000.0,
        },
      };
    }

    final decoded = await _post(
      _searchTextUrl,
      'places.location,places.formattedAddress',
      body,
    );

    final places = (decoded['places'] as List?) ?? const <dynamic>[];
    if (places.isEmpty) return null;
    final first = places.first;
    if (first is! Map) return null;

    final loc = first['location'];
    final lat = (loc is Map ? loc['latitude'] as num? : null)?.toDouble();
    final lng = (loc is Map ? loc['longitude'] as num? : null)?.toDouble();
    if (lat == null || lng == null) return null;

    return GeoPoint(
      latitude: lat,
      longitude: lng,
      address: (first['formattedAddress'] ?? text).toString(),
    );
  }

  /// Reverse geocode to a coarse "City, Country" label — used by the "Use my
  /// location" buttons. Places API (New) has no dedicated reverse geocoder, so
  /// this reads the address components of the nearest place.
  static Future<String?> reverseGeocodeArea({
    required double latitude,
    required double longitude,
  }) async {
    final decoded = await _post(
      _searchNearbyUrl,
      'places.addressComponents,places.formattedAddress',
      <String, dynamic>{
        'maxResultCount': 1,
        'rankPreference': 'DISTANCE',
        'locationRestriction': <String, dynamic>{
          'circle': <String, dynamic>{
            'center': <String, dynamic>{
              'latitude': latitude,
              'longitude': longitude,
            },
            'radius': 800.0,
          },
        },
      },
    );

    final places = (decoded['places'] as List?) ?? const <dynamic>[];
    if (places.isEmpty) return null;
    final first = places.first;
    if (first is! Map) return null;

    final components = (first['addressComponents'] as List?) ?? const <dynamic>[];
    String? pick(List<String> wanted) {
      for (final want in wanted) {
        for (final c in components) {
          if (c is! Map) continue;
          final types = ((c['types'] as List?) ?? const <dynamic>[])
              .map((e) => e.toString());
          if (types.contains(want)) {
            final text = (c['longText'] ?? c['shortText'] ?? '').toString().trim();
            if (text.isNotEmpty) return text;
          }
        }
      }
      return null;
    }

    final city = pick(<String>[
      'locality',
      'postal_town',
      'administrative_area_level_2',
      'administrative_area_level_1',
    ]);
    final country = pick(<String>['country']);

    if (city != null && country != null) return '$city, $country';
    if (city != null) return city;
    if (country != null) return country;

    final formatted = (first['formattedAddress'] ?? '').toString().trim();
    return formatted.isEmpty ? null : formatted;
  }

  /// Reverse geocode to the most specific readable address for a dropped pin
  /// (street-level when available). Used by the "pin your location" map.
  /// Falls back to the coarse area label, then to raw coordinates.
  static Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final decoded = await _post(
        _searchNearbyUrl,
        'places.formattedAddress,places.displayName',
        <String, dynamic>{
          'maxResultCount': 1,
          'rankPreference': 'DISTANCE',
          'locationRestriction': <String, dynamic>{
            'circle': <String, dynamic>{
              'center': <String, dynamic>{
                'latitude': latitude,
                'longitude': longitude,
              },
              'radius': 200.0,
            },
          },
        },
      );
      final places = (decoded['places'] as List?) ?? const <dynamic>[];
      if (places.isNotEmpty && places.first is Map) {
        final formatted =
            ((places.first as Map)['formattedAddress'] ?? '').toString().trim();
        if (formatted.isNotEmpty) return formatted;
      }
    } catch (_) {
      // Fall through to the coarse label.
    }

    return reverseGeocodeArea(latitude: latitude, longitude: longitude);
  }

  // ── Parsing ────────────────────────────────────────────────────────────────

  static List<PlaceVenue> _parseVenues(
    Map<String, dynamic> decoded, {
    bool requireFoodVenue = true,
  }) {
    final rawPlaces = (decoded['places'] is List)
        ? decoded['places'] as List
        : const <dynamic>[];

    final venues = <PlaceVenue>[];
    for (final raw in rawPlaces) {
      if (raw is! Map) continue;

      if ((raw['businessStatus']?.toString() ?? '') == 'CLOSED_PERMANENTLY') {
        continue;
      }

      final primaryType = (raw['primaryType'] ?? '').toString();
      final types = ((raw['types'] as List?) ?? const <dynamic>[])
          .map((e) => e.toString())
          .toSet();
      final amenity = _bucketFor(primaryType, types);
      if (requireFoodVenue && amenity == null) continue;

      final location = raw['location'];
      final lat = (location is Map ? location['latitude'] as num? : null)?.toDouble();
      final lng = (location is Map ? location['longitude'] as num? : null)?.toDouble();
      final name = (raw['displayName'] is Map
              ? raw['displayName']['text']
              : raw['displayName'])
          ?.toString()
          .trim();

      if (lat == null || lng == null || name == null || name.isEmpty) continue;

      venues.add(PlaceVenue(
        id: (raw['id'] ?? '$lat,$lng').toString(),
        name: name,
        amenity: amenity ?? '',
        address: (raw['formattedAddress'] ?? '').toString(),
        latitude: lat,
        longitude: lng,
      ));
    }

    return venues;
  }

  /// Collapses Places' fine-grained taxonomy (`italian_restaurant`,
  /// `coffee_shop`, `wine_bar`, …) into our four buckets. Returns null for
  /// anything that isn't a food/drink venue.
  static String? _bucketFor(String primaryType, Set<String> types) {
    bool has(String t) => primaryType == t || types.contains(t);

    if (has('cafe') || has('coffee_shop') || has('cafeteria')) return 'cafe';
    if (has('pub')) return 'pub';
    if (has('bar') || has('wine_bar') || has('bar_and_grill')) return 'bar';
    if (has('restaurant') ||
        has('food_court') ||
        has('meal_takeaway') ||
        primaryType.endsWith('_restaurant') ||
        types.any((t) => t.endsWith('_restaurant'))) {
      return 'restaurant';
    }
    return null;
  }
}
