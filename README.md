# Athera

Athera is a Flutter application for discovering and exploring Algerian cultural heritage and historic places.

## Main application

The active Flutter project is in `terathi_v2_release/`.

## Technology

- Flutter and Dart
- Riverpod for state management
- GoRouter for navigation
- Supabase integration
- Google Generative AI integration

## Requirements

- Flutter SDK compatible with the constraints in `terathi_v2_release/pubspec.yaml`
- Dart SDK
- Android Studio or another supported Flutter development environment

## Run locally

```bash
cd terathi_v2_release
flutter pub get
flutter run
```

## Verify

```bash
cd terathi_v2_release
flutter analyze
flutter test
```

## Configuration and security

Keep API keys, Supabase credentials, and other private configuration out of Git. Use local configuration or your deployment secret manager, and never place privileged credentials in the client application.

## Repository layout

- `terathi_v2_release/` — main Flutter application
- `MyApplication/` — legacy Android Studio starter project; not the active Flutter application
