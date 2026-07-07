import 'package:flutter/material.dart';

import '../items/custom_menu_item.dart';
import '../items/menu_item.dart';
import 'menu_submenu.dart';

/// Builder for a custom row representation of a [MenuItem].
typedef MenuItemBuilder = Widget Function(
  BuildContext context,
  MenuItem item,
);

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
    this.menuPadding = const EdgeInsets.symmetric(vertical: 0),
    this.itemPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.backgroundColor,
    this.elevation = 8,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.showDividers = false,
    this.dividerColor,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: backgroundColor ?? theme.cardColor,
      elevation: elevation,
      borderRadius: borderRadius,
      child: IntrinsicWidth(
        child: Padding(
          padding: menuPadding,
          child: _buildBody(context),
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
    final color = dividerColor ?? Theme.of(context).dividerColor;
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        result.add(Container(
          height: 0.5,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: color,
        ));
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
      );
    }

    final theme = Theme.of(context);
    final disabledStyle = (item.textStyle ?? theme.textTheme.bodyMedium)
        ?.copyWith(color: theme.disabledColor);

    return InkWell(
      onTap: item.enabled
          ? () {
              onDismiss();
              item.onTap();
            }
          : null,
      child: Padding(
        padding: itemPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 20,
                color: item.enabled
                    ? (item.iconColor ?? theme.iconTheme.color)
                    : theme.disabledColor,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              item.title,
              style: item.enabled
                  ? (item.textStyle ?? theme.textTheme.bodyMedium)
                  : disabledStyle,
            ),
          ],
        ),
      ),
    );
  }
}
