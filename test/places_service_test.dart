// Live checks of the Google Places (New) integration — the app's only
// mapping/geocoding backend. Hits the real API.
//
//   flutter test test/places_service_test.dart --dart-define-from-file=env.json

import 'package:flutter_test/flutter_test.dart';
import 'package:meetmern/data/service/places_service.dart';

void main() {
  final configured = PlacesService.isConfigured;
  final skip =
      configured ? null : 'PLACES_API_KEY not set (--dart-define-from-file=env.json)';

  test('searchNearbyVenues returns cafe/restaurant/bar/pub venues', () async {
    final venues = await PlacesService.searchNearbyVenues(
      latitude: 51.5098,
      longitude: -0.1342,
      radiusMeters: 1200,
    );
    // ignore: avoid_print
    print('venues: ${venues.length}');
    for (final v in venues.take(10)) {
      // ignore: avoid_print
      print('  - ${v.name} [${v.amenity}]');
    }
    expect(venues, isNotEmpty);
    const allowed = {'cafe', 'restaurant', 'bar', 'pub'};
    expect(venues.every((v) => allowed.contains(v.amenity)), isTrue);
  }, skip: skip);

  test('geocode resolves a place name to coordinates', () async {
    final point = await PlacesService.geocode('Soho, London, UK');
    // ignore: avoid_print
    print('geocode -> $point / ${point?.address}');
    expect(point, isNotNull);
    expect(point!.latitude, closeTo(51.51, 0.1));
    expect(point.longitude, closeTo(-0.13, 0.1));
  }, skip: skip);

  test('reverseGeocode resolves a dropped pin to a street-level address',
      () async {
    final addr = await PlacesService.reverseGeocode(
      latitude: 51.5098,
      longitude: -0.1342,
    );
    // ignore: avoid_print
    print('reverseGeocode -> $addr');
    expect(addr, isNotNull);
    expect(addr!.toLowerCase(), contains('london'));
  }, skip: skip);

  test('reverseGeocodeArea resolves coordinates to a City, Country label',
      () async {
    final label = await PlacesService.reverseGeocodeArea(
      latitude: 51.5074,
      longitude: -0.1278,
    );
    // ignore: avoid_print
    print('reverseGeocodeArea -> $label');
    expect(label, isNotNull);
    expect(label!.toLowerCase(), contains('london'));
  }, skip: skip);
}
