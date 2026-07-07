import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/resend_state.dart';
import '../providers/resend_cooldown_notifier.dart';

/// Renders the OTP countdown + resend button as a stateless consumer of
/// [resendCooldownProvider]. Time formatting and labels are caller-supplied
/// via [labels] so the module stays free of localization deps.
class OTPResendButton extends ConsumerWidget {
  const OTPResendButton({
    super.key,
    required this.config,
    required this.labels,
    required this.onResend,
    required this.buttonBuilder,
    this.timerStyle,
    this.cooldownTextStyle,
    this.spacing = 8.0,
    this.bottomSpacing = 16.0,
  });

  final ResendCooldownConfig config;
  final ResendButtonLabels labels;

  /// Called *after* the notifier records the resend; safe to fire the
  /// network request here.
  final VoidCallback onResend;

  /// Caller renders the actual button. Wire [onPressed] to the tap handler
  /// — pass `null` directly, or use the supplied callback which is null when
  /// the button must stay disabled (during cooldown).
  final Widget Function(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
  }) buttonBuilder;

  final TextStyle? timerStyle;
  final TextStyle? cooldownTextStyle;
  final double spacing;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resendCooldownProvider(config));

    final timerText = switch (state) {
      TickingResendState(:final remainingSeconds) =>
        _formatDuration(remainingSeconds),
      ShortCooldownResendState(:final remainingSeconds) =>
        _formatDuration(remainingSeconds),
      LongCooldownResendState(:final remainingSeconds) =>
        _formatDuration(remainingSeconds),
      IdleResendState() => '00:00',
    };

    final cooldownLine = switch (state) {
      ShortCooldownResendState(:final remainingSeconds) =>
        labels.shortCooldown(_formatDuration(remainingSeconds)),
      LongCooldownResendState(:final remainingSeconds) =>
        labels.longCooldown(_formatDuration(remainingSeconds)),
      _ => null,
    };

    final remaining = state.attemptsRemaining;
    final label = remaining > 0
        ? '${labels.resend} ($remaining)'
        : labels.resend;

    final tapHandler = state.canResend
        ? () async {
            final triggered = await ref
                .read(resendCooldownProvider(config).notifier)
                .recordResend();
            if (triggered) onResend();
          }
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed-width box so the digits can vary in glyph width without
        // re-centering the parent Column on every tick.
        SizedBox(
          height: (timerStyle?.fontSize ?? 14) * 1.6,
          child: Center(
            child: Text(
              timerText,
              style: timerStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (cooldownLine != null) ...[
          SizedBox(height: spacing),
          // Reserve a vertical line of space so the button below doesn't
          // jump as the cooldown text appears/disappears or wraps.
          Text(
            cooldownLine,
            style: cooldownTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: bottomSpacing),
        buttonBuilder(context, label: label, onPressed: tapHandler),
      ],
    );
  }
}

/// Labels supplied by the calling feature (so the module has no L10n dep).
class ResendButtonLabels {
  const ResendButtonLabels({
    required this.resend,
    required this.shortCooldown,
    required this.longCooldown,
  });

  final String resend;
  final String Function(String formattedTime) shortCooldown;
  final String Function(String formattedTime) longCooldown;
}

/// Convenience handle for callers that want to trigger the resend
/// programmatically (e.g. from a `ref.listen` callback).
extension ResendCooldownActions on WidgetRef {
  Future<bool> triggerOTPResend(ResendCooldownConfig config) =>
      read(resendCooldownProvider(config).notifier).recordResend();

  Future<void> resetOTPResend(ResendCooldownConfig config) =>
      read(resendCooldownProvider(config).notifier).resetAll();
}

String _formatMMSS(int totalSeconds) {
  final s = totalSeconds.clamp(0, 1 << 31);
  final m = s ~/ 60;
  final r = s % 60;
  return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
}

/// Adaptive duration formatter:
/// - `< 1 hour`  → `mm:ss`   (e.g. `14:00`, `00:42`)
/// - `>= 1 hour` → `hh:mm:ss` (e.g. `01:30:00`)
String _formatDuration(int totalSeconds) {
  final s = totalSeconds.clamp(0, 1 << 31);
  if (s < 3600) return _formatMMSS(s);
  final h = s ~/ 3600;
  final rest = s % 3600;
  final m = rest ~/ 60;
  final sec = rest % 60;
  return '${h.toString().padLeft(2, '0')}:'
      '${m.toString().padLeft(2, '0')}:'
      '${sec.toString().padLeft(2, '0')}';
}
