import 'package:flutter/material.dart';

import '../config/indicator_config.dart';

part 'carousel_indicator/indicator_effects.dart';
part 'carousel_indicator/standalone_indicators.dart';
part 'carousel_indicator/carousel_dot.dart';

/// A page indicator widget for the carousel.
///
/// Supports various indicator effects including dots, pills, and expanding indicators.
/// Can be positioned overlay or below the carousel content.
class CarouselIndicator extends StatelessWidget {
  /// Current page index.
  final int currentPage;

  /// Total number of pages.
  final int pageCount;

  /// Indicator configuration.
  final IndicatorConfig config;

  const CarouselIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
    this.config = const IndicatorConfig(),
  });

  @override
  Widget build(BuildContext context) {
    if (!config.show || pageCount <= 1) {
      return const SizedBox.shrink();
    }

    if (config.customBuilder != null) {
      return Padding(
        padding: config.padding,
        child: Row(
          mainAxisAlignment: config.alignment,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(pageCount, (index) {
            return config.customBuilder!(index, index == currentPage);
          }),
        ),
      );
    }

    switch (config.effect) {
      case IndicatorEffect.worm:
        return _WormIndicator(
          currentPage: currentPage,
          pageCount: pageCount,
          config: config,
        );
      case IndicatorEffect.expanding:
        return _ExpandingIndicator(
          currentPage: currentPage,
          pageCount: pageCount,
          config: config,
        );
      case IndicatorEffect.jumping:
        return _JumpingIndicator(
          currentPage: currentPage,
          pageCount: pageCount,
          config: config,
        );
      case IndicatorEffect.scrolling:
        return _ScrollingIndicator(
          currentPage: currentPage,
          pageCount: pageCount,
          config: config,
        );
      case IndicatorEffect.swap:
        return _SwapIndicator(
          currentPage: currentPage,
          pageCount: pageCount,
          config: config,
        );
      default:
        return _DotIndicator(
          currentPage: currentPage,
          pageCount: pageCount,
          config: config,
        );
    }
  }
}
