import 'package:flutter/material.dart';

import '../config/indicator_config.dart';

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

/// Basic dot indicator.
class _DotIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final IndicatorConfig config;

  const _DotIndicator({
    required this.currentPage,
    required this.pageCount,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          config.padding +
          EdgeInsets.only(
            left: config.margin,
            right: config.margin,
            top: config.margin,
            bottom: config.margin,
          ),
      child: Row(
        mainAxisAlignment: config.alignment,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageCount, (index) {
          final isActive = index == currentPage;
          return _buildDot(isActive);
        }),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    final dotWidth = isActive ? config.activeWidth : config.inactiveWidth;
    final dotHeight = isActive ? config.activeHeight : config.inactiveHeight;
    final dotColor = isActive ? config.activeColor : config.inactiveColor;

    return AnimatedContainer(
      duration: config.animationDuration,
      curve: config.animationCurve,
      width: dotWidth,
      height: dotHeight,
      margin: EdgeInsets.symmetric(horizontal: config.spacing / 2),
      decoration: BoxDecoration(
        color: dotColor,
        borderRadius: _getBorderRadius(),
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    switch (config.shape) {
      case IndicatorShape.circle:
        return BorderRadius.circular(config.activeHeight / 2);
      case IndicatorShape.square:
        return BorderRadius.zero;
      case IndicatorShape.pill:
        return BorderRadius.circular(config.borderRadius);
      case IndicatorShape.custom:
        return BorderRadius.circular(config.borderRadius);
    }
  }
}

/// Worm effect indicator - active dot stretches between positions.
class _WormIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final IndicatorConfig config;

  const _WormIndicator({
    required this.currentPage,
    required this.pageCount,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final dotWidth = config.inactiveWidth;
    final totalWidth =
        (dotWidth * pageCount) + (config.spacing * (pageCount - 1));

    return Padding(
      padding:
          config.padding +
          EdgeInsets.only(
            left: config.margin,
            right: config.margin,
            top: config.margin,
            bottom: config.margin,
          ),
      child: SizedBox(
        height: config.activeHeight,
        width: totalWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Inactive dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(pageCount, (index) {
                return Container(
                  width: dotWidth,
                  height: config.inactiveHeight,
                  margin: EdgeInsets.only(
                    right: index < pageCount - 1 ? config.spacing : 0,
                  ),
                  decoration: BoxDecoration(
                    color: config.inactiveColor,
                    borderRadius: BorderRadius.circular(
                      config.activeHeight / 2,
                    ),
                  ),
                );
              }),
            ),
            // Active worm
            AnimatedPositioned(
              duration: config.animationDuration,
              curve: config.animationCurve,
              left: (dotWidth + config.spacing) * currentPage,
              child: Container(
                width: config.activeWidth,
                height: config.activeHeight,
                decoration: BoxDecoration(
                  color: config.activeColor,
                  borderRadius: BorderRadius.circular(config.activeHeight / 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expanding effect indicator - active dot expands.
class _ExpandingIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final IndicatorConfig config;

  const _ExpandingIndicator({
    required this.currentPage,
    required this.pageCount,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          config.padding +
          EdgeInsets.only(
            left: config.margin,
            right: config.margin,
            top: config.margin,
            bottom: config.margin,
          ),
      child: Row(
        mainAxisAlignment: config.alignment,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageCount, (index) {
          final isActive = index == currentPage;
          return AnimatedContainer(
            duration: config.animationDuration,
            curve: config.animationCurve,
            width: isActive ? config.activeWidth : config.inactiveWidth,
            height: isActive ? config.activeHeight : config.inactiveHeight,
            margin: EdgeInsets.symmetric(horizontal: config.spacing / 2),
            decoration: BoxDecoration(
              color: isActive ? config.activeColor : config.inactiveColor,
              borderRadius: BorderRadius.circular(config.activeHeight / 2),
            ),
          );
        }),
      ),
    );
  }
}

/// Jumping effect indicator.
class _JumpingIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final IndicatorConfig config;

  const _JumpingIndicator({
    required this.currentPage,
    required this.pageCount,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          config.padding +
          EdgeInsets.only(
            left: config.margin,
            right: config.margin,
            top: config.margin,
            bottom: config.margin,
          ),
      child: Row(
        mainAxisAlignment: config.alignment,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageCount, (index) {
          final isActive = index == currentPage;
          return AnimatedContainer(
            duration: config.animationDuration,
            curve: config.animationCurve,
            width: config.inactiveWidth,
            height: isActive ? config.activeHeight : config.inactiveHeight,
            margin: EdgeInsets.symmetric(horizontal: config.spacing / 2),
            decoration: BoxDecoration(
              color: isActive ? config.activeColor : config.inactiveColor,
              borderRadius: BorderRadius.circular(config.inactiveHeight / 2),
            ),
          );
        }),
      ),
    );
  }
}

/// Scrolling effect indicator.
class _ScrollingIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final IndicatorConfig config;

  const _ScrollingIndicator({
    required this.currentPage,
    required this.pageCount,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          config.padding +
          EdgeInsets.only(
            left: config.margin,
            right: config.margin,
            top: config.margin,
            bottom: config.margin,
          ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisAlignment: config.alignment,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(pageCount, (index) {
            final isActive = index == currentPage;
            return AnimatedContainer(
              duration: config.animationDuration,
              curve: config.animationCurve,
              width: isActive ? config.activeWidth : config.inactiveWidth,
              height: isActive ? config.activeHeight : config.inactiveHeight,
              margin: EdgeInsets.symmetric(horizontal: config.spacing / 2),
              decoration: BoxDecoration(
                color: isActive ? config.activeColor : config.inactiveColor,
                borderRadius: BorderRadius.circular(config.activeHeight / 2),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Swap effect indicator.
class _SwapIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final IndicatorConfig config;

  const _SwapIndicator({
    required this.currentPage,
    required this.pageCount,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          config.padding +
          EdgeInsets.only(
            left: config.margin,
            right: config.margin,
            top: config.margin,
            bottom: config.margin,
          ),
      child: Row(
        mainAxisAlignment: config.alignment,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageCount, (index) {
          final isActive = index == currentPage;
          return AnimatedContainer(
            duration: config.animationDuration,
            curve: config.animationCurve,
            width: isActive ? config.inactiveWidth : config.activeWidth,
            height: isActive ? config.inactiveHeight : config.activeHeight,
            margin: EdgeInsets.symmetric(horizontal: config.spacing / 2),
            decoration: BoxDecoration(
              color: isActive ? config.activeColor : config.inactiveColor,
              borderRadius: BorderRadius.circular(config.activeHeight / 2),
            ),
          );
        }),
      ),
    );
  }
}

/// Smooth dot indicator with scale animation effect.
class SmoothDotIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final double dotSize;
  final double activeDotSize;
  final double spacing;
  final Color activeColor;
  final Color inactiveColor;
  final Duration animationDuration;

  const SmoothDotIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
    this.dotSize = 8.0,
    this.activeDotSize = 8.0,
    this.spacing = 8.0,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white54,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: animationDuration,
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: isActive ? activeDotSize * 2.5 : dotSize,
          height: isActive ? activeDotSize : dotSize,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}

/// Scale-based dot indicator.
class ScaleDotIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final double dotSize;
  final double activeScale;
  final double spacing;
  final Color activeColor;
  final Color inactiveColor;
  final Duration animationDuration;

  const ScaleDotIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
    this.dotSize = 8.0,
    this.activeScale = 1.3,
    this.spacing = 8.0,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white54,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return Transform.scale(
          scale: isActive ? activeScale : 1.0,
          child: AnimatedContainer(
            duration: animationDuration,
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: spacing / 2),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

/// Number-based page indicator (e.g., "1 / 5").
class NumberIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final TextStyle? textStyle;
  final String separator;
  final EdgeInsetsGeometry padding;

  const NumberIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
    this.textStyle,
    this.separator = ' / ',
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle =
        textStyle ??
        theme.textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );

    return Padding(
      padding: padding,
      child: Text(
        '${currentPage + 1}$separator$pageCount',
        style: effectiveStyle,
      ),
    );
  }
}
