/// Snippets for the widget_kit landing page.
library;

const kWidgetKitInstall = '''
dependencies:
  widget_kit:
    git:
      url: https://github.com/loqmanali/flutter_kits.git
      path: widget_kit
      # Tags are monorepo releases, not per-package versions —
      # widget_kit 1.2.0 ships inside the v2.0.0 tag.
      ref: v2.0.0

# While working on the kit itself, point at your checkout instead:
dependency_overrides:
  widget_kit:
    path: ../packages/widget_kit
''';

const kWidgetKitQuickStart = '''
import 'package:widget_kit/widget_kit.dart';

AppButton(
  label: 'Continue',
  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
  iconAlignment: AppIconAlignment.end,
  onPressed: () {},
)
''';

const kWidgetKitTheming = '''
MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: const [
      // Styling for inputs, dialogs, sheets and spacing.
      WidgetKitTheme(
        inputBorderRadius: 12,
        primaryButtonColor: Color(0xFF104C65),
      ),
      // Button colours live in their own extension — see the AppButton page.
      AppButtonThemeExtension.defaults,
    ],
  ),
);
''';
