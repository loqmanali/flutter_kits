import 'package:flutter/material.dart';

import '../buttons/adaptive_button/adaptive_button.dart';
import '../config/widget_kit_config.dart';
import '../theme/widget_kit_theme.dart';

/// A reusable, branded error state widget.
///
/// Use this for feature-level errors (API failures, unexpected states, etc.).
///
/// Example:
/// ```dart
/// if (state.status == AsyncStatus.error) {
///   return ErrorStateWidget(
///     title: 'Something went wrong',
///     message: state.errorMessage,
///     onRetry: () => context.read<MyCubit>().load(),
///   );
/// }
/// ```
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    this.title,
    required this.message,
    required this.onRetry,
    this.retryLabel,
  });

  /// Optional short title, e.g. "Something went wrong".
  final String? title;

  /// Optional detailed error message (safe, user-facing).
  final String message;

  /// Optional retry callback. If null, the button is not shown.
  final VoidCallback onRetry;

  /// Optional custom label for the retry button.
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    // "interface": an app can swap the whole error state widget app-wide.
    final errorBuilder = WidgetKitScope.of(context).builders.errorStateBuilder;
    if (errorBuilder != null) {
      return errorBuilder(
        context,
        ErrorStateData(
          message: message,
          onRetry: onRetry,
          title: title,
          retryLabel: retryLabel,
        ),
      );
    }

    // Accent: WidgetKitTheme.errorStateIconColor, else the built-in red.
    final accent = WidgetKitTheme.of(context).errorStateIconColor ?? Colors.red;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accent.withValues(alpha: 0.16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon circle
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: accent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    title ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                  if (message.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accent.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        onPressed: onRetry,
                        label: retryLabel ?? 'Retry',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
