import 'package:flutter/material.dart';

import '../buttons/adaptive_button/adaptive_button.dart';

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
    // final spacing = context.spacing;
    // final colors = context.colors;
    // final textStyles = context.textStyles;

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
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                // Bold primary title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                // Muted descriptive subtitle
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.6),
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
