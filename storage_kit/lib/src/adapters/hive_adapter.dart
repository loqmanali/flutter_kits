import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'storage_adapter.dart';

/// {@template hive_adapter}
/// Implementation of [StorageAdapter] using Hive.
///
/// Hive is a lightweight and blazing fast key-value database.
///
/// Benefits:
/// - ✅ Much faster than SharedPreferences
/// - ✅ No size limitations
/// - ✅ Supports complex data types
/// - ✅ Encryption support
/// - ✅ Works on all platforms
///
/// Use this when:
/// - You need better performance
/// - You're storing large amounts of data
/// - You need to store complex objects
/// {@endtemplate}
class HiveAdapter implements StorageAdapter {
  late Box _box;
  final String boxName;
  final String? encryptionKey;

  HiveAdapter({
    this.boxName = 'app_storage',
    this.encryptionKey,
  });

  @override
  Future<void> init() async {
    await Hive.initFlutter();

    if (encryptionKey != null) {
      // Open encrypted box
      final key = _generateEncryptionKey(encryptionKey!);
      _box = await Hive.openBox(
        boxName,
        encryptionCipher: HiveAesCipher(key),
      );
    } else {
      // Open regular box
      _box = await Hive.openBox(boxName);
    }
  }

  /// Generate encryption key from string
  List<int> _generateEncryptionKey(String key) {
    // Ensure key is exactly 32 bytes
    final bytes = key.codeUnits;
    if (bytes.length >= 32) {
      return bytes.sublist(0, 32);
    } else {
      // Pad with zeros if too short
      return [...bytes, ...List.filled(32 - bytes.length, 0)];
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      final value = _box.get(key);
      return value as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> setString(String key, String value) async {
    try {
      await _box.put(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      final value = _box.get(key);
      return value as int?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      await _box.put(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      final value = _box.get(key);
      return value as double?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      await _box.put(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      final value = _box.get(key);
      return value as bool?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      await _box.put(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    try {
      final value = _box.get(key);
      if (value == null) return null;
      return List<String>.from(value as List);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      await _box.put(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return _box.containsKey(key);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      await _box.delete(key);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> clear({Set<String>? allowList}) async {
    try {
      if (allowList != null && allowList.isNotEmpty) {
        // Remove all keys except those in allowList
        final keysToRemove =
            _box.keys.where((key) => !allowList.contains(key)).toList();

        for (final key in keysToRemove) {
          await _box.delete(key);
        }
      } else {
        // Clear all
        await _box.clear();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Set<String>> getKeys() async {
    try {
      return _box.keys.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> reload() async {
    // Hive doesn't need reload as it's always in sync
    // But we can compact the box for optimization
    try {
      await _box.compact();
    } catch (_) {
      // Ignore errors
    }
  }

  @override
  Future<void> close() async {
    try {
      await _box.close();
    } catch (_) {
      // Ignore errors
    }
  }
}
