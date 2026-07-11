import 'package:flutter/material.dart';

/// {@template picker_sheet_option_tile}
/// A standard single-select row: a leading radio glyph that reflects
/// [isSelected], a bold [title], and an optional trailing [trailingText].
/// Shared by the warehouse and salesperson pickers, which have identical rows.
/// {@endtemplate}
class PickerSheetOptionTile extends StatelessWidget {
  /// {@macro picker_sheet_option_tile}
  const PickerSheetOptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.trailingText,
    this.trailingTextStyle,
    super.key,
  });

  /// The option label.
  final String title;

  /// Whether this option is the current selection (drives the radio glyph).
  final bool isSelected;

  /// Tapped to choose this option.
  final VoidCallback onTap;

  /// Optional muted text on the trailing side (e.g. a quantity or an id).
  final String? trailingText;

  /// Overrides the default trailing text style (e.g. a monospace id). Merged
  /// over the default muted style.
  final TextStyle? trailingTextStyle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final trailingText = this.trailingText;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 18,
              color: isSelected ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)
                    .merge(trailingTextStyle),
              ),
          ],
        ),
      ),
    );
  }
}
