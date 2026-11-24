import 'package:adaptive_kit/src/adaptive.dart';
import 'package:flutter/widgets.dart';

/// Picks the right body for the current form factor, with automatic
/// fallback: desktop → tablet → mobile.
///
/// [mobile] is the only required body, so a screen whose tablet design isn't
/// built yet simply shows the mobile one — never a missing screen. Keep ALL
/// logic (controllers, lifecycle, error handling) in the screen that owns
/// this widget; the bodies should be dumb layout-only widgets.
///
/// This is the widget-based sibling of [ResponsiveLayout] (which takes builder
/// callbacks and branches on MediaQuery width). Use whichever reads better at
/// the call site — both live in this kit.
///
/// ```dart
/// AdaptiveLayout(
///   mobile: HomeMobileBody(onRefresh: _refresh),
///   tablet: HomeTabletBody(onRefresh: _refresh),
/// )
/// ```
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// The phone-portrait body — also the fallback for every other size.
  final Widget mobile;

  /// Tablet (and landscape-phone) body. Falls back to [mobile].
  final Widget? tablet;

  /// Desktop body. Falls back to [tablet], then [mobile].
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    if (Adaptive.i.isDesktop) {
      return desktop ?? tablet ?? mobile;
    }
    if (Adaptive.i.shouldUseTabletLayout) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}
