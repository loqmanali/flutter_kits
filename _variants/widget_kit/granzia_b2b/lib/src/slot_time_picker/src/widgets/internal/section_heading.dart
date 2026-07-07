import 'package:flutter/material.dart';
import '../../theme/slot_picker_theme.dart';

/// A small accent-bar + label heading used above the date and time sections.
class SectionHeading extends StatelessWidget {
  final String label;
  final SlotPickerTheme theme;

  const SectionHeading({
    super.key,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.sectionHeadingStyle ??
              TextStyle(
                color: theme.grey900,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
        ),
      ],
    );
  }
}
