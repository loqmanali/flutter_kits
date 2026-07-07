import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:otp_kit/otp_kit.dart';

/// Advanced example: 6-digit OTP with custom validation rules, error display,
/// progress indicator, and a real resend flow backed by [resendCooldownProvider].
class AdvancedOTPExample extends ConsumerStatefulWidget {
  const AdvancedOTPExample({super.key});

  @override
  ConsumerState<AdvancedOTPExample> createState() => _AdvancedOTPExampleState();
}

class _AdvancedOTPExampleState extends ConsumerState<AdvancedOTPExample> {
  late final OTPConfig _otp;
  late final ResendCooldownConfig _resend;

  @override
  void initState() {
    super.initState();
    _otp = OTPTheme.custom(
      context: context,
      length: 6,
      inputType: OTPInputType.numeric,
      clearOnError: true,
      autoDismissKeyboard: true,
      // Auto-submission flows usually want this on, so a backspace + retype
      // of the same digits doesn't fire the verify call twice.
      dedupeCompletion: true,
    );
    _resend = const ResendCooldownConfig(namespace: 'advanced_example');
  }

  void _handleCompletion(String otp) {
    final controller = ref.read(otpControllerProvider(_otp).notifier);
    final error = controller.validate(
      customRules: const [
        NoSequentialPatternRule(),
        NoRepeatedDigitsRule(),
        MinimumUniqueDigitsRule(minimumUnique: 3),
      ],
    );
    if (error != null) {
      controller.setError(error);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Valid OTP: $otp'), backgroundColor: Colors.green),
    );
    // Reset the resend cooldown for the next round.
    ref.read(resendCooldownProvider(_resend).notifier).resetAll();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpControllerProvider(_otp));
    final controller = ref.read(otpControllerProvider(_otp).notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced OTP Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter 6-digit OTP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'We sent a code to your phone',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OTPTextField(
              config: _otp,
              onCompleted: _handleCompletion,
              onChanged: (_) {
                if (otpState.hasError) controller.clearError();
              },
            ),
            const SizedBox(height: 16),
            if (otpState.hasError)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        otpState.errorMessage ?? 'Invalid OTP',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: otpState.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${otpState.filledCount} of ${_otp.length} digits entered',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.clear,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: otpState.canSubmit
                        ? () => _handleCompletion(otpState.value)
                        : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Verify'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Real resend flow — disables itself during cooldowns and locks
            // out after `maxAttempts`. State persists across app restarts.
            OTPResendButton(
              config: _resend,
              labels: ResendButtonLabels(
                resend: 'Resend Code',
                shortCooldown: (t) => 'Wait $t before retrying',
                longCooldown: (t) => 'Locked — try again in $t',
              ),
              onResend: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('OTP resent')));
              },
              buttonBuilder: (context, {required label, required onPressed}) {
                return TextButton(onPressed: onPressed, child: Text(label));
              },
            ),
          ],
        ),
      ),
    );
  }
}
