import 'package:flutter/material.dart';

import '../toast_card.dart';
import '../toast_kit_theme.dart';
import '../toast_layout.dart';

/// The plainest built-in: surface fill, no border, no progress line — just
/// the icon, the text and (if present) the action/close controls.
final class MinimalToastLayout implements ToastLayout {
  const MinimalToastLayout();

  @override
  Widget build(BuildContext context, ToastView view) {
    final scheme = Theme.of(context).colorScheme;
    final theme = ToastKitTheme.of(context);
    final accent = theme.accentFor(view.tone, scheme);
    return ToastCard(
      view: view,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      iconColor: accent,
      elevation: 0,
      showProgressBar: false,
    );
  }
}
