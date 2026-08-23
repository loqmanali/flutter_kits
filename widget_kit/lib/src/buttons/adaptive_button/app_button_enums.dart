part of 'adaptive_button.dart';

/// ---------------------------------------------------------------------------
/// Enums (Material 3 naming)
/// ---------------------------------------------------------------------------

/// Size variants for buttons
enum AppButtonSize {
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
enum AppFabVariant {
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
/// AppButtonVariant - Enum for Button Style Selection
/// ---------------------------------------------------------------------------
/// Provides type-safe selection of button styles.
/// This enum is used to select the appropriate style from the theme extension.
/// ---------------------------------------------------------------------------

enum AppButtonVariant {
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

/// Renamed for consistency: everything in this module is `AppButton*`.
@Deprecated('Use AppButtonSize instead. Will be removed in a future release.')
typedef AdaptiveButtonSize = AppButtonSize;

/// Renamed: Material calls these variants, and `...Type` said nothing that
/// `AppButtonVariant` does not.
@Deprecated(
    'Use AppButtonVariant instead. Will be removed in a future release.')
typedef AppButtonStyleType = AppButtonVariant;
