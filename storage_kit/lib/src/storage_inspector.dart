import 'dart:convert';

import 'app_storage.dart';
import 'storage_keys.dart';

/// One entry in the storage usage report.
class StorageUsageEntry {
  StorageUsageEntry({
    required this.key,
    required this.sizeBytes,
    this.preview,
  });

  final String key;
  final int sizeBytes;
  final String? preview;
}

/// Aggregated usage info returned by [StorageInspector.getUsageSummary].
class StorageUsageSummary {
  StorageUsageSummary({required this.totalBytes, required this.entries});

  final int totalBytes;
  final List<StorageUsageEntry> entries;
}

/// Utility for measuring how much space is taken up by stored values.
///
/// Three ways to use it:
///
/// 1. No-args — walk every key in [StorageKeys.allKeys] plus a few known
///    feature-specific keys (insights, profile, settings):
///    ```dart
///    final summary = await StorageInspector.getUsageSummary();
///    ```
///
/// 2. Inspect a known set of keys:
///    ```dart
///    final summary = await StorageInspector.getUsageSummaryForKeys(
///      keys: {'access_token', 'settings', 'cart_items'},
///    );
///    ```
///
/// 3. Inspect every key currently in storage:
///    ```dart
///    final summary = await StorageInspector.getUsageSummaryForAllKeys();
///    ```
class StorageInspector {
  StorageInspector._();

  /// Feature-area keys that are written outside of [StorageKeys] (insights,
  /// profile, settings stores). Listed here so the default summary still
  /// surfaces them.
  static const Set<String> _extraTrackedKeys = {
    'insights_weekly_trends',
    'insights_health_score',
    'insights_goals',
    'insights_last_updated',
    'user_profile',
    'user_goals',
    'user_achievements',
    'profile_last_updated',
    'app_settings',
    'settings_last_updated',
  };

  /// Walks [StorageKeys.allKeys] plus a built-in set of feature-area keys.
  ///
  /// Equivalent to the legacy `StorageInspector.getUsageSummary()` call.
  static Future<StorageUsageSummary> getUsageSummary() {
    final keys = {...StorageKeys.allKeys, ..._extraTrackedKeys};
    return getUsageSummaryForKeys(keys: keys);
  }

  /// Inspects only the [keys] passed in.
  ///
  /// Entries with no value present are skipped. The returned list is sorted
  /// from largest to smallest.
  static Future<StorageUsageSummary> getUsageSummaryForKeys({
    required Set<String> keys,
  }) async {
    int total = 0;
    final entries = <StorageUsageEntry>[];

    for (final key in keys) {
      final value = await _readAny(key);
      if (value == null) continue;
      final serialized = jsonEncode(value);
      final bytes = utf8.encode(serialized).length;
      total += bytes;
      entries.add(
        StorageUsageEntry(
          key: key,
          sizeBytes: bytes,
          preview: _shorten(serialized),
        ),
      );
    }

    entries.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
    return StorageUsageSummary(totalBytes: total, entries: entries);
  }

  /// Inspects every key currently present in storage.
  static Future<StorageUsageSummary> getUsageSummaryForAllKeys() async {
    final allKeys = await AppStorage.instance.getKeys();
    return getUsageSummaryForKeys(keys: allKeys);
  }

  static Future<dynamic> _readAny(String key) async {
    try {
      final s = await AppStorage.instance.getString(key);
      if (s != null) {
        try {
          return jsonDecode(s);
        } catch (_) {
          return s;
        }
      }
    } catch (_) {}

    try {
      final i = await AppStorage.instance.getInt(key);
      if (i != null) return i;
    } catch (_) {}

    try {
      final d = await AppStorage.instance.getDouble(key);
      if (d != null) return d;
    } catch (_) {}

    try {
      final b = await AppStorage.instance.getBool(key);
      if (b != null) return b;
    } catch (_) {}

    try {
      final list = await AppStorage.instance.getStringList(key);
      if (list != null) return list;
    } catch (_) {}

    return null;
  }

  /// Formats a byte count as `'1.2 KB'`, `'3 MB'`, etc.
  static String humanizeBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    return '${size.toStringAsFixed(size < 10 && unit > 0 ? 1 : 0)} ${units[unit]}';
  }

  static String _shorten(String s, {int max = 120}) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…';
  }
}
