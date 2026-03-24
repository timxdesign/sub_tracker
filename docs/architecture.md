# Architecture

## Overview

The codebase uses a feature-first Flutter structure:

- `app/`: application composition, dependency injection, router, theme
- `core/`: shared primitives such as storage, logging, widgets, constants
- `features/`: business features, each split into `data`, `domain`, and `presentation`

## Layers

### Presentation

Presentation state is managed with `provider` and `ChangeNotifier`-based view models.
Routes create screen-scoped view models, and widgets consume them through `Consumer`,
`context.read`, and `context.watch`.

### Domain

Domain code contains models, repository contracts, and use cases. This keeps screens and
view models from depending directly on persistence or networking details.

### Data

Data code contains DTOs, local data sources, remote data sources, and repository
implementations. Repositories coordinate between local and remote sources.

## Current Tradeoffs

- Local persistence currently uses JSON encoded values in `SharedPreferences`.
- The app is offline-first and treats local storage as the source of truth.
- Remote sync failures are logged and should not block local usage.

## Safe Improvement Path

The safest path for scaling this app is:

1. Keep the feature-first structure.
2. Standardize controller patterns and error reporting.
3. Expand test coverage and CI checks.
4. Migrate entity storage from preferences to a proper local database in a staged release.
