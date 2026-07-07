import 'package:flutter/material.dart';

import 'code_block.dart';

/// One documented widget demo: a title, a short description, the live
/// (interactive) widget, and the copy-able code that produced it.
///
/// This is the single building block every gallery page is composed of — it
/// keeps all demos visually consistent and removes layout boilerplate from the
/// pages themselves.
class DemoSection extends StatelessWidget {
  const DemoSection({
    super.key,
    required this.title,
    required this.description,
    required this.demo,
    this.code,
    this.demoBackground = true,
  });

  /// Short, bold heading naming the widget/variant.
  final String title;

  /// One or two sentences: what it is and when to use it.
  final String description;

  /// The live, interactive widget being demonstrated.
  final Widget demo;

  /// Optional Dart snippet shown under the demo with a copy button.
  final String? code;

  /// Whether to render the demo on a subtle surface card. Turn off for demos
  /// that bring their own full-bleed background.
  final bool demoBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        )),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        if (demoBackground)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Center(child: demo),
          )
        else
          demo,
        if (code != null) ...[
          const SizedBox(height: 12),
          CodeBlock(code!),
        ],
      ],
    );
  }
}

/// A labelled group of related demos under a page, with a divider before it.
/// Use to cluster (e.g.) all button *styles* vs all button *sizes*.
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
        const SizedBox(height: 16),
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) const SizedBox(height: 28),
        ],
      ],
    );
  }
}
