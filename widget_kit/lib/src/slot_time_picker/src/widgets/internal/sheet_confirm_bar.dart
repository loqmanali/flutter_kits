import 'package:flutter/material.dart';
import '../../theme/slot_picker_theme.dart';

/// The bottom confirm bar of the bottom-sheet picker.
///
/// Uses [SlotPickerTheme.confirmButtonBuilder] when provided, otherwise falls
/// back to the default full-width [ElevatedButton].
class SheetConfirmBar extends StatelessWidget {
  /// `null` disables the button (nothing selected yet).
  final VoidCallback? onConfirm;
  final String label;
  final double bottomPadding;
  final SlotPickerTheme theme;

  const SheetConfirmBar({
    super.key,
    required this.onConfirm,
    required this.label,
    required this.bottomPadding,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPadding + 16),
      child: t.confirmButtonBuilder?.call(context, onConfirm, label) ??
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primaryColor,
                disabledBackgroundColor: t.primaryColor.withValues(alpha: 0.4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
    );
  }
}
