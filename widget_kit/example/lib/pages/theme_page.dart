import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../gallery/demo_section.dart';
import '../gallery/gallery_scaffold.dart';

/// Documents the design tokens and the WidgetKitTheme ThemeExtension.
class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final wk = WidgetKitTheme.of(context);
    return GalleryScaffold(
      title: 'Theme & Tokens',
      intro:
          'WidgetKitTokens are fixed design constants; WidgetKitTheme is a '
          'ThemeExtension you register on ThemeData to customise widgets '
          'app-wide. This gallery registers inputBorderRadius: 12.',
      sections: [
        DemoSection(
          title: 'Spacing scale',
          description: 'WidgetKitTokens.space* — a consistent spacing ramp.',
          demoBackground: false,
          demo: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(context, 'spaceXs', WidgetKitTokens.spaceXs),
              _bar(context, 'spaceSm', WidgetKitTokens.spaceSm),
              _bar(context, 'spaceMd', WidgetKitTokens.spaceMd),
              _bar(context, 'spaceLg', WidgetKitTokens.spaceLg),
              _bar(context, 'spaceXl', WidgetKitTokens.spaceXl),
              _bar(context, 'spaceXxl', WidgetKitTokens.spaceXxl),
            ],
          ),
          code: '''
WidgetKitTokens.spaceMd   // 16
WidgetKitTokens.radiusSm  // 8
WidgetKitTokens.buttonHeight // 48''',
        ),
        DemoSection(
          title: 'Border-radius scale',
          description:
              'WidgetKitTokens.radius* — corner radii from xs to pill.',
          demoBackground: false,
          demo: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _radius(context, 'xs', WidgetKitTokens.radiusXs),
              _radius(context, 'sm', WidgetKitTokens.radiusSm),
              _radius(context, 'md', WidgetKitTokens.radiusMd),
              _radius(context, 'lg', WidgetKitTokens.radiusLg),
              _radius(context, 'xl', WidgetKitTokens.radiusXl),
            ],
          ),
        ),
        DemoSection(
          title: 'WidgetKitTheme.of(context)',
          description:
              'Widgets resolve their look from the registered '
              'extension, falling back to token defaults when none is set.',
          demoBackground: false,
          demo: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('inputBorderRadius: ${wk.inputBorderRadius}'),
                Text('buttonHeight: ${wk.buttonHeight}'),
              ],
            ),
          ),
          code: '''
MaterialApp(
  theme: ThemeData(extensions: const [
    WidgetKitTheme(inputBorderRadius: 12, buttonHeight: 52),
  ]),
);

// Anywhere:
final wk = WidgetKitTheme.of(context);''',
        ),
      ],
    );
  }

  Widget _bar(BuildContext context, String name, double value) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(name, style: Theme.of(context).textTheme.labelSmall),
          ),
          Container(height: 14, width: value, color: color),
          const SizedBox(width: 8),
          Text(value.toStringAsFixed(0)),
        ],
      ),
    );
  }

  Widget _radius(BuildContext context, String name, double value) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(value),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$name (${value.toStringAsFixed(0)})',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
