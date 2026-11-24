import 'package:flutter/material.dart';

import 'code_block.dart';

/// A forui-style Preview / Code toggle around a single demo.
///
/// Two tabs sit in a header row: **Preview** renders [demo] on a subtle
/// surface; **Code** shows the [code] snippet via [CodeBlock]. The whole
/// thing lives in a bordered container so each demo reads as one unit.
class PreviewTabs extends StatelessWidget {
  const PreviewTabs({
    super.key,
    required this.demo,
    required this.code,
    this.previewBackground,
    this.previewPadding = const EdgeInsets.all(28),
    this.centerPreview = true,
  });

  /// The live, interactive widget being demonstrated.
  final Widget demo;

  /// The Dart snippet shown under the "Code" tab.
  final String code;

  /// Override the preview surface colour (rarely needed).
  final Color? previewBackground;

  /// Padding inside the preview area.
  final EdgeInsetsGeometry previewPadding;

  /// Center the demo horizontally (most demos want this).
  final bool centerPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewTabsStateful(
      theme: theme,
      demo: demo,
      code: code,
      previewBackground: previewBackground,
      previewPadding: previewPadding,
      centerPreview: centerPreview,
    );
  }
}

// Stateful so the tab index survives rebuilds of an ancestor (e.g. theme toggle).
class _PreviewTabsStateful extends StatefulWidget {
  const _PreviewTabsStateful({
    required this.theme,
    required this.demo,
    required this.code,
    required this.previewBackground,
    required this.previewPadding,
    required this.centerPreview,
  });

  final ThemeData theme;
  final Widget demo;
  final String code;
  final Color? previewBackground;
  final EdgeInsetsGeometry previewPadding;
  final bool centerPreview;

  @override
  State<_PreviewTabsStateful> createState() => _PreviewTabsStatefulState();
}

class _PreviewTabsStatefulState extends State<_PreviewTabsStateful> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        color: theme.colorScheme.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tab header.
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                _TabButton(
                  label: 'Preview',
                  icon: Icons.visibility_outlined,
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _TabButton(
                  label: 'Code',
                  icon: Icons.code_rounded,
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
              ],
            ),
          ),
          // Body.
          if (_index == 0)
            Container(
              width: double.infinity,
              color: widget.previewBackground,
              padding: widget.previewPadding,
              child: widget.centerPreview
                  ? Center(child: widget.demo)
                  : widget.demo,
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: CodeBlock(widget.code),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            if (selected)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
