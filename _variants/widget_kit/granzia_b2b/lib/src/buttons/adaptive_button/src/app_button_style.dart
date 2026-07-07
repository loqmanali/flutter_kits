part of '../adaptive_button.dart';

/// ---------------------------------------------------------------------------
/// AppButtonStyle - Centralized Button Styling
/// ---------------------------------------------------------------------------
/// Provides predefined button styles that replace the variant enum approach.
/// Each style encapsulates colors, borders, and visual properties for consistency.
/// ---------------------------------------------------------------------------

class AppButtonStyle {
  const AppButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.overlayColor,
    this.borderColor,
    this.elevation = 0.0,
    this.borderSide = BorderSide.none,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color overlayColor;
  final Color? borderColor;
  final double elevation;
  final BorderSide borderSide;

  /// Filled button (high emphasis) - Burger Republic Primary Red
  static const filled = AppButtonStyle(
    backgroundColor: Color(0xFFDC1213), // Primary red (DC1213)
    foregroundColor: Color(0xFFFFFFFF), // White
    overlayColor: Color(0x14DC1213), // Primary red with 8% opacity
  );

  /// Filled tonal button (medium emphasis) - Secondary Orange
  static const filledTonal = AppButtonStyle(
    backgroundColor: Color(0xFFF49B25), // Secondary orange (F49B25)
    foregroundColor: Color(0xFFFFFFFF), // White
    overlayColor: Color(0x1AF49B25), // Secondary orange with 10% opacity
  );

  /// Elevated button (medium emphasis) - Surface with primary text
  static const elevated = AppButtonStyle(
    backgroundColor: Color(0xFFFFFFFF), // Surface white
    foregroundColor: Color(0xFFDC1213), // Primary red
    overlayColor: Color(0x14DC1213), // Primary red with 8% opacity
    elevation: 1.0,
  );

  /// Outlined button (medium emphasis) - Primary red outline
  static const outlined = AppButtonStyle(
    backgroundColor: Color(0x00000000), // Transparent
    foregroundColor: Color(0xFFDC1213), // Primary red
    overlayColor: Color(0x0FDC1213), // Primary red with 6% opacity
    borderColor: Color(0xFFDC1213), // Primary red
    borderSide: BorderSide(color: Color(0xFFDC1213)),
  );

  /// Text button (low emphasis) - Primary red text
  static const text = AppButtonStyle(
    backgroundColor: Color(0x00000000), // Transparent
    foregroundColor: Color(0xFFDC1213), // Primary red
    overlayColor: Color(0x0FDC1213), // Primary red with 6% opacity
  );

  /// Icon button (standard) - Muted gray
  static const icon = AppButtonStyle(
    backgroundColor: Color(0x00000000), // Transparent
    foregroundColor: Color(0xFF94A3B8), // Muted gray
    overlayColor: Color(0x1F94A3B8), // Muted gray with 12% opacity
  );

  /// Icon button filled (high emphasis) - Primary red
  static const iconFilled = AppButtonStyle(
    backgroundColor: Color(0xFFDC1213), // Primary red
    foregroundColor: Color(0xFFFFFFFF), // White
    overlayColor: Color(0x1FDC1213), // Primary red with 12% opacity
  );

  /// Icon button filled tonal (medium emphasis) - Secondary orange
  static const iconFilledTonal = AppButtonStyle(
    backgroundColor: Color(0xFFF49B25), // Secondary orange
    foregroundColor: Color(0xFFFFFFFF), // White
    overlayColor: Color(0x1FF49B25), // Secondary orange with 12% opacity
  );

  /// Icon button outlined (medium emphasis) - Muted gray outline
  static const iconOutlined = AppButtonStyle(
    backgroundColor: Color(0x00000000), // Transparent
    foregroundColor: Color(0xFF94A3B8), // Muted gray
    overlayColor: Color(0x1F94A3B8), // Muted gray with 12% opacity
    borderColor: Color(0xFFE2E8F0), // Light border
    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
  );

  /// Floating action button - Secondary orange
  static const fab = AppButtonStyle(
    backgroundColor: Color(0xFFF49B25), // Secondary orange
    foregroundColor: Color(0xFFFFFFFF), // White
    overlayColor: Color(0x14F49B25), // Secondary orange with 8% opacity
    elevation: 3.0,
  );
}

/// Extension to easily get button styles from theme
extension AppButtonStyleExtension on ThemeData {
  AppButtonStyle getButtonStyle(ColorScheme scheme) {
    // This can be extended to use theme colors dynamically
    return AppButtonStyle.filled;
  }
}
