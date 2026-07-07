import 'package:flutter/material.dart';

/// Render-time state passed to [NavigationItem.build].
///
/// Bundles the runtime values an item needs to render itself so the
/// `build` signature stays stable as the bar evolves.
@immutable
class NavigationItemState {
  /// Creates a render state snapshot for a navigation item.
  const NavigationItemState({
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.labelVisible,
  });

  /// Whether this item is currently the selected destination.
  final bool isSelected;

  /// Color to use when the item is selected.
  final Color activeColor;

  /// Color to use when the item is not selected.
  final Color inactiveColor;

  /// Whether the label should be rendered. Derived from the bar's
  /// [NavigationLabelBehavior] and the selection state.
  final bool labelVisible;

  /// The color that applies to this item right now ([activeColor] when
  /// selected, otherwise [inactiveColor]).
  Color get color => isSelected ? activeColor : inactiveColor;
}

/// Contract for an item displayed in [NavigationKitBar].
///
/// Implementations are immutable value-objects that know how to render
/// themselves given a [NavigationItemState]. The bar itself owns selection,
/// animation, and colors — items only paint a single slot.
///
/// Most callers should use [IconNavigationItem]; implement this interface
/// directly only when you need a custom icon+label layout (e.g. an icon
/// with a notification badge).
abstract class NavigationItem {
  /// The label text — used for accessibility (tab labels) and for items
  /// that render text below the icon.
  String get label;

  /// The icon rendered when the item is not selected.
  Widget get icon;

  /// The icon rendered when the item is selected.
  Widget get activeIcon;

  /// Build the slot content for this item.
  ///
  /// Called once per build cycle with a fresh [NavigationItemState].
  Widget build(BuildContext context, NavigationItemState state);
}
