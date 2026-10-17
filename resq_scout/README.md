# ResQVision Scout

`resq_scout` is the Flutter mobile application for field operators and shared account/data features. Aircraft command transmission and 5.8 GHz receiver video are handled directly by the single `resq_command` ground station; Scout does not depend on cloud routes for those radio links.

## Layout

- `lib/app/` — application-level setup and shared behavior.
- `lib/config/` — environment and app configuration.
- `lib/data/` — data access and API-facing code.
- `lib/models/` — application data models.
- `lib/providers/` — state providers.
- `lib/screens/` — operator-facing screens.
- `lib/widgets/` — reusable UI elements.
- `public/` — shared static resources.
- `android/`, `ios/` — the only supported Scout application targets.
- `pubspec.yaml` — Flutter/Dart dependencies and asset declarations.

## Setup and run

Install Flutter, then run these commands from this folder:

```sh
flutter pub get
flutter devices
flutter run -d <android-device-id>
# or
flutter run -d <ios-device-id>
```

Configure the API base URL for the intended environment before connecting to the backend:

```sh
flutter run -d <android-device-id> --dart-define=RESQ_API_BASE_URL=https://api.example.invalid
# or
flutter run -d <ios-device-id> --dart-define=RESQ_API_BASE_URL=https://api.example.invalid
```

Scout is a mobile app; web and desktop runner targets are intentionally not included.

The Scout account screen signs in through the backend. Access and rotating refresh tokens are stored using platform secure storage and renewed automatically through `/auth/token/refresh`. The refresh lifetime is `REFRESH_TOKEN_EXPIRE_DAYS` (7 days by default) and resets on each refresh, so an active operator stays signed in while an unused session expires after the configured interval or when revoked. Fleet, missions, reports, team messages, emergency actions, and AI insights are loaded from authenticated `/workspace/{collection}` routes; empty, loading, authentication, and error states are shown without demo records. Aircraft commands and receiver video remain local to Command/FC hardware. Avoid committing signing keys, service-account files, or production credentials.
