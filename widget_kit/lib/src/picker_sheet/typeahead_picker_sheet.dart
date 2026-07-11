import 'dart:async';

import 'package:flutter/material.dart';

import 'picker_sheet.dart';

/// {@template typeahead_picker_sheet}
/// Generic server-typeahead picker sheet: a search box drives an async [search]
/// callback (debounced, with a minimum query length) and the matching results
/// render as a plain list of [TypeaheadOptionTile]s.
///
/// Use it for any "type to search a server, pick one" field: the search box
/// drives a [search] callback and the results render as a plain list.
///
/// `T` is the result type. The caller supplies how to read a row's [titleOf],
/// optional [subtitleOf], and optional [trailingOf] so the sheet stays fully
/// type-agnostic.
///
/// Open it through `UIHelper.showBottomSheet`.
/// {@endtemplate}
class TypeaheadPickerSheet<T> extends StatefulWidget {
  /// {@macro typeahead_picker_sheet}
  const TypeaheadPickerSheet({
    required this.search,
    required this.onPick,
    required this.hintText,
    required this.emptyLabel,
    required this.titleOf,
    this.subtitleOf,
    this.trailingOf,
    this.leadingIcon = Icons.search_rounded,
    this.minQueryLength = 3,
    this.debounce = const Duration(milliseconds: 250),
    super.key,
  });

  /// Server search; returns matches for a (trimmed, ≥ [minQueryLength]) query.
  final Future<List<T>> Function(String query) search;

  /// Reports the chosen item. The caller closes the sheet (e.g. `Navigator.pop`).
  final ValueChanged<T> onPick;

  /// Placeholder shown in the search field.
  final String hintText;

  /// Centered caption shown before a search and when a search returns nothing.
  final String emptyLabel;

  /// The bold primary text of a result row.
  final String Function(T item) titleOf;

  /// Optional muted subtitle of a result row.
  final String? Function(T item)? subtitleOf;

  /// Optional muted trailing text of a result row (e.g. an id).
  final String? Function(T item)? trailingOf;

  /// Leading icon in the search field.
  final IconData leadingIcon;

  /// Shortest query that triggers a search; shorter clears the results.
  final int minQueryLength;

  /// Debounce applied before each [search] call.
  final Duration debounce;

  @override
  State<TypeaheadPickerSheet<T>> createState() =>
      _TypeaheadPickerSheetState<T>();
}

class _TypeaheadPickerSheetState<T> extends State<TypeaheadPickerSheet<T>> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<T> _results = const [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    _debounce?.cancel();
    if (query.length < widget.minQueryLength) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(widget.debounce, () async {
      try {
        final results = await widget.search(query);
        if (!mounted) return;
        setState(() {
          _results = results;
          _searching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _searching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PickerSheetScaffold(
      header: PickerSheetSearchField(
        controller: _searchController,
        hintText: widget.hintText,
        leadingIcon: widget.leadingIcon,
        onChanged: _onQueryChanged,
        trailing: _searching
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      body: (context, scrollController) => PickerSheetList<T>(
        items: _results,
        emptyLabel: widget.emptyLabel,
        scrollController: scrollController,
        itemBuilder: (context, item, _) => TypeaheadOptionTile(
          title: widget.titleOf(item),
          subtitle: widget.subtitleOf?.call(item),
          trailingText: widget.trailingOf?.call(item),
          onTap: () => widget.onPick(item),
        ),
      ),
    );
  }
}

/// {@template typeahead_option_tile}
/// A result row for a [TypeaheadPickerSheet]: a bold [title], an optional muted
/// [subtitle], and an optional muted [trailingText].
/// {@endtemplate}
class TypeaheadOptionTile extends StatelessWidget {
  /// {@macro typeahead_option_tile}
  const TypeaheadOptionTile({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailingText,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final subtitle = this.subtitle;
    final trailingText = this.trailingText;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 11, color: colors.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}
