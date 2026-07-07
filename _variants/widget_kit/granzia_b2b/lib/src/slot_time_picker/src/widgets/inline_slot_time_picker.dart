import 'package:flutter/material.dart';
import '../config/slot_date_config.dart';
import '../l10n/slot_picker_labels.dart';
import '../models/slot_item.dart';
import '../theme/slot_picker_theme.dart';
import '../utils/slot_date_math.dart';
import 'internal/month_day_picker.dart';
import 'internal/section_heading.dart';
import 'internal/slot_times_area.dart';
import 'internal/year_grid.dart';

/// Signature for the async callback that fetches slots for a specific date.
typedef SlotDayLoader = Future<List<SlotItem>?> Function(DateTime date);

/// An always-visible (inline) slot/date-time picker.
///
/// Embed it directly inside a form or any scrollable view.
///
/// ```dart
/// InlineSlotTimePicker(
///   onDaySelected: (date) async => await myApi.fetchSlots(date),
///   onTimeSlotSelected: (slot) => setState(() => _chosen = slot),
/// )
/// ```
class InlineSlotTimePicker extends StatefulWidget {
  // ── Data callbacks ────────────────────────────────────────────────────────

  /// Called whenever the user taps a day. Return the available [SlotItem]s
  /// for that date (or `null` / throw on error).
  ///
  /// Only invoked in [SlotPickerMode.dateAndTime] mode. In
  /// [SlotPickerMode.dateOnly] mode use [onDateSelected] instead.
  final SlotDayLoader? onDaySelected;

  /// Called when the user selects a time-slot chip.
  ///
  /// Not called in [SlotPickerMode.dateOnly] mode.
  final ValueChanged<SlotItem>? onTimeSlotSelected;

  /// Called when the user taps a day in [SlotPickerMode.dateOnly] mode.
  final ValueChanged<DateTime>? onDateSelected;

  /// Called when the user navigates to a different month, clearing selection.
  final VoidCallback? onSelectionCleared;

  // ── Selection state ───────────────────────────────────────────────────────

  /// Pre-selected date (e.g. restored from saved state).
  final DateTime? selectedDate;

  /// ID of the pre-selected slot (e.g. restored from saved state).
  final int? selectedTimeSlotId;

  /// Slots already known for [selectedDate]; avoids a redundant API call.
  final List<SlotItem> initialSlots;

  // ── Mode & constraints ────────────────────────────────────────────────────

  /// Which sections of the picker to render. Defaults to [SlotPickerMode.dateAndTime].
  final SlotPickerMode mode;

  /// Date navigation / availability constraints.
  final SlotDateConfig dateConfig;

  // ── Customization ─────────────────────────────────────────────────────────

  /// Visual configuration. Defaults to [SlotPickerTheme] built-in values.
  final SlotPickerTheme theme;

  /// String labels / translations.
  final SlotPickerLabels labels;

  /// BCP-47 locale code for date formatting and numeral style. E.g. `'en'`, `'ar'`.
  final String locale;

  /// Optional formatter applied to each [SlotItem.time] string inside chips.
  final String Function(String time)? timeFormatter;

  const InlineSlotTimePicker({
    super.key,
    this.onDaySelected,
    this.onTimeSlotSelected,
    this.onDateSelected,
    this.onSelectionCleared,
    this.selectedDate,
    this.selectedTimeSlotId,
    this.initialSlots = const [],
    this.mode = SlotPickerMode.dateAndTime,
    this.dateConfig = const SlotDateConfig(),
    this.theme = const SlotPickerTheme(),
    this.labels = const SlotPickerLabels(),
    this.locale = 'en',
    this.timeFormatter,
  })  : assert(
          mode != SlotPickerMode.dateAndTime || onDaySelected != null,
          'onDaySelected is required when mode is dateAndTime',
        ),
        assert(
          mode != SlotPickerMode.dateOnly || onDateSelected != null,
          'onDateSelected is required when mode is dateOnly',
        ),
        assert(
          mode == SlotPickerMode.dateOnly || onTimeSlotSelected != null,
          'onTimeSlotSelected is required when mode is dateAndTime or timeOnly',
        );

  @override
  State<InlineSlotTimePicker> createState() => _InlineSlotTimePickerState();
}

class _InlineSlotTimePickerState extends State<InlineSlotTimePicker> {
  late DateTime _displayedMonth;
  DateTime? _selectedDate;
  int? _selectedSlotId;
  List<SlotItem> _slots = const [];
  bool _isLoading = false;
  bool _hasLoadedSelectedDay = false;
  bool _hasError = false;

