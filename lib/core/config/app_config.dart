/// Environment/flavor configuration.
///
/// **This file is the one documented seam for pointing Pyago at a real
/// backend.** Everything upstream (repositories, providers, UI) talks to
/// [ApiClient] and the repository interfaces only — nothing else needs to
/// change when a real API exists.
///
/// To go live:
/// 1. Set [Flavor.staging] or [Flavor.production] via `--dart-define=PYAGO_FLAVOR=staging`
///    (see `AppConfig.current`), or hard-code it here for a release build.
/// 2. Fill in [AppConfig.baseUrl] for that flavor.
/// 3. In `lib/core/di/repository_providers.dart`, the repository providers
///    already branch on `AppConfig.current.useMockData` — for `staging`/
///    `production` they resolve to the real `Http*Repository` implementations
///    instead of the `Mock*Repository` ones. No UI or provider-shape changes
///    are required either way.
library;

enum Flavor { dev, staging, production }

class AppConfig {
  const AppConfig._({
    required this.flavor,
    required this.baseUrl,
    required this.useMockData,
    required this.simulatedLatencyMs,
    required this.simulatedFailureRate,
  });

  /// Test-only constructor so unit tests can inject specific latency/
  /// failure-rate values (e.g. 0% or 100%) without depending on the
  /// `--dart-define` environment resolution used by [current].
  const AppConfig.forTest({
    this.simulatedLatencyMs = 0,
    this.simulatedFailureRate = 0,
  })  : flavor = Flavor.dev,
        baseUrl = 'https://test.invalid',
        useMockData = true;

  final Flavor flavor;
  final String baseUrl;

  /// When true, repositories are backed by the realistic in-memory fake
  /// data source (`lib/core/network/mock/`) instead of real HTTP calls.
  /// The fake data source still goes through [ApiClient]-shaped
  /// pagination/latency/error behavior, so swapping this to `false`
  /// requires no UI changes — only real repository implementations.
  final bool useMockData;

  final int simulatedLatencyMs;

  /// 0.0–1.0 chance any given mock request fails with a transient error,
  /// so error/retry paths get exercised the same way they would against
  /// a real, occasionally-flaky API.
  final double simulatedFailureRate;

  static const _flavorName = String.fromEnvironment(
    'PYAGO_FLAVOR',
    defaultValue: 'dev',
  );

  static final AppConfig current = _resolve(_flavorName);

  static AppConfig _resolve(String name) {
    switch (name) {
      case 'staging':
        return const AppConfig._(
          flavor: Flavor.staging,
          baseUrl: 'https://staging.api.pyago.app',
          useMockData: false,
          simulatedLatencyMs: 0,
          simulatedFailureRate: 0,
        );
      case 'production':
        return const AppConfig._(
          flavor: Flavor.production,
          baseUrl: 'https://api.pyago.app',
          useMockData: false,
          simulatedLatencyMs: 0,
          simulatedFailureRate: 0,
        );
      case 'dev':
      default:
        return const AppConfig._(
          flavor: Flavor.dev,
          baseUrl: 'https://dev.api.pyago.app',
          useMockData: true,
          simulatedLatencyMs: 450,
          simulatedFailureRate: 0.06,
        );
    }
  }

  bool get isDev => flavor == Flavor.dev;
}
