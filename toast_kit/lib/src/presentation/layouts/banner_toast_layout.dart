import 'package:flutter/material.dart';

import '../toast_card.dart';
import '../toast_kit_theme.dart';
import '../toast_layout.dart';

/// A full-width edge banner: solid tone fill, square corners, no `maxWidth`
/// cap. Meant for `ToastPlacement`s that span the screen edge.
final class BannerToastLayout implements ToastLayout {
  const BannerToastLayout();

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
      elevation: 0,
      fullWidth: true,
      showProgressBar: theme.showProgress ?? true,
    );
  }
}
