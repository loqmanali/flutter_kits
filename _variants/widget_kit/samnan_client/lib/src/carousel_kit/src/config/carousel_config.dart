import 'package:flutter/widgets.dart';

import 'auto_scroll_config.dart';
import 'indicator_config.dart';
import 'layout_config.dart';
import 'visual_config.dart';

/// Complete configuration for the Carousel widget.
///
/// This class combines all configuration options into a single object
/// for convenient management and theme-based styling.
class CarouselConfig {
  /// Visual styling configuration.
  final VisualConfig visual;

  /// Layout and scrolling configuration.
  final LayoutConfig layout;

  /// Page indicator configuration.
  final IndicatorConfig indicator;

  /// Auto-scroll behavior configuration.
  final AutoScrollConfig autoScroll;

  const CarouselConfig({
    this.visual = const VisualConfig(),
    this.layout = const LayoutConfig(),
    this.indicator = const IndicatorConfig(),
    this.autoScroll = const AutoScrollConfig(),
  });

  /// Creates a copy with the given fields replaced.
  CarouselConfig copyWith({
    VisualConfig? visual,
    LayoutConfig? layout,
    IndicatorConfig? indicator,
    AutoScrollConfig? autoScroll,
  }) {
    return CarouselConfig(
      visual: visual ?? this.visual,
      layout: layout ?? this.layout,
      indicator: indicator ?? this.indicator,
      autoScroll: autoScroll ?? this.autoScroll,
    );
  }

  /// Preset: Standard banner carousel.
  static const banner = CarouselConfig(autoScroll: AutoScrollConfig.normal);

  /// Preset: Hero carousel (large, auto-scrolling).
  static const hero = CarouselConfig(
    visual: VisualConfig.large,
    indicator: IndicatorConfig(
      position: IndicatorPosition.overlay,
      activeColor: Color(0xFFFFFFFF),
      inactiveColor: Color(0x80FFFFFF),
    ),
    autoScroll: AutoScrollConfig.slow,
  );

  /// Preset: Card carousel with peek.
  static const cards = CarouselConfig(
    visual: VisualConfig.card,
    layout: LayoutConfig.cardPeek,
    indicator: IndicatorConfig.pill,
  );

  /// Preset: Product showcase carousel.
  static const productShowcase = CarouselConfig(
    visual: VisualConfig(height: 200.0, borderRadius: 12.0),
    layout: LayoutConfig(viewportFraction: 0.75),
    indicator: IndicatorConfig.smallDots,
  );

  /// Preset: Full-screen carousel.
  static const fullScreen = CarouselConfig(
    visual: VisualConfig.fullWidth,
    layout: LayoutConfig.fullBleed,
    indicator: IndicatorConfig.overlay,
    autoScroll: AutoScrollConfig.slow,
  );

  /// Preset: Thumbnail carousel (small, no auto-scroll).
  static const thumbnail = CarouselConfig(
    visual: VisualConfig.small,
    layout: LayoutConfig.horizontalList,
    indicator: IndicatorConfig.hidden,
  );

  /// Preset: Onboarding carousel.
  static const onboarding = CarouselConfig(
    visual: VisualConfig.large,
    indicator: IndicatorConfig(effect: IndicatorEffect.expanding, margin: 24.0),
  );
}
