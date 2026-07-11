import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart'
    show AppButton, AppButtonStyleType, AppButtonWidthMode;

/// {@template picker_sheet_title_bar}
/// A [PickerSheetScaffold] header showing a bold title and, optionally, a
/// trailing "Clear" action. Used by single-select pickers that have no search
/// box (warehouse, salesperson).
/// {@endtemplate}
class PickerSheetTitleBar extends StatelessWidget {
  /// {@macro picker_sheet_title_bar}
  const PickerSheetTitleBar({
    required this.title,
    this.clearLabel,
    this.onClear,
    super.key,
  });

  /// Bold heading shown on the leading side.
  final String title;

  /// Label for the trailing clear action. When null (or [onClear] is null) the
  /// action is hidden.
  final String? clearLabel;

  /// Invoked when the clear action is tapped.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final clearLabel = this.clearLabel;
    final onClear = this.onClear;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const Spacer(),
          if (clearLabel != null && onClear != null)
            AppButton(
              label: clearLabel,
              style: AppButtonStyleType.text,
              widthMode: AppButtonWidthMode.hug,
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}

/// {@template picker_sheet_section_label}
/// The small, spaced, uppercase caption shown above a picker list (e.g.
/// "PRODUCTS"). A [PickerSheetScaffold] header on its own, or combined with a
/// search field in a [Column].
/// {@endtemplate}
class PickerSheetSectionLabel extends StatelessWidget {
  /// {@macro picker_sheet_section_label}
  const PickerSheetSectionLabel({required this.label, super.key});

  /// Caption text. Already-uppercased text is shown verbatim.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
