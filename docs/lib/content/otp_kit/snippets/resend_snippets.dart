/// Hand-written snippets for the OTPResendButton demos.
library;

const String kResendBasicSnippet = r'''OTPResendButton(
  config: ResendCooldownConfig(
    namespace: 'signup_otp',
    initialCountdownSeconds: 60,
    maxAttempts: 3,
  ),
  labels: ResendButtonLabels(
    resend: 'Resend code',
    shortCooldown: (t) => 'Resend available in $t',
    longCooldown: (t) => 'Too many attempts. Try again in $t',
  ),
  onResend: () {
    // call your API to resend the OTP
  },
  buttonBuilder: (context, {required label, required onPressed}) =>
      FilledButton(
        onPressed: onPressed,
        child: Text(label),
      ),
)''';

const String kResendConfigSnippet = r'''// Escalation: after maxAttempts quick resends, the kit switches to a long
// cooldown (5 min by default). Both persist across app restarts via
// SharedPreferences, scoped by `namespace`.

const ResendCooldownConfig(
  namespace: 'signup_otp',
  initialCountdownSeconds: 60,   // first countdown
  shortCooldownSeconds: 60,      // retry cooldown
  longCooldownSeconds: 5 * 60,   // after maxAttempts
  maxAttempts: 3,
)''';
