# Sub Tracker

Sub Tracker is a Flutter application for tracking subscriptions, renewal dates,
spending, and profile preferences with offline-first local persistence.

## Stack

- Flutter
- `provider` + `ChangeNotifier` for presentation state
- `go_router` for routing
- `shared_preferences` backed JSON persistence for the current offline store
- Feature-first structure with `data`, `domain`, and `presentation` layers

## Project Structure

```text
lib/
  app/        App shell, DI, router, theme
  core/       Shared utilities, storage, widgets, logging
  features/   Feature modules split into data/domain/presentation
```

Additional architecture notes live in [docs/architecture.md](docs/architecture.md).

## Getting Started

1. Install Flutter SDK `3.35+` and verify with `flutter doctor`.
2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Optional Environment Variables

Remote sync endpoints are configured with compile-time defines:

```bash
flutter run --dart-define=FORM_SERVICE_ENDPOINT=https://example.com/profile-sync --dart-define=SUBSCRIPTIONS_SERVICE_ENDPOINT=https://example.com/subscriptions-sync
```

If these values are omitted, the app continues to work in offline-first mode.

## Quality Checks

Run the standard checks before merging:

```bash
flutter analyze --no-pub lib test
flutter test
```

## Current Engineering Guidelines

- Keep UI behavior stable while improving internal structure.
- Add shared logic to `core/` only when it is used by multiple features.
- Prefer feature-local changes over app-wide rewrites.
- Preserve the current design language unless a redesign is intentional.
