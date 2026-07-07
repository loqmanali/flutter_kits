import 'package:flutter/material.dart';

import 'indicators/drop_indicator.dart';
import 'indicators/indicator_params.dart';
import 'indicators/underline_indicator.dart';
import 'items/navigation_item.dart';
import 'semantics/destination_semantics.dart';
import 'types.dart';

/// A fully customizable bottom navigation bar.
///
/// Renders a row of typed [NavigationItem]s, an optional animated indicator
/// (underline, drop, or fully custom), and an optional floating "center"
/// item that floats above the bar (typical FAB-style action).
///
/// Design notes:
/// - Items are typed via [NavigationItem]; the bar itself is the single
///   source of truth for selection, animation, and colors.
/// - The bar maintains a single shared `AnimationController` for every
///   indicator and replays it on each selection change — O(1) per frame.
/// - Indicator precedence: [indicatorBuilder] > [showDropIndicator] >
///   [showDefaultIndicator]. The first one truthy wins.
class NavigationKitBar extends StatefulWidget {
  /// Creates a bottom navigation bar.
  const NavigationKitBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.indicatorColor,
    this.animationDuration = const Duration(milliseconds: 500),
    this.labelBehavior = NavigationLabelBehavior.alwaysShow,
    this.elevation = 6,
    this.showDefaultIndicator = false,
    this.showDropIndicator = false,
    this.indicatorBuilder,
    this.height,
    this.itemHorizontalPadding = 0,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
    ),
    this.centerItemIndex,
    this.centerItemSize = 56,
    this.centerItemElevation = 8,
    this.centerItemBackground,
    this.centerItemIconColor,
    this.centerItemBottomOffset = 18,
    this.centerItemOnTapOverride,
  })  : assert(
          items.length >= 2,
          'NavigationKitBar needs at least two destinations',
        ),
        assert(
          selectedIndex >= 0 && selectedIndex < items.length,
          'selectedIndex is out of range for items',
        ),
        assert(
          centerItemIndex == null ||
              (centerItemIndex >= 0 && centerItemIndex < items.length),
          'centerItemIndex is out of range for items',
        );

  /// The destinations rendered in the bar, in order.
  final List<NavigationItem> items;

  /// Currently selected destination, as an index into [items].
  final int selectedIndex;

  /// Called when the user taps a destination.
  final DestinationSelected onDestinationSelected;

  /// Bar background. Falls back to [ColorScheme.surface].
  final Color? backgroundColor;

  /// Color for the selected item. Falls back to [ColorScheme.primary].
  final Color? activeColor;

  /// Color for unselected items. Falls back to a faded
  /// [ColorScheme.onSurface].
  final Color? inactiveColor;

  /// Color for the indicator. Falls back to [ColorScheme.secondary].
  final Color? indicatorColor;

  /// Duration of the indicator transition between two slots.
  final Duration animationDuration;

  /// When labels are rendered for items.
  final NavigationLabelBehavior labelBehavior;

  /// Material elevation of the bar.
  final double elevation;

  /// Whether to render the default underline indicator. Ignored when
  /// [showDropIndicator] or [indicatorBuilder] is provided.
  final bool showDefaultIndicator;

  /// Whether to render the water-drop indicator. Ignored when
  /// [indicatorBuilder] is provided.
  final bool showDropIndicator;

  /// Custom indicator. When non-null this takes precedence over both
  /// [showDropIndicator] and [showDefaultIndicator].
  final IndicatorBuilder? indicatorBuilder;

  /// Fixed bar height. Defaults to `kBottomNavigationBarHeight + 24`.
  final double? height;

  /// Horizontal padding applied to each item slot.
  final double itemHorizontalPadding;

  /// Border radius applied to the top corners of the bar.
  final BorderRadius borderRadius;

  /// Index of the item to render as a floating "center" FAB.
  ///
  /// When set, the corresponding flat slot is hidden and a circular
  /// floating button is rendered above the bar at that horizontal position.
  final int? centerItemIndex;

  /// Diameter of the floating center item.
  final double centerItemSize;

  /// Elevation of the floating center item.
  final double centerItemElevation;

  /// Background color of the floating center item. Falls back to
  /// [activeColor].
  final Color? centerItemBackground;

  /// Icon color used inside the floating center item.
  final Color? centerItemIconColor;

  /// Vertical offset of the floating center item from the bar's bottom.
  final double centerItemBottomOffset;

  /// Optional tap override for the floating center item. When null,
  /// tapping the center item calls [onDestinationSelected] with
  /// [centerItemIndex].
  final VoidCallback? centerItemOnTapOverride;

  @override
  State<NavigationKitBar> createState() => _NavigationKitBarState();
}

