import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../gallery/demo_section.dart';
import '../gallery/gallery_scaffold.dart';

/// Documents [AppButton] (all style variants, sizes, states, FAB) and
/// [AppBackButton].
class ButtonsPage extends StatelessWidget {
  const ButtonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Buttons',
      intro:
          'AppButton is one adaptive button covering ten Material styles, '
          'three sizes, loading/disabled states, icons, and a FAB constructor — '
          'all themable via AppButtonThemeExtension.',
      sections: [
        DemoGroup(
          label: 'Style variants',
          children: [
            DemoSection(
              title: 'The ten styles',
              description:
                  'Pass an AppButtonStyleType to switch emphasis. Filled is '
                  'highest-emphasis; text/outlined are lowest.',
              demo: const Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  AppButton(label: 'Filled', style: AppButtonStyleType.filled),
                  AppButton(
                    label: 'Tonal',
                    style: AppButtonStyleType.filledTonal,
                  ),
                  AppButton(
                    label: 'Elevated',
                    style: AppButtonStyleType.elevated,
                  ),
                  AppButton(
                    label: 'Outlined',
                    style: AppButtonStyleType.outlined,
                  ),
                  AppButton(label: 'Text', style: AppButtonStyleType.text),
                ],
              ),
              code: '''
AppButton(label: 'Filled',   style: AppButtonStyleType.filled)
AppButton(label: 'Tonal',    style: AppButtonStyleType.filledTonal)
AppButton(label: 'Elevated', style: AppButtonStyleType.elevated)
AppButton(label: 'Outlined', style: AppButtonStyleType.outlined)
AppButton(label: 'Text',     style: AppButtonStyleType.text)''',
            ),
            DemoSection(
              title: 'Icon buttons',
              description: 'Icon-only variants for compact actions.',
              demo: Wrap(
                spacing: 10,
                children: [
                  AppButton(
                    style: AppButtonStyleType.icon,
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                  AppButton(
                    style: AppButtonStyleType.iconFilled,
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                  ),
                  AppButton(
                    style: AppButtonStyleType.iconOutlined,
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
              ),
              code: '''
AppButton(
  style: AppButtonStyleType.iconFilled,
  icon: const Icon(Icons.add),
  onPressed: () {},
)''',
            ),
          ],
        ),
        DemoGroup(
          label: 'Sizes & content',
          children: [
            DemoSection(
              title: 'Three sizes',
              description:
                  'large / medium / small adjust height, padding and '
                  'font size together.',
              demo: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(label: 'Large', size: AdaptiveButtonSize.large),
                  SizedBox(height: 10),
                  AppButton(label: 'Medium', size: AdaptiveButtonSize.medium),
                  SizedBox(height: 10),
                  AppButton(label: 'Small', size: AdaptiveButtonSize.small),
                ],
              ),
              code:
                  "AppButton(label: 'Medium', size: AdaptiveButtonSize.medium)",
            ),
            DemoSection(
              title: 'Label + icon',
              description:
                  'Add a leading or trailing icon alongside the label.',
              demo: const Wrap(
                spacing: 10,
                children: [
                  AppButton(label: 'Leading', icon: Icon(Icons.download)),
                  AppButton(
                    label: 'Trailing',
                    icon: Icon(Icons.arrow_forward),
                    iconAlignment: AppIconAlignment.end,
                  ),
                ],
              ),
              code: '''
AppButton(
  label: 'Trailing',
  icon: const Icon(Icons.arrow_forward),
  iconAlignment: AppIconAlignment.end,
)''',
            ),
          ],
        ),
        DemoGroup(
          label: 'States',
          children: [
            const DemoSection(
              title: 'Loading & disabled',
              description:
                  'isLoading swaps the label for a spinner and blocks taps; '
                  'isDisabled greys the button out.',
              demo: Wrap(
                spacing: 10,
                children: [
                  AppButton(label: 'Loading', isLoading: true),
                  AppButton(label: 'Disabled', isDisabled: true),
                ],
              ),
              code: '''
AppButton(label: 'Saving…', isLoading: true)
AppButton(label: 'Disabled', isDisabled: true)''',
            ),
            const _InteractiveCounterButton(),
          ],
        ),
        DemoGroup(
          label: 'Floating action button',
          children: [
            DemoSection(
              title: 'AppButton.fab',
              description:
                  'A FAB constructor with regular, small, large and '
                  'extended types.',
              demo: Wrap(
                spacing: 14,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Each FAB needs a distinct heroTag — two FABs on one route
                  // share Flutter's default Hero tag otherwise and crash.
                  AppButton.fab(
                    heroTag: 'fab-regular',
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                  ),
                  AppButton.fab(
                    heroTag: 'fab-small',
                    icon: const Icon(Icons.edit),
                    buttonType: FloatingActionButtonType.small,
                    onPressed: () {},
                  ),
                  AppButton.fab(
                    heroTag: 'fab-extended',
                    icon: const Icon(Icons.navigation),
                    label: 'Navigate',
                    buttonType: FloatingActionButtonType.extended,
                    onPressed: () {},
                  ),
                ],
              ),
              code: '''
// Give each FAB a unique heroTag when more than one is on screen.
AppButton.fab(heroTag: 'add', icon: const Icon(Icons.add), onPressed: () {})

AppButton.fab(
  heroTag: 'navigate',
  icon: const Icon(Icons.navigation),
  label: 'Navigate',
  buttonType: FloatingActionButtonType.extended,
  onPressed: () {},
)''',
            ),
          ],
        ),
        DemoGroup(
          label: 'Back button',
          children: [
            DemoSection(
              title: 'AppBackButton',
              description:
                  'A circular, shadowed back affordance for custom '
                  'top bars.',
              demo: AppBackButton(onTap: () {}),
              code: 'AppBackButton(onTap: () => Navigator.pop(context))',
            ),
          ],
        ),
      ],
    );
  }
}

/// A small stateful demo proving onPressed actually fires.
class _InteractiveCounterButton extends StatefulWidget {
  const _InteractiveCounterButton();

  @override
  State<_InteractiveCounterButton> createState() =>
      _InteractiveCounterButtonState();
}

class _InteractiveCounterButtonState extends State<_InteractiveCounterButton> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Interactive (onPressed)',
      description: 'Tap to see the callback fire — taps update local state.',
      demo: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pressed $_count times'),
          const SizedBox(height: 12),
          AppButton(
            label: 'Tap me',
            icon: const Icon(Icons.touch_app),
            onPressed: () => setState(() => _count++),
          ),
        ],
      ),
      code: '''
AppButton(
  label: 'Tap me',
  icon: const Icon(Icons.touch_app),
  onPressed: () => setState(() => _count++),
)''',
    );
  }
}
