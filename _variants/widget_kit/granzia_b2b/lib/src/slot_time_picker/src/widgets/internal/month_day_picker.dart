import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/slot_date_config.dart';
import '../../theme/slot_picker_theme.dart';
import '../../utils/slot_date_math.dart';
import 'day_tile.dart';
import 'month_header.dart';

/// Renders the displayed month in one of two layouts, chosen by [mode]:
///
///  • [SlotPickerMode.dateOnly] — a full 7-column calendar grid so the whole
///    month is visible at once (week starts Saturday for RTL, Sunday
///    otherwise).
///  • otherwise (date **and** time) — the compact horizontal day strip that
///    sits above the time-slot grid.
class MonthDayPicker extends StatelessWidget {
  final DateTime displayedMonth;
  final List<DateTime> days;
  final bool canGoToPreviousMonth;
  final bool canGoToNextMonth;
  final DateTime? selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDaySelected;
  final SlotPickerTheme theme;
  final String locale;
  final SlotDateConfig dateConfig;
  final SlotPickerMode mode;

  /// When true the horizontal strip auto-scrolls to the end after build.
  /// Useful for [DateDirection.past] so the most recent date is immediately
  /// visible. Ignored by the calendar-grid layout.
  final bool scrollToEnd;

  /// Optional: makes the month-year heading tappable (e.g. to open a year
  /// picker). When null, the heading stays non-interactive.
  final VoidCallback? onMonthHeadingTap;

  /// Whether the heading currently shows an expanded state (rotates its
  /// chevron 180°). Only meaningful when [onMonthHeadingTap] is non-null.
  final bool isMonthHeadingExpanded;

  const MonthDayPicker({
    super.key,
    required this.displayedMonth,
    required this.days,
    required this.canGoToPreviousMonth,
    required this.canGoToNextMonth,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDaySelected,
    required this.theme,
    required this.locale,
    required this.dateConfig,
    required this.mode,
    this.scrollToEnd = false,
    this.onMonthHeadingTap,
    this.isMonthHeadingExpanded = false,
  });

  /// The full-month grid is only used when there are no time slots to show.
  bool get _useGrid => mode == SlotPickerMode.dateOnly;

  bool get _isRtl => isRtlLocale(locale);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MonthHeader(
          displayedMonth: displayedMonth,
          canGoToPreviousMonth: canGoToPreviousMonth,
          canGoToNextMonth: canGoToNextMonth,
          onPreviousMonth: onPreviousMonth,
          onNextMonth: onNextMonth,
          theme: theme,
          locale: locale,
          onTitleTap: onMonthHeadingTap,
          isTitleExpanded: isMonthHeadingExpanded,
        ),
        const SizedBox(height: 14),
        if (_useGrid)
          Directionality(
            textDirection: _isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: _MonthCalendarGrid(
              days: days,
              selectedDate: selectedDate,
              dateConfig: dateConfig,
              theme: theme,
              locale: locale,
              onDaySelected: onDaySelected,
            ),
          )
        else
          _DayStrip(
            displayedMonth: displayedMonth,
            days: days,
            selectedDate: selectedDate,
            dateConfig: dateConfig,
            theme: theme,
            locale: locale,
            onDaySelected: onDaySelected,
            scrollToEnd: scrollToEnd,
          ),
      ],
    );
  }
}

/// The full 7-column month grid used in [SlotPickerMode.dateOnly]: a weekday
/// header row above a wrapping grid of [_DayCell]s, with leading blanks so the
/// first day sits under the correct column.
class _MonthCalendarGrid extends StatelessWidget {
  final List<DateTime> days;
  final DateTime? selectedDate;
  final SlotDateConfig dateConfig;
  final SlotPickerTheme theme;
  final String locale;
  final ValueChanged<DateTime> onDaySelected;

  const _MonthCalendarGrid({
    required this.days,
    required this.selectedDate,
    required this.dateConfig,
    required this.theme,
    required this.locale,
    required this.onDaySelected,
  });

  static const double _cellSpacing = 6;

  /// `DateTime.saturday` (6) for RTL, `DateTime.sunday` (7) otherwise.
  int get _firstWeekday =>
      isRtlLocale(locale) ? DateTime.saturday : DateTime.sunday;

