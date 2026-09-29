import 'package:flutter/material.dart';

import '../toast_card.dart';
import '../toast_kit_theme.dart';
import '../toast_layout.dart';

/// Solid tone-colored fill with a readable-by-contrast foreground.
final class FilledToastLayout implements ToastLayout {
  const FilledToastLayout();

  @override
  Widget build(BuildContext context, ToastView view) {
    final scheme = Theme.of(context).colorScheme;
    final theme = ToastKitTheme.of(context);
    final accent = theme.accentFor(view.tone, scheme);
    final foreground = ToastKitTheme.readableOn(accent);
    return ToastCard(
      view: view,
      backgroundColor: accent,
      foregroundColor: foreground,
      iconColor: foreground,
      showProgressBar: theme.showProgress ?? true,
    );
  }
}
