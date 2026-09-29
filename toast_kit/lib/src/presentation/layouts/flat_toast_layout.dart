import 'package:flutter/material.dart';

import '../toast_card.dart';
import '../toast_kit_theme.dart';
import '../toast_layout.dart';

/// Light tone-tinted fill, a tone-colored border and a progress line —
/// closest to toastification's `flatColored`, and the kit's default.
final class FlatToastLayout implements ToastLayout {
  const FlatToastLayout();

  @override
  Widget build(BuildContext context, ToastView view) {
    final scheme = Theme.of(context).colorScheme;
    final theme = ToastKitTheme.of(context);
    final accent = theme.accentFor(view.tone, scheme);
    return ToastCard(
      view: view,
      backgroundColor: theme.backgroundFor(view.tone, scheme),
      foregroundColor: theme.foregroundFor(view.tone, scheme),
      iconColor: accent,
      borderSide: BorderSide(color: accent, width: 1),
      showProgressBar: theme.showProgress ?? true,
    );
  }
}
