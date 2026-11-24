import 'package:flutter/material.dart';

/// What a [Callout] is telling the reader.
enum CalloutTone {
  /// Useful context; nothing breaks if it's ignored.
  note,

  /// Behaviour that surprises people — the kind of thing that costs an hour.
  warning,
}

/// A bordered aside for a fact the widget's appearance doesn't reveal.
///
/// Used for the things a reader cannot guess from a preview: a default that
/// isn't what it looks like, a theme knob that silently does nothing, a
/// constructor that asserts. Colour alone never carries the meaning — each tone
/// also has its own icon and title.
class Callout extends StatelessWidget {
  const Callout({
    super.key,
    required this.title,
    required this.child,
    this.tone = CalloutTone.note,
  });

  /// Short heading, sentence case (e.g. 'Buttons fill their parent by default').
  final String title;

  /// Body — usually a [Text], occasionally a small column.
  final Widget child;

  final CalloutTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Amber for warnings, the theme's primary for notes. Both are tuned per
    // brightness so the text keeps a 4.5:1 ratio against the tinted surface.
    final accent = switch (tone) {
      CalloutTone.warning =>
        isDark ? const Color(0xFFE0A82E) : const Color(0xFF9A6700),
      CalloutTone.note => theme.colorScheme.primary,
    };

    final icon = switch (tone) {
      CalloutTone.warning => Icons.warning_amber_rounded,
      CalloutTone.note => Icons.info_outline_rounded,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.10 : 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 17, color: accent),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 5),
                DefaultTextStyle(
                  style: theme.textTheme.bodySmall!.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.onSurface,
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
