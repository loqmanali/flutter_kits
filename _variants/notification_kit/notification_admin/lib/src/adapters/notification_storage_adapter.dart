import 'package:shared_preferences/shared_preferences.dart';

/// Storage contract used by notification_kit to persist settings, history,
/// counters and subscribed topics.
///
/// The host app can supply its own implementation (Hive, secure storage,
/// custom backend, etc.) via [NotificationKitRuntime.use].
/// When nothing is provided, the kit falls back to [SharedPreferencesAdapter].
abstract class NotificationStorageAdapter {
  Future<bool> setString(String key, String value);
  Future<String?> getString(String key);

  Future<bool> setInt(String key, int value);
  Future<int?> getInt(String key);

  Future<bool> setStringList(String key, List<String> value);
  Future<List<String>?> getStringList(String key);

  Future<bool> remove(String key);
}

/// Default storage adapter — backed by [SharedPreferences].
class SharedPreferencesAdapter implements NotificationStorageAdapter {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<bool> setString(String key, String value) async =>
      (await _instance).setString(key, value);

  @override
  Future<String?> getString(String key) async =>
      (await _instance).getString(key);

  @override
  Future<bool> setInt(String key, int value) async =>
      (await _instance).setInt(key, value);

  @override
  Future<int?> getInt(String key) async => (await _instance).getInt(key);

  @override
  Future<bool> setStringList(String key, List<String> value) async =>
      (await _instance).setStringList(key, value);

  @override
  Future<List<String>?> getStringList(String key) async =>
      (await _instance).getStringList(key);

  @override
  Future<bool> remove(String key) async => (await _instance).remove(key);
}
