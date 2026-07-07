import 'package:flutter/material.dart';

/// A value-object describing one row in a [ContextMenu].
///
/// Use [subItems] to nest a submenu under this row; when [hasSubItems] is
/// true, the renderer shows a chevron and opens a nested menu on
/// hover (desktop) or tap (mobile).
@immutable
class MenuItem {
  /// Creates a menu row.
  const MenuItem({
    required this.title,
    required this.onTap,
    this.icon,
    this.textStyle,
    this.iconColor,
    this.enabled = true,
    this.subItems,
  });

  /// Visible label.
  final String title;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the row is tapped. Not called when [enabled] is false.
  final VoidCallback onTap;

  /// Optional text style override; defaults to `Theme.textTheme.bodyMedium`.
  final TextStyle? textStyle;

  /// Optional icon color override; defaults to `Theme.iconTheme.color`.
  final Color? iconColor;

  /// When false, the row is rendered greyed out and taps are ignored.
  final bool enabled;

  /// Optional nested submenu. When non-empty, the row is rendered as a
  /// submenu trigger.
  final List<MenuItem>? subItems;

  /// `true` iff [subItems] is non-null and non-empty.
  bool get hasSubItems => subItems != null && subItems!.isNotEmpty;
}
