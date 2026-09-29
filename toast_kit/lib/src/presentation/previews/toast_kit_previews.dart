// Not exported from the barrel (`lib/toast_kit.dart`): previews are a
// development-time surface for `flutter widget-preview`, not part of the
// kit's public API.
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../domain/toast_action.dart';
import '../../domain/toast_close_button_policy.dart';
import '../../domain/toast_request.dart';
import '../../domain/toast_tone.dart';
import '../layouts/banner_toast_layout.dart';
import '../layouts/filled_toast_layout.dart';
import '../layouts/flat_toast_layout.dart';
import '../layouts/minimal_toast_layout.dart';
import '../layouts/outlined_toast_layout.dart';
import '../toast_kit_theme.dart';
import '../toast_layout.dart';

/// A single toast, built without a [ToastController]/`ToastHost` — the
/// static progress [Animation] previews need, since there is no timer here.
Widget _staticToast({
  required ToastLayout layout,
  required ToastTone tone,
  String title = 'Upload complete',
  String? message = 'Your file is ready to share.',
  double progress = 0.65,
  bool withAction = false,
  bool withClose = false,
}) {
  return Builder(
    builder: (context) {
      final theme = ToastKitTheme.of(context);
      final scheme = Theme.of(context).colorScheme;
      final request = ToastRequest(
        title: title,
        message: message,
        tone: tone,
        action:
            withAction ? ToastAction(label: 'Undo', onPressed: () {}) : null,
        showCloseButton: withClose
            ? ToastCloseButtonPolicy.always
            : ToastCloseButtonPolicy.never,
      );
      final view = ToastView(
        request: request,
        tone: tone,
        backgroundColor: theme.backgroundFor(tone, scheme),
        foregroundColor: theme.foregroundFor(tone, scheme),
        borderColor: theme.accentFor(tone, scheme),
        iconColor: theme.accentFor(tone, scheme),
        titleStyle: Theme.of(context).textTheme.titleSmall!,
        messageStyle: Theme.of(context).textTheme.bodySmall!,
        progress: AlwaysStoppedAnimation<double>(progress),
        showCloseButton: withClose,
        maxTitleLines: theme.maxTitleLines ?? 5,
        maxMessageLines: theme.maxMessageLines ?? 3,
        strings: theme.strings!,
        onClose: () {},
        onAction: () {},
      );
      return Padding(
        padding: const EdgeInsets.all(12),
        child: layout.build(context, view),
      );
    },
  );
}

Widget _previewApp(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: ThemeData(brightness: brightness, useMaterial3: true),
    home: Scaffold(body: Center(child: child)),
  );
}

// ---- Every built-in layout x every tone ----

@Preview(name: 'flat / success', group: 'toast_kit')
Widget flatSuccessPreview() => _previewApp(
    _staticToast(layout: const FlatToastLayout(), tone: ToastTone.success));

@Preview(name: 'flat / error', group: 'toast_kit')
Widget flatErrorPreview() => _previewApp(
    _staticToast(layout: const FlatToastLayout(), tone: ToastTone.error));

@Preview(name: 'flat / warning', group: 'toast_kit')
Widget flatWarningPreview() => _previewApp(
    _staticToast(layout: const FlatToastLayout(), tone: ToastTone.warning));

@Preview(name: 'flat / info', group: 'toast_kit')
Widget flatInfoPreview() => _previewApp(
    _staticToast(layout: const FlatToastLayout(), tone: ToastTone.info));

@Preview(name: 'flat / neutral', group: 'toast_kit')
Widget flatNeutralPreview() => _previewApp(
    _staticToast(layout: const FlatToastLayout(), tone: ToastTone.neutral));

@Preview(name: 'filled / success', group: 'toast_kit')
Widget filledSuccessPreview() => _previewApp(
    _staticToast(layout: const FilledToastLayout(), tone: ToastTone.success));

@Preview(name: 'filled / error', group: 'toast_kit')
Widget filledErrorPreview() => _previewApp(
    _staticToast(layout: const FilledToastLayout(), tone: ToastTone.error));

@Preview(name: 'filled / warning', group: 'toast_kit')
Widget filledWarningPreview() => _previewApp(
    _staticToast(layout: const FilledToastLayout(), tone: ToastTone.warning));

@Preview(name: 'filled / info', group: 'toast_kit')
Widget filledInfoPreview() => _previewApp(
    _staticToast(layout: const FilledToastLayout(), tone: ToastTone.info));

@Preview(name: 'filled / neutral', group: 'toast_kit')
Widget filledNeutralPreview() => _previewApp(
    _staticToast(layout: const FilledToastLayout(), tone: ToastTone.neutral));

@Preview(name: 'outlined / success', group: 'toast_kit')
Widget outlinedSuccessPreview() => _previewApp(
    _staticToast(layout: const OutlinedToastLayout(), tone: ToastTone.success));

@Preview(name: 'outlined / error', group: 'toast_kit')
Widget outlinedErrorPreview() => _previewApp(
    _staticToast(layout: const OutlinedToastLayout(), tone: ToastTone.error));

@Preview(name: 'outlined / warning', group: 'toast_kit')
Widget outlinedWarningPreview() => _previewApp(
    _staticToast(layout: const OutlinedToastLayout(), tone: ToastTone.warning));

