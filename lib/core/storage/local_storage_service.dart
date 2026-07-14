import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/app_exception.dart';

/// Thin, testable wrapper around [SharedPreferences]. Every feature
/// depends on this abstraction instead of touching the plugin directly,
/// which keeps persistence swappable and mockable.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);
  bool? getBool(String key) => _prefs.getBool(key);
  double? getDouble(String key) => _prefs.getDouble(key);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<void> setString(String key, String value) async {
    final ok = await _prefs.setString(key, value);
    if (!ok) throw const StorageException();
  }

  Future<void> setBool(String key, bool value) async {
    final ok = await _prefs.setBool(key, value);
    if (!ok) throw const StorageException();
  }

  Future<void> setDouble(String key, double value) async {
    final ok = await _prefs.setDouble(key, value);
    if (!ok) throw const StorageException();
  }

  Future<void> setStringList(String key, List<String> value) async {
    final ok = await _prefs.setStringList(key, value);
    if (!ok) throw const StorageException();
  }

  Future<void> remove(String key) => _prefs.remove(key);
}

/// Overridden in [main] once SharedPreferences has resolved, so the rest
/// of the app can depend on it synchronously.
final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageProvider must be overridden in main()');
});
