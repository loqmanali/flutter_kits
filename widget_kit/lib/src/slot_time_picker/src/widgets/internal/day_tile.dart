import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/slot_picker_theme.dart';
import '../../utils/slot_date_math.dart';

class DayTile extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;
  final SlotPickerTheme theme;
  final String locale;

  const DayTile({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.locale,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = isRtlLocale(locale);
    final dayName = DateFormat('EEEE', locale).format(date);
    final displayDayName =
        isRtl ? dayName : dayName.substring(0, 3).toUpperCase();
    final dayNumber = date.day.toString().padLeft(2, '0');
    final displayDayNumber = isRtl ? toArabicNumerals(dayNumber) : dayNumber;
    final isToday = SlotDateMath.isToday(date);

    final radius = BorderRadius.circular(theme.dayTileBorderRadius);

    Color tileColor;
    Color borderColor;
    Color nameColor;
    Color numberColor;
    double borderWidth;

    if (isDisabled) {
      tileColor = theme.grey50;
      borderColor = theme.grey50;
      nameColor = theme.grey400;
      numberColor = theme.grey400;
      borderWidth = 1;
    } else if (isSelected) {
      tileColor = theme.primaryColor;
      borderColor = theme.primaryColor;
      nameColor = Colors.white;
      numberColor = Colors.white;
      borderWidth = 1.5;
    } else {
      tileColor = theme.backgroundColor;
      borderColor = theme.grey400.withValues(alpha: 0.25);
      nameColor = theme.grey600;
      numberColor = theme.grey900;
      borderWidth = 1;
    }

    return Opacity(
      opacity: isDisabled ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: isDisabled ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: theme.dayTileWidth,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: radius,
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: isSelected || isDisabled
                  ? const []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayDayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.dayNameStyle?.copyWith(color: nameColor) ??
                      TextStyle(
                        color: nameColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayDayNumber,
                  style: theme.dayNumberStyle?.copyWith(color: numberColor) ??
                      TextStyle(
                        color: numberColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        height: 1,
                      ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isToday && !isSelected
                        ? theme.primaryColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