  /// Number of empty cells before the first rendered day so it sits under the
  /// correct weekday column.
  int get _leadingBlanks =>
      days.isEmpty ? 0 : (days.first.weekday - _firstWeekday + 7) % 7;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _weekdayHeader(),
        const SizedBox(height: 8),
        _daysGrid(),
      ],
    );
  }

  Widget _weekdayHeader() {
    // A reference week starting on [_firstWeekday], used only for labels.
    // 2024-01-01 is a Monday (weekday 1).
    final base = DateTime(2024, 1, 1).add(Duration(days: _firstWeekday - 1));
    final style = theme.dayNameStyle?.copyWith(color: theme.grey500) ??
        TextStyle(
          color: theme.grey500,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        );

    return Row(
      children: List.generate(7, (i) {
        final label = DateFormat.E(locale).format(base.add(Duration(days: i)));
        return Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _daysGrid() {
    if (days.isEmpty) return const SizedBox.shrink();

    final cells = <Widget>[
      for (var i = 0; i < _leadingBlanks; i++) const SizedBox.shrink(),
      for (final day in days)
        _DayCell(
          date: day,
          isSelected: selectedDate != null &&
              SlotDateMath.dateOnly(day).isAtSameMomentAs(selectedDate!),
          isDisabled: dateConfig.isDayDisabled(day),
          isToday: SlotDateMath.isToday(day),
          theme: theme,
          onTap: () => onDaySelected(day),
        ),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: _cellSpacing,
      crossAxisSpacing: _cellSpacing,
      padding: EdgeInsets.zero,
      children: cells,
    );
  }
}

/// A single compact, square day cell (grid layout) showing only the day number
/// plus selected / today / disabled styling.
class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isDisabled;
  final bool isToday;
  final SlotPickerTheme theme;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isDisabled,
    required this.isToday,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = date.day.toString();
    final radius = BorderRadius.circular(12);

    Color tileColor;
    Color borderColor;
    Color numberColor;
    FontWeight weight;

    if (isDisabled) {
      tileColor = Colors.transparent;
      borderColor = Colors.transparent;
      numberColor = theme.grey400;
      weight = FontWeight.w500;
    } else if (isSelected) {
      tileColor = theme.primaryColor;
      borderColor = theme.primaryColor;
      numberColor = Colors.white;
      weight = FontWeight.w700;
    } else if (isToday) {
      tileColor = theme.primaryLightColor;
      borderColor = theme.primaryColor;
      numberColor = theme.primaryColor;
      weight = FontWeight.w700;
    } else {
      tileColor = Colors.transparent;
      borderColor = theme.grey400.withValues(alpha: 0.25);
      numberColor = theme.grey900;
      weight = FontWeight.w600;
    }

    return Opacity(
      opacity: isDisabled ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: isDisabled ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: radius,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Text(
              label,
              style: theme.dayNumberStyle?.copyWith(
                    color: numberColor,
                    fontWeight: weight,
                    fontSize: 15,
                  ) ??
                  TextStyle(
                    color: numberColor,
                    fontWeight: weight,
                    fontSize: 15,
                    height: 1,
                  ),
            ),
          ),
        ),
      ),
    );
  }

}

/// Horizontal day strip (date-and-time layout): the original scrolling row of
/// tall day tiles shown above the time-slot grid.
class _DayStrip extends StatefulWidget {
  final DateTime displayedMonth;
  final List<DateTime> days;
  final DateTime? selectedDate;
  final SlotDateConfig dateConfig;
  final SlotPickerTheme theme;
  final String locale;
  final ValueChanged<DateTime> onDaySelected;
  final bool scrollToEnd;

  const _DayStrip({
    required this.displayedMonth,
    required this.days,
    required this.selectedDate,
    required this.dateConfig,
    required this.theme,
    required this.locale,
    required this.onDaySelected,
    required this.scrollToEnd,
  });

  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (widget.scrollToEnd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant _DayStrip old) {
    super.didUpdateWidget(old);
    if (widget.scrollToEnd && widget.displayedMonth != old.displayedMonth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.theme.dayStripHeight,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final day = widget.days[index];
          final isSelected = widget.selectedDate != null &&
              SlotDateMath.dateOnly(day).isAtSameMomentAs(widget.selectedDate!);
          final isDisabled = widget.dateConfig.isDayDisabled(day);
          return DayTile(
            date: day,
            isSelected: isSelected,
            isDisabled: isDisabled,
            onTap: () => widget.onDaySelected(day),
            theme: widget.theme,
            locale: widget.locale,
          );
        },
      ),
    );
  }
}
