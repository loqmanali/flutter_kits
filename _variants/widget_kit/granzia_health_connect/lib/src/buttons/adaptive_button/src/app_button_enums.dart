part of '../adaptive_button.dart';

/// ---------------------------------------------------------------------------
/// Enums (Material 3 naming)
/// ---------------------------------------------------------------------------

/// Size variants for buttons
enum AdaptiveButtonSize {
  /// Large size (56dp height)
  large,

  /// Medium size (48dp height) - Default
  medium,

  /// Small size (32dp height)
  small,
}

/// Button width mode
enum AppButtonWidthMode {
  /// Fill available space
  fill,

  /// Shrink to content
  hug,
}

/// Icon alignment in button
enum AppIconAlignment {
  /// Icon at start (left in LTR, right in RTL)
  start,

  /// Icon at end (right in LTR, left in RTL)
  end,
}

/// Floating Action Button types
enum FloatingActionButtonType {
  /// Regular FAB (56x56)
  regular,

  /// Small FAB (40x40)
  small,

  /// Large FAB (96x96)
  large,

  /// Extended FAB with label
  extended,
}

/// ---------------------------------------------------------------------------
/// AppButtonStyleType - Enum for Button Style Selection
/// ---------------------------------------------------------------------------
/// Provides type-safe selection of button styles.
/// This enum is used to select the appropriate style from the theme extension.
/// ---------------------------------------------------------------------------

enum AppButtonStyleType {
  filled,
  filledTonal,
  elevated,
  outlined,
  text,
  icon,
  iconFilled,
  iconFilledTonal,
  iconOutlined,
  fab,
}
