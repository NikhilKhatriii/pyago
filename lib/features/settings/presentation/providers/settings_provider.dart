import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.highContrast = false,
    this.textScale = 1.0,
    this.locale = 'en',
    this.appLockEnabled = false,
  });

  final ThemeMode themeMode;
  final bool highContrast;
  final double textScale;
  final String locale;

  /// Off by default per the security-hardening requirement — the user
  /// must explicitly opt in from Settings.
  final bool appLockEnabled;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? highContrast,
    double? textScale,
    String? locale,
    bool? appLockEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      highContrast: highContrast ?? this.highContrast,
      textScale: textScale ?? this.textScale,
      locale: locale ?? this.locale,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._storage)
      : super(SettingsState(
          themeMode: ThemeMode.values.firstWhere(
            (m) => m.name == (_storage.getString(StorageKeys.themeMode) ?? 'system'),
            orElse: () => ThemeMode.system,
          ),
          highContrast: _storage.getBool(StorageKeys.highContrast) ?? false,
          textScale: _storage.getDouble(StorageKeys.textScale) ?? 1.0,
          locale: _storage.getString(StorageKeys.locale) ?? 'en',
          appLockEnabled: _storage.getBool(StorageKeys.appLockEnabled) ?? false,
        ));

  final LocalStorageService _storage;

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _storage.setString(StorageKeys.themeMode, mode.name);
  }

  Future<void> setHighContrast(bool value) async {
    state = state.copyWith(highContrast: value);
    await _storage.setBool(StorageKeys.highContrast, value);
  }

  Future<void> setTextScale(double value) async {
    state = state.copyWith(textScale: value);
    await _storage.setDouble(StorageKeys.textScale, value);
  }

  Future<void> setLocale(String value) async {
    state = state.copyWith(locale: value);
    await _storage.setString(StorageKeys.locale, value);
  }

  Future<void> setAppLockEnabled(bool value) async {
    state = state.copyWith(appLockEnabled: value);
    await _storage.setBool(StorageKeys.appLockEnabled, value);
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController(ref.watch(localStorageProvider));
});
