part of '../carousel_indicator.dart';

// The six animated effects [CarouselIndicator] dispatches to.
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
      padding: config.padding +
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
          return _CarouselDot(config: config, isActive: isActive);
        }),
      ),
    );
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
      padding: config.padding +
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
                      right: index < pageCount - 1 ? config.spacing : 0),
                  decoration: BoxDecoration(
                    color: config.inactiveColorOf(context),
                    borderRadius:
                        BorderRadius.circular(config.activeHeight / 2),
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
                  color: config.activeColorOf(context),
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
      padding: config.padding +
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
              color: isActive
                  ? config.activeColorOf(context)
                  : config.inactiveColorOf(context),
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
      padding: config.padding +
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
              color: isActive
                  ? config.activeColorOf(context)
                  : config.inactiveColorOf(context),
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
      padding: config.padding +
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
                color: isActive
                    ? config.activeColorOf(context)
                    : config.inactiveColorOf(context),
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
      padding: config.padding +
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
              color: isActive
                  ? config.activeColorOf(context)
                  : config.inactiveColorOf(context),
              borderRadius: BorderRadius.circular(config.activeHeight / 2),
            ),
          );
        }),
      ),
    );
  }
}