class _NavigationKitBarState extends State<NavigationKitBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _previousIndex;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..value = 1.0;
  }

  @override
  void didUpdateWidget(covariant NavigationKitBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _labelVisibleFor(bool isSelected) {
    switch (widget.labelBehavior) {
      case NavigationLabelBehavior.alwaysShow:
        return true;
      case NavigationLabelBehavior.alwaysHide:
        return false;
      case NavigationLabelBehavior.onlyShowSelected:
        return isSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor = widget.inactiveColor ??
        theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final indicatorColor =
        widget.indicatorColor ?? theme.colorScheme.secondary;
    final background = widget.backgroundColor ?? theme.colorScheme.surface;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final barHeight = widget.height ?? (kBottomNavigationBarHeight + 24);
    final itemCount = widget.items.length;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Bottom navigation',
      child: Material(
        color: Colors.transparent,
        elevation: widget.elevation,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: barHeight,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / itemCount;
                  final params = IndicatorParams(
                    selectedIndex: widget.selectedIndex,
                    previousIndex: _previousIndex,
                    itemCount: itemCount,
                    itemWidth: itemWidth,
                    color: indicatorColor,
                    animation: _controller,
                    isRTL: isRTL,
                  );

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildIndicator(context, params),
                      _buildItemsRow(
                        context: context,
                        barHeight: barHeight,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                      ),
                      if (widget.centerItemIndex != null)
                        _buildCenterItem(
                          context: context,
                          itemWidth: itemWidth,
                          activeColor: activeColor,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, IndicatorParams params) {
    if (widget.indicatorBuilder != null) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => widget.indicatorBuilder!(context, params),
      );
    }
    if (widget.showDropIndicator) {
      return DropIndicator(params: params);
    }
    if (widget.showDefaultIndicator) {
      return UnderlineIndicator(params: params);
    }
    return const SizedBox.shrink();
  }

  Widget _buildItemsRow({
    required BuildContext context,
    required double barHeight,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List<Widget>.generate(widget.items.length, (index) {
        final item = widget.items[index];
        final isSelected = index == widget.selectedIndex;
        final isCenter = widget.centerItemIndex == index;

        final state = NavigationItemState(
          isSelected: isSelected,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          labelVisible: _labelVisibleFor(isSelected),
        );

        Widget child = Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.itemHorizontalPadding,
          ),
          child: item.build(context, state),
        );

        return Expanded(
          child: InkResponse(
            onTap: () => widget.onDestinationSelected(index),
            radius: barHeight / 2,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Opacity(
              opacity: isCenter ? 0.0 : 1.0,
              child: DestinationSemantics(
                index: index,
                total: widget.items.length,
                selected: isSelected,
                child: SizedBox(height: barHeight, child: child),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCenterItem({
    required BuildContext context,
    required double itemWidth,
    required Color activeColor,
  }) {
    final idx = widget.centerItemIndex!;
    final item = widget.items[idx];
    final selected = widget.selectedIndex == idx;
    final iconWidget = selected ? item.activeIcon : item.icon;

    final slotCenter = (idx + 0.5) * itemWidth;
    final left = slotCenter - widget.centerItemSize / 2;

    return Positioned(
      left: left,
      bottom: widget.centerItemBottomOffset,
      width: widget.centerItemSize,
      height: widget.centerItemSize,
      child: Transform.translate(
        offset: Offset(0, -(widget.centerItemSize * 0.4)),
        child: FloatingActionButton(
          heroTag: 'navigation_kit_center_${identityHashCode(widget)}',
          elevation: widget.centerItemElevation,
          backgroundColor: widget.centerItemBackground ?? activeColor,
          foregroundColor: widget.centerItemIconColor ?? Colors.white,
          shape: const CircleBorder(),
          onPressed: widget.centerItemOnTapOverride ??
              () => widget.onDestinationSelected(idx),
          child: IconTheme.merge(
            data: const IconThemeData(size: 26),
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}
