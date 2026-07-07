import 'package:flutter/material.dart';
import '../../theme/slot_picker_theme.dart';

/// The circular outlined close button at the top of the bottom-sheet picker.
class SheetCloseButton extends StatelessWidget {
  final VoidCallback onTap;
  final SlotPickerTheme theme;

  const SheetCloseButton({
    super.key,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.grey400.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(Icons.close_rounded, color: theme.grey600, size: 18),
        ),
      ),
    );
  }
}
