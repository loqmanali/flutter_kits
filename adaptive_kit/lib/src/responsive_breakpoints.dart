import 'package:flutter/material.dart';

/// {@template responsive_breakpoints}
/// Centralized breakpoints that classify devices into mobile, tablet, and desktop
/// ranges based on logical pixels.
///
/// The defaults follow common Flutter guidance:
/// - Mobile: width < 600
/// - Tablet: 600 <= width < 1024
/// - Desktop: width >= 1024
/// {@endtemplate}
class ResponsiveBreakpoints {
  const ResponsiveBreakpoints._();

  /// {@macro responsive_breakpoints}
  static const double mobileMaxWidth = 600;

  /// {@macro responsive_breakpoints}
  static const double tabletMaxWidth = 1024;

  /// {@macro responsive_breakpoints}
  static const double desktopMinWidth = tabletMaxWidth;
}

/// Represents the current display class used by responsive widgets.
enum DisplaySize { mobile, tablet, desktop }

/// {@template context_breakpoints_extension}
/// Adds readable helpers to any [BuildContext] so screens can respond to width,
/// height, and orientation without repeatedly calling [MediaQuery].
///
/// Example:
/// ```dart
/// if (context.isDesktop) ...
/// final padding = context.responsivePadding;
/// final columns = context.responsiveColumns();
/// ```
/// {@endtemplate}
extension ContextBreakpoints on BuildContext {
  MediaQueryData get _mediaQuery => MediaQuery.of(this);

  /// Current logical size of the viewport.
  Size get screenSize => _mediaQuery.size;

  /// Logical width of the viewport.
  double get screenWidth => screenSize.width;

  /// Logical height of the viewport.
  double get screenHeight => screenSize.height;

  /// Current orientation (portrait or landscape).
  Orientation get orientation => _mediaQuery.orientation;

  /// Whether the layout should follow the mobile spec.
  bool get isMobile => screenWidth < ResponsiveBreakpoints.mobileMaxWidth;

  /// Whether the layout should follow the tablet spec.
  bool get isTablet =>
      screenWidth >= ResponsiveBreakpoints.mobileMaxWidth &&
      screenWidth < ResponsiveBreakpoints.tabletMaxWidth;

  /// Whether the layout should follow the desktop spec.
  bool get isDesktop => screenWidth >= ResponsiveBreakpoints.tabletMaxWidth;

  /// Quick access to the resolved [DisplaySize].
  DisplaySize get displaySize => isDesktop
      ? DisplaySize.desktop
      : isTablet
          ? DisplaySize.tablet
          : DisplaySize.mobile;

  /// Returns the most appropriate value for the active breakpoint.
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Consistent horizontal padding that scales with screen width.
  EdgeInsets get responsivePadding => EdgeInsets.symmetric(
        horizontal: responsiveValue(
          mobile: 16,
          tablet: 24,
          desktop: 32,
        ),
        vertical: responsiveValue(
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
      );

  /// Ideal content width to keep wide desktop layouts readable.
  double get maxContentWidth => responsiveValue(
        mobile: double.infinity,
        tablet: 900,
        desktop: 1200,
      );

  /// Returns how many columns should be shown for grid-based layouts.
  int responsiveColumns({
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return mobile;
  }

  /// Returns spacing that matches the active breakpoint.
  double responsiveSpacing({
    double mobile = 12,
    double tablet = 16,
    double desktop = 20,
  }) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return mobile;
  }
}
