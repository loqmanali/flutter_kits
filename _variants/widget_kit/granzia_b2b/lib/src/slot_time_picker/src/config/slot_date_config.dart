/// Controls which dates are reachable and visible in the day strip.
enum DateDirection {
  /// Only today and future dates are shown (default).
  future,

  /// Only today and past dates are shown.
  past,

  /// All dates are shown; navigation direction is unconstrained (use
  /// [minDate] / [maxDate] to set explicit bounds).
  all,
}

/// Controls which UI sections the picker renders.
enum SlotPickerMode {
  /// Date strip **and** time-slot grid (default behaviour).
  dateAndTime,

  /// Date strip only — no time-slot grid is shown.
  /// Use [onDateSelected] to receive the chosen date.
  dateOnly,

  /// Time-slot grid only — no date strip is shown.
  /// Slots are taken from the [initialSlots] list.
  timeOnly,
}

/// Fine-grained date selection constraints.
///
/// ```dart
/// // Future only, disabled on weekends
/// SlotDateConfig(
///   direction: DateDirection.future,
///   isDateDisabled: (d) => d.weekday == DateTime.saturday
///                       || d.weekday == DateTime.sunday,
/// )
///
/// // Past 3 months only
/// SlotDateConfig(
///   direction: DateDirection.past,
///   minDate: DateTime.now().subtract(const Duration(days: 90)),
/// )
///
/// // A fixed window
/// SlotDateConfig(
///   direction: DateDirection.all,
///   minDate: DateTime(2025, 1, 1),
///   maxDate: DateTime(2025, 12, 31),
/// )
/// ```
class SlotDateConfig {
  /// Which direction(s) of dates are accessible.
  final DateDirection direction;

  /// Earliest selectable date (inclusive). Applied on top of [direction].
  final DateTime? minDate;

  /// Latest selectable date (inclusive). Applied on top of [direction].
  final DateTime? maxDate;

  /// Explicit list of dates to disable regardless of [direction] or range.
  /// The time portion is ignored — only year/month/day are compared.
  final List<DateTime> disabledDates;

  /// A predicate called for every visible day. Return `true` to disable that
  /// date. Useful for blocking weekends, holidays, or any custom pattern.
  final bool Function(DateTime date)? isDateDisabled;

  const SlotDateConfig({
    this.direction = DateDirection.future,
    this.minDate,
    this.maxDate,
    this.disabledDates = const [],
    this.isDateDisabled,
  });

  /// Convenience preset — future dates only, optional max boundary.
  const SlotDateConfig.future({
    DateTime? maxDate,
    List<DateTime> disabledDates = const [],
    bool Function(DateTime)? isDateDisabled,
  }) : this(
          direction: DateDirection.future,
          maxDate: maxDate,
          disabledDates: disabledDates,
          isDateDisabled: isDateDisabled,
        );

  /// Convenience preset — past dates only, optional min boundary.
  const SlotDateConfig.past({
    DateTime? minDate,
    List<DateTime> disabledDates = const [],
    bool Function(DateTime)? isDateDisabled,
  }) : this(
          direction: DateDirection.past,
          minDate: minDate,
          disabledDates: disabledDates,
          isDateDisabled: isDateDisabled,
        );

  /// Convenience preset — all dates within [minDate]…[maxDate].
  const SlotDateConfig.range({
    required DateTime minDate,
    required DateTime maxDate,
    List<DateTime> disabledDates = const [],
    bool Function(DateTime)? isDateDisabled,
  }) : this(
          direction: DateDirection.all,
          minDate: minDate,
          maxDate: maxDate,
          disabledDates: disabledDates,
          isDateDisabled: isDateDisabled,
        );

  /// Returns `true` if [day] should be shown but not tappable.
  bool isDayDisabled(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);

    if (isDateDisabled?.call(d) == true) return true;

    for (final blocked in disabledDates) {
      final b = DateTime(blocked.year, blocked.month, blocked.day);
      if (d.isAtSameMomentAs(b)) return true;
    }
    return false;
  }
}
