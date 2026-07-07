import 'package:flutter/material.dart';

import '../items/custom_menu_item.dart';
import '../items/menu_item.dart';
import 'menu_submenu.dart';

/// Builder for a custom row representation of a [MenuItem].
typedef MenuItemBuilder = Widget Function(BuildContext context, MenuItem item);

/// Renders the body of a menu — a vertical list of rows wrapped in a
/// [Material] with optional dividers.
///
/// Three rendering modes (precedence order):
/// 1. [itemBuilder] is provided → each [MenuItem] is rendered by it.
/// 2. [customItems] is provided → each [CustomMenuItem] renders itself.
/// 3. Otherwise the default row layout is used for [items].
///
/// Exactly one of [items] / [customItems] must be supplied; [itemBuilder]
/// is only meaningful with [items].
class MenuContent extends StatelessWidget {
  /// Creates the menu body.
  const MenuContent({
    super.key,
    this.items,
    this.customItems,
    this.itemBuilder,
    required this.onDismiss,
    this.menuPadding = const EdgeInsets.symmetric(vertical: 4),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.backgroundColor,
    this.elevation = 0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.showDividers = false,
    this.dividerColor,
    this.borderColor,
  }) : assert(
         items != null || customItems != null,
         'Provide either items or customItems',
       );

  /// Standard menu items. Mutually exclusive with [customItems].
  final List<MenuItem>? items;

  /// Custom-rendered menu items. Mutually exclusive with [items].
  final List<CustomMenuItem>? customItems;

  /// Optional builder applied to each row when [items] is used.
  final MenuItemBuilder? itemBuilder;

  /// Called when the menu should close — for example after a row is tapped.
  final VoidCallback onDismiss;

  /// Padding applied around the menu body.
  final EdgeInsets menuPadding;

  /// Padding applied inside each default row.
  final EdgeInsets itemPadding;

  /// Background color of the menu. Defaults to `Theme.cardColor`.
  final Color? backgroundColor;

  /// Material elevation of the menu.
  final double elevation;

  /// Border radius of the menu.
  final BorderRadius borderRadius;

  /// When true, paint a thin divider between adjacent rows.
  final bool showDividers;

  /// Color of the divider; defaults to `Theme.dividerColor`.
  final Color? dividerColor;

  /// Border color of the menu; defaults to a subtle border color.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderColor =
        borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.15);
    return Material(
      color: backgroundColor ?? theme.colorScheme.surface,
      elevation: elevation,
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: effectiveBorderColor, width: 1),
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicWidth(
          child: Padding(padding: menuPadding, child: _buildBody(context)),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final children = _buildChildren(context);
    final withDividers = _interleaveDividers(context, children);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: withDividers,
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    if (customItems != null) {
      return customItems!.map((i) => i.build(context)).toList();
    }
    if (itemBuilder != null) {
      return items!.map((i) => itemBuilder!(context, i)).toList();
    }
    return items!.map((i) => _buildDefaultRow(context, i)).toList();
  }

  List<Widget> _interleaveDividers(
    BuildContext context,
    List<Widget> children,
  ) {
    if (!showDividers || children.length < 2) return children;
    final theme = Theme.of(context);
    final color = dividerColor ?? theme.dividerColor.withValues(alpha: 0.5);
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        result.add(
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: color,
          ),
        );
      }
      result.add(children[i]);
    }
    return result;
  }

  Widget _buildDefaultRow(BuildContext context, MenuItem item) {
    if (item.hasSubItems) {
      return MenuSubmenu(
        parentItem: item,
        itemPadding: itemPadding,
        backgroundColor: backgroundColor,
        elevation: elevation,
        borderRadius: borderRadius,
        itemBuilder: itemBuilder,
        borderColor: borderColor,
      );
    }

    return _MenuItemRow(
      item: item,
      itemPadding: itemPadding,
      onTap: item.enabled
          ? () {
              onDismiss();
              item.onTap();
            }
          : null,
    );
  }
}

/// {@template menu_item_row}
/// A styled menu item row following ShadcnUI design principles.
///
/// Features:
/// - Subtle hover background
/// - Smooth transitions
/// - Proper spacing and icon alignment
/// - Disabled state handling
/// {@endtemplate}
class _MenuItemRow extends StatelessWidget {
  const _MenuItemRow({
    required this.item,
    required this.itemPadding,
    required this.onTap,
  });

  final MenuItem item;
  final EdgeInsets itemPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        splashColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: itemPadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 16,
                  color: isEnabled
                      ? (item.iconColor ?? theme.colorScheme.onSurface)
                      : theme.disabledColor,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                item.title,
                style: (item.textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
                  color: isEnabled
                      ? theme.colorScheme.onSurface
                      : theme.disabledColor,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
