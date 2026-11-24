import 'package:flutter/cupertino.dart' show CupertinoColors;
import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../../../core/api_table.dart';
import '../../../core/callout.dart';
import '../../../core/component_page.dart';
import '../../../core/demo_section.dart';
import '../snippets/app_button_snippets.dart';

/// The AppButton page.
///
/// Every default quoted here is read out of
/// `widget_kit/lib/src/buttons/adaptive_button/src/` — the size table from
/// `_sizeConfig`, the colours from `AppButtonStyle`, the width behaviour from
/// `_widthMode`. When that source changes, this page has to change with it.
class AppButtonSection extends StatelessWidget {
  const AppButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'AppButton',
      lead: 'One button covering all ten Material 3 variants — filled, tonal, '
          'elevated, outlined, text, four icon styles, and the FAB — plus a '
          'Cupertino mode. Sizes, loading and disabled states, and haptics are '
          'built in.',
      params: const [
        ApiParam(
          name: 'label',
          type: 'String?',
          note: 'Required unless child or an icon style is used.',
        ),
        ApiParam(name: 'child', type: 'Widget?', note: 'Replaces label entirely.'),
        ApiParam(
          name: 'style',
          type: 'AppButtonStyleType',
          defaultValue: '.filled',
        ),
        ApiParam(
          name: 'size',
          type: 'AdaptiveButtonSize',
          defaultValue: '.medium',
        ),
        ApiParam(
          name: 'widthMode',
          type: 'AppButtonWidthMode?',
          defaultValue: '.fill',
          note: 'Defaults to .hug for the icon styles.',
        ),
        ApiParam(name: 'icon', type: 'Widget?'),
        ApiParam(name: 'iconAlignment', type: 'AppIconAlignment?'),
        ApiParam(name: 'isLoading', type: 'bool', defaultValue: 'false'),
        ApiParam(name: 'isDisabled', type: 'bool', defaultValue: 'false'),
        ApiParam(name: 'onPressed', type: 'VoidCallback?'),
        ApiParam(name: 'onLongPress', type: 'VoidCallback?'),
        ApiParam(name: 'backgroundColor', type: 'Color?'),
        ApiParam(name: 'foregroundColor', type: 'Color?'),
        ApiParam(name: 'borderRadius', type: 'double?', defaultValue: '8.0'),
        ApiParam(name: 'fitLabel', type: 'bool', defaultValue: 'true'),
        ApiParam(
          name: 'enableHapticFeedback',
          type: 'bool',
          defaultValue: 'true',
        ),
        ApiParam(name: 'tooltip', type: 'String?'),
        ApiParam(
          name: 'useCupertinoStyle',
          type: 'bool',
          defaultValue: 'false',
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'The basic button',
            description: 'A label and a callback is the whole minimum.',
            demo: SizedBox(width: 260, child: _Basic()),
            code: kAppButtonBasic,
          ),
          const SizedBox(height: 20),
          const Callout(
            title: 'A button fills its parent unless you tell it not to',
            tone: CalloutTone.warning,
            child: Text(
              'widthMode defaults to fill for every style except the four icon '
              'styles, which default to hug. Drop an AppButton straight into a '
              'Column and it spans the full width — that is the intended '
              'default for form and sheet actions, and the usual surprise when '
              'you wanted a small inline button. Pass '
              'widthMode: AppButtonWidthMode.hug for that.',
            ),
          ),
          const SizedBox(height: 32),
          const DemoSection(
            title: 'Width mode',
            description: 'The same button, both ways, in a 320dp-wide parent.',
            demo: _WidthModes(),
            code: kAppButtonWidthMode,
          ),
          const SizedBox(height: 44),
          DemoGroup(
            label: 'Variants',
            children: const [
              DemoSection(
                title: 'Styles',
                description: 'Five text styles, in descending emphasis. Pick '
                    'one filled button per screen and make everything else '
                    'quieter.',
                demo: _Styles(),
                code: kAppButtonStyles,
              ),
              DemoSection(
                title: 'Sizes',
                description: 'large is 56dp tall with a 16sp label, medium '
                    '48dp / 14sp, small 32dp / 12sp. Icons scale with them '
                    '(24 / 20 / 18).',
                demo: _Sizes(),
                code: kAppButtonSizes,
              ),
              DemoSection(
                title: 'With an icon',
                description: 'Pass icon alongside label. Sizing is yours to '
                    'set — the button does not resize the widget you hand it.',
                demo: _WithIcon(),
                code: kAppButtonIcon,
              ),
              DemoSection(
                title: 'Icon-only',
                description: 'The four icon styles render icon and ignore '
                    'label. Give each one a tooltip: an icon alone is not a '
                    'name.',
                demo: _IconOnly(),
                code: kAppButtonIconOnly,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Callout(
            title: 'The icon sits on the left in RTL too',
            child: Text(
              'iconAlignment defaults to .start in LTR and .end in RTL. Because '
              'a Row already mirrors under RTL, both resolve to the same visual '
              'side — the icon stays on the left either way instead of '
              'mirroring with the text. Set iconAlignment explicitly if you '
              'want it to follow the reading direction.',
            ),
          ),
          const SizedBox(height: 44),
          DemoGroup(
            label: 'States',
            children: const [
              DemoSection(
                title: 'Loading and disabled',
                description: 'Both states swallow taps. isLoading also swaps '
                    'the label for a spinner, so the button keeps its height '
                    'but loses its label width unless widthMode is fill.',
                demo: _States(),
                code: kAppButtonStates,
              ),
              DemoSection(
                title: 'A real async action',
                description: 'The pattern this is built for: flip isLoading '
                    'around the await and leave onPressed alone.',
                demo: _AsyncDemo(),
                code: kAppButtonLoadingFlow,
              ),
            ],
          ),
          const SizedBox(height: 44),
          DemoGroup(
            label: 'Floating action button',
            children: const [
              DemoSection(
                title: 'AppButton.fab',
                description: 'A separate constructor: regular, small, large, '
                    'or extended with a label.',
                demo: _Fabs(),
                code: kAppButtonFab,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Callout(
            title: 'Two FABs on one route need distinct heroTags',
            tone: CalloutTone.warning,
            child: Text(
              'FloatingActionButton animates through a Hero with a default '
              'tag, so a second FAB on the same route throws "There are '
              'multiple heroes that share the same tag". Give each one its own '
              'heroTag, or pass null to opt out of the Hero entirely.',
            ),
          ),
          const SizedBox(height: 44),
          DemoGroup(
            label: 'Theming',
            children: const [
              DemoSection(
                title: 'Per-instance colours',
                description: 'backgroundColor and foregroundColor override the '
                    'style for one button — right for a destructive action, '
                    'wrong as a way to restyle the app.',
                demo: _CustomColors(),
                code: kAppButtonPerInstanceColors,
              ),
              DemoSection(
                title: 'App-wide, via AppButtonThemeExtension',
                description: 'Register the extension on your ThemeData and '
                    'every AppButton picks it up. It is read at build time, so '
                    'hot reload shows the change immediately.',
                demo: _ThemedPreview(),
                code: kAppButtonThemeExtension,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Callout(
            title: 'Out of the box the colours are brand red and orange, not '
                'your ColorScheme',
            tone: CalloutTone.warning,
            child: Text(
              'AppButtonStyle ships hardcoded defaults — filled is #DC1213, '
              'filledTonal and fab are #F49B25, elevated sits on an opaque '
              'white background that stays white in dark mode. They come from '
              'the app this kit was extracted from, and they do not follow '
              'Theme.of(context).colorScheme. Register an '
              'AppButtonThemeExtension before shipping, or every button in the '
              'app is red.',
            ),
          ),
          const SizedBox(height: 16),
          const Callout(
            title: 'WidgetKitTheme does not reach AppButton',
            tone: CalloutTone.warning,
            child: Text(
              'WidgetKitTheme exposes buttonBorderRadius, buttonHeight, '
              'primaryButtonColor and primaryButtonTextColor, and AppButton '
              'reads none of them — it only consults AppButtonThemeExtension, '
              'and its corner radius is a fixed 8.0 unless you pass '
              'borderRadius. Setting those four fields changes nothing here.',
            ),
          ),
          const SizedBox(height: 44),
          DemoGroup(
            label: 'Platform',
            children: const [
              DemoSection(
                title: 'Cupertino mode',
                description: 'useCupertinoStyle renders a CupertinoButton '
                    'instead. outlined and text both fall back to the '
                    'borderless Cupertino button, which has no border.',
                demo: _Cupertino(),
                code: kAppButtonCupertino,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Demos ───────────────────────────────────────────────────────────────────
// Each demo is the real widget, not a mock-up: what the reader sees here is
// exactly what the snippet beside it produces.

class _Basic extends StatelessWidget {
  const _Basic();

  @override
  Widget build(BuildContext context) =>
      AppButton(label: 'Continue', onPressed: () {});
}

class _WidthModes extends StatelessWidget {
  const _WidthModes();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(label: 'Fills the row', onPressed: () {}),
          const SizedBox(height: 12),
          AppButton(
            label: 'Hugs its label',
            widthMode: AppButtonWidthMode.hug,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

/// Demos with several buttons share this wrap so they reflow on narrow screens
/// instead of overflowing the preview.
class _DemoWrap extends StatelessWidget {
  const _DemoWrap({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
}

class _Styles extends StatelessWidget {
  const _Styles();

  @override
  Widget build(BuildContext context) {
    return _DemoWrap(
      children: [
        for (final (style, label) in const [
          (AppButtonStyleType.filled, 'Filled'),
          (AppButtonStyleType.filledTonal, 'Filled tonal'),
          (AppButtonStyleType.elevated, 'Elevated'),
          (AppButtonStyleType.outlined, 'Outlined'),
          (AppButtonStyleType.text, 'Text'),
        ])
          AppButton(
            label: label,
            style: style,
            widthMode: AppButtonWidthMode.hug,
            onPressed: () {},
          ),
      ],
    );
  }
}

class _Sizes extends StatelessWidget {
  const _Sizes();

  @override
  Widget build(BuildContext context) {
    return _DemoWrap(
      children: [
        for (final (size, label) in const [
          (AdaptiveButtonSize.large, 'Large'),
          (AdaptiveButtonSize.medium, 'Medium'),
          (AdaptiveButtonSize.small, 'Small'),
        ])
          AppButton(
            label: label,
            size: size,
            widthMode: AppButtonWidthMode.hug,
            onPressed: () {},
          ),
      ],
    );
  }
}

class _WithIcon extends StatelessWidget {
  const _WithIcon();

  @override
  Widget build(BuildContext context) {
    return _DemoWrap(
      children: [
        AppButton(
          label: 'Download',
          icon: const Icon(Icons.download_rounded, size: 20),
          widthMode: AppButtonWidthMode.hug,
          onPressed: () {},
        ),
        AppButton(
          label: 'Next',
          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
          iconAlignment: AppIconAlignment.end,
          widthMode: AppButtonWidthMode.hug,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _IconOnly extends StatelessWidget {
  const _IconOnly();

  @override
  Widget build(BuildContext context) {
    return _DemoWrap(
      children: [
        AppButton(
          style: AppButtonStyleType.icon,
          icon: const Icon(Icons.favorite_border_rounded),
          tooltip: 'Save to favourites',
          onPressed: () {},
        ),
        AppButton(
          style: AppButtonStyleType.iconFilled,
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Add item',
          onPressed: () {},
        ),
        AppButton(
          style: AppButtonStyleType.iconFilledTonal,
          icon: const Icon(Icons.bookmark_border_rounded),
          tooltip: 'Bookmark',
          onPressed: () {},
        ),
        AppButton(
          style: AppButtonStyleType.iconOutlined,
          icon: const Icon(Icons.share_rounded),
          tooltip: 'Share',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _States extends StatelessWidget {
  const _States();

  @override
  Widget build(BuildContext context) {
    return _DemoWrap(
      children: [
        SizedBox(
          width: 150,
          child: AppButton(
            label: 'Saving…',
            isLoading: true,
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 150,
          child: AppButton(
            label: 'Unavailable',
            isDisabled: true,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

/// A real two-second round trip, so the reader can watch the state flip.
class _AsyncDemo extends StatefulWidget {
  const _AsyncDemo();

  @override
  State<_AsyncDemo> createState() => _AsyncDemoState();
}

class _AsyncDemoState extends State<_AsyncDemo> {
  bool _saving = false;
  bool _done = false;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _done = false;
    });
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _saving = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 240,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: _saving ? 'Saving…' : 'Save changes',
            isLoading: _saving,
            onPressed: _save,
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: _done ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 15,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Saved',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fabs extends StatelessWidget {
  const _Fabs();

  @override
  Widget build(BuildContext context) {
    return _DemoWrap(
      children: [
        AppButton.fab(
          icon: const Icon(Icons.add),
          buttonType: FloatingActionButtonType.small,
          heroTag: 'docs-fab-small',
          onPressed: () {},
        ),
        AppButton.fab(
          icon: const Icon(Icons.add),
          heroTag: 'docs-fab-regular',
          onPressed: () {},
        ),
        AppButton.fab(
          icon: const Icon(Icons.edit),
          label: 'Compose',
          buttonType: FloatingActionButtonType.extended,
          heroTag: 'docs-fab-extended',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _CustomColors extends StatelessWidget {
  const _CustomColors();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: AppButton(
        label: 'Delete account',
        backgroundColor: const Color(0xFFB3261E),
        foregroundColor: Colors.white,
        onPressed: () {},
      ),
    );
  }
}

/// Shows the extension actually working: the same three buttons under a locally
/// overridden theme, so the reader sees the effect rather than taking it on
/// trust.
class _ThemedPreview extends StatelessWidget {
  const _ThemedPreview();

  static const _brand = Color(0xFF104C65);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        extensions: const [
          AppButtonThemeExtension(
            filled: AppButtonStyle(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              overlayColor: Color(0x14104C65),
            ),
            filledTonal: AppButtonStyle(
              backgroundColor: Color(0xFFD7E7EE),
              foregroundColor: _brand,
              overlayColor: Color(0x1A104C65),
            ),
            elevated: AppButtonStyle.elevated,
            outlined: AppButtonStyle(
              backgroundColor: Color(0x00000000),
              foregroundColor: _brand,
              overlayColor: Color(0x0F104C65),
              borderColor: _brand,
              borderSide: BorderSide(color: _brand),
            ),
            text: AppButtonStyle(
              backgroundColor: Color(0x00000000),
              foregroundColor: _brand,
              overlayColor: Color(0x0F104C65),
            ),
            icon: AppButtonStyle.icon,
            iconFilled: AppButtonStyle.iconFilled,
            iconFilledTonal: AppButtonStyle.iconFilledTonal,
            iconOutlined: AppButtonStyle.iconOutlined,
            fab: AppButtonStyle.fab,
          ),
        ],
      ),
      child: _DemoWrap(
        children: [
          for (final (style, label) in const [
            (AppButtonStyleType.filled, 'Filled'),
            (AppButtonStyleType.filledTonal, 'Tonal'),
            (AppButtonStyleType.outlined, 'Outlined'),
            (AppButtonStyleType.text, 'Text'),
          ])
            AppButton(
              label: label,
              style: style,
              widthMode: AppButtonWidthMode.hug,
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

class _Cupertino extends StatelessWidget {
  const _Cupertino();

  @override
  Widget build(BuildContext context) {
    return _DemoWrap(
      children: [
        SizedBox(
          width: 200,
          child: AppButton(
            label: 'Continue',
            useCupertinoStyle: true,
            cupertinoColor: CupertinoColors.activeBlue,
            onPressed: () {},
          ),
        ),
        AppButton(
          label: 'Cancel',
          style: AppButtonStyleType.text,
          useCupertinoStyle: true,
          widthMode: AppButtonWidthMode.hug,
          onPressed: () {},
        ),
      ],
    );
  }
}
