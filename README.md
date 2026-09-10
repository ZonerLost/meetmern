# meetmern

A new Flutter project.

## Configuration / secrets

All API keys live in **`env.json`** at the repo root — it is git-ignored. Copy
the template and fill it in:

```bash
cp .env.example .env      # then edit .env
```

Keys in `.env` (plain `KEY=value` lines):

| Key | Used by |
| --- | --- |
| `SUPABASE_URL`, `SUPABASE_ANON_KEY` | Supabase client (`lib/main.dart`) |
| `PLACES_API_KEY` | Google Places API (New) — venue search in Create Meetup (HTTP) |
| `MAPS_API_KEY` | Google Maps SDK — map rendering (Android manifest + iOS) |
| `ANDROID_FIREBASE_*`, `IOS_FIREBASE_*`, `FIREBASE_*` | `lib/firebase_options.dart` |

Run / build **always** passing the file:

```bash
# Debug
flutter run --dart-define-from-file=.env

# Release APK (single universal APK)
flutter build apk --release --dart-define-from-file=.env

# Release APK split per ABI — smaller downloads
flutter build apk --release --split-per-abi --dart-define-from-file=.env

# Play Store bundle
flutter build appbundle --release --dart-define-from-file=.env

# Integration tests
flutter test integration_test/ -d <device> --dart-define-from-file=.env
```

Output lands in `build/app/outputs/flutter-apk/app-release.apk`.

(VS Code launch configs in `.vscode/launch.json` already pass it.)

> **Release signing is not configured yet.** `android/app/build.gradle` has
> `release { signingConfig = signingConfigs.debug }`, so release APKs are signed
> with the debug key. They install and run fine for testing, but **cannot be
> uploaded to the Play Store**. Before publishing, generate an upload keystore,
> add `android/key.properties` (git-ignored), and point the release
> `signingConfig` at it.

**Native pieces that can't read `--dart-define`:**

- **Android** — `android/app/build.gradle` parses `MAPS_API_KEY` straight out of
  `.env` (or a `MAPS_API_KEY` env var for CI) and injects it as a manifest
  placeholder. Nothing else to do.
- **iOS** — copy `ios/Flutter/Keys.example.xcconfig` to
  `ios/Flutter/Keys.xcconfig` (git-ignored) and set `MAPS_API_KEY` to match
  `.env`.

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
