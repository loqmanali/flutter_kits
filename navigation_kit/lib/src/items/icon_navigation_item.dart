import 'package:flutter/material.dart';

import 'navigation_item.dart';

/// The default [NavigationItem] implementation: an icon (with a separate
/// active icon) and an optional label rendered below it.
///
/// Both the icon swap and the label color animate smoothly when the
/// selection changes.
class IconNavigationItem implements NavigationItem {
  /// Creates a standard icon+label navigation item.
  const IconNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.iconSwitchDuration = const Duration(milliseconds: 250),
    this.labelColorDuration = const Duration(milliseconds: 200),
    this.labelStyle,
  });

  @override
  final Widget icon;

  @override
  final Widget activeIcon;

  @override
  final String label;

  /// Duration of the icon crossfade when selection toggles.
  final Duration iconSwitchDuration;

  /// Duration of the label color animation when selection toggles.
  final Duration labelColorDuration;

  /// Optional base text style for the label. The color is overridden at
  /// runtime to match the item state.
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context, NavigationItemState state) {
    final color = state.color;
    final baseStyle = labelStyle ?? const TextStyle(fontSize: 12);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconTheme.merge(
          data: IconThemeData(color: color),
          child: AnimatedSwitcher(
            duration: iconSwitchDuration,
            child: KeyedSubtree(
              key: ValueKey<bool>(state.isSelected),
              child: state.isSelected ? activeIcon : icon,
            ),
          ),
        ),
        if (state.labelVisible) ...[
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: labelColorDuration,
            style: baseStyle.copyWith(color: color),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
