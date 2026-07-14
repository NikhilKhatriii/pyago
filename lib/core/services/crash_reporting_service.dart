import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstraction over a crash/error reporting backend (Sentry, Firebase
/// Crashlytics, DataDog, etc.).
///
/// The dev flavor uses [NoOpCrashReportingService], which just prints to the
/// console. For staging/production, swap in a real implementation:
///
/// ```dart
/// // lib/core/services/sentry_crash_reporting_service.dart
/// import 'package:sentry_flutter/sentry_flutter.dart';
///
/// class SentryCrashReportingService implements CrashReportingService {
///   @override
///   Future<void> recordError(Object error, StackTrace? stack, {
///     String? context,
///     bool fatal = false,
///   }) => Sentry.captureException(error, stackTrace: stack);
///
///   @override
///   Future<void> setUserContext({required String userId, String? email}) =>
///       Sentry.configureScope((s) => s.setUser(SentryUser(id: userId, email: email)));
///
///   @override
///   Future<void> clearUserContext() =>
///       Sentry.configureScope((s) => s.setUser(null));
/// }
/// ```
///
/// Then override [crashReportingServiceProvider] in your ProviderScope:
/// ```dart
/// crashReportingServiceProvider.overrideWithValue(SentryCrashReportingService())
/// ```
abstract interface class CrashReportingService {
  /// Records a non-fatal error. Call this from catch blocks in repositories
  /// and notifiers to surface unexpected failures in your monitoring dashboard.
  ///
  /// [context] is an optional human-readable label for where the error
  /// occurred (e.g. `'FeedController.loadMore'`).
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? context,
    bool fatal = false,
  });

  /// Associates subsequent error reports with the given authenticated user.
  /// Call this after successful login.
  Future<void> setUserContext({required String userId, String? email});

  /// Clears the user association. Call this on logout.
  Future<void> clearUserContext();
}

/// No-op implementation used in the `dev` flavor and in tests.
/// Errors are printed to the console so they are still visible during
/// development, but nothing is sent to a remote service.
class NoOpCrashReportingService implements CrashReportingService {
  const NoOpCrashReportingService();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? context,
    bool fatal = false,
  }) async {
    final label = context != null ? '[$context] ' : '';
    // ignore: avoid_print
    print('🐛 ${fatal ? 'FATAL ' : ''}Error ${label}recorded (dev/no-op): $error');
    if (stack != null) {
      // ignore: avoid_print
      print(stack);
    }
  }

  @override
  Future<void> setUserContext({required String userId, String? email}) async {}

  @override
  Future<void> clearUserContext() async {}
}

/// Global provider for the crash reporting service.
///
/// In `main()`, override this with your real implementation for
/// staging/production builds:
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     crashReportingServiceProvider.overrideWithValue(
///       SentryCrashReportingService(),
///     ),
///   ],
///   child: const PyagoApp(),
/// )
/// ```
final crashReportingServiceProvider = Provider<CrashReportingService>(
  (_) => const NoOpCrashReportingService(),
  name: 'crashReportingServiceProvider',
);
