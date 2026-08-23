part of '../carousel_indicator.dart';

// The single dot every effect draws.
/// One indicator dot. A class, not a builder method, so Flutter can skip the
/// dots that did not change while the active one animates.
class _CarouselDot extends StatelessWidget {
  const _CarouselDot({required this.config, required this.isActive});

  final IndicatorConfig config;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
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
        borderRadius: switch (config.shape) {
          IndicatorShape.circle =>
            BorderRadius.circular(config.activeHeight / 2),
          IndicatorShape.square => BorderRadius.zero,
          IndicatorShape.pill ||
          IndicatorShape.custom =>
            BorderRadius.circular(config.borderRadius),
        },
      ),
    );
  }
}
