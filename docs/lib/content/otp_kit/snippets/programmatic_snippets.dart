/// Hand-written snippets for the Programmatic control demos.
library;

const String kProgrammaticSnippet = r'''// Drive the field from code via the OTPController.
final config = OTPTheme.custom(context: context, length: 4);
final controller = ref.read(otpControllerProvider(config).notifier);

controller.setValue('1234');        // fill cells, medium haptic
controller.setError('Expired');     // turns red + shakes
controller.clearError();            // back to normal
controller.clear();                 // wipe everything
controller.validate();              // -> String? error

// Read state declaratively via selectors:
ref.watch(otpValueProvider(config));        // '1234'
ref.watch(otpIsCompleteProvider(config));   // true
ref.watch(otpProgressProvider(config));     // 1.0''';

const String kOverviewQuickStartSnippet = r'''import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:otp_kit/otp_kit.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: OTPTextField(
            config: OTPTheme.defaultLight(context),
            onCompleted: (code) => debugPrint('User entered: $code'),
          ),
        ),
      ),
    );
  }
}''';

const String kOverviewInstallSnippet = r'''# pubspec.yaml — pin a git ref, bump deliberately.
dependencies:
  otp_kit:
    git:
      url: https://github.com/loqmanali/flutter_kits.git
      path: otp_kit
      # Tags are monorepo releases, not per-package versions —
      # otp_kit 3.2.0 ships inside the v2.0.0 tag.
      ref: v2.0.0

# During local development, override with a path dep (git-ignored):
# dependency_overrides:
#   otp_kit:
#     path: ../flutter_kits/otp_kit''';
