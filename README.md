# Pyago

[![CI](https://github.com/your-org/pyago/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/your-org/pyago/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/your-org/pyago/branch/main/graph/badge.svg)](https://codecov.io/gh/your-org/pyago)
[![Flutter](https://img.shields.io/badge/Flutter-3.x_stable-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4%2B-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> A quiet, feature-first Flutter app for meaningful writing and reading — journals, poetry, articles, voice notes, and slow, deliberate community discussion.

---

## Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Environment Flavors](#environment-flavors)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Testing](#testing)
- [CI/CD](#cicd)
- [Contributing](#contributing)
- [Security](#security)
- [Changelog](#changelog)

---

## Overview

Pyago is a long-form social writing platform built with Flutter. It is designed around a single conviction: that the best social products are slow, deliberate, and focused entirely on the quality of what people share — not the speed at which they share it.

**Phase 2 features (all in this repo):**

| Area | What's in |
|---|---|
| **Network layer** | `ApiClient` (Dio) with auth-token interceptor, refresh-on-401, retry with back-off, offline short-circuit |
| **Mock backend** | `MockEngine` — realistic latency, pagination, and ~6 % injected failure rate so error/retry paths are always exercised |
| **Offline-first** | Hive-backed feed cache, drafts, bookmarks, and mutation outbox that replays on reconnect |
| **Feed** | Cursor-paginated batches with session cap, pull-to-refresh, optimistic resonance with rollback |
| **Create** | Selection-aware Markdown toolbar, live preview, image/video/voice attachment, drag-to-reorder, autosave drafts |
| **Chat** | `RealtimeChannel<T>` abstraction, typing indicators, read receipts, pending/sent/failed message lifecycle |
| **Auth** | Biometric/PIN `AppLockGate`, tokens exclusively in `flutter_secure_storage` |
| **Localization** | Full `flutter_localizations` + ARB setup for 7 languages (en, ne, hi, ja, de, fr, ar) |
| **Push notifications** | Scaffolding with tap-to-deep-link, documented for FCM wiring |
| **Testing** | Unit + widget + golden + integration tests; coverage uploaded to Codecov on every CI run |

---

## Screenshots

> Add real device screenshots here once the app is running locally.
> Use `flutter screenshot` or Android Studio's device capture.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Material 3) |
| State | Riverpod 2 + code generation (`riverpod_annotation`) |
| Navigation | GoRouter 14 |
| Networking | Dio 5, `web_socket_channel` |
| Local storage | Hive 2, `flutter_secure_storage` |
| Fonts | Google Fonts (Inter UI + Merriweather display) |
| Animation | `flutter_animate` |
| Models | `freezed` + `json_serializable` |
| Localization | `flutter_localizations` + ARB |
| Testing | `mocktail`, `golden_toolkit`, `integration_test` |
| CI | GitHub Actions + Codecov |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x stable (`flutter --version`)
- Android Studio Ladybug or VS Code with the Dart + Flutter extensions
- Java 17 (for Android builds — `java -version`)

### First-time setup

```bash
# 1. Clone
git clone https://github.com/your-org/pyago.git
cd pyago

# 2. Install Flutter dependencies
flutter pub get

# 3. Run the code generator (required for Riverpod + freezed)
dart run build_runner build --delete-conflicting-outputs

# 4. Run on a connected device or emulator (defaults to dev flavor)
flutter run --dart-define-from-file=.dart_defines/dev.json
```

No backend is required. The `dev` flavor runs entirely against the in-memory
mock backend — you will see realistic loading, pagination, and occasional
transient errors (by design — they exercise error/retry UI paths).

### VS Code

Open the repo in VS Code, accept the extensions prompt, then select one of the
pre-configured launch profiles from the Run & Debug panel (`Ctrl+Shift+D`):
- **Pyago (dev)** — mock backend, debug mode
- **Pyago (staging)** — real backend, debug mode
- **Pyago (production)** — real backend, release mode

### Pre-commit hooks

```bash
# Install Lefthook (enforces dart format + flutter analyze before every commit)
brew install lefthook   # macOS; see CONTRIBUTING.md for other platforms
lefthook install
```

---

## Environment Flavors

Set via `--dart-define=PYAGO_FLAVOR=dev|staging|production` (default `dev`).
The flavor files live in `.dart_defines/`. **`lib/core/config/app_config.dart`
is the single seam** for pointing the app at a real backend.

| Flavor | Mock data | Backend URL |
|---|---|---|
| `dev` | ✅ (6 % failure injection, 450 ms latency) | n/a |
| `staging` | ❌ | `https://staging.api.pyago.app` |
| `production` | ❌ | `https://api.pyago.app` |

Switching to a real backend for `staging`/`production` requires **zero UI or
provider-shape changes** — only a real `Http*Repository` implementation in
`lib/features/*/data/repositories/` needs to be added, and the single
`AppConfig.useMockData` branch in the DI layer picks it up.

---

## Project Structure

```
lib/
├── core/
│   ├── config/             — AppConfig (flavor/backend swap seam)
│   ├── constants/          — AppConstants (app name, locales, etc.)
│   ├── errors/             — Typed AppException hierarchy (9 subtypes)
│   ├── extensions/         — Dart extension methods
│   ├── helpers/            — Utility functions
│   ├── models/             — Shared domain primitives
│   ├── network/
│   │   ├── api_client.dart         — Dio wrapper (Result<T>, auth, retry)
│   │   ├── connectivity_service.dart
│   │   ├── interceptors/           — Auth, retry, logging, error-mapper
│   │   ├── mock/                   — MockEngine (latency, pagination, failures)
│   │   ├── offline_queue.dart      — Mutation outbox
│   │   ├── pagination.dart         — Page<T> cursor model
│   │   ├── realtime/               — RealtimeChannel<T> abstraction + WS impl
│   │   └── result.dart             — Sealed Result<T> (Success / Failure)
│   ├── routing/            — GoRouter + auth-gated redirect
│   ├── services/
│   │   ├── app_lock_gate.dart      — Biometric/PIN gate
│   │   ├── biometric_service.dart
│   │   ├── crash_reporting_service.dart  — CrashReportingService abstraction
│   │   └── push_notification_service.dart
│   ├── shared/
│   │   ├── animations/     — Shared animation helpers
│   │   ├── app_shell.dart  — Bottom-nav StatefulShellRoute host
│   │   └── widgets/        — PyagoButton, PyagoAvatar, SkeletonLoader, …
│   ├── storage/            — HiveService, LocalStorageService, SecureTokenStorage
│   └── theme/              — AppColors, AppTypography, AppTheme, AppSpacing, …
│
├── features/
│   ├── auth/               — Splash → Welcome → Onboarding → Login/Register → OTP → Profile
│   ├── bookmarks/          — Local-first bookmarks
│   ├── chat/               — Full real-time chat (threads + messages)
│   ├── communities/        — Community browsing
│   ├── create/             — Rich create screen (Markdown + media + drafts)
│   ├── drafts/             — Draft management
│   ├── explore/            — Explore feed
│   ├── home/               — Main feed + comments
│   ├── notifications/      — Notification list
│   ├── onboarding/         — Interest selection
│   ├── profile/            — User profile
│   ├── search/             — Search
│   └── settings/           — Theme, locale, text scale, app lock
│
├── l10n/                   — ARB localisation files (en, ne, hi, ja, de, fr, ar)
└── main.dart
```

---

## Architecture

Pyago uses **clean architecture** applied feature-first:

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│   Screens ← Riverpod Providers/Notifiers → Widgets   │
└─────────────────────┬───────────────────────────────┘
                      │ depends on
┌─────────────────────▼───────────────────────────────┐
│                   Domain Layer                       │
│       Repository Interfaces   Domain Models          │
└─────────────────────┬───────────────────────────────┘
                      │ implements
┌─────────────────────▼───────────────────────────────┐
│                    Data Layer                        │
│    Mock*Repository  ←──── AppConfig.useMockData      │
│    Http*Repository  ←/                               │
│         ↓                                            │
│     ApiClient (Dio)  /  HiveService                  │
└─────────────────────────────────────────────────────┘
```

**Key patterns:**

- **`Result<T>`** — Sealed `Success<T>` / `Failure<T>` wrapper returned by all repository methods. Presenters pattern-match via `.when()` instead of try/catch.
- **Repository interfaces** — Every feature's `domain/repositories/` contains an abstract interface. The DI layer (`AppConfig.useMockData`) decides which implementation to inject — no UI code ever knows.
- **MockEngine** — Single source of simulated latency, pagination, and failure injection so all mock repositories behave consistently. Swap to a real backend later with zero UI changes.
- **Offline outbox** — `OfflineQueue` serialises mutations to Hive while offline and replays them in order on reconnect.

---

## Testing

```bash
# All unit + widget tests
flutter test

# Regenerate golden baselines (run once, then commit the PNGs)
flutter test --update-goldens test/golden/

# Integration tests (requires a connected device or simulator)
flutter test integration_test/app_test.dart
```

Coverage is uploaded to Codecov automatically by CI. To view locally:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## CI/CD

Three GitHub Actions workflows:

| Workflow | Triggers | Jobs |
|---|---|---|
| **CI** (`ci.yml`) | Push/PR to `main`, `develop` | Analyze + format + test + Codecov upload; Debug APK build; Integration tests |
| **Release** (`release.yml`) | Push of `v*` tag | Signed release APK + AAB + GitHub Release |

Dependency updates are automated weekly via **Dependabot** for both pub packages
and GitHub Actions.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide, including:
- Local environment setup and pre-commit hooks
- Branch naming and PR size conventions
- Commit message format (Conventional Commits)
- Architecture rules and code-style guide

---

## Security

See [SECURITY.md](SECURITY.md) for the vulnerability disclosure policy and
security architecture notes.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed version history.
