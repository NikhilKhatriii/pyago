/// App-wide constant values that are not user-configurable.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Pyago';
  static const String tagline = 'A quiet place for what you have to say.';

  static const int otpLength = 6;
  static const int maxBioLength = 280;
  static const int maxPostTitleLength = 120;
  static const int autoSaveIntervalSeconds = 15;

  static const List<String> supportedLocales = [
    'en',
    'ne',
    'hi',
    'ja',
    'de',
    'fr',
    'ar',
  ];

  static const List<String> rtlLocales = ['ar'];
}

/// SharedPreferences / secure-storage key names, kept in one place so
/// no key is ever typo'd across features.
class StorageKeys {
  const StorageKeys._();

  static const String themeMode = 'pyago.theme_mode';
  static const String highContrast = 'pyago.high_contrast';
  static const String textScale = 'pyago.text_scale';
  static const String locale = 'pyago.locale';
  static const String onboardingComplete = 'pyago.onboarding_complete';
  // Deprecated: tokens now live exclusively in `SecureTokenStorage`
  // (flutter_secure_storage), never in SharedPreferences. Kept only so
  // an upgrading install can detect + wipe a stale plaintext token.
  static const String authToken = 'pyago.auth_token';
  static const String appLockEnabled = 'pyago.app_lock_enabled';
  static const String recentSearches = 'pyago.recent_searches';
  static const String draftPrefix = 'pyago.draft.';
}
