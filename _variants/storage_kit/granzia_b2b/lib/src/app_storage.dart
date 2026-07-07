import 'adapters/hive_adapter.dart';
import 'adapters/shared_prefs_adapter.dart';
import 'adapters/storage_adapter.dart';
import 'storage_type.dart';

/// {@template app_storage}
/// Process-wide entry point for key/value storage.
///
/// The class is intentionally **generic** — it exposes a single uniform API
/// over different backends ([SharedPreferencesAdapter], [HiveAdapter]) and
/// stays free of any domain-specific keys or convenience methods. Apps that
/// want a higher-level API (auth tokens, user profile, etc.) should build
/// their own repository on top of this class.
///
/// Usage:
/// ```dart
/// // Initialize once at app startup
/// await AppStorage.initialize();
///
/// // Use anywhere in the app
/// await AppStorage.instance.setString('key', 'value');
/// final value = await AppStorage.instance.getString('key');
/// ```
///
/// Switching backends:
/// ```dart
/// await AppStorage.initialize(type: StorageType.hive);
///
/// // Hive with encryption
/// await AppStorage.initialize(
///   type: StorageType.hive,
///   hiveBoxName: 'secure_storage',
///   hiveEncryptionKey: 'my-32-byte-encryption-key',
/// );
/// ```
///
/// Supplying a custom adapter (e.g. secure_storage, in-memory mock, etc.):
/// ```dart
/// await AppStorage.initializeWithAdapter(MyCustomAdapter());
/// ```
/// {@endtemplate}
class AppStorage {
  AppStorage._();

  static AppStorage? _instance;
  static StorageAdapter? _adapter;

  /// Initialize with a built-in backend.
  ///
  /// [type] - Storage backend type (default: [StorageType.sharedPrefs]).
  /// [hiveBoxName] - Name of Hive box if using Hive.
  /// [hiveEncryptionKey] - Encryption key for Hive if needed.
  static Future<void> initialize({
    StorageType type = StorageType.sharedPrefs,
    String? hiveBoxName,
    String? hiveEncryptionKey,
  }) async {
    if (_instance != null) return;

    switch (type) {
      case StorageType.sharedPrefs:
        _adapter = SharedPrefsAdapter();
        break;
      case StorageType.hive:
        _adapter = HiveAdapter(
          boxName: hiveBoxName ?? 'app_storage',
          encryptionKey: hiveEncryptionKey,
        );
        break;
    }

    await _adapter!.init();
    _instance = AppStorage._();
  }

  /// Initialize with a custom [StorageAdapter] implementation.
  ///
  /// Useful for tests (in-memory adapter) or for plugging in other backends
  /// (e.g. flutter_secure_storage, Drift, Isar, etc.).
  static Future<void> initializeWithAdapter(StorageAdapter adapter) async {
    if (_instance != null) return;
    _adapter = adapter;
    await _adapter!.init();
    _instance = AppStorage._();
  }

  /// Whether [initialize] has already run.
  static bool get isInitialized => _instance != null;

  /// Get the singleton instance.
  ///
  /// Throws [StateError] if accessed before [initialize].
  static AppStorage get instance {
    if (_instance == null) {
      throw StateError(
        'AppStorage must be initialized first. Call AppStorage.initialize()',
      );
    }
    return _instance!;
  }

  /// The underlying adapter — useful for advanced use cases.
  StorageAdapter get adapter => _adapter!;

  // ==================== String ====================

  Future<bool> setString(String key, String value) =>
      _adapter!.setString(key, value);

  Future<String?> getString(String key) => _adapter!.getString(key);

  // ==================== Int ====================

  Future<bool> setInt(String key, int value) => _adapter!.setInt(key, value);

  Future<int?> getInt(String key) => _adapter!.getInt(key);

  // ==================== Double ====================

  Future<bool> setDouble(String key, double value) =>
      _adapter!.setDouble(key, value);

  Future<double?> getDouble(String key) => _adapter!.getDouble(key);

  // ==================== Bool ====================

  Future<bool> setBool(String key, bool value) => _adapter!.setBool(key, value);

  Future<bool?> getBool(String key) => _adapter!.getBool(key);

  // ==================== List<String> ====================

  Future<bool> setStringList(String key, List<String> value) =>
      _adapter!.setStringList(key, value);

  Future<List<String>?> getStringList(String key) =>
      _adapter!.getStringList(key);

  // ==================== Generic ====================

  /// Checks if a key exists.
  Future<bool> containsKey(String key) => _adapter!.containsKey(key);

  /// Removes a value by key.
  Future<bool> remove(String key) => _adapter!.remove(key);

  /// Clears all stored values.
  ///
  /// [allowList] - Optional set of keys to preserve during clear.
  Future<bool> clear({Set<String>? allowList}) =>
      _adapter!.clear(allowList: allowList);

  /// Gets all keys in storage.
  Future<Set<String>> getKeys() => _adapter!.getKeys();

  /// Reloads data from storage (useful for multi-isolate scenarios).
  Future<void> reload() => _adapter!.reload();

  /// Closes the storage backend (for cleanup; mostly Hive).
  Future<void> close() => _adapter!.close();

  /// Resets the singleton — intended for tests only.
  static Future<void> resetForTesting() async {
    if (_adapter != null) {
      try {
        await _adapter!.close();
      } catch (_) {}
    }
    _adapter = null;
    _instance = null;
  }
}
