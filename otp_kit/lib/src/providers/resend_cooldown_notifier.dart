import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../models/resend_state.dart';
import '../services/resend_cooldown_service.dart';

/// Configuration for a resend cooldown flow.
///
/// Two flows that share the same [namespace] share counters and long-cooldown
/// state. Use distinct namespaces for distinct flows ("password_recovery",
/// "phone_change", "registration").
class ResendCooldownConfig {
  const ResendCooldownConfig({
    required this.namespace,
    this.initialCountdownSeconds = 60,
    this.shortCooldownSeconds = 60,
    this.longCooldownSeconds = 5 * 60,
    this.maxAttempts = 3,
  });

  final String namespace;
  final int initialCountdownSeconds;
  final int shortCooldownSeconds;
  final int longCooldownSeconds;
  final int maxAttempts;

  @override
  bool operator ==(Object other) =>
      other is ResendCooldownConfig &&
      other.namespace == namespace &&
      other.initialCountdownSeconds == initialCountdownSeconds &&
      other.shortCooldownSeconds == shortCooldownSeconds &&
      other.longCooldownSeconds == longCooldownSeconds &&
      other.maxAttempts == maxAttempts;

  @override
  int get hashCode => Object.hash(
    namespace,
    initialCountdownSeconds,
    shortCooldownSeconds,
    longCooldownSeconds,
    maxAttempts,
  );
}

/// Single-source-of-truth provider for the [ResendCooldownService]. Override
/// this in tests with a fake-prefs-backed service.
final resendCooldownServiceProvider = Provider<ResendCooldownService>(
  (ref) => ResendCooldownService(),
);

/// Notifier that drives the resend timer. Uses a wall-clock end-time per
/// phase so pause/resume and backgrounding don't drift, and a single 1-second
/// `Timer.periodic` to recompute the public state.
class ResendCooldownNotifier extends StateNotifier<ResendState> {
  ResendCooldownNotifier({
    required this.config,
    required ResendCooldownService service,
  }) : _service = service,
       super(
         IdleResendState(attemptsUsed: 0, maxAttempts: config.maxAttempts),
       ) {
    _bootstrap();
  }

  final ResendCooldownConfig config;
  final ResendCooldownService _service;

  Timer? _ticker;
  DateTime? _phaseEndsAt;

  /// Restore persisted long-cooldown / attempts, then start the initial
  /// countdown if we're not already locked out.
  Future<void> _bootstrap() async {
    final attempts = await _service.readAttempts(config.namespace);
    final longEnd = await _service.readLongCooldownEnd(config.namespace);

    if (longEnd != null) {
      _phaseEndsAt = longEnd;
      _emit(_buildLong(attempts));
      _start();
      return;
    }

    _phaseEndsAt = DateTime.now().add(
      Duration(seconds: config.initialCountdownSeconds),
    );
    _emit(_buildTicking(attempts));
    _start();
  }

  void _start() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final endsAt = _phaseEndsAt;
    if (endsAt == null) return;
    final remaining = endsAt.difference(DateTime.now()).inSeconds;
    final current = state;

    if (remaining > 0) {
      _emit(_rebuild(current, remaining));
      return;
    }

    // Phase complete.
    switch (current) {
      case TickingResendState():
      case ShortCooldownResendState():
        _phaseEndsAt = null;
        _ticker?.cancel();
        _emit(
          IdleResendState(
            attemptsUsed: current.attemptsUsed,
            maxAttempts: config.maxAttempts,
          ),
        );
      case LongCooldownResendState():
        // Long cooldown elapsed → reset attempts and return to idle.
        _phaseEndsAt = null;
        _ticker?.cancel();
        unawaited(_service.reset(config.namespace));
        _emit(
          IdleResendState(attemptsUsed: 0, maxAttempts: config.maxAttempts),
        );
      case IdleResendState():
        _ticker?.cancel();
    }
  }

  ResendState _rebuild(ResendState current, int remaining) => switch (current) {
    TickingResendState() => TickingResendState(
      remainingSeconds: remaining,
      attemptsUsed: current.attemptsUsed,
      maxAttempts: config.maxAttempts,
    ),
    ShortCooldownResendState() => ShortCooldownResendState(
      remainingSeconds: remaining,
      attemptsUsed: current.attemptsUsed,
      maxAttempts: config.maxAttempts,
    ),
    LongCooldownResendState() => LongCooldownResendState(
      remainingSeconds: remaining,
      attemptsUsed: current.attemptsUsed,
      maxAttempts: config.maxAttempts,
    ),
    IdleResendState() => current,
  };

  TickingResendState _buildTicking(int attemptsUsed) => TickingResendState(
    remainingSeconds: _remaining(),
    attemptsUsed: attemptsUsed,
    maxAttempts: config.maxAttempts,
  );

  ShortCooldownResendState _buildShort(int attemptsUsed) =>
      ShortCooldownResendState(
        remainingSeconds: _remaining(),
        attemptsUsed: attemptsUsed,
        maxAttempts: config.maxAttempts,
      );

  LongCooldownResendState _buildLong(int attemptsUsed) =>
      LongCooldownResendState(
        remainingSeconds: _remaining(),
        attemptsUsed: attemptsUsed,
        maxAttempts: config.maxAttempts,
      );

  int _remaining() {
    final endsAt = _phaseEndsAt;
    if (endsAt == null) return 0;
    return endsAt.difference(DateTime.now()).inSeconds.clamp(0, 1 << 31);
  }

  void _emit(ResendState next) {
    if (!mounted) return;
    state = next;
  }

  /// Called by the screen when the user taps the resend button.
  /// Returns true if the resend was triggered, false if it was rate-limited.
  Future<bool> recordResend() async {
    if (state is! IdleResendState) return false;

    final newAttempts = state.attemptsUsed + 1;
    await _service.writeAttempts(config.namespace, newAttempts);

    if (newAttempts >= config.maxAttempts) {
      final endsAt = DateTime.now().add(
        Duration(seconds: config.longCooldownSeconds),
      );
      await _service.writeLongCooldownEnd(config.namespace, endsAt);
      _phaseEndsAt = endsAt;
      _emit(_buildLong(newAttempts));
    } else {
      _phaseEndsAt = DateTime.now().add(
        Duration(seconds: config.shortCooldownSeconds),
      );
      _emit(_buildShort(newAttempts));
    }
    _start();
    return true;
  }

  /// Reset everything. Use when the verification flow completes successfully.
  Future<void> resetAll() async {
    _ticker?.cancel();
    _phaseEndsAt = null;
    await _service.reset(config.namespace);
    _emit(IdleResendState(attemptsUsed: 0, maxAttempts: config.maxAttempts));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

/// Family provider keyed by [ResendCooldownConfig].
final resendCooldownProvider =
    StateNotifierProvider.family<
      ResendCooldownNotifier,
      ResendState,
      ResendCooldownConfig
    >((ref, config) {
      return ResendCooldownNotifier(
        config: config,
        service: ref.watch(resendCooldownServiceProvider),
      );
    });
