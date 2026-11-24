// template: otp-screen
// description: A full OTP verification screen with resend cooldown.
// kits: otp_kit
// pub: hooks_riverpod
// output: lib/features/auth/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:otp_kit/otp_kit.dart';

/// A complete verification screen: the code field, a resend button with its
/// cooldown, and a verify action.
///
/// otp_kit keeps its state in Riverpod, so this must sit under a ProviderScope.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.onVerify,
    required this.onResend,
  });

  /// Shown in the subtitle so the user can check they typed it correctly.
  final String phoneNumber;

  /// Called with the entered code. Return an error message to display, or null
  /// when verification succeeded.
  final Future<String?> Function(String code) onVerify;

  /// Ask your backend to send a new code.
  final Future<void> Function() onResend;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  // Two separate configs: the field's look and length, and the resend
  // cooldown. `namespace` is the key the cooldown is persisted under — give
  // each flow its own so a signup countdown doesn't block a login one.
  late final OTPConfig _config = OTPTheme.custom(
    context: context,
    length: 6,
  );

  static const _cooldown = ResendCooldownConfig(namespace: 'verify-phone');

  bool _verifying = false;

  OTPController get _controller =>
      ref.read(otpControllerProvider(_config).notifier);

  Future<void> _verify(String code) async {
    if (_verifying) return;
    setState(() => _verifying = true);

    final error = await widget.onVerify(code);

    if (!mounted) return;
    setState(() => _verifying = false);

    // Push the failure back into the field so it shows its error styling and
    // the user can correct it in place.
    if (error != null) _controller.setError(error);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(otpControllerProvider(_config));

    return Scaffold(
      appBar: AppBar(title: const Text('Verify your number')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text('Enter the code', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to ${widget.phoneNumber}.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              OTPTextField(
                config: _config,
                onCompleted: _verify,
              ),
              const SizedBox(height: 24),
              OTPResendButton(
                config: _cooldown,
                labels: ResendButtonLabels(
                  resend: 'Resend code',
                  shortCooldown: (t) => 'Resend in $t',
                  longCooldown: (t) => 'Try again in $t',
                ),
                onResend: () async {
                  await widget.onResend();
                  // Starts the next cooldown; without this the button stays
                  // available and users can spam your SMS provider.
                  ref
                      .read(resendCooldownProvider(_cooldown).notifier)
                      .recordResend();
                },
                buttonBuilder: (context, {required label, required onPressed}) {
                  return TextButton(onPressed: onPressed, child: Text(label));
                },
              ),
              const Spacer(),
              FilledButton(
                onPressed: state.isComplete && !_verifying
                    ? () => _verify(state.value)
                    : null,
                child: _verifying
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
