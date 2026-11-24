// template: app-shell
// description: A MaterialApp wired for the kits — theme extensions, ProviderScope, toasts.
// kits: widget_kit
// pub: hooks_riverpod
// output: lib/app.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widget_kit/widget_kit.dart';

/// The root of an app using the kits.
///
/// Three things have to be in place, and each fails quietly if it isn't:
///
///  * **ProviderScope** — otp_kit and the other Riverpod-backed kits throw
///    without one.
///  * **ToastificationWrapper** — `UIHelper.showToast` needs it mounted above
///    the navigator. Without it toasts are silently dropped rather than
///    throwing, so the bug looks like "toasts don't work".
///  * **The theme extensions** — `AppButton` reads `AppButtonThemeExtension`
///    and nothing else. Leave it out and every button uses widget_kit's
///    built-in brand red. Run `fkit theme --primary <hex>` to generate a real
///    one, then swap it in for the defaults below.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ToastificationWrapper(
        child: MaterialApp(
          title: 'My App',
          debugShowCheckedModeBanner: false,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: const _Home(),
        ),
      ),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final base = ThemeData(
      brightness: brightness,
      colorSchemeSeed: const Color(0xFF104C65),
      useMaterial3: true,
    );

    return base.copyWith(
      extensions: const <ThemeExtension<dynamic>>[
        // Replace both with the pair `fkit theme` generates.
        WidgetKitTheme(
          inputBorderRadius: 12,
          buttonBorderRadius: 12,
          dialogBorderRadius: 20,
          sheetBorderRadius: 20,
        ),
        AppButtonThemeExtension.defaults,
      ],
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppButton(
            label: 'It works',
            widthMode: AppButtonWidthMode.hug,
            onPressed: () =>
                UIHelper.showSnackBar(context, message: 'Hello from widget_kit'),
          ),
        ),
      ),
    );
  }
}
