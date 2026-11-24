part of '../carousel_indicator.dart';

// Indicators usable on their own, outside [CarouselIndicator].
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
    // Indicators sit on top of photos, where white reads on any image —
    // this is a contrast-over-media default, not the app's palette.
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
    // Indicators sit on top of photos, where white reads on any image —
    // this is a contrast-over-media default, not the app's palette.
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
    final effectiveStyle = textStyle ??
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
