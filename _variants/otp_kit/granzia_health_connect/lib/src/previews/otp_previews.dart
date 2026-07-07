// Widget previews for the OTP module. Open the "Flutter Widget Preview"
// pane in your IDE (or run `flutter widget-preview start`) to render these
// in isolation without booting the full app.

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/resend_state.dart';
import '../providers/resend_cooldown_notifier.dart';
import '../services/resend_cooldown_service.dart';
import '../theme/otp_theme.dart';
import '../widgets/otp_resend_button.dart';
import '../widgets/otp_text_field.dart';

const Size previewSize = Size(360, 160);

Widget _scope(Widget child) => ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(child: child),
          ),
        ),
      ),
    );

@Preview(name: 'Default light · 4 cells', group: 'OTPTextField', size: previewSize)
Widget otpDefaultLight() => _scope(
      Builder(
        builder: (context) => OTPTextField(
          config: OTPTheme.defaultLight(context),
        ),
      ),
    );

@Preview(name: 'Modern · 6 cells', group: 'OTPTextField', size: previewSize)
Widget otpModern() => _scope(
      Builder(
        builder: (context) => OTPTextField(
          config: OTPTheme.modern(context),
        ),
      ),
    );

@Preview(name: 'Secure (obscured)', group: 'OTPTextField', size: previewSize)
Widget otpSecure() => _scope(
      Builder(
        builder: (context) => OTPTextField(
          config: OTPTheme.secure(context),
        ),
      ),
    );

@Preview(name: 'Premium', group: 'OTPTextField', size: previewSize)
Widget otpPremium() => _scope(
      Builder(
        builder: (context) => OTPTextField(
          config: OTPTheme.premium(context),
        ),
      ),
    );

@Preview(name: 'RTL', group: 'OTPTextField', size: previewSize)
Widget otpRtl() => _scope(
      Builder(
        builder: (context) {
          final base = OTPTheme.defaultLight(context);
          return OTPTextField(
            config: base.copyWith(isRTL: true),
          );
        },
      ),
    );

const resendPreviewSize = Size(360, 220);

ResendButtonLabels _previewLabels() => ResendButtonLabels(
      resend: 'Resend code',
      shortCooldown: (t) => 'Wait $t before retrying',
      longCooldown: (t) => 'Too many attempts — try again in $t',
    );

Widget _resendWith(ResendState seed) {
  // Override the provider with one whose service returns canned state.
  return ProviderScope(
    overrides: [
      resendCooldownServiceProvider.overrideWithValue(
        _SeededCooldownService(seed),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: OTPResendButton(
              config: const ResendCooldownConfig(namespace: 'preview'),
              labels: _previewLabels(),
              onResend: _noop,
              timerStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
              cooldownTextStyle: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              buttonBuilder:
                  (context, {required label, required onPressed}) {
                return ElevatedButton(onPressed: onPressed, child: Text(label));
              },
            ),
          ),
        ),
      ),
    ),
  );
}

void _noop() {}

@Preview(name: 'Idle', group: 'OTPResendButton', size: resendPreviewSize)
Widget resendIdle() => _resendWith(
      const IdleResendState(attemptsUsed: 0, maxAttempts: 3),
    );

@Preview(name: 'Ticking', group: 'OTPResendButton', size: resendPreviewSize)
Widget resendTicking() => _resendWith(
      const TickingResendState(
        remainingSeconds: 45,
        attemptsUsed: 0,
        maxAttempts: 3,
      ),
    );

@Preview(name: 'Short cooldown', group: 'OTPResendButton', size: resendPreviewSize)
Widget resendShortCooldown() => _resendWith(
      const ShortCooldownResendState(
        remainingSeconds: 8,
        attemptsUsed: 1,
        maxAttempts: 3,
      ),
    );

@Preview(name: 'Long cooldown', group: 'OTPResendButton', size: resendPreviewSize)
Widget resendLongCooldown() => _resendWith(
      const LongCooldownResendState(
        remainingSeconds: 14 * 60,
        attemptsUsed: 3,
        maxAttempts: 3,
      ),
    );

/// Minimal stub that lets the resend notifier bootstrap deterministically:
/// pre-loaded attempts/long-cooldown values are read on init, then a tick
/// or two later the previewed [seed] state will be reached naturally.
class _SeededCooldownService implements ResendCooldownService {
  _SeededCooldownService(this.seed);
  final ResendState seed;

  @override
  Future<int> readAttempts(String namespace) async => seed.attemptsUsed;

  @override
  Future<DateTime?> readLongCooldownEnd(String namespace) async {
    if (seed is LongCooldownResendState) {
      final remaining = (seed as LongCooldownResendState).remainingSeconds;
      return DateTime.now().add(Duration(seconds: remaining));
    }
    return null;
  }

  @override
  Future<void> writeAttempts(String namespace, int attempts) async {}

  @override
  Future<void> writeLongCooldownEnd(String namespace, DateTime endsAt) async {}

  @override
  Future<void> clearLongCooldown(String namespace) async {}

  @override
  Future<void> reset(String namespace) async {}
}
