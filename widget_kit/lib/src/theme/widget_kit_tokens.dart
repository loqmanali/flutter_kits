/// Default sizing/spacing tokens used by `widget_kit` widgets.
///
/// All tokens are plain `const double` values — no `flutter_screenutil`.
/// Override per-widget via constructor params, or globally via
/// [WidgetKitTheme] (`ThemeExtension`).
class WidgetKitTokens {
  WidgetKitTokens._();

  // Spacing
  static const double spaceXxs = 4;
  static const double spaceXs = 8;
  static const double spaceSm = 12;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  // Radius
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  // Typography sizes (logical pixels, not scaled)
  static const double fontXs = 11;
  static const double fontSm = 12;
  static const double fontMd = 14;
  static const double fontLg = 16;
  static const double fontXl = 18;
  static const double fontHeading = 22;

  // Touch target / control heights (Material guideline ≥ 48)
  static const double minTouchTarget = 48;
  static const double inputHeight = 52;
  static const double buttonHeight = 48;

  // Default border widths
  static const double borderThin = 1;
  static const double borderRegular = 1.5;
  static const double borderThick = 2;
}

/// Common breakpoints used by `widget_kit` widgets when adapting layout.
///
/// These follow the `flutter-build-responsive-layout` guidance: decisions
/// are based on **available window space**, never on hardware type.
class WidgetKitBreakpoints {
  WidgetKitBreakpoints._();

  /// Below this, layouts collapse to a single-column / compact form.
  static const double compact = 600;

  /// Medium-width layouts (e.g. foldables unfolded, small tablets).
  static const double medium = 840;

  /// Wide layouts (desktop, large tablets).
  static const double expanded = 1200;
}
