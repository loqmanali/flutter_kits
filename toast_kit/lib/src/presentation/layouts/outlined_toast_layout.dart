import 'package:flutter/material.dart';

import '../toast_card.dart';
import '../toast_kit_theme.dart';
import '../toast_layout.dart';

/// Plain surface fill with a bare tone-colored border; no tint.
final class OutlinedToastLayout implements ToastLayout {
  const OutlinedToastLayout();

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
      borderSide: BorderSide(color: accent, width: 1.5),
      elevation: 1,
      showProgressBar: theme.showProgress ?? true,
    );
  }
}
