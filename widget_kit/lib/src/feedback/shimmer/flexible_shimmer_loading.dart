import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../theme/widget_kit_theme.dart';
import 'shimmer_layouts.dart';

/// Enhanced Shimmer Loading Widget with full customization
class FlexibleShimmerLoading extends HookWidget {
  final Widget child;
  final bool enabled;
  final Duration duration;

  /// Null → derived from the ambient [ColorScheme] (see [gradientFor]), so
  /// the sweep stays visible on a light or a dark surface without the host
  /// app configuring anything.
  final List<Color>? gradientColors;
  final List<double>? gradientStops;
  final double gradientSpeed;
  final Alignment beginAlignment;
  final Alignment endAlignment;
  final TileMode tileMode;

  const FlexibleShimmerLoading({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 2000),
    this.gradientColors,
    this.gradientStops,
    this.gradientSpeed = 2.0,
    this.beginAlignment = const Alignment(-1.0, 0.0),
    this.endAlignment = const Alignment(1.0, 0.0),
    this.tileMode = TileMode.repeated,
  });

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: duration,
    );

    final animation = useMemoized(
      () => Tween<double>(
        begin: -gradientSpeed,
        end: gradientSpeed,
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.linear,
        ),
      ),
      [animationController, gradientSpeed],
    );

    useEffect(
      () {
        if (enabled) {
          animationController.repeat();
        } else {
          animationController.stop();
        }
        return null;
      },
      [enabled, animationController],
    );

    if (!enabled) {
      return child;
    }

    final colors = gradientColors ?? gradientFor(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: colors,
              stops: gradientStops ??
                  List.generate(
                    colors.length,
                    (index) => index / (colors.length - 1),
                  ),
              begin: Alignment(
                beginAlignment.x + animation.value - 1,
                beginAlignment.y,
              ),
              end: Alignment(
                endAlignment.x + animation.value + 1,
                endAlignment.y,
              ),
              tileMode: tileMode,
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }

  /// The default sweep: transparent → highlight → transparent, built from
  /// [WidgetKitTheme.shimmerHighlightColor] when the app registers one, and
  /// otherwise from the ambient scheme — `surfaceContainerHighest` reads as a
  /// highlight against both light and dark surfaces.
  static List<Color> gradientFor(BuildContext context) {
    final highlight = WidgetKitTheme.of(context).shimmerHighlightColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    return <Color>[
      Colors.transparent,
      highlight.withValues(alpha: 0.10),
      highlight.withValues(alpha: 0.20),
      highlight.withValues(alpha: 0.40),
      highlight,
      highlight.withValues(alpha: 0.40),
      highlight.withValues(alpha: 0.20),
      highlight.withValues(alpha: 0.10),
      Colors.transparent,
    ];
  }
}

/// Your Home Tab Shimmer using the new system
class HomeTabShimmerLoading extends HookWidget {
  final int tabCount;
  final double tabHeight;
  final double minTabWidth;
  final double maxTabWidth;
  final EdgeInsets tabPadding;

  const HomeTabShimmerLoading({
    super.key,
    this.tabCount = 4,
    this.tabHeight = 30,
    this.minTabWidth = 80,
    this.maxTabWidth = 120,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLayouts.tabs(
      count: tabCount,
      tabHeight: tabHeight,
      minWidth: minTabWidth,
      maxWidth: maxTabWidth,
      padding: tabPadding,
    );
  }
}
