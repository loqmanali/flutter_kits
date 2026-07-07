/// Sealed representation of the OTP resend timer state.
///
/// Drives both the resend button (enabled/disabled + label) and the
/// optional countdown text. All time values are *remaining* seconds —
/// computed from a wall-clock end-time so the UI stays accurate across
/// pause/resume and app backgrounding.
sealed class ResendState {
  const ResendState({required this.attemptsUsed, required this.maxAttempts});

  final int attemptsUsed;
  final int maxAttempts;

  int get attemptsRemaining => (maxAttempts - attemptsUsed).clamp(0, maxAttempts);

  /// Initial countdown after the OTP was sent — resend is disabled until 0.
  const factory ResendState.ticking({
    required int remainingSeconds,
    required int attemptsUsed,
    required int maxAttempts,
  }) = TickingResendState;

  /// Idle — resend button is enabled.
  const factory ResendState.idle({
    required int attemptsUsed,
    required int maxAttempts,
  }) = IdleResendState;

  /// Short cooldown after a resend tap (anti-spam).
  const factory ResendState.shortCooldown({
    required int remainingSeconds,
    required int attemptsUsed,
    required int maxAttempts,
  }) = ShortCooldownResendState;

  /// Long cooldown after [maxAttempts] is reached.
  const factory ResendState.longCooldown({
    required int remainingSeconds,
    required int attemptsUsed,
    required int maxAttempts,
  }) = LongCooldownResendState;

  bool get canResend => switch (this) {
        IdleResendState() => true,
        _ => false,
      };
}

final class TickingResendState extends ResendState {
  const TickingResendState({
    required this.remainingSeconds,
    required super.attemptsUsed,
    required super.maxAttempts,
  });
  final int remainingSeconds;
}

final class IdleResendState extends ResendState {
  const IdleResendState({
    required super.attemptsUsed,
    required super.maxAttempts,
  });
}

final class ShortCooldownResendState extends ResendState {
  const ShortCooldownResendState({
    required this.remainingSeconds,
    required super.attemptsUsed,
    required super.maxAttempts,
  });
  final int remainingSeconds;
}

final class LongCooldownResendState extends ResendState {
  const LongCooldownResendState({
    required this.remainingSeconds,
    required super.attemptsUsed,
    required super.maxAttempts,
  });
  final int remainingSeconds;
}
