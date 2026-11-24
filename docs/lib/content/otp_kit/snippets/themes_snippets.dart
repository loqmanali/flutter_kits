/// Hand-written snippets for the Themes demos.
library;

const String kThemesIntroSnippet = r'''// Every OTPTheme preset is a static factory reading Theme.of(context).colorScheme,
// so they adapt automatically to your app's light/dark palette.

OTPTextField(config: OTPTheme.defaultLight(context))
OTPTextField(config: OTPTheme.minimal(context))
OTPTextField(config: OTPTheme.rounded(context))
OTPTextField(config: OTPTheme.modern(context))
OTPTextField(config: OTPTheme.compact(context))
OTPTextField(config: OTPTheme.large(context))
OTPTextField(config: OTPTheme.secure(context))
OTPTextField(config: OTPTheme.premium(context))
OTPTextField(config: OTPTheme.underline(context))
OTPTextField(config: OTPTheme.adaptive(context)) // picks dark/light by current theme''';

const String kThemeCustomSnippet = r'''// Start from adaptive and override any field. All 30 OTPConfig knobs are here.
OTPTextField(
  config: OTPTheme.custom(
    context: context,
    length: 6,
    activeColor: Color(0xFF7C3AED),
    successColor: Color(0xFF15803D),
    borderRadius: 14,
    size: 56,
    spacing: 12,
    textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
    enableShadow: true,
    shadowElevation: 3,
  ),
)''';
