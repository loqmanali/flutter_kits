import 'package:flutter/material.dart';

/// Wraps a navigation destination in a [Semantics] node with the
/// "Tab N of M" label used by screen readers, and marks the selected state.
///
/// The label is sourced from [MaterialLocalizations] so it follows the
/// app's locale automatically.
class DestinationSemantics extends StatelessWidget {
  /// Wraps [child] with destination semantics.
  ///
  /// [index] is zero-based; the label rendered for screen readers uses
  /// 1-based numbering ("Tab 1 of 4").
  const DestinationSemantics({
    super.key,
    required this.index,
    required this.total,
    required this.selected,
    required this.child,
  });

  /// Zero-based index of this destination.
  final int index;

  /// Total number of destinations in the bar.
  final int total;

  /// Whether this destination is currently selected.
  final bool selected;

  /// The widget to wrap.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Semantics(
      selected: selected,
      button: true,
      label: localizations.tabLabel(tabIndex: index + 1, tabCount: total),
      child: child,
    );
  }
}
