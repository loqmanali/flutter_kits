import 'package:flutter/material.dart';

import '../buttons/adaptive_button/adaptive_button.dart';

class AppWarningDialog extends StatelessWidget {
  const AppWarningDialog({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
    this.cancelText = 'Cancel',
    this.dangerColor,
    this.iconBackgroundOpacity = 0.08,
  });

  final String title;
  final String message;
  final String buttonText;
  final String cancelText;
  final VoidCallback onPressed;

  /// Color used for the warning icon and the confirm button. Falls back to
  /// `ColorScheme.error` when not set.
  final Color? dangerColor;

  final double iconBackgroundOpacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final effectiveDanger = dangerColor ?? scheme.error;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color:
                      effectiveDanger.withValues(alpha: iconBackgroundOpacity),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: effectiveDanger,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: cancelText,
                  style: AppButtonStyleType.outlined,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: buttonText,
                  backgroundColor: effectiveDanger,
                  onPressed: onPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
