import 'package:flutter/material.dart';

import 'items/custom_menu_item.dart';
import 'items/menu_item.dart';
import 'overlay/menu_overlay_controller.dart';
import 'positioning/menu_position_calculator.dart';
import 'widgets/menu_content.dart';

/// How a [ContextMenu] is opened.
enum MenuTrigger {
  /// A regular tap (suited to desktop or icon-button triggers).
  tap,

  /// A long press (suited to mobile contexts).
  longPress,
}

/// Wraps [child] and opens a floating menu at the gesture point.
///
/// Pass exactly one of:
/// - [items] — built-in rows (with optional [itemBuilder] for custom row
///   rendering), or
/// - [customItems] — rows that paint themselves via [CustomMenuItem].
///
/// The menu is positioned at the gesture's global coordinates and then
/// re-positioned to stay inside the screen using
/// [MenuPositionCalculator] (constant-time per axis).
class ContextMenu extends StatefulWidget {
  /// Creates a context menu wrapping [child].
  const ContextMenu({
    super.key,
    required this.child,
    this.items,
    this.customItems,
    this.itemBuilder,
    this.trigger = MenuTrigger.tap,
    this.onMenuShown,
    this.onMenuDismissed,
    this.menuPadding = const EdgeInsets.symmetric(vertical: 4),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.backgroundColor,
    this.elevation = 0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.showDividers = false,
    this.borderColor,
  }) : assert(
         (items != null) ^ (customItems != null),
         'Provide exactly one of items or customItems',
       );

  /// The gesture target — anything that receives the tap/long-press.
  final Widget child;

  /// Standard rows. Mutually exclusive with [customItems].
  final List<MenuItem>? items;

  /// Custom-rendered rows. Mutually exclusive with [items].
  final List<CustomMenuItem>? customItems;

  /// Optional custom row builder applied to [items].
  final MenuItemBuilder? itemBuilder;

  /// What gesture opens the menu.
  final MenuTrigger trigger;

  /// Called right after the menu is inserted into the overlay.
  final VoidCallback? onMenuShown;

  /// Called whenever the menu is dismissed (tap-outside, item tap, dispose).
  final VoidCallback? onMenuDismissed;

  /// Padding around the menu body.
  final EdgeInsets menuPadding;

  /// Padding inside each default row.
  final EdgeInsets itemPadding;

  /// Background color of the menu.
  final Color? backgroundColor;

  /// Material elevation of the menu.
  final double elevation;

  /// Border radius of the menu.
  final BorderRadius borderRadius;

  /// When true, paint a divider between adjacent rows.
  final bool showDividers;

  /// Border color of the menu; defaults to a subtle border color.
  final Color? borderColor;

  @override
  State<ContextMenu> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  final MenuOverlayController _overlay = MenuOverlayController();
  final GlobalKey _contentKey = GlobalKey();

  @override
  void dispose() {
    if (_overlay.isShowing) {
      _overlay.dismissAll();
      widget.onMenuDismissed?.call();
    }
    super.dispose();
  }

  void _showAt(Offset position) {
    final screenSize = MediaQuery.sizeOf(context);
    _overlay.dismissAll();
    _overlay.show(
      context: context,
      contentBuilder: (_) => _buildOverlay(position, screenSize),
      onShown: widget.onMenuShown,
    );
  }

  void _dismiss() {
    if (!_overlay.isShowing) return;
    _overlay.dismissAll();
    widget.onMenuDismissed?.call();
  }

  Widget _buildOverlay(Offset position, Size screenSize) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _dismiss,
      child: Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Builder(
              builder: (ctx) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _clampAfterLayout(position, screenSize);
                });
                return MenuContent(
                  key: _contentKey,
                  items: widget.items,
                  customItems: widget.customItems,
                  itemBuilder: widget.itemBuilder,
                  onDismiss: _dismiss,
                  menuPadding: widget.menuPadding,
                  itemPadding: widget.itemPadding,
                  backgroundColor: widget.backgroundColor,
                  elevation: widget.elevation,
                  borderRadius: widget.borderRadius,
                  showDividers: widget.showDividers,
                  borderColor: widget.borderColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _clampAfterLayout(Offset position, Size screenSize) {
    if (!mounted) return;
    final renderBox =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final clamped = MenuPositionCalculator.calculateAdjustedPosition(
      position,
      renderBox.size,
      screenSize,
    );
    if (clamped != position) _showAt(clamped);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.trigger) {
      case MenuTrigger.tap:
        return GestureDetector(
          onTapDown: (d) => _showAt(d.globalPosition),
          child: widget.child,
        );
      case MenuTrigger.longPress:
        return GestureDetector(
          onLongPressStart: (d) => _showAt(d.globalPosition),
          child: widget.child,
        );
    }
  }
}
