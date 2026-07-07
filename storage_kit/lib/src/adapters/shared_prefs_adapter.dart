import 'package:shared_preferences/shared_preferences.dart';

import 'storage_adapter.dart';

/// {@template shared_prefs_adapter}
/// Implementation of [StorageAdapter] using SharedPreferences.
/// This provides reliable storage with proper initialization.
/// {@endtemplate}
class SharedPrefsAdapter implements StorageAdapter {
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    // Initialize SharedPreferences synchronously
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (_) {
      // The stored value exists but is of a different type — coerce to string
      // so that callers (e.g. StorageInspector) never crash on legacy data.
      if (_prefs.containsKey(key)) {
        try {
          final boolValue = _prefs.getBool(key);
          if (boolValue != null) return boolValue.toString();
        } catch (_) {}

        try {
          final intValue = _prefs.getInt(key);
          if (intValue != null) return intValue.toString();
        } catch (_) {}

        try {
          final doubleValue = _prefs.getDouble(key);
          if (doubleValue != null) return doubleValue.toString();
        } catch (_) {}
      }
      return null;
    }
  }

  @override
  Future<bool> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      await _prefs.setDouble(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      await _prefs.setStringList(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<bool> remove(String key) async {
    try {
      await _prefs.remove(key);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> clear({Set<String>? allowList}) async {
    try {
      if (allowList != null && allowList.isNotEmpty) {
        // Get all keys
        final allKeys = _prefs.getKeys();
        // Remove keys not in allowList
        final keysToRemove = allKeys.where((key) => !allowList.contains(key));
        for (final key in keysToRemove) {
          await _prefs.remove(key);
        }
      } else {
        await _prefs.clear();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Set<String>> getKeys() async {
    return _prefs.getKeys();
  }

  @override
  Future<void> reload() async {
    // SharedPreferences doesn't have reload method
    // This is kept for interface compatibility
  }

  @override
  Future<void> close() async {
    // SharedPreferences doesn't have close method
    // This is kept for interface compatibility
  }
}
