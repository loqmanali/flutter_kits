import 'package:flutter/material.dart';

/// Semantic meaning of a confirmation. Drives the accent color, the default
/// icon, and the default confirm label.
enum ConfirmIntent {
  /// No accent — plain surface colors, no default icon.
  neutral,

  /// The ordinary "are you sure?" confirmation.
  primary,

  /// Irreversible / data-losing actions: delete, cancel an order, log out.
  destructive,

  /// A positive outcome the user is acknowledging.
  success,

  /// A risky-but-reversible action, or a caution the user must read.
  warning,

  /// Purely informational — permissions, "what happens next", tips.
  info,
}

extension ConfirmIntentDefaults on ConfirmIntent {
  /// Icon shown when the caller does not pass a custom one.
  IconData? get defaultIcon => switch (this) {
        ConfirmIntent.neutral => null,
        ConfirmIntent.primary => Icons.help_outline_rounded,
        ConfirmIntent.destructive => Icons.warning_amber_rounded,
        ConfirmIntent.success => Icons.check_circle_outline_rounded,
        ConfirmIntent.warning => Icons.error_outline_rounded,
        ConfirmIntent.info => Icons.info_outline_rounded,
      };
}

/// Visual weight of a single action button.
enum ConfirmActionStyle {
  /// Solid background in the action's accent color.
  filled,

  /// Tinted background, accent-colored label. Good for a secondary action
  /// that still needs presence.
  tonal,

  /// Transparent background with an accent-colored border.
  outlined,

  /// Label only — the lightest option, usually for "Cancel".
  text,
}

/// How the action buttons are arranged.
enum ConfirmActionsLayout {
  /// Side by side while there are at most two actions, stacked beyond that.
  auto,

  /// Always side by side, each action taking an equal share of the width.
  row,

  /// Always stacked, each action full width.
  column,
}

/// What the confirmation is wrapped in.
enum ConfirmSurface {
  /// A centered [Dialog].
  dialog,

  /// A bottom sheet with a drag handle.
  sheet,

  /// No wrapper at all — drop the content straight into your own layout
  /// (a card, a page, a custom sheet). In this surface the widget never pops
  /// a route: actions only run their `onPressed`.
  bare,
}

/// Horizontal alignment of the icon, title and message.
enum ConfirmAlignment {
  /// Icon and text centered — the "hero" confirmation look.
  center,

  /// Icon and text aligned to the reading start edge (Material style).
  start,
}
