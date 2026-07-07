import 'dart:convert';

import 'adapters/hive_adapter.dart';
import 'adapters/shared_prefs_adapter.dart';
import 'adapters/storage_adapter.dart';
import 'storage_keys.dart';
import 'storage_type.dart';

/// {@template app_storage}
/// Process-wide entry point for key/value storage.
///
/// Exposes a single uniform API over multiple backends
/// ([SharedPrefsAdapter], [HiveAdapter]) and adds a thin layer of
/// app-specific convenience methods (auth tokens, onboarding flags,
/// settings, device payloads) so feature code doesn't have to repeat
/// the same encode/decode and key-management boilerplate.
///
/// Usage:
/// ```dart
/// // Initialize once at app startup
/// await AppStorage.initialize();
///
/// // Use anywhere in the app
/// await AppStorage.instance.setString('key', 'value');
/// final value = await AppStorage.instance.getString('key');
///
/// // Convenience methods
/// await AppStorage.instance.saveAuthTokens(
///   accessToken: 'token',
///   refreshToken: 'refresh',
/// );
/// final isLoggedIn = await AppStorage.instance.isLoggedIn();
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

  /// In-memory cache for the access token — enables synchronous reads
  /// required by Dio interceptors during request processing.
  String? _cachedAccessToken;

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
    // Pre-warm the in-memory token cache so synchronous reads work immediately.
    _instance!._cachedAccessToken = await _instance!.getAccessToken();
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
    _instance!._cachedAccessToken = await _instance!.getAccessToken();
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

  // ==================== Authentication ====================

  /// Saves authentication tokens (with optional refresh token for future use).
  Future<bool> saveAuthTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    final ops = <Future<bool>>[
      setString(StorageKeys.accessToken, accessToken),
      setBool(StorageKeys.isLoggedIn, true),
    ];
    if (refreshToken != null) {
      ops.add(setString(StorageKeys.refreshToken, refreshToken));
    }
    final results = await Future.wait(ops);
    return results.every((result) => result);
  }

  /// Saves only the access token (Laravel Sanctum — no separate refresh token).
  Future<bool> saveAccessToken(String accessToken) async {
    _cachedAccessToken = accessToken;
    final results = await Future.wait([
      setString(StorageKeys.accessToken, accessToken),
      setBool(StorageKeys.isLoggedIn, true),
    ]);
    return results.every((result) => result);
  }

  /// Gets the access token asynchronously.
  Future<String?> getAccessToken() => getString(StorageKeys.accessToken);

  /// Returns the access token synchronously from the in-memory cache.
  ///
  /// The cache is populated on [initialize] and kept in sync by
  /// [saveAuthTokens] / [saveAccessToken] / [performLogout].
  /// Use this only in interceptors where async is not available.
  String? getAccessTokenSync() => _cachedAccessToken;

  /// Gets the refresh token.
  Future<String?> getRefreshToken() => getString(StorageKeys.refreshToken);

  /// Checks if user is logged in.
  Future<bool> isLoggedIn() async {
    final isLoggedIn = await getBool(StorageKeys.isLoggedIn);
    return isLoggedIn ?? false;
  }

  /// Saves user ID.
  Future<bool> saveUserId(String userId) =>
      setString(StorageKeys.userId, userId);

  /// Gets user ID.
  Future<String?> getUserId() => getString(StorageKeys.userId);

  /// Saves user email.
  Future<bool> saveUserEmail(String email) =>
      setString(StorageKeys.userEmail, email);

  /// Gets user email.
  Future<String?> getUserEmail() => getString(StorageKeys.userEmail);

  /// Clears authentication data (logout).
  Future<bool> clearAuthData() => performLogout();

  // ==================== Onboarding ====================

  /// Marks onboarding as completed.
  Future<bool> setOnboardingCompleted({int version = 1}) async {
    final results = await Future.wait([
      setBool(StorageKeys.hasSeenOnboarding, true),
      setInt(StorageKeys.onboardingVersion, version),
    ]);
    return results.every((result) => result);
  }

  /// Checks if onboarding has been completed.
  Future<bool> hasSeenOnboarding() async {
    final hasSeen = await getBool(StorageKeys.hasSeenOnboarding);
    return hasSeen ?? false;
  }

  /// Gets onboarding version.
  Future<int> getOnboardingVersion() async {
    final version = await getInt(StorageKeys.onboardingVersion);
    return version ?? 0;
  }

  /// Clears onboarding cache.
  Future<bool> clearOnboardingCache() async {
    final results = await Future.wait([
      remove(StorageKeys.hasSeenOnboarding),
      remove(StorageKeys.onboardingVersion),
    ]);
    return results.every((result) => result);
  }

  // ==================== Settings ====================

  /// Saves settings as JSON.
  Future<bool> saveSettings(Map<String, dynamic> settings) {
    final json = jsonEncode(settings);
    return setString(StorageKeys.settings, json);
  }

  /// Gets settings as JSON.
  Future<Map<String, dynamic>?> getSettings() async {
    final json = await getString(StorageKeys.settings);
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Saves theme mode.
  Future<bool> saveThemeMode(String themeMode) =>
      setString(StorageKeys.themeMode, themeMode);

  /// Gets theme mode.
  Future<String?> getThemeMode() => getString(StorageKeys.themeMode);

  /// Saves locale/language code.
  Future<bool> saveLocale(String languageCode) =>
      setString(StorageKeys.languageCode, languageCode);

  /// Gets locale/language code.
  Future<String?> getLocale() => getString(StorageKeys.languageCode);

  // ==================== Health Devices ====================

  /// Saves devices list as JSON.
  Future<bool> saveDevices(List<Map<String, dynamic>> devices) {
    final json = jsonEncode(devices);
    return setString(StorageKeys.savedDevices, json);
  }

  /// Gets devices list.
  Future<List<Map<String, dynamic>>?> getDevices() async {
    final json = await getString(StorageKeys.savedDevices);
    if (json == null) return null;
    try {
      final list = jsonDecode(json) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  /// Saves device readings as JSON.
  Future<bool> saveDeviceReadings(Map<String, dynamic> readings) {
    final json = jsonEncode(readings);
    return setString(StorageKeys.deviceReadings, json);
  }

  /// Gets device readings.
  Future<Map<String, dynamic>?> getDeviceReadings() async {
    final json = await getString(StorageKeys.deviceReadings);
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Saves last sync timestamp.
  Future<bool> saveLastSyncTime(DateTime dateTime) => setString(
        StorageKeys.lastSyncTime,
        dateTime.toIso8601String(),
      );

  /// Gets last sync timestamp.
  Future<DateTime?> getLastSyncTime() async {
    final timeString = await getString(StorageKeys.lastSyncTime);
    if (timeString == null) return null;
    try {
      return DateTime.parse(timeString);
    } catch (_) {
      return null;
    }
  }

  // ==================== User Preferences ====================

  /// Saves notification preference.
  Future<bool> setNotificationsEnabled(bool enabled) =>
      setBool(StorageKeys.notificationsEnabled, enabled);

  /// Gets notification preference.
  Future<bool> getNotificationsEnabled() async {
    final enabled = await getBool(StorageKeys.notificationsEnabled);
    return enabled ?? true;
  }

  /// Saves biometrics preference.
  Future<bool> setBiometricsEnabled(bool enabled) =>
      setBool(StorageKeys.biometricsEnabled, enabled);

  /// Gets biometrics preference.
  Future<bool> getBiometricsEnabled() async {
    final enabled = await getBool(StorageKeys.biometricsEnabled);
    return enabled ?? false;
  }

  /// Saves auto-sync preference.
  Future<bool> setAutoSyncEnabled(bool enabled) =>
      setBool(StorageKeys.autoSyncEnabled, enabled);

  /// Gets auto-sync preference.
  Future<bool> getAutoSyncEnabled() async {
    final enabled = await getBool(StorageKeys.autoSyncEnabled);
    return enabled ?? true;
  }

  // ==================== App State ====================

  /// Saves app version.
  Future<bool> saveAppVersion(String version) =>
      setString(StorageKeys.appVersion, version);

  /// Gets app version.
  Future<String?> getAppVersion() => getString(StorageKeys.appVersion);

  /// Saves last update check timestamp.
  Future<bool> saveLastUpdateCheck(DateTime dateTime) => setString(
        StorageKeys.lastUpdateCheck,
        dateTime.toIso8601String(),
      );

  /// Gets last update check timestamp.
  Future<DateTime?> getLastUpdateCheck() async {
    final timeString = await getString(StorageKeys.lastUpdateCheck);
    if (timeString == null) return null;
    try {
      return DateTime.parse(timeString);
    } catch (_) {
      return null;
    }
  }

  /// Saves crash reporting preference.
  Future<bool> setCrashReportingEnabled(bool enabled) =>
      setBool(StorageKeys.crashReportingEnabled, enabled);

  /// Gets crash reporting preference.
  Future<bool> getCrashReportingEnabled() async {
    final enabled = await getBool(StorageKeys.crashReportingEnabled);
    return enabled ?? true;
  }

  // ==================== Utility Methods ====================

  /// Clears all data (use with caution!).
  Future<bool> clearAll() => clear();

  /// Clears all data except critical keys.
  Future<bool> clearAllExceptCritical() =>
      clear(allowList: StorageKeys.criticalKeys);

  /// Performs a full logout (clears specific keys).
  Future<bool> performLogout() async {
    _cachedAccessToken = null;
    final keysToRemove = StorageKeys.clearableOnLogout;
    final results = await Future.wait(
      keysToRemove.map((key) => remove(key)),
    );
    return results.every((result) => result);
  }

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

  /// Resets the singleton synchronously (no async cleanup).
  static void reset() {
    _instance = null;
    _adapter = null;
  }
}
