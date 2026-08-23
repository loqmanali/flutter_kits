import 'package:flutter/material.dart';

import '../items/menu_item.dart';
import '../overlay/menu_overlay_controller.dart';
import '../positioning/menu_position_calculator.dart';
import 'menu_content.dart';

/// A row that opens a nested submenu when entered with the mouse
/// (desktop) or tapped (mobile).
///
/// The submenu is positioned to the right of this row by default; if
/// that overflows the screen, the position is clamped via
/// [MenuPositionCalculator] — a two-pass measure-then-reposition cycle
/// implemented with a post-frame callback.
///
/// Owns its own [MenuOverlayController]; dismissing this widget also
/// dismisses the submenu.
class MenuSubmenu extends StatefulWidget {
  /// Creates a submenu trigger row for [parentItem].
  const MenuSubmenu({
    super.key,
    required this.parentItem,
    required this.itemPadding,
    this.backgroundColor,
    this.elevation = 0,
    this.borderRadius,
    this.itemBuilder,
    this.borderColor,
  });

  /// Row whose `subItems` populate the nested menu.
  final MenuItem parentItem;

  /// Padding inside each row.
  final EdgeInsets itemPadding;

  /// Submenu background; defaults to the parent menu's.
  final Color? backgroundColor;

  /// Submenu elevation.
  final double elevation;

  /// Submenu border radius.
  final BorderRadius? borderRadius;

  /// Optional custom builder for submenu rows.
  final MenuItemBuilder? itemBuilder;

  /// Border color of the submenu; defaults to a subtle border color.
  final Color? borderColor;

  @override
  State<MenuSubmenu> createState() => _MenuSubmenuState();
}

class _MenuSubmenuState extends State<MenuSubmenu> {
  final MenuOverlayController _overlay = MenuOverlayController();
  final GlobalKey _submenuKey = GlobalKey();

  @override
  void dispose() {
    _overlay.dismissAll();
    super.dispose();
  }

  void _openSubmenu() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final origin =
        renderBox.localToGlobal(Offset.zero) + Offset(renderBox.size.width, 0);
    _show(origin);
  }

  void _show(Offset position) {
    final screenSize = MediaQuery.sizeOf(context);
    _overlay.dismissAll();
    _overlay.show(
      context: context,
      contentBuilder: (ctx) => _build(position, screenSize),
    );
  }

  Widget _build(Offset position, Size screenSize) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Builder(
        builder: (ctx) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final renderBox =
                _submenuKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox == null || !mounted) return;
            final clamped = MenuPositionCalculator.calculateAdjustedPosition(
              position,
              renderBox.size,
              screenSize,
            );
            if (clamped != position) _show(clamped);
          });
          return MenuContent(
            key: _submenuKey,
            items: widget.parentItem.subItems,
            onDismiss: _overlay.dismissAll,
            menuPadding: const EdgeInsets.symmetric(vertical: 4),
            itemPadding: widget.itemPadding,
            backgroundColor: widget.backgroundColor,
            elevation: widget.elevation,
            borderRadius: widget.borderRadius ??
                const BorderRadius.all(Radius.circular(6)),
            itemBuilder: widget.itemBuilder,
            borderColor: widget.borderColor,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.parentItem.enabled;

    return MouseRegion(
      onEnter: (_) {
        if (isEnabled && widget.parentItem.hasSubItems) {
          _openSubmenu();
        }
      },
      onExit: (_) => _overlay.dismissAll(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled
              ? () {
                  widget.parentItem.onTap();
                  _openSubmenu();
                }
              : null,
          hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          splashColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: widget.itemPadding,
            child: Row(
              children: [
                if (widget.parentItem.icon != null) ...[
                  Icon(
                    widget.parentItem.icon,
                    size: 16,
                    color: isEnabled
                        ? (widget.parentItem.iconColor ??
                            theme.colorScheme.onSurface)
                        : theme.disabledColor,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    widget.parentItem.title,
                    style: (widget.parentItem.textStyle ??
                            theme.textTheme.bodyMedium)
                        ?.copyWith(
                      color: isEnabled
                          ? theme.colorScheme.onSurface
                          : theme.disabledColor,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
