import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../../../core/callout.dart';
import '../../../core/code_block.dart';
import '../../../core/preview_tabs.dart';
import '../snippets/overview_snippets.dart';

/// The widget_kit landing page.
class WidgetKitOverview extends StatelessWidget {
  const WidgetKitOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'widget_kit',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 44),
              ),
              const SizedBox(height: 14),
              Text(
                'The project-agnostic widget layer: buttons, inputs, dialogs and '
                'sheets, feedback and shimmer states, media, layout helpers, '
                'menus, pickers, and effects. Every widget takes per-instance '
                'overrides, and the whole set can be restyled from the theme.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 28),
              PreviewTabs(
                demo: const _Hero(),
                code: kWidgetKitQuickStart,
                previewPadding: const EdgeInsets.symmetric(
                  vertical: 36,
                  horizontal: 24,
                ),
              ),
              const SizedBox(height: 48),

              Text('Install', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                'Pin a git ref and bump deliberately. Override with a path dep '
                'while developing locally.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 14),
              const CodeBlock(kWidgetKitInstall, language: 'yaml'),
              const SizedBox(height: 48),

              Text("What's inside", style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Nine families under one import. Pages are being written one '
                'family at a time — the sidebar lists what is documented so far.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              const _FamilyGrid(),
              const SizedBox(height: 48),

              Text('Theming', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                'Most widgets read WidgetKitTheme, a ThemeExtension carrying '
                'radii, heights and colours. Register it once and the kit '
                'follows your brand.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 14),
              const CodeBlock(kWidgetKitTheming),
              const SizedBox(height: 20),
              const Callout(
                title: 'Buttons are themed separately',
                tone: CalloutTone.warning,
                child: Text(
                  'AppButton does not read WidgetKitTheme. Its colours come '
                  'from AppButtonThemeExtension, and its defaults are the brand '
                  'red and orange of the app this kit came from — not your '
                  'ColorScheme. Register that extension too, or every button '
                  'ships red.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: AppButton(
        label: 'Continue',
        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
        iconAlignment: AppIconAlignment.end,
        onPressed: () {},
      ),
    );
  }
}

/// The nine families the barrel file exports, and whether each has a page yet.
class _FamilyGrid extends StatelessWidget {
  const _FamilyGrid();

  static const _families = <(IconData, String, String, bool)>[
    (
      Icons.smart_button_rounded,
      'Buttons',
      'AppButton (10 variants + FAB + Cupertino), AppBackButton',
      true,
    ),
    (
      Icons.edit_rounded,
      'Inputs',
      'AppTextFormField, phone field with country picker, DOB picker, formatters',
      false,
    ),
    (
      Icons.chat_bubble_outline_rounded,
      'Dialogs & sheets',
      'UIHelper (toasts, sheets, loaders), warning dialog, dialog picker',
      false,
    ),
    (
      Icons.hourglass_empty_rounded,
      'Feedback',
      'Empty and error states, adaptive loading, shimmer layouts',
      false,
    ),
    (
      Icons.dashboard_outlined,
      'Layout',
      'Accordion, page top bar, profile layout, spacing scale',
      false,
    ),
    (
      Icons.image_outlined,
      'Media',
      'AppMediaImage (network/SVG/asset), video webview, YouTube player',
      false,
    ),
    (
      Icons.menu_open_rounded,
      'Menus',
      'Context menu with submenus, custom dropdown menu',
      false,
    ),
    (
      Icons.event_available_rounded,
      'Pickers',
      'Slot & time picker (inline + sheet), generic picker sheet with search',
      false,
    ),
    (
      Icons.auto_awesome_rounded,
      'Effects',
      'Animated SVG, star rating, refresh trigger, travelling border',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 2 : 1;
        const gap = 12.0;
        final width =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (icon, name, blurb, documented) in _families)
              SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 17, color: theme.colorScheme.primary),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                if (!documented)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'soon',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              blurb,
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
