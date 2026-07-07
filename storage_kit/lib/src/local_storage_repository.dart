import 'dart:convert';

import 'app_storage.dart';
import 'storage_keys.dart';

/// {@template local_storage_repository}
/// Feature-grouped façade over [AppStorage].
///
/// Use this in providers / services when you want an injectable, easily
/// mocked dependency rather than reaching for the [AppStorage.instance]
/// singleton directly.
/// {@endtemplate}
class LocalStorageRepository {
  final AppStorage _storage;

  LocalStorageRepository(this._storage);

  // ==================== Authentication ====================

  Future<bool> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final results = await Future.wait([
      _storage.setString(StorageKeys.accessToken, accessToken),
      _storage.setString(StorageKeys.refreshToken, refreshToken),
      _storage.setBool(StorageKeys.isLoggedIn, true),
    ]);
    return results.every((result) => result);
  }

  Future<String?> getAccessToken() =>
      _storage.getString(StorageKeys.accessToken);

  Future<String?> getRefreshToken() =>
      _storage.getString(StorageKeys.refreshToken);

  Future<bool> isLoggedIn() async {
    final isLoggedIn = await _storage.getBool(StorageKeys.isLoggedIn);
    return isLoggedIn ?? false;
  }

  Future<bool> saveUserId(String userId) =>
      _storage.setString(StorageKeys.userId, userId);

  Future<String?> getUserId() => _storage.getString(StorageKeys.userId);

  Future<bool> saveUserEmail(String email) =>
      _storage.setString(StorageKeys.userEmail, email);

  Future<String?> getUserEmail() => _storage.getString(StorageKeys.userEmail);

  Future<bool> clearAuthData() => performLogout();

  // ==================== Onboarding ====================

  Future<bool> setOnboardingCompleted({int version = 1}) async {
    final results = await Future.wait([
      _storage.setBool(StorageKeys.hasSeenOnboarding, true),
      _storage.setInt(StorageKeys.onboardingVersion, version),
    ]);
    return results.every((result) => result);
  }

  Future<bool> hasSeenOnboarding() async {
    final hasSeen = await _storage.getBool(StorageKeys.hasSeenOnboarding);
    return hasSeen ?? false;
  }

  Future<int> getOnboardingVersion() async {
    final version = await _storage.getInt(StorageKeys.onboardingVersion);
    return version ?? 0;
  }

  Future<bool> clearOnboardingCache() async {
    final results = await Future.wait([
      _storage.remove(StorageKeys.hasSeenOnboarding),
      _storage.remove(StorageKeys.onboardingVersion),
    ]);
    return results.every((result) => result);
  }

  // ==================== Legal Documents Cache ====================

  /// Caches the raw JSON payload of a legal document keyed by slug so the
  /// next launch can render instantly without a network round-trip. The
  /// payload is whatever the server returned (Map or List).
  Future<bool> cacheLegalDocument(String slug, String rawJson) =>
      _storage.setString(_legalCacheKey(slug), rawJson);

  /// Returns the cached raw JSON for [slug], or null if nothing is cached.
  Future<String?> readCachedLegalDocument(String slug) =>
      _storage.getString(_legalCacheKey(slug));

  /// Clears the cached entry for [slug] (used on logout or explicit reset).
  Future<bool> clearCachedLegalDocument(String slug) =>
      _storage.remove(_legalCacheKey(slug));

  String _legalCacheKey(String slug) => 'legal_document_cache:$slug';

  // ==================== Intro / Guided Setup ====================

  Future<bool> setIntroTermsAccepted(bool accepted) =>
      _storage.setBool(StorageKeys.introTermsAccepted, accepted);

  Future<bool> hasAcceptedIntroTerms() async {
    final value = await _storage.getBool(StorageKeys.introTermsAccepted);
    return value ?? false;
  }

  Future<bool> setIntroWelcomeSeen(bool seen) =>
      _storage.setBool(StorageKeys.introWelcomeSeen, seen);

  Future<bool> hasSeenIntroWelcome() async {
    final value = await _storage.getBool(StorageKeys.introWelcomeSeen);
    return value ?? false;
  }

  Future<bool> setIntroProfileSetupDone(bool done) =>
      _storage.setBool(StorageKeys.introProfileSetupDone, done);

  Future<bool> hasCompletedIntroProfileSetup() async {
    final value = await _storage.getBool(StorageKeys.introProfileSetupDone);
    return value ?? false;
  }

  Future<bool> setIntroGoalsSetupDone(bool done) =>
      _storage.setBool(StorageKeys.introGoalsSetupDone, done);

  Future<bool> hasCompletedIntroGoalsSetup() async {
    final value = await _storage.getBool(StorageKeys.introGoalsSetupDone);
    return value ?? false;
  }

  Future<bool> saveIntroProfileDraft({
    String? name,
    String? gender,
    String? ageGroup,
  }) async {
    final results = await Future.wait([
      if (name != null) _storage.setString(StorageKeys.introProfileName, name),
      if (gender != null)
        _storage.setString(StorageKeys.introProfileGender, gender),
      if (ageGroup != null)
        _storage.setString(StorageKeys.introProfileAgeGroup, ageGroup),
    ]);
    return results.every((result) => result);
  }

  Future<({String? name, String? gender, String? ageGroup})>
      readIntroProfileDraft() async {
    final values = await Future.wait([
      _storage.getString(StorageKeys.introProfileName),
      _storage.getString(StorageKeys.introProfileGender),
      _storage.getString(StorageKeys.introProfileAgeGroup),
    ]);
    return (name: values[0], gender: values[1], ageGroup: values[2]);
  }

  Future<bool> saveIntroGoalsDraft({
    int? systolic,
    int? diastolic,
    double? weight,
    String? weightUnit,
    int? stepsPerDay,
  }) async {
    final results = await Future.wait([
      if (systolic != null)
        _storage.setInt(StorageKeys.introGoalSystolic, systolic),
      if (diastolic != null)
        _storage.setInt(StorageKeys.introGoalDiastolic, diastolic),
      if (weight != null)
        _storage.setString(StorageKeys.introGoalWeight, weight.toString()),
      if (weightUnit != null)
        _storage.setString(StorageKeys.introGoalWeightUnit, weightUnit),
      if (stepsPerDay != null)
        _storage.setInt(StorageKeys.introGoalStepsPerDay, stepsPerDay),
    ]);
    return results.every((result) => result);
  }

  Future<
      ({
        int? systolic,
        int? diastolic,
        double? weight,
        String? weightUnit,
        int? stepsPerDay,
      })> readIntroGoalsDraft() async {
    final systolic = await _storage.getInt(StorageKeys.introGoalSystolic);
    final diastolic = await _storage.getInt(StorageKeys.introGoalDiastolic);
    final weightStr = await _storage.getString(StorageKeys.introGoalWeight);
    final weightUnit =
        await _storage.getString(StorageKeys.introGoalWeightUnit);
    final stepsPerDay = await _storage.getInt(StorageKeys.introGoalStepsPerDay);
    return (
      systolic: systolic,
      diastolic: diastolic,
      weight: weightStr != null ? double.tryParse(weightStr) : null,
      weightUnit: weightUnit,
      stepsPerDay: stepsPerDay,
    );
  }

  // ---- Offline-first sync flags for goals & profile ------------------------
  // Set "dirty" whenever local data changes; clear it after a successful sync
  // to the backend. The sync layer uses these to know what to push.

  Future<bool> setHealthGoalsDirty(bool dirty) =>
      _storage.setBool(StorageKeys.healthGoalsDirty, dirty);

  Future<bool> isHealthGoalsDirty() async {
    final v = await _storage.getBool(StorageKeys.healthGoalsDirty);
    return v ?? false;
  }

  Future<bool> setHealthGoalsSyncedAt(int epochMillis) =>
      _storage.setInt(StorageKeys.healthGoalsSyncedAt, epochMillis);

  Future<int?> getHealthGoalsSyncedAt() =>
      _storage.getInt(StorageKeys.healthGoalsSyncedAt);

  Future<bool> setIntroProfileDirty(bool dirty) =>
      _storage.setBool(StorageKeys.introProfileDirty, dirty);

  Future<bool> isIntroProfileDirty() async {
    final v = await _storage.getBool(StorageKeys.introProfileDirty);
    return v ?? false;
  }

  Future<bool> setIntroProfileSyncedAt(int epochMillis) =>
      _storage.setInt(StorageKeys.introProfileSyncedAt, epochMillis);

  Future<int?> getIntroProfileSyncedAt() =>
      _storage.getInt(StorageKeys.introProfileSyncedAt);

  // ==================== Settings ====================

  Future<bool> saveSettings(Map<String, dynamic> settings) {
    final json = jsonEncode(settings);
    return _storage.setString(StorageKeys.settings, json);
  }

  Future<Map<String, dynamic>?> getSettings() async {
    final json = await _storage.getString(StorageKeys.settings);
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveThemeMode(String themeMode) =>
      _storage.setString(StorageKeys.themeMode, themeMode);

  Future<String?> getThemeMode() => _storage.getString(StorageKeys.themeMode);

  Future<bool> saveLocale(String languageCode) =>
      _storage.setString(StorageKeys.languageCode, languageCode);

  Future<String?> getLocale() => _storage.getString(StorageKeys.languageCode);

  // ==================== Health Devices ====================

  Future<bool> saveDevices(List<Map<String, dynamic>> devices) {
    final json = jsonEncode(devices);
    return _storage.setString(StorageKeys.savedDevices, json);
  }

  Future<List<Map<String, dynamic>>?> getDevices() async {
    final json = await _storage.getString(StorageKeys.savedDevices);
    if (json == null) return null;
    try {
      final list = jsonDecode(json) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveDeviceReadings(Map<String, dynamic> readings) {
    final json = jsonEncode(readings);
    return _storage.setString(StorageKeys.deviceReadings, json);
  }

  Future<Map<String, dynamic>?> getDeviceReadings() async {
    final json = await _storage.getString(StorageKeys.deviceReadings);
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveLastSyncTime(DateTime dateTime) => _storage.setString(
        StorageKeys.lastSyncTime,
        dateTime.toIso8601String(),
      );

  Future<DateTime?> getLastSyncTime() async {
    final timeString = await _storage.getString(StorageKeys.lastSyncTime);
    if (timeString == null) return null;
    try {
      return DateTime.parse(timeString);
    } catch (_) {
      return null;
    }
  }

  // ==================== User Preferences ====================

  Future<bool> setNotificationsEnabled(bool enabled) =>
      _storage.setBool(StorageKeys.notificationsEnabled, enabled);

  Future<bool> getNotificationsEnabled() async {
    final enabled = await _storage.getBool(StorageKeys.notificationsEnabled);
    return enabled ?? true;
  }

  Future<bool> setBiometricsEnabled(bool enabled) =>
      _storage.setBool(StorageKeys.biometricsEnabled, enabled);

  Future<bool> getBiometricsEnabled() async {
    final enabled = await _storage.getBool(StorageKeys.biometricsEnabled);
    return enabled ?? false;
  }

  Future<bool> setAutoSyncEnabled(bool enabled) =>
      _storage.setBool(StorageKeys.autoSyncEnabled, enabled);

  Future<bool> getAutoSyncEnabled() async {
    final enabled = await _storage.getBool(StorageKeys.autoSyncEnabled);
    return enabled ?? true;
  }

  // ==================== App State ====================

  Future<bool> saveAppVersion(String version) =>
      _storage.setString(StorageKeys.appVersion, version);

  Future<String?> getAppVersion() => _storage.getString(StorageKeys.appVersion);

  Future<bool> saveLastUpdateCheck(DateTime dateTime) => _storage.setString(
        StorageKeys.lastUpdateCheck,
        dateTime.toIso8601String(),
      );

  Future<DateTime?> getLastUpdateCheck() async {
    final timeString = await _storage.getString(StorageKeys.lastUpdateCheck);
    if (timeString == null) return null;
    try {
      return DateTime.parse(timeString);
    } catch (_) {
      return null;
    }
  }

  Future<bool> setCrashReportingEnabled(bool enabled) =>
      _storage.setBool(StorageKeys.crashReportingEnabled, enabled);

  Future<bool> getCrashReportingEnabled() async {
    final enabled = await _storage.getBool(StorageKeys.crashReportingEnabled);
    return enabled ?? true;
  }

  // ==================== Utility Methods ====================

  Future<bool> clearAll() => _storage.clear();

  Future<bool> clearAllExceptCritical() =>
      _storage.clear(allowList: StorageKeys.criticalKeys);

  Future<bool> performLogout() async {
    final keysToRemove = StorageKeys.clearableOnLogout;
    final results = await Future.wait(
      keysToRemove.map((key) => _storage.remove(key)),
    );
    return results.every((result) => result);
  }

  Future<bool> containsKey(String key) => _storage.containsKey(key);

  Future<Set<String>> getAllKeys() => _storage.getKeys();

  Future<void> reload() => _storage.reload();
}
