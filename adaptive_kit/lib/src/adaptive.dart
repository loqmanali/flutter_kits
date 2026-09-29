import 'package:flutter/widgets.dart';

/// Screen-size and orientation facts for the whole app.
///
/// [AdaptiveBuilder] (mounted once at the app root) feeds it from MediaQuery;
/// after that any code — widgets, helpers, plain functions — can read
/// `Adaptive.i.isTablet` etc. synchronously without a [BuildContext].
///
/// Breakpoints are configurable per app via [configure]; the defaults follow
/// the Material guidance (phone < 600dp ≤ tablet < 900dp ≤ desktop, measured
/// on the shortest side).
class Adaptive {
  Adaptive._();

  static final Adaptive i = Adaptive._();

  double _phoneBreakpoint = 600;
  double _tabletBreakpoint = 900;

  /// Override the default breakpoints (in dp). Call once at app startup,
  /// before the first frame, if the defaults don't fit your design.
  void configure({double? phoneBreakpoint, double? tabletBreakpoint}) {
    if (phoneBreakpoint != null) _phoneBreakpoint = phoneBreakpoint;
    if (tabletBreakpoint != null) _tabletBreakpoint = tabletBreakpoint;
    assert(
      _phoneBreakpoint < _tabletBreakpoint,
      'phoneBreakpoint must be smaller than tabletBreakpoint',
    );
  }

  double get phoneBreakpoint => _phoneBreakpoint;
  double get tabletBreakpoint => _tabletBreakpoint;

  double _screenWidth = 0;
  double _screenHeight = 0;
  Orientation _orientation = Orientation.portrait;

  /// Update the current metrics. Normally called only by [AdaptiveBuilder].
  void update({
    required double width,
    required double height,
    required Orientation orientation,
  }) {
    _screenWidth = width;
    _screenHeight = height;
    _orientation = orientation;
  }

  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  Orientation get orientation => _orientation;

  /// Shortest side of the window in dp — the stable measure of device class
  /// (it doesn't change when the device rotates).
  double get shortestSide =>
      _screenWidth < _screenHeight ? _screenWidth : _screenHeight;

  bool get isLandscape => _orientation == Orientation.landscape;
  bool get isPortrait => _orientation == Orientation.portrait;

  bool get isPhone => shortestSide < _phoneBreakpoint;
  bool get isTablet =>
      shortestSide >= _phoneBreakpoint && shortestSide < _tabletBreakpoint;
  bool get isDesktop => shortestSide >= _tabletBreakpoint;

  /// True when the tablet layout should be used: a big screen, or a phone
  /// rotated to landscape (where the phone layout usually doesn't fit).
  /// This is what [AdaptiveLayout] branches on.
  bool get shouldUseTabletLayout => isLandscape || shortestSide > _phoneBreakpoint;

  /// Alias kept for call-site readability: `isLandscapeOrTablet` reads better
  /// in feature code than `shouldUseTabletLayout`.
  bool get isLandscapeOrTablet => isLandscape || isTablet;

  /// A phone held in landscape — useful for compact-height tweaks.
  bool get isLandscapeInMobile => isLandscape && isPhone;

  /// Pick a value per form factor with mobile as the guaranteed fallback:
  ///
  /// ```dart
  /// final columns = Adaptive.i.value(mobile: 2, tablet: 4, desktop: 6);
  /// ```
  T value<T>({
    required T mobile,
    T? mobileLandscape,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    if (isPhone && isLandscape && mobileLandscape != null) {
      return mobileLandscape;
    }
    return mobile;
  }
}