@Preview(name: 'outlined / info', group: 'toast_kit')
Widget outlinedInfoPreview() => _previewApp(
    _staticToast(layout: const OutlinedToastLayout(), tone: ToastTone.info));

@Preview(name: 'outlined / neutral', group: 'toast_kit')
Widget outlinedNeutralPreview() => _previewApp(
    _staticToast(layout: const OutlinedToastLayout(), tone: ToastTone.neutral));

@Preview(name: 'minimal / success', group: 'toast_kit')
Widget minimalSuccessPreview() => _previewApp(
    _staticToast(layout: const MinimalToastLayout(), tone: ToastTone.success));

@Preview(name: 'minimal / error', group: 'toast_kit')
Widget minimalErrorPreview() => _previewApp(
    _staticToast(layout: const MinimalToastLayout(), tone: ToastTone.error));

@Preview(name: 'minimal / warning', group: 'toast_kit')
Widget minimalWarningPreview() => _previewApp(
    _staticToast(layout: const MinimalToastLayout(), tone: ToastTone.warning));

@Preview(name: 'minimal / info', group: 'toast_kit')
Widget minimalInfoPreview() => _previewApp(
    _staticToast(layout: const MinimalToastLayout(), tone: ToastTone.info));

@Preview(name: 'minimal / neutral', group: 'toast_kit')
Widget minimalNeutralPreview() => _previewApp(
    _staticToast(layout: const MinimalToastLayout(), tone: ToastTone.neutral));

@Preview(name: 'banner / success', group: 'toast_kit', size: Size(400, 120))
Widget bannerSuccessPreview() => _previewApp(
    _staticToast(layout: const BannerToastLayout(), tone: ToastTone.success));

@Preview(name: 'banner / error', group: 'toast_kit', size: Size(400, 120))
Widget bannerErrorPreview() => _previewApp(
    _staticToast(layout: const BannerToastLayout(), tone: ToastTone.error));

@Preview(name: 'banner / warning', group: 'toast_kit', size: Size(400, 120))
Widget bannerWarningPreview() => _previewApp(
    _staticToast(layout: const BannerToastLayout(), tone: ToastTone.warning));

@Preview(name: 'banner / info', group: 'toast_kit', size: Size(400, 120))
Widget bannerInfoPreview() => _previewApp(
    _staticToast(layout: const BannerToastLayout(), tone: ToastTone.info));

@Preview(name: 'banner / neutral', group: 'toast_kit', size: Size(400, 120))
Widget bannerNeutralPreview() => _previewApp(
    _staticToast(layout: const BannerToastLayout(), tone: ToastTone.neutral));

// ---- Edge cases ----

@Preview(name: 'RTL, 5-line Arabic title', group: 'toast_kit')
Widget rtlLongTitlePreview() => MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: _staticToast(
              layout: const FlatToastLayout(),
              tone: ToastTone.info,
              title:
                  'تعذر حفظ التغييرات لأن الاتصال بالخادم انقطع أثناء المزامنة، '
                  'يرجى المحاولة مرة أخرى بعد التحقق من اتصال الشبكة لديك والمحاولة لاحقًا',
              message: 'حاول مرة أخرى بعد التحقق من الشبكة.',
              withClose: true,
            ),
          ),
        ),
      ),
    );

@Preview(name: 'dark brightness', group: 'toast_kit')
Widget darkBrightnessPreview() => _previewApp(
      _staticToast(
          layout: const FilledToastLayout(),
          tone: ToastTone.error,
          withClose: true),
      brightness: Brightness.dark,
    );

@Preview(name: 'textScaleFactor 2.0', group: 'toast_kit', textScaleFactor: 2.0)
Widget textScale2Preview() => _previewApp(
    _staticToast(layout: const FlatToastLayout(), tone: ToastTone.warning));

@Preview(
    name: 'top placement, stack of 3', group: 'toast_kit', size: Size(400, 400))
Widget topStackPreview() => _previewApp(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _staticToast(
              layout: const FlatToastLayout(),
              tone: ToastTone.success,
              message: null),
          const SizedBox(height: 8),
          _staticToast(
              layout: const FlatToastLayout(),
              tone: ToastTone.info,
              message: null),
          const SizedBox(height: 8),
          _staticToast(
              layout: const FlatToastLayout(),
              tone: ToastTone.neutral,
              message: null),
        ],
      ),
    );

@Preview(
    name: 'bottom placement, stack of 3',
    group: 'toast_kit',
    size: Size(400, 400))
Widget bottomStackPreview() => _previewApp(
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _staticToast(
              layout: const FlatToastLayout(),
              tone: ToastTone.neutral,
              message: null),
          const SizedBox(height: 8),
          _staticToast(
              layout: const FlatToastLayout(),
              tone: ToastTone.warning,
              message: null),
          const SizedBox(height: 8),
          _staticToast(
              layout: const FlatToastLayout(),
              tone: ToastTone.error,
              message: null),
        ],
      ),
    );

@Preview(name: 'action + close button', group: 'toast_kit')
Widget actionAndClosePreview() => _previewApp(
      _staticToast(
        layout: const FlatToastLayout(),
        tone: ToastTone.neutral,
        title: 'Message deleted',
        message: null,
        withAction: true,
        withClose: true,
      ),
    );
