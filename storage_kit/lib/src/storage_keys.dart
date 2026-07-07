/// {@template storage_keys}
/// Centralized storage keys used by [LocalStorageRepository].
///
/// Defining every key here keeps allow-lists, inspectors, and feature code in
/// sync — and prevents the typos that arise from sprinkling string literals
/// across the codebase.
/// {@endtemplate}
class StorageKeys {
  StorageKeys._();

  // ==================== Authentication ====================
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String isLoggedIn = 'is_logged_in';

  // ==================== Onboarding ====================
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String onboardingVersion = 'onboarding_version';

  // Intro / guided setup flow (OMRON-style)
  static const String introTermsAccepted = 'intro_terms_accepted';
  static const String introWelcomeSeen = 'intro_welcome_seen';
  static const String introProfileSetupDone = 'intro_profile_setup_done';
  static const String introGoalsSetupDone = 'intro_goals_setup_done';
  static const String introProfileName = 'intro_profile_name';
  static const String introProfileGender = 'intro_profile_gender';
  static const String introProfileAgeGroup = 'intro_profile_age_group';
  static const String introGoalSystolic = 'intro_goal_systolic';
  static const String introGoalDiastolic = 'intro_goal_diastolic';
  static const String introGoalWeight = 'intro_goal_weight';
  static const String introGoalWeightUnit = 'intro_goal_weight_unit';
  static const String introGoalStepsPerDay = 'intro_goal_steps_per_day';

  // Offline-first sync flags for user health goals & profile.
  // `*_dirty` = local has unsynced edits; `*_synced_at` = epoch millis of
  // last successful upload to the backend.
  static const String healthGoalsDirty = 'health_goals_dirty';
  static const String healthGoalsSyncedAt = 'health_goals_synced_at';
  static const String introProfileDirty = 'intro_profile_dirty';
  static const String introProfileSyncedAt = 'intro_profile_synced_at';

  // ==================== Settings ====================
  static const String settings = 'settings';
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String languageCode = 'language_code';

  // ==================== Health Devices ====================
  static const String savedDevices = 'saved_devices';
  static const String savedDevicesV2 = 'saved_devices_v2';
  static const String deviceReadings = 'device_readings';
  static const String lastSyncTime = 'last_sync_time';
  static const String devicesSelectedCategory = 'devices_selected_category';
  static const String selectedDeviceFilter = 'selected_device_filter';

  // ==================== User Preferences ====================
  static const String notificationsEnabled = 'notifications_enabled';
  static const String biometricsEnabled = 'biometrics_enabled';
  static const String autoSyncEnabled = 'auto_sync_enabled';
  static const String notificationPreferences = 'notification_preferences';

  // ==================== App State ====================
  static const String appVersion = 'app_version';
  static const String lastUpdateCheck = 'last_update_check';
  static const String crashReportingEnabled = 'crash_reporting_enabled';

  // ==================== Gemini AI OCR Quota ====================
  static const String geminiOcrDailyCount = 'gemini_ocr_daily_count';
  static const String geminiOcrTotalCount = 'gemini_ocr_total_count';
  static const String geminiOcrLastResetDate = 'gemini_ocr_last_reset_date';
  static const String geminiOcrQuotaConfig = 'gemini_ocr_quota_config';
  static const String geminiOcrPromptConfigs = 'gemini_ocr_prompt_configs';

  // ==================== Theme Editor ====================
  static const String customThemes = 'custom_themes';
  static const String activeCustomThemeId = 'active_custom_theme_id';

  /// Every key the app knows about.
  ///
  /// Used by [StorageInspector] to enumerate usage and by allow-list–aware
  /// clears that should preserve the full set.
  static Set<String> get allKeys => {
        // Authentication
        accessToken,
        refreshToken,
        userId,
        userEmail,
        isLoggedIn,
        // Onboarding
        hasSeenOnboarding,
        onboardingVersion,
        introTermsAccepted,
        introWelcomeSeen,
        introProfileSetupDone,
        introGoalsSetupDone,
        introProfileName,
        introProfileGender,
        introProfileAgeGroup,
        introGoalSystolic,
        introGoalDiastolic,
        introGoalWeight,
        introGoalWeightUnit,
        introGoalStepsPerDay,
        // Settings
        settings,
        themeMode,
        locale,
        languageCode,
        // Health Devices
        savedDevices,
        savedDevicesV2,
        deviceReadings,
        lastSyncTime,
        devicesSelectedCategory,
        selectedDeviceFilter,
        // User Preferences
        notificationsEnabled,
        biometricsEnabled,
        autoSyncEnabled,
        // App State
        appVersion,
        lastUpdateCheck,
        crashReportingEnabled,
        // Gemini AI OCR Quota
        geminiOcrDailyCount,
        geminiOcrTotalCount,
        geminiOcrLastResetDate,
        geminiOcrQuotaConfig,
        geminiOcrPromptConfigs,
        // Theme Editor
        customThemes,
        activeCustomThemeId,
      };

  /// Critical keys that must never be cleared accidentally.
  static Set<String> get criticalKeys => {
        accessToken,
        refreshToken,
        userId,
        isLoggedIn,
      };

  /// Keys that should be wiped on logout.
  ///
  /// Deliberately excludes the onboarding/feature-tour/intro-terms flags:
  /// those record a fact about the *device* ("has this phone seen the tour
  /// and accepted the terms"), not the account session. Clearing them here
  /// used to send every logged-out user back through the entire onboarding
  /// flow on their next login instead of straight to the sign-in screen.
  static Set<String> get clearableOnLogout => {
        accessToken,
        refreshToken,
        userId,
        userEmail,
        isLoggedIn,
        savedDevices,
        deviceReadings,
        lastSyncTime,
        introProfileName,
        introProfileGender,
        introProfileAgeGroup,
        introGoalSystolic,
        introGoalDiastolic,
        introGoalWeight,
        introGoalWeightUnit,
        introGoalStepsPerDay,
      };
}
