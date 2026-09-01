# meetmern

A new Flutter project.

## Configuration / secrets

All API keys live in **`env.json`** at the repo root — it is git-ignored. Copy
the template and fill it in:

```bash
cp env.example.json env.json      # then edit env.json
```

Keys in `env.json`:

| Key | Used by |
| --- | --- |
| `SUPABASE_URL`, `SUPABASE_ANON_KEY` | Supabase client (`lib/main.dart`) |
| `PLACES_API_KEY` | Google Places API (New) — venue search in Create Meetup (HTTP) |
| `MAPS_API_KEY` | Google Maps SDK — map rendering (Android manifest + iOS) |
| `ANDROID_FIREBASE_*`, `IOS_FIREBASE_*`, `FIREBASE_*` | `lib/firebase_options.dart` |

Run / build **always** passing the file:

```bash
flutter run   --dart-define-from-file=env.json
flutter build apk --dart-define-from-file=env.json
flutter test  integration_test/ -d <device> --dart-define-from-file=env.json
```

(VS Code launch configs in `.vscode/launch.json` already pass it.)

**Native pieces that can't read `--dart-define`:**

- **Android** — `android/app/build.gradle` reads `MAPS_API_KEY` straight out of
  `env.json` (or a `MAPS_API_KEY` env var for CI) and injects it as a manifest
  placeholder. Nothing else to do.
- **iOS** — copy `ios/Flutter/Keys.example.xcconfig` to
  `ios/Flutter/Keys.xcconfig` (git-ignored) and set `MAPS_API_KEY` to match
  `env.json`.

Also git-ignored and required for Firebase: `android/app/google-services.json`,
`ios/Runner/GoogleService-Info.plist`.

## Maps & location

Google is the **only** maps/geo backend — no OpenStreetMap / Nominatim / Overpass
/ OS geocoder anywhere.

- **Map rendering** — `google_maps_flutter` (needs `MAPS_API_KEY`).
- **Everything else** — `PlacesService` (`lib/data/service/places_service.dart`),
  Google **Places API (New)** over HTTP (needs `PLACES_API_KEY`):
  - venue search in Create Meetup — `places:searchNearby`
  - search box / forward geocoding — `places:searchText`
  - "Use my location" reverse geocoding — `places:searchNearby` + `addressComponents`

Required Google Cloud APIs on the project: **Maps SDK for Android/iOS** and
**Places API (New)** (+ billing). The Geocoding API is *not* used.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
