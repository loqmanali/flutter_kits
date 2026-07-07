import 'package:flutter/material.dart';
import '../config/slot_date_config.dart';
import '../l10n/slot_picker_labels.dart';
import '../models/slot_item.dart';
import '../theme/slot_picker_theme.dart';
import 'internal/message_state_widget.dart';
import 'internal/month_day_picker.dart';
import 'internal/time_slots_grid.dart';

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
  }) : assert(
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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate == null
        ? null
        : _dateOnly(widget.selectedDate!);
    _displayedMonth = _initialMonth();
    _selectedSlotId = widget.selectedTimeSlotId;
    _slots = _filterSlotsForDate(widget.initialSlots);
    _hasLoadedSelectedDay =
        _selectedDate != null || widget.mode == SlotPickerMode.timeOnly;
  }

  @override
  void didUpdateWidget(covariant InlineSlotTimePicker old) {
    super.didUpdateWidget(old);
    final nextDate = widget.selectedDate == null
        ? null
        : _dateOnly(widget.selectedDate!);
    if (nextDate != _selectedDate ||
        widget.selectedTimeSlotId != _selectedSlotId ||
        widget.initialSlots != old.initialSlots) {
      setState(() {
        _selectedDate = nextDate;
        if (nextDate != null) _displayedMonth = _monthOnly(nextDate);
        _selectedSlotId = widget.selectedTimeSlotId;
        _slots = _filterSlotsForDate(widget.initialSlots);
        _hasLoadedSelectedDay =
            _selectedDate != null || widget.mode == SlotPickerMode.timeOnly;
      });
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _monthOnly(DateTime d) => DateTime(d.year, d.month);

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  DateTime _initialMonth() {
    if (_selectedDate != null) return _monthOnly(_selectedDate!);
    final now = DateTime.now();
    final cfg = widget.dateConfig;
    // For past direction with a maxDate in the past, start there.
    if (cfg.direction == DateDirection.past && cfg.maxDate != null) {
      final max = _dateOnly(cfg.maxDate!);
      if (max.isBefore(_dateOnly(now))) return _monthOnly(max);
    }
    return _monthOnly(now);
  }

  // ── Day-strip logic ───────────────────────────────────────────────────────

  List<DateTime> get _visibleDays => _buildDays(_displayedMonth);

  List<DateTime> _buildDays(DateTime month) {
    final today = _dateOnly(DateTime.now());
    final cfg = widget.dateConfig;

    final firstOfMonth = DateTime(month.year, month.month, 1);
    final lastOfMonth = DateTime(month.year, month.month + 1, 0);

    DateTime rangeStart;
    DateTime rangeEnd;

    switch (cfg.direction) {
      case DateDirection.future:
        final effectiveMin = cfg.minDate != null
            ? _dateOnly(cfg.minDate!).isAfter(today)
                  ? _dateOnly(cfg.minDate!)
                  : today
            : today;
        rangeStart = effectiveMin.isAfter(firstOfMonth)
            ? effectiveMin
            : firstOfMonth;
        rangeEnd =
            cfg.maxDate != null && _dateOnly(cfg.maxDate!).isBefore(lastOfMonth)
            ? _dateOnly(cfg.maxDate!)
            : lastOfMonth;

      case DateDirection.past:
        final effectiveMax = cfg.maxDate != null
            ? _dateOnly(cfg.maxDate!).isBefore(today)
                  ? _dateOnly(cfg.maxDate!)
                  : today
            : today;
        rangeStart =
            cfg.minDate != null && _dateOnly(cfg.minDate!).isAfter(firstOfMonth)
            ? _dateOnly(cfg.minDate!)
            : firstOfMonth;
        rangeEnd = effectiveMax.isBefore(lastOfMonth)
            ? effectiveMax
            : lastOfMonth;

      case DateDirection.all:
        rangeStart =
            cfg.minDate != null && _dateOnly(cfg.minDate!).isAfter(firstOfMonth)
            ? _dateOnly(cfg.minDate!)
            : firstOfMonth;
        rangeEnd =
            cfg.maxDate != null && _dateOnly(cfg.maxDate!).isBefore(lastOfMonth)
            ? _dateOnly(cfg.maxDate!)
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

  // ── Month navigation ──────────────────────────────────────────────────────

  bool get _canGoToPreviousMonth {
    final cfg = widget.dateConfig;
    switch (cfg.direction) {
      case DateDirection.future:
        return _displayedMonth.isAfter(_monthOnly(DateTime.now()));
      case DateDirection.past:
      case DateDirection.all:
        if (cfg.minDate == null) {
          // Default look-back: 10 years.
          final limit = _monthOnly(
            DateTime(DateTime.now().year - 10, DateTime.now().month),
          );
          return _displayedMonth.isAfter(limit);
        }
        return _displayedMonth.isAfter(_monthOnly(cfg.minDate!));
    }
  }

  bool get _canGoToNextMonth {
    final cfg = widget.dateConfig;
    switch (cfg.direction) {
      case DateDirection.past:
        return _displayedMonth.isBefore(_monthOnly(DateTime.now()));
      case DateDirection.future:
      case DateDirection.all:
        if (cfg.maxDate == null) return true;
        return _displayedMonth.isBefore(_monthOnly(cfg.maxDate!));
    }
  }

  bool get _scrollToEnd => widget.dateConfig.direction == DateDirection.past;

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _selectDay(DateTime date) async {
    if (widget.mode == SlotPickerMode.dateOnly) {
      setState(() {
        _selectedDate = _dateOnly(date);
        _hasLoadedSelectedDay = true;
      });
      widget.onDateSelected?.call(_dateOnly(date));
      return;
    }

    setState(() {
      _selectedDate = _dateOnly(date);
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
        _slots = _filterSlotsForDate(fetched ?? const []);
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
      if (_selectedDate == null || !_isSameMonth(_selectedDate!, next)) {
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

  List<SlotItem> _filterSlotsForDate(List<SlotItem> slots) {
    if (_selectedDate == null) return const [];
    return slots
        .where((s) => _dateOnly(s.date).isAtSameMomentAs(_selectedDate!))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  Widget _buildTimesArea() {
    final t = widget.theme;
    final l = widget.labels;

    if (_isLoading) {
      return SizedBox(
        height: 132,
        child: Center(
          child:
              t.loadingBuilder?.call(context) ??
              CircularProgressIndicator(color: t.primaryColor),
        ),
      );
    }
    if (_hasError) {
      return MessageStateWidget(message: l.errorMessage, theme: t);
    }
    if (!_hasLoadedSelectedDay) {
      return MessageStateWidget(message: l.chooseDatePrompt, theme: t);
    }

    final source = widget.mode == SlotPickerMode.timeOnly
        ? widget.initialSlots
        : _slots;
    final available = source.where((s) => !s.isBooked).toList();
    if (available.isEmpty) {
      return MessageStateWidget(message: l.noSlotsMessage, theme: t);
    }
    return TimeSlotsGrid(
      slots: available,
      selectedSlotId: _selectedSlotId,
      onSlotSelected: (slot) {
        setState(() => _selectedSlotId = slot.id);
        widget.onTimeSlotSelected!(slot);
      },
      theme: t,
      timeFormatter: widget.timeFormatter,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final l = widget.labels;
    final showDatePicker = widget.mode != SlotPickerMode.timeOnly;
    final showTimeSlots = widget.mode != SlotPickerMode.dateOnly;

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
            MonthDayPicker(
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
            ),
          ],
          if (showDatePicker && showTimeSlots) const SizedBox(height: 24),
          if (showTimeSlots) ...[
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: t.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l.timeHeading,
                  style:
                      t.sectionHeadingStyle ??
                      TextStyle(
                        color: t.grey900,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTimesArea(),
          ],
        ],
      ),
    );
  }
}
