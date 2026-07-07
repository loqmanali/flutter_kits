import 'package:shared_preferences/shared_preferences.dart';

/// Persists OTP resend attempts and the long-cooldown end-time so they
/// survive app restarts and screen disposal.
///
/// All state is keyed by an opaque [namespace] string so multiple flows
/// (e.g. password recovery vs. phone change) don't share counters.
class ResendCooldownService {
  ResendCooldownService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensure() async =>
      _prefs ??= await SharedPreferences.getInstance();

  String _attemptsKey(String namespace) => 'otp.$namespace.attempts';
  String _longCooldownKey(String namespace) =>
      'otp.$namespace.longCooldownEndsAt';

  Future<int> readAttempts(String namespace) async {
    final prefs = await _ensure();
    return prefs.getInt(_attemptsKey(namespace)) ?? 0;
  }

  Future<void> writeAttempts(String namespace, int attempts) async {
    final prefs = await _ensure();
    await prefs.setInt(_attemptsKey(namespace), attempts);
  }

  /// Returns the cooldown end-time if one is currently active, else null.
  /// An expired cooldown is cleaned up and reported as null.
  Future<DateTime?> readLongCooldownEnd(String namespace) async {
    final prefs = await _ensure();
    final millis = prefs.getInt(_longCooldownKey(namespace));
    if (millis == null) return null;
    final endsAt = DateTime.fromMillisecondsSinceEpoch(millis);
    if (endsAt.isBefore(DateTime.now())) {
      await prefs.remove(_longCooldownKey(namespace));
      return null;
    }
    return endsAt;
  }

  Future<void> writeLongCooldownEnd(String namespace, DateTime endsAt) async {
    final prefs = await _ensure();
    await prefs.setInt(
      _longCooldownKey(namespace),
      endsAt.millisecondsSinceEpoch,
    );
  }

  Future<void> clearLongCooldown(String namespace) async {
    final prefs = await _ensure();
    await prefs.remove(_longCooldownKey(namespace));
  }

  Future<void> reset(String namespace) async {
    final prefs = await _ensure();
    await prefs.remove(_attemptsKey(namespace));
    await prefs.remove(_longCooldownKey(namespace));
  }
}
