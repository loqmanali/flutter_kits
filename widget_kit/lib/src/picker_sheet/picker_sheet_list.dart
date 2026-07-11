import 'package:flutter/material.dart';

/// {@template picker_sheet_list}
/// Generic body for a [PickerSheetScaffold] driven by a plain (already-loaded)
/// list — for pickers that manage their own fetch state outside an
/// [AsyncValue] (e.g. a typeahead that stores results in local state).
///
/// Shows [emptyLabel] centered when [items] is empty, otherwise a separated,
/// scrollable list using the caller's [itemBuilder].
/// {@endtemplate}
class PickerSheetList<T> extends StatelessWidget {
  /// {@macro picker_sheet_list}
  const PickerSheetList({
    required this.items,
    required this.itemBuilder,
    required this.emptyLabel,
    required this.scrollController,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 24),
    this.separatorIndent = 0,
    super.key,
  });

  /// The already-resolved items to show.
  final List<T> items;

  /// Builds one row for [item] at [index].
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Shown centered when [items] is empty.
  final String emptyLabel;

  /// The sheet's scroll controller (from [PickerSheetScaffold.body]).
  final ScrollController scrollController;

  /// List padding.
  final EdgeInsetsGeometry padding;

  /// Left indent of the row separators.
  final double separatorIndent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),
      );
    }
    return ListView.separated(
      controller: scrollController,
      padding: padding,
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: separatorIndent,
        color: colors.outlineVariant.withValues(alpha: 0.08),
      ),
      itemBuilder: (context, index) =>
          itemBuilder(context, items[index], index),
    );
  }
}
