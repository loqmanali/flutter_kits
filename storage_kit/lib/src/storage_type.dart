/// {@template storage_type}
/// Available storage backend types.
/// {@endtemplate}
enum StorageType {
  /// SharedPreferencesAsync (recommended for most cases)
  /// - Always provides latest data from platform storage
  /// - Works correctly with multiple isolates
  /// - No cache synchronization issues
  sharedPrefs,

  /// Hive (for better performance and large datasets)
  /// - Much faster than SharedPreferences
  /// - No size limitations
  /// - Supports complex data types
  /// - Optional encryption support
  hive,
}
