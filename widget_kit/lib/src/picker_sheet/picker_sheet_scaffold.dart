import 'package:flutter/material.dart';

/// {@template picker_sheet_scaffold}
/// Generic bottom-sheet shell shared by every "pick one item from a list"
/// sheet in the app (partners, products, warehouses, salespeople, …).
///
/// It owns ONLY the chrome that every picker has in common: a
/// [DraggableScrollableSheet], a top drag handle, and an optional [header]
/// region above the scrollable [body]. It carries no data and no search logic —
/// the caller supplies the [header] (usually a [PickerSheetSearchField] or a
/// [PickerSheetTitleBar]) and the [body] (usually a [PickerSheetAsyncList]).
///
/// Open it through `UIHelper.showBottomSheet`, which sets `showDragHandle:
/// false`; this scaffold draws its own handle so the look is preserved.
///
/// The scrollable [body] is built with the sheet's [ScrollController] so the
/// list scrolls and the sheet drags as one — pass that controller straight to
/// your `ListView`.
/// {@endtemplate}
class PickerSheetScaffold extends StatelessWidget {
  /// {@macro picker_sheet_scaffold}
  const PickerSheetScaffold({
    required this.body,
    this.header,
    this.initialChildSize = 0.75,
    this.minChildSize = 0.5,
    this.maxChildSize = 0.95,
    super.key,
  });

  /// Optional region between the drag handle and the scrollable body — a search
  /// field, a title bar, a section label, or a column combining them.
  final Widget? header;

  /// Builds the scrollable content. Receives the sheet's scroll controller,
  /// which MUST be handed to the body's scrollable so drag-and-scroll compose.
  final Widget Function(BuildContext context, ScrollController scrollController)
      body;

  /// Fraction of the screen the sheet occupies when first shown.
  final double initialChildSize;

  /// Smallest fraction the sheet can be dragged down to.
  final double minChildSize;

  /// Largest fraction the sheet can be dragged up to.
  final double maxChildSize;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        final header = this.header;
        return Column(
          children: [
            const PickerSheetHandle(),
            if (header != null) header,
            Expanded(child: body(context, scrollController)),
          ],
        );
      },
    );
  }
}

/// {@template picker_sheet_handle}
/// The 40×4 rounded drag handle drawn at the top of a [PickerSheetScaffold].
/// Re-created manually because `UIHelper.showBottomSheet` disables the
/// framework handle.
/// {@endtemplate}
class PickerSheetHandle extends StatelessWidget {
  /// {@macro picker_sheet_handle}
  const PickerSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 12),
        decoration: BoxDecoration(
          color: colors.outlineVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
