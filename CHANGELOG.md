# Changelog

All notable changes to Pyago will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- Adaptive launcher icon + native splash screen via `flutter_launcher_icons` and `flutter_native_splash`
- Embedded Inter font locally for offline-safe typography
- `CrashReportingService` abstraction with a no-op dev implementation and Sentry stub
- `SessionExpiredNotifier` — replaces the raw `StateProvider<int>` counter anti-pattern with a typed `AsyncNotifier`-based stream
- `.dart_defines/` environment files for `dev`, `staging`, and `production` flavors
- `.vscode/launch.json` with pre-configured dart-define launch profiles for all three flavors
- `lefthook.yml` for local pre-commit formatting + analysis enforcement
- `.github/dependabot.yml` for automated weekly dependency updates (pub + GitHub Actions)
- `.github/workflows/release.yml` — release APK build with signing, artifact upload, and GitHub Release creation
- Code coverage upload to Codecov on every CI run
- CI status and coverage badges in README
- `tertiaryContainer` / `onTertiaryContainer` set explicitly in `AppTheme` dark `ColorScheme`
- `MockChatRepository.dispose()` — all broadcast `StreamController`s and `Timer`s are now cancelled on provider dispose
- Stronger `analysis_options.yaml`: `avoid_dynamic_calls`, `cancel_subscriptions`, `close_sinks`, `unawaited_futures`, `riverpod_lint` rules active

### Changed
- CI Flutter version updated from pinned `3.24.0` to `flutter-version-file: pubspec.yaml` + `channel: stable`
- Integration test CI job no longer silently swallows failures with `|| echo`; missing simulator exits clearly
- `appRouterProvider` annotated `keepAlive: true` — router instance is no longer recreated on provider graph refreshes
- README overhauled: architecture diagram, badge row, flavor setup guide, contribution quickstart

### Fixed
- `sessionExpiredSignalProvider` was a mutable `StateProvider<int>` bumped as a side-effect inside `ApiClient`; replaced with a proper event-stream notifier
- `_OfflineBanner` referenced `scheme.tertiaryContainer` which was `Colors.transparent` in the manually-constructed dark `ColorScheme`

---

## [0.2.0] — Phase 2 — 2026-06-01

### Added
- Full data layer: `dio`-based `ApiClient` with auth-token interceptor (refresh-on-401, single retry, force-logout), debug-only `LoggingInterceptor`, `RetryInterceptor` with exponential back-off, offline short-circuit
- `MockEngine`: realistic in-memory fake backend with latency simulation, pagination, and ~6 % injected transient-failure rate
- Hive-backed offline persistence (`HiveService`) for feed cache, drafts, bookmarks, and an offline mutation outbox
- Feed cursor-pagination with session cap, pull-to-refresh, optimistic resonance with rollback
- Rich create screen: selection-aware Markdown toolbar, live preview, image/video/voice-note attachment picking, drag-to-reorder, draft autosave
- Full chat feature: `RealtimeChannel<T>` abstraction, `MockChatRepository` with typing indicators, read receipts, optimistic pending/sent/failed message lifecycle
- Biometric/PIN `AppLockGate`, `SecureTokenStorage` (tokens never touch `SharedPreferences`)
- `flutter_localizations` + ARB setup for 7 languages (en, ne, hi, ja, de, fr, ar)
- Push-notification scaffolding with tap-to-deep-link via `PushNotificationService`
- CI pipeline: format check + `flutter analyze --fatal-infos` + `flutter test --coverage` + debug APK + integration test
- Unit tests for `MockEngine`, `Result<T>`, `DraftModel`, `FeedController`; widget tests + golden baselines for `PyagoButton`, `PyagoAvatar`, `PyagoTag`; integration test covering bottom-nav + create-and-publish flow

### Changed
- `MainActivity` switched to `FlutterFragmentActivity` (required by `local_auth`)
- Android `build.gradle.kts` has core-library desugaring enabled (required by `flutter_local_notifications`)
- `AndroidManifest.xml` updated with all Phase 2 permissions (network state, camera, mic, media, biometric, notifications)

---

## [0.1.0] — Phase 1 — 2026-04-15

### Added
- Project scaffold: clean architecture layout (`lib/core`, `lib/features/<feature>/{data,domain,presentation}`)
- Material 3 design system: `AppColors`, `AppTypography` (Inter UI + Merriweather display), `AppTheme` (light/dark/high-contrast), `AppSpacing`, `AppRadius`, `AppElevation`, `AppAnimations`
- Shared component library: `PyagoButton`, `PyagoAvatar`, `PyagoBadge`, `PyagoCard`, `PyagoTextField`, `SkeletonLoader`, `EmptyState`, `ErrorState`, `SectionHeader`, `LoadingIndicator`
- GoRouter navigation: `StatefulShellRoute` bottom-nav shell + auth-gated redirect
- Riverpod state management with `riverpod_generator` and `riverpod_annotation`
- Five shell destinations: Home feed, Explore, Create, Communities, Profile
- Auth flow: Splash → Welcome → Onboarding → Login / Register → OTP verification → Complete profile
- Settings screen: theme toggle, text scale, high-contrast, locale, app-lock
- `flutter_localizations` delegate setup (7 locales declared, en implemented)

[Unreleased]: https://github.com/your-org/pyago/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/your-org/pyago/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/your-org/pyago/releases/tag/v0.1.0
