import 'package:flutter/material.dart';

import '../theme/selection_kit_theme.dart';

/// Wraps a selection group with its label, helper, and error text, plus a
/// [Semantics] / [Focus] envelope.
class SelectionGroupShell extends StatelessWidget {
  const SelectionGroupShell({
    super.key,
    this.label,
    this.labelStyle,
    this.isRequired = false,
    this.helperText,
    this.helperStyle,
    this.errorText,
    this.errorStyle,
    this.semanticsLabel,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    required this.child,
  });

  final String? label;
  final TextStyle? labelStyle;
  final bool isRequired;
  final String? helperText;
  final TextStyle? helperStyle;
  final String? errorText;
  final TextStyle? errorStyle;
  final String? semanticsLabel;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kitTheme = SelectionKitTheme.of(context);
    final scheme = theme.colorScheme;

    final hasFooter = errorText != null || helperText != null;
    final isError = errorText != null;

    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: onFocusChange,
      child: Semantics(
        label: semanticsLabel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              RichText(
                text: TextSpan(
                  text: label,
                  style: labelStyle ??
                      kitTheme.labelStyle ??
                      theme.textTheme.labelLarge,
                  children: [
                    if (isRequired)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: scheme.error),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            child,
            if (hasFooter) ...[
              const SizedBox(height: 4),
              Text(
                errorText ?? helperText!,
                style: (isError
                        ? (errorStyle ?? kitTheme.errorStyle)
                        : (helperStyle ?? kitTheme.helperStyle)) ??
                    theme.textTheme.bodySmall?.copyWith(
                      color: isError
                          ? scheme.error
                          : scheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
