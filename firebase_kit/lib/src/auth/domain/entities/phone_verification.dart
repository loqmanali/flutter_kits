/// Result of [AuthRepository.startPhoneVerification].
///
/// Phone auth is two-step on mobile: send code → confirm code. The kit returns
/// this so callers can later confirm the SMS code with the same verificationId.
class PhoneVerificationSession {
  /// Opaque id returned by Firebase. Pass back to [confirmPhoneCode].
  final String verificationId;

  /// Token used to force-resend the code.
  final int? resendToken;

  /// `true` when Android auto-retrieval already verified the user — the kit
  /// has signed them in and no code entry is required.
  final bool autoVerified;

  const PhoneVerificationSession({
    required this.verificationId,
    this.resendToken,
    this.autoVerified = false,
  });
}
