import 'package:flutter/material.dart';

import '../buttons/adaptive_button/adaptive_button.dart';
import '../config/widget_kit_config.dart';
import '../theme/widget_kit_theme.dart';

/// A premium empty state widget following Shadcn UI aesthetics.
///
/// Use this for displaying empty states when no data is available.
/// The widget integrates seamlessly with the app's theme data to automatically
/// inherit colors, typography, and border styles.
///
/// Example:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.inbox_outlined,
///   title: 'No products available',
///   subtitle: 'Check back later for new arrivals',
///   actionLabel: 'Browse Categories',
///   onAction: () => context.go('/categories'),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.height,
  });

  /// Large semi-transparent icon to visually represent the empty state.
  /// Defaults to Icons.inbox_outlined.
  final IconData? icon;

  /// Bold primary title text.
  final String title;

  /// Muted descriptive subtitle text.
  final String subtitle;

  /// Optional call-to-action button label.
  final String? actionLabel;

  /// Optional callback for the action button.
  final VoidCallback? onAction;

  /// Optional constrained height. Defaults to 200.
  final double? height;

  @override
  Widget build(BuildContext context) {
    // "interface": an app can swap the whole empty state widget app-wide.
    final emptyBuilder = WidgetKitScope.of(context).builders.emptyStateBuilder;
    if (emptyBuilder != null) {
      return emptyBuilder(
        context,
        EmptyStateData(
          title: title,
          subtitle: subtitle,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction,
          height: height,
        ),
      );
    }

    // Icon color: WidgetKitTheme.emptyStateIconColor, else a muted neutral
    // from the ambient scheme so it reads on light and dark surfaces.
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final iconColor = WidgetKitTheme.of(context).emptyStateIconColor ??
        scheme.onSurfaceVariant.withValues(alpha: 0.3);

    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Large semi-transparent icon
                Icon(
                  icon ?? Icons.inbox_outlined,
                  size: 56,
                  color: iconColor,
                ),
                const SizedBox(height: 16),
                // Bold primary title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: texts.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                // Muted descriptive subtitle
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: texts.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    onPressed: onAction,
                    label: actionLabel,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
