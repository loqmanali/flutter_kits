import '../config/slot_date_config.dart';
import '../models/slot_item.dart';

/// Pure, context-free date helpers shared by the inline and bottom-sheet
/// pickers. Every method here used to live (identically) inside both picker
/// State classes; consolidating them keeps the two widgets in lock-step.
///
/// All inputs/outputs use date-only [DateTime]s (time portion zeroed) unless
/// noted otherwise.
abstract final class SlotDateMath {
  /// Strips the time portion, keeping year/month/day.
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Strips day + time, keeping year/month.
  static DateTime monthOnly(DateTime d) => DateTime(d.year, d.month);

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static bool isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// The month a freshly-opened picker should display, given the current
  /// [selectedDate] (if any) and the [config]'s direction/bounds.
  static DateTime initialMonth(DateTime? selectedDate, SlotDateConfig config) {
    if (selectedDate != null) return monthOnly(selectedDate);
    final now = DateTime.now();
    // For past direction with a maxDate in the past, start there.
    if (config.direction == DateDirection.past && config.maxDate != null) {
      final max = dateOnly(config.maxDate!);
      if (max.isBefore(dateOnly(now))) return monthOnly(max);
    }
    return monthOnly(now);
  }

  /// The list of selectable days within [month], clamped to today and the
  /// [config]'s direction/min/max bounds.
  static List<DateTime> buildDays(DateTime month, SlotDateConfig config) {
    final today = dateOnly(DateTime.now());
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final lastOfMonth = DateTime(month.year, month.month + 1, 0);

    DateTime rangeStart;
    DateTime rangeEnd;

    switch (config.direction) {
      case DateDirection.future:
        final effectiveMin = config.minDate != null
            ? dateOnly(config.minDate!).isAfter(today)
                ? dateOnly(config.minDate!)
                : today
            : today;
        rangeStart =
            effectiveMin.isAfter(firstOfMonth) ? effectiveMin : firstOfMonth;
        rangeEnd = config.maxDate != null &&
                dateOnly(config.maxDate!).isBefore(lastOfMonth)
            ? dateOnly(config.maxDate!)
            : lastOfMonth;

      case DateDirection.past:
        final effectiveMax = config.maxDate != null
            ? dateOnly(config.maxDate!).isBefore(today)
                ? dateOnly(config.maxDate!)
                : today
            : today;
        rangeStart = config.minDate != null &&
                dateOnly(config.minDate!).isAfter(firstOfMonth)
            ? dateOnly(config.minDate!)
            : firstOfMonth;
        rangeEnd =
            effectiveMax.isBefore(lastOfMonth) ? effectiveMax : lastOfMonth;

      case DateDirection.all:
        rangeStart = config.minDate != null &&
                dateOnly(config.minDate!).isAfter(firstOfMonth)
            ? dateOnly(config.minDate!)
            : firstOfMonth;
        rangeEnd = config.maxDate != null &&
                dateOnly(config.maxDate!).isBefore(lastOfMonth)
            ? dateOnly(config.maxDate!)
            : lastOfMonth;
    }

    if (rangeStart.isAfter(rangeEnd)) return const [];

    final days = <DateTime>[];
    var cur = rangeStart;
    while (!cur.isAfter(rangeEnd)) {
      days.add(cur);
      cur = cur.add(const Duration(days: 1));
    }
    return days;
  }

  /// Whether the picker may navigate back from [displayedMonth].
  static bool canGoToPreviousMonth(
    DateTime displayedMonth,
    SlotDateConfig config,
  ) {
    switch (config.direction) {
      case DateDirection.future:
        return displayedMonth.isAfter(monthOnly(DateTime.now()));
      case DateDirection.past:
      case DateDirection.all:
        if (config.minDate == null) {
          // Default look-back: 10 years.
          final limit = monthOnly(
            DateTime(DateTime.now().year - 10, DateTime.now().month),
          );
          return displayedMonth.isAfter(limit);
        }
        return displayedMonth.isAfter(monthOnly(config.minDate!));
    }
  }

  /// Whether the picker may navigate forward from [displayedMonth].
  static bool canGoToNextMonth(DateTime displayedMonth, SlotDateConfig config) {
    switch (config.direction) {
      case DateDirection.past:
        return displayedMonth.isBefore(monthOnly(DateTime.now()));
      case DateDirection.future:
      case DateDirection.all:
        if (config.maxDate == null) return true;
        return displayedMonth.isBefore(monthOnly(config.maxDate!));
    }
  }

  /// Past-direction pickers scroll the day strip to its end on open.
  static bool scrollToEnd(SlotDateConfig config) =>
      config.direction == DateDirection.past;

  /// Filters [slots] to those on [selectedDate], sorted by time.
  static List<SlotItem> filterSlotsForDate(
    List<SlotItem> slots,
    DateTime? selectedDate,
  ) {
    if (selectedDate == null) return const [];
    return slots
        .where((s) => dateOnly(s.date).isAtSameMomentAs(selectedDate))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  /// The inclusive (min, max) years selectable by the year picker, derived
  /// from [SlotDateConfig.minDate]/[maxDate] when present, with sane 10-year
  /// fallbacks matching [canGoToPreviousMonth].
  static (int min, int max) yearBounds(SlotDateConfig config) {
    final now = DateTime.now();
    final int minYear;
    final int maxYear;

    switch (config.direction) {
      case DateDirection.future:
        minYear = (config.minDate ?? now).year;
        maxYear = config.maxDate?.year ?? now.year + 10;
      case DateDirection.past:
        minYear = config.minDate?.year ?? now.year - 10;
        maxYear = (config.maxDate ?? now).year;
      case DateDirection.all:
        minYear = config.minDate?.year ?? now.year - 10;
        maxYear = config.maxDate?.year ?? now.year + 10;
    }
    return (minYear, maxYear);
  }
}

/// Whether [locale] (BCP-47, e.g. `'ar'`, `'en_US'`) is right-to-left.
bool isRtlLocale(String locale) {
  final lang = locale.split('_').first.toLowerCase();
  const rtlLanguages = {'ar', 'fa', 'he', 'ur', 'ps', 'sd', 'yi'};
  return rtlLanguages.contains(lang);
}

/// Converts Western digits in [input] to Eastern-Arabic numerals.
String toArabicNumerals(String input) {
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var result = input;
  for (var i = 0; i < western.length; i++) {
    result = result.replaceAll(western[i], arabic[i]);
  }
  return result;
}
