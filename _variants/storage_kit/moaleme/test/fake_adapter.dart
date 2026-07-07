import 'package:storage_kit/storage_kit.dart';

/// A simple in-memory [StorageAdapter] for tests.
///
/// Mirrors the semantics of the real adapters closely enough to exercise
/// [AppStorage] and [StorageInspector] without any platform channels:
/// values are kept type-segregated in a single map keyed by [key], and
/// round-trips preserve types.
class FakeAdapter implements StorageAdapter {
  final Map<String, Object?> _store = <String, Object?>{};

  bool initCalled = false;
  bool reloadCalled = false;
  bool closeCalled = false;

  /// Direct, read-only view of the backing store (for assertions).
  Map<String, Object?> get raw => Map<String, Object?>.unmodifiable(_store);

  @override
  Future<void> init() async {
    initCalled = true;
  }

  // Typed getters mirror SharedPreferences/Hive semantics: a getter returns
  // null when the stored value is of a different type, rather than throwing.
  @override
  Future<String?> getString(String key) async {
    final v = _store[key];
    return v is String ? v : null;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async {
    final v = _store[key];
    return v is int ? v : null;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<double?> getDouble(String key) async {
    final v = _store[key];
    return v is double ? v : null;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async {
    final v = _store[key];
    return v is bool ? v : null;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final v = _store[key];
    if (v is! List) return null;
    return List<String>.from(v);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _store[key] = List<String>.from(value);
    return true;
  }

  @override
  Future<bool> containsKey(String key) async => _store.containsKey(key);

  @override
  Future<bool> remove(String key) async {
    _store.remove(key);
    return true;
  }

  @override
  Future<bool> clear({Set<String>? allowList}) async {
    if (allowList == null || allowList.isEmpty) {
      _store.clear();
      return true;
    }
    _store.removeWhere((key, _) => !allowList.contains(key));
    return true;
  }

  @override
  Future<Set<String>> getKeys() async => _store.keys.toSet();

  @override
  Future<void> reload() async {
    reloadCalled = true;
  }

  @override
  Future<void> close() async {
    closeCalled = true;
  }
}
