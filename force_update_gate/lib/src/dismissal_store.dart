import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

/// Persists "Later" / "Skip this version" dismissals across launches.
///
/// Backed by `shared_preferences`. Two keys:
/// - `force_update_gate.dismissed_until` — millis-since-epoch deadline
///   for cooldown-based dismissal.
/// - `force_update_gate.skipped_version` — the store version string the
///   user dismissed (used by [ForceUpdateSkipMode.version]).
class DismissalStore {
  DismissalStore({SharedPreferences? prefs}) : _prefs = prefs;

  static const _kCooldownKey = 'force_update_gate.dismissed_until';
  static const _kVersionKey = 'force_update_gate.skipped_version';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _resolve() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> isDismissed({
    required ForceUpdateSkipMode mode,
    required String? storeVersion,
    DateTime? now,
  }) async {
    if (mode == ForceUpdateSkipMode.session) return false;
    final prefs = await _resolve();

    if (mode == ForceUpdateSkipMode.cooldown) {
      final until = prefs.getInt(_kCooldownKey);
      if (until == null) return false;
      final deadline = DateTime.fromMillisecondsSinceEpoch(until);
      final reference = now ?? DateTime.now();
      if (reference.isBefore(deadline)) return true;
      await prefs.remove(_kCooldownKey);
      return false;
    }

    final skipped = prefs.getString(_kVersionKey);
    if (skipped == null || storeVersion == null) return false;
    if (skipped == storeVersion) return true;
    await prefs.remove(_kVersionKey);
    return false;
  }

  Future<void> recordDismissal({
    required ForceUpdateSkipMode mode,
    required Duration cooldown,
    required String? storeVersion,
    DateTime? now,
  }) async {
    if (mode == ForceUpdateSkipMode.session) return;
    final prefs = await _resolve();

    if (mode == ForceUpdateSkipMode.cooldown) {
      if (cooldown <= Duration.zero) return;
      final deadline = (now ?? DateTime.now()).add(cooldown);
      await prefs.setInt(_kCooldownKey, deadline.millisecondsSinceEpoch);
      return;
    }

    if (storeVersion != null) {
      await prefs.setString(_kVersionKey, storeVersion);
    }
  }

  Future<void> clear() async {
    final prefs = await _resolve();
    await prefs.remove(_kCooldownKey);
    await prefs.remove(_kVersionKey);
  }
}
