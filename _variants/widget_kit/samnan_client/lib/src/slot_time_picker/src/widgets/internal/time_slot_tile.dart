import 'package:flutter/material.dart';
import '../../theme/slot_picker_theme.dart';

class TimeSlotTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final SlotPickerTheme theme;

  const TimeSlotTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(theme.timeSlotBorderRadius);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryLightColor : theme.backgroundColor,
            borderRadius: radius,
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : theme.grey400.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? const []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style:
                  theme.timeSlotLabelStyle?.copyWith(
                    color: isSelected ? theme.primaryColor : theme.grey700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ) ??
                  TextStyle(
                    color: isSelected ? theme.primaryColor : theme.grey700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
