import 'package:flutter/material.dart';

import 'preview_tabs.dart';

/// One documented widget demo: a title, a short description, and a
/// [PreviewTabs] showing the live widget + its copy-able code.
///
/// This is the single building block every component page is composed of —
/// it keeps demos visually consistent and removes layout boilerplate from
/// the page files themselves.
class DemoSection extends StatelessWidget {
  const DemoSection({
    super.key,
    required this.title,
    required this.description,
    required this.demo,
    required this.code,
    this.previewBackground,
    this.previewPadding,
  });

  /// Short, bold heading naming the widget/variant.
  final String title;

  /// One or two sentences: what it is and when to use it.
  final String description;

  /// The live, interactive widget being demonstrated.
  final Widget demo;

  /// The Dart snippet shown under the "Code" tab.
  final String code;

  /// Override the preview surface colour (rarely needed).
  final Color? previewBackground;

  /// Padding inside the preview area (defaults to PreviewTabs' default).
  final EdgeInsetsGeometry? previewPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 14),
        PreviewTabs(
          demo: demo,
          code: code,
          previewBackground: previewBackground,
          previewPadding: previewPadding ?? const EdgeInsets.all(28),
        ),
      ],
    );
  }
}

/// A labelled cluster of demos under a page, with a divider before it.
/// Use to group (e.g.) all input *types* vs all *sizes*.
class DemoGroup extends StatelessWidget {
  const DemoGroup({super.key, required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
          ],
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) const SizedBox(height: 32),
        ],
      ],
    );
  }
}
