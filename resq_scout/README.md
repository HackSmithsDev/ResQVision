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
- `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` — Flutter platform runners and native project configuration.
- `pubspec.yaml` — Flutter/Dart dependencies and asset declarations.

## Setup and run

Install Flutter, then run these commands from this folder:

```sh
flutter pub get
flutter run
```

Configure the API base URL for the intended environment before connecting to the backend. Avoid committing signing keys, service-account files, or production credentials.
