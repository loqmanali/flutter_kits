/// Hand-written Dart snippets for the OTPTextField demos.
///
/// These are shown verbatim under each demo's "Code" tab, so they MUST match
/// the real otp_kit API. Keep them minimal and copy-pasteable.
library;

// ---------------------------------------------------------------------------
// Basic 4-digit
// ---------------------------------------------------------------------------
const String kOtpBasicSnippet = r'''import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:otp_kit/otp_kit.dart';

class BasicOtpExample extends ConsumerWidget {
  const BasicOtpExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OTPTextField(
      config: OTPTheme.defaultLight(context),
      onCompleted: (code) => debugPrint('Completed: $code'),
    );
  }
}''';

// ---------------------------------------------------------------------------
// 6-digit length
// ---------------------------------------------------------------------------
const String kOtpLength6Snippet = r'''OTPTextField(
  config: OTPTheme.custom(
    context: context,
    length: 6,
  ),
  onCompleted: (code) => debugPrint('Code: $code'),
)''';

// ---------------------------------------------------------------------------
// Input types (numeric / alphabetic / alphanumeric / any)
// ---------------------------------------------------------------------------
const String kOtpInputTypesSnippet = r'''// Numeric (digits only) — default
OTPTextField(
  config: OTPTheme.custom(context: context, inputType: OTPInputType.numeric),
)

// Alphabetic (A-Z)
OTPTextField(
  config: OTPTheme.custom(context: context, inputType: OTPInputType.alphabetic),
)

// Alphanumeric
OTPTextField(
  config: OTPTheme.custom(
    context: context,
    inputType: OTPInputType.alphanumeric,
  ),
)''';

// ---------------------------------------------------------------------------
// Obscured (secure entry)
// ---------------------------------------------------------------------------
const String kOtpObscuredSnippet = r'''OTPTextField(
  config: OTPTheme.custom(
    context: context,
    obscureText: true,
    obscureCharacter: '•',
  ),
)''';

// ---------------------------------------------------------------------------
// Expand (rectangular cells that fill width)
// ---------------------------------------------------------------------------
const String kOtpExpandSnippet = r'''OTPTextField(
  config: OTPTheme.custom(
    context: context,
    length: 4,
    expand: true, // cells stretch to fill the available width
  ),
)''';

// ---------------------------------------------------------------------------
// RTL (right-to-left)
// ---------------------------------------------------------------------------
const String kOtpRtlSnippet = r'''OTPTextField(
  config: OTPTheme.custom(
    context: context,
    isRTL: true,
  ),
)''';

// ---------------------------------------------------------------------------
// Custom colours via OTPTheme.custom
// ---------------------------------------------------------------------------
const String kOtpCustomColorsSnippet = r'''// Start from a preset, then override any of the 30 OTPConfig fields.
OTPTextField(
  config: OTPTheme.adaptive(context).copyWith(
    length: 5,
    activeColor: Color(0xFF16A34A),   // green when focused
    inactiveColor: Color(0xFFD1D5DB), // grey when empty
    successColor: Color(0xFF15803D),  // green when complete
    backgroundColor: Color(0xFFF0FDF4),
    borderRadius: 12,
    borderWidth: 2,
    size: 56,
  ),
)''';

// ---------------------------------------------------------------------------
// Error state (triggered by setError on the controller)
// ---------------------------------------------------------------------------
const String kOtpErrorSnippet = r'''// ref.read(otpControllerProvider(config).notifier).setError('Invalid code')
// The cells turn red and shake. clearOnError (default false) wipes them first.

OTPTextField(
  config: OTPTheme.custom(context: context),
  onCompleted: (code) {
    // Simulate a verification failure.
    ref
        .read(otpControllerProvider(OTPTheme.custom(context: context)).notifier)
        .setError('The code you entered is incorrect.');
  },
)''';