  /// When true the month-day grid is replaced by a year-picker grid.
  bool _pickingYear = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate == null
        ? null
        : SlotDateMath.dateOnly(widget.selectedDate!);
    _displayedMonth =
        SlotDateMath.initialMonth(_selectedDate, widget.dateConfig);
    _selectedSlotId = widget.selectedTimeSlotId;
    _slots = SlotDateMath.filterSlotsForDate(widget.initialSlots, _selectedDate);
    _hasLoadedSelectedDay =
        _selectedDate != null || widget.mode == SlotPickerMode.timeOnly;
  }

  @override
  void didUpdateWidget(covariant InlineSlotTimePicker old) {
    super.didUpdateWidget(old);
    final nextDate = widget.selectedDate == null
        ? null
        : SlotDateMath.dateOnly(widget.selectedDate!);
    if (nextDate != _selectedDate ||
        widget.selectedTimeSlotId != _selectedSlotId ||
        widget.initialSlots != old.initialSlots) {
      setState(() {
        _selectedDate = nextDate;
        if (nextDate != null) _displayedMonth = SlotDateMath.monthOnly(nextDate);
        _selectedSlotId = widget.selectedTimeSlotId;
        _slots =
            SlotDateMath.filterSlotsForDate(widget.initialSlots, _selectedDate);
        _hasLoadedSelectedDay =
            _selectedDate != null || widget.mode == SlotPickerMode.timeOnly;
      });
    }
  }

  // ── Derived state ───────────────────────────────────────────────────────────

  List<DateTime> get _visibleDays =>
      SlotDateMath.buildDays(_displayedMonth, widget.dateConfig);

  bool get _canGoToPreviousMonth =>
      SlotDateMath.canGoToPreviousMonth(_displayedMonth, widget.dateConfig);

  bool get _canGoToNextMonth =>
      SlotDateMath.canGoToNextMonth(_displayedMonth, widget.dateConfig);

  bool get _scrollToEnd => SlotDateMath.scrollToEnd(widget.dateConfig);

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _selectDay(DateTime date) async {
    if (widget.mode == SlotPickerMode.dateOnly) {
      setState(() {
        _selectedDate = SlotDateMath.dateOnly(date);
        _hasLoadedSelectedDay = true;
      });
      widget.onDateSelected?.call(SlotDateMath.dateOnly(date));
      return;
    }

    setState(() {
      _selectedDate = SlotDateMath.dateOnly(date);
      _selectedSlotId = null;
      _slots = const [];
      _isLoading = true;
      _hasLoadedSelectedDay = true;
      _hasError = false;
    });

    try {
      final fetched = await widget.onDaySelected!(date);
      if (!mounted) return;
      setState(() {
        _slots =
            SlotDateMath.filterSlotsForDate(fetched ?? const [], _selectedDate);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _changeMonth(int delta) {
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    setState(() {
      _displayedMonth = next;
      if (_selectedDate == null ||
          !SlotDateMath.isSameMonth(_selectedDate!, next)) {
        _selectedDate = null;
        _selectedSlotId = null;
        _slots = const [];
        _isLoading = false;
        _hasLoadedSelectedDay = false;
        _hasError = false;
      }
    });
    widget.onSelectionCleared?.call();
  }

  (int min, int max) get _yearBounds =>
      SlotDateMath.yearBounds(widget.dateConfig);

  void _toggleYearPicker() =>
      setState(() => _pickingYear = !_pickingYear);

  void _selectYear(int year) {
    setState(() {
      _displayedMonth = DateTime(year, _displayedMonth.month);
      _pickingYear = false;
      if (_selectedDate != null && _selectedDate!.year != year) {
        _selectedDate = null;
        _selectedSlotId = null;
        _slots = const [];
        _isLoading = false;
        _hasLoadedSelectedDay = false;
        _hasError = false;
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final l = widget.labels;
    final showDatePicker = widget.mode != SlotPickerMode.timeOnly;
    final showTimeSlots = widget.mode != SlotPickerMode.dateOnly;
    final timesSource =
        widget.mode == SlotPickerMode.timeOnly ? widget.initialSlots : _slots;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: t.backgroundColor,
        borderRadius: BorderRadius.circular(t.selectorBorderRadius),
        border: Border.all(color: t.grey400.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDatePicker) ...[
            _pickingYear
                ? YearGrid(
                    bounds: _yearBounds,
                    selectedYear: _displayedMonth.year,
                    locale: widget.locale,
                    theme: t,
                    onYearSelected: _selectYear,
                  )
                : MonthDayPicker(
                    displayedMonth: _displayedMonth,
                    days: _visibleDays,
                    canGoToPreviousMonth: _canGoToPreviousMonth,
                    canGoToNextMonth: _canGoToNextMonth,
                    selectedDate: _selectedDate,
                    onPreviousMonth: () => _changeMonth(-1),
                    onNextMonth: () => _changeMonth(1),
                    onDaySelected: _selectDay,
                    theme: t,
                    locale: widget.locale,
                    dateConfig: widget.dateConfig,
                    mode: widget.mode,
                    scrollToEnd: _scrollToEnd,
                    onMonthHeadingTap: _toggleYearPicker,
                    isMonthHeadingExpanded: _pickingYear,
                  ),
          ],
          if (showDatePicker && showTimeSlots) const SizedBox(height: 24),
          if (showTimeSlots) ...[
            SectionHeading(label: l.timeHeading, theme: t),
            const SizedBox(height: 12),
            SlotTimesArea(
              slots: timesSource,
              selectedSlotId: _selectedSlotId,
              onSlotSelected: (slot) {
                setState(() => _selectedSlotId = slot.id);
                widget.onTimeSlotSelected!(slot);
              },
              isLoading: _isLoading,
              hasError: _hasError,
              hasLoadedSelectedDay: _hasLoadedSelectedDay,
              loadingHeight: 132,
              theme: t,
              labels: l,
              timeFormatter: widget.timeFormatter,
            ),
          ],
        ],
      ),
    );
  }
}
