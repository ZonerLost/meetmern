// Runs on a real device/emulator so it exercises the actual Android/iOS
// network stack and the same `http` client the app uses.
//
//   flutter test integration_test/places_service_test.dart \
//     -d emulator-5554 --dart-define-from-file=env.json

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meetmern/data/service/places_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PlacesService (live)', () {
    test('key is configured', () {
      expect(PlacesService.isConfigured, isTrue);
    });

    test('searchNearby returns cafe/restaurant/bar/pub venues around a point',
        () async {
      // Piccadilly Circus, London — dense with venues.
      final venues = await PlacesService.searchNearbyVenues(
        latitude: 51.5098,
        longitude: -0.1342,
        radiusMeters: 1200,
      );

      // ignore: avoid_print
      print('PlacesService returned ${venues.length} venues:');
      for (final v in venues.take(15)) {
        // ignore: avoid_print
        print('  • ${v.name}  [${v.amenity}]  ${v.latitude},${v.longitude}');
      }

      expect(venues, isNotEmpty,
          reason: 'Places returned no venues — check API enablement/billing');

      const allowed = {'cafe', 'restaurant', 'bar', 'pub'};
      expect(
        venues.every((v) => allowed.contains(v.amenity)),
        isTrue,
        reason: 'every venue must be normalised to one of $allowed',
      );

      expect(
        venues.every((v) =>
            v.latitude.abs() <= 90 &&
            v.longitude.abs() <= 180 &&
            v.name.isNotEmpty),
        isTrue,
      );
    });
  });
}
