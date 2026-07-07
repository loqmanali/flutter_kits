import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/slot_picker_theme.dart';

class MonthHeader extends StatelessWidget {
  final DateTime displayedMonth;
  final bool canGoToPreviousMonth;
  final bool canGoToNextMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  /// Optional tap callback for the centered "Month Year" title. When
  /// provided, the title becomes interactive (with a small chevron
  /// affordance) so callers can open a year picker. Leave null to keep the
  /// title non-interactive.
  final VoidCallback? onTitleTap;

  /// Flips the chevron icon next to the title to indicate that an open
  /// year-picker can be collapsed back to the month view.
  final bool isTitleExpanded;

  final SlotPickerTheme theme;
  final String locale;

  const MonthHeader({
    super.key,
    required this.displayedMonth,
    required this.canGoToPreviousMonth,
    required this.canGoToNextMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.theme,
    required this.locale,
    this.onTitleTap,
    this.isTitleExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', locale).format(displayedMonth);

    final titleStyle = theme.monthHeadingStyle ??
        TextStyle(
          color: theme.grey900,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.3,
        );

    final titleContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_month_outlined, color: theme.grey500, size: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            monthLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
        ),
        if (onTitleTap != null) ...[
          const SizedBox(width: 4),
          AnimatedRotation(
            turns: isTitleExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 180),
            child: Icon(
              Icons.expand_more_rounded,
              color: theme.grey500,
              size: 20,
            ),
          ),
        ],
      ],
    );

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Row(
        children: [
          _ArrowButton(
            icon: Icons.chevron_left_rounded,
            isEnabled: canGoToPreviousMonth,
            onTap: onPreviousMonth,
            theme: theme,
          ),
          Expanded(
            child: onTitleTap == null
                ? titleContent
                : Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onTitleTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: titleContent,
                      ),
                    ),
                  ),
          ),
          _ArrowButton(
            icon: Icons.chevron_right_rounded,
            isEnabled: canGoToNextMonth,
            onTap: onNextMonth,
            theme: theme,
          ),
        ],
      ),
    );
  }

}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;
  final SlotPickerTheme theme;

  const _ArrowButton({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1 : 0.4,
      child: Material(
        color: theme.grey50,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isEnabled ? onTap : null,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: theme.grey700, size: 22),
          ),
        ),
      ),
    );
  }
}
