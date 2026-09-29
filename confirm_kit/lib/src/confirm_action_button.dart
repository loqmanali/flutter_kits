import 'package:flutter/material.dart';

import 'confirm_action.dart';
import 'confirm_enums.dart';
import 'confirm_kit_theme.dart';

/// Renders a single [ConfirmAction] in one of the four [ConfirmActionStyle]s.
///
/// Public so an app can reuse the exact same button outside a confirmation
/// (e.g. in a custom sheet) without re-deriving the colors.
class ConfirmActionButton<T> extends StatelessWidget {
  const ConfirmActionButton({
    super.key,
    required this.action,
    required this.color,
    required this.height,
    required this.borderRadius,
    this.busy = false,
    this.enabled = true,
    this.onPressed,
  });

  final ConfirmAction<T> action;

  /// Accent color already resolved for this action's intent.
  final Color color;
  final double height;
  final double borderRadius;

  /// Shows a spinner in place of the label.
  final bool busy;

  /// `false` when the action itself is disabled, or another action is busy.
  final bool enabled;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final filled = action.style == ConfirmActionStyle.filled;
    final foreground = filled ? ConfirmKitTheme.onColor(color) : color;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
    final minimumSize = Size.fromHeight(height);
    const padding = EdgeInsets.symmetric(horizontal: 12);
    final callback = enabled && !busy ? onPressed : null;

    final child = busy
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (action.icon != null) ...[
                action.icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    return switch (action.style) {
      ConfirmActionStyle.filled => FilledButton(
          onPressed: callback,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: foreground,
            disabledBackgroundColor: color.withValues(alpha: 0.35),
            disabledForegroundColor: foreground.withValues(alpha: 0.7),
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
          ),
          child: child,
        ),
      ConfirmActionStyle.tonal => FilledButton.tonal(
          onPressed: callback,
          style: FilledButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.12),
            foregroundColor: color,
            disabledBackgroundColor: color.withValues(alpha: 0.06),
            disabledForegroundColor: color.withValues(alpha: 0.5),
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
          ),
          child: child,
        ),
      ConfirmActionStyle.outlined => OutlinedButton(
          onPressed: callback,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            disabledForegroundColor: color.withValues(alpha: 0.5),
            side: BorderSide(color: color.withValues(alpha: 0.6)),
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
          ),
          child: child,
        ),
      ConfirmActionStyle.text => TextButton(
          onPressed: callback,
          style: TextButton.styleFrom(
            foregroundColor: color,
            disabledForegroundColor: color.withValues(alpha: 0.5),
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
          ),
          child: child,
        ),
    };
  }
}
