import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/slot_date_config.dart';
import '../l10n/slot_picker_labels.dart';
import '../models/slot_item.dart';
import '../theme/slot_picker_theme.dart';
import 'inline_slot_time_picker.dart';
import 'internal/message_state_widget.dart';
import 'internal/month_day_picker.dart';
import 'internal/time_slots_grid.dart';

/// A compact trigger button that, when tapped, opens a draggable bottom sheet
/// containing a full slot/date-time picker.
///
/// ```dart
/// SlotTimeBottomSheetSelector(
///   onDaySelected: (date) async => await myApi.fetchSlots(date),
///   onTimeSlotSelected: (slot) => setState(() => _chosen = slot),
///   selectedDate: _chosenDate,
///   selectedTimeSlotId: _chosenSlot?.id,
///   selectedTimeLabel: _chosenSlot?.time,
/// )
/// ```
class SlotTimeBottomSheetSelector extends StatelessWidget {
  // ── Data callbacks ────────────────────────────────────────────────────────

  /// Called whenever the user taps a day inside the sheet. Return the available
  /// [SlotItem]s for that date (or `null` / throw on error).
  ///
  /// Only used when [mode] is [SlotPickerMode.dateAndTime]. In
  /// [SlotPickerMode.dateOnly] mode use [onDateSelected] instead.
  final SlotDayLoader? onDaySelected;

  /// Called when the user confirms a time-slot selection.
  ///
  /// Not required when [mode] is [SlotPickerMode.dateOnly].
  final ValueChanged<SlotItem>? onTimeSlotSelected;

  /// Called when the user confirms a date in [SlotPickerMode.dateOnly] mode.
  final ValueChanged<DateTime>? onDateSelected;

  // ── Selection state ───────────────────────────────────────────────────────

  /// Pre-selected date shown in the collapsed button label.
  final DateTime? selectedDate;

  /// ID of the pre-selected slot; drives the check-mark icon in the button.
  final int? selectedTimeSlotId;

  /// Human-readable time string shown in the collapsed button (e.g. `"10:00 AM"`).
  final String? selectedTimeLabel;

  /// Slots already known for [selectedDate] — avoids a redundant API call.
  final List<SlotItem> initialSlots;

  // ── Behaviour ─────────────────────────────────────────────────────────────

  /// When `true` the button is dimmed and ignores taps.
  final bool isDisabled;

  /// Called just before the bottom sheet is presented.
  final VoidCallback? onOpen;

  // ── Mode & constraints ────────────────────────────────────────────────────

  /// Which sections of the picker to render.
  final SlotPickerMode mode;

  /// Date navigation / availability constraints.
  final SlotDateConfig dateConfig;

  // ── Customization ─────────────────────────────────────────────────────────

  /// Visual configuration.
  final SlotPickerTheme theme;

  /// String labels / translations.
  final SlotPickerLabels labels;

  /// BCP-47 locale code for date formatting and numeral style.
  final String locale;

  /// Optional formatter applied to each [SlotItem.time] string inside chips.
  final String Function(String time)? timeFormatter;

  /// Override how the selected date is formatted in the collapsed button.
  final String Function(DateTime date, String locale)? dateFormatter;

  const SlotTimeBottomSheetSelector({
    super.key,
    this.onDaySelected,
    this.onTimeSlotSelected,
    this.onDateSelected,
    this.selectedDate,
    this.selectedTimeSlotId,
    this.selectedTimeLabel,
    this.initialSlots = const [],
    this.isDisabled = false,
    this.onOpen,
    this.mode = SlotPickerMode.dateAndTime,
    this.dateConfig = const SlotDateConfig(),
    this.theme = const SlotPickerTheme(),
    this.labels = const SlotPickerLabels(),
    this.locale = 'en',
    this.timeFormatter,
    this.dateFormatter,
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get _isRtl {
    final lang = locale.split('_').first.toLowerCase();
    const rtlLanguages = {'ar', 'fa', 'he', 'ur', 'ps', 'sd', 'yi'};
    return rtlLanguages.contains(lang);
  }

  String _buildDisplayLabel() {
    if (mode == SlotPickerMode.timeOnly) {
      return selectedTimeLabel ?? labels.chooseDatePrompt;
    }

    if (selectedDate == null) return labels.chooseDatePrompt;

    final String dateStr;
    if (dateFormatter != null) {
      dateStr = dateFormatter!(selectedDate!, locale);
    } else {
      final pattern = _isRtl ? 'EEEE، d MMMM' : 'EEEE, d MMMM';
      dateStr = DateFormat(pattern, locale).format(selectedDate!);
    }

    if (mode == SlotPickerMode.dateOnly) return dateStr;

    if (selectedTimeLabel == null || selectedTimeLabel!.isEmpty) return dateStr;
    return '$dateStr  •  $selectedTimeLabel';
  }

  bool get _hasSelection {
    return switch (mode) {
      SlotPickerMode.dateAndTime =>
        selectedDate != null && selectedTimeSlotId != null,
      SlotPickerMode.dateOnly => selectedDate != null,
      SlotPickerMode.timeOnly => selectedTimeSlotId != null,
    };
  }

  void _open(BuildContext context) {
    onOpen?.call();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SlotPickerSheet(
        initialSelectedDate: selectedDate,
        initialSelectedSlotId: selectedTimeSlotId,
        initialSlots: initialSlots,
        onDaySelected: onDaySelected,
        onTimeSlotSelected: onTimeSlotSelected,
        onDateSelected: onDateSelected,
        mode: mode,
        dateConfig: dateConfig,
        theme: theme,
        labels: labels,
        locale: locale,
        timeFormatter: timeFormatter,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final hasSelection = _hasSelection;
    final radius = BorderRadius.circular(t.selectorBorderRadius);

    return Opacity(
      opacity: isDisabled ? 0.5 : 1,
      child: IgnorePointer(
        ignoring: isDisabled,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: () => _open(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: hasSelection
                    ? t.primaryLightColor.withValues(alpha: 0.35)
                    : t.backgroundColor,
                borderRadius: radius,
                border: Border.all(
                  color: hasSelection
                      ? t.primaryColor
                      : t.grey400.withValues(alpha: 0.5),
                  width: hasSelection ? 1.4 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasSelection
                        ? Icons.check_circle
                        : CupertinoIcons.calendar_today,
                    color: hasSelection ? t.primaryColor : t.grey400,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _buildDisplayLabel(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.selectorLabelStyle?.copyWith(
                            color: hasSelection ? t.grey900 : t.grey500,
                          ) ??
                          TextStyle(
                            color: hasSelection ? t.grey900 : t.grey500,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.expand_more_rounded, color: t.grey400, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Internal bottom-sheet ────────────────────────────────────────────────────

class _SlotPickerSheet extends StatefulWidget {
  final DateTime? initialSelectedDate;
  final int? initialSelectedSlotId;
  final List<SlotItem> initialSlots;
  final SlotDayLoader? onDaySelected;
  final ValueChanged<SlotItem>? onTimeSlotSelected;
  final ValueChanged<DateTime>? onDateSelected;
  final SlotPickerMode mode;
  final SlotDateConfig dateConfig;
  final SlotPickerTheme theme;
  final SlotPickerLabels labels;
  final String locale;
  final String Function(String time)? timeFormatter;

  const _SlotPickerSheet({
    required this.initialSelectedDate,
    required this.initialSelectedSlotId,
    required this.initialSlots,
    required this.onDaySelected,
    required this.onTimeSlotSelected,
    required this.onDateSelected,
    required this.mode,
    required this.dateConfig,
    required this.theme,
    required this.labels,
    required this.locale,
    this.timeFormatter,
  });

  @override
  State<_SlotPickerSheet> createState() => _SlotPickerSheetState();
}

class _SlotPickerSheetState extends State<_SlotPickerSheet> {
  late DateTime _displayedMonth;
  DateTime? _selectedDate;
  int? _selectedSlotId;
  SlotItem? _selectedSlot;
  List<SlotItem> _slots = const [];
  bool _isLoading = false;
  bool _hasLoadedSelectedDay = false;
  bool _hasError = false;

  /// When true the month-day grid is replaced by a year-picker grid.
  bool _pickingYear = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialSelectedDate == null
        ? null
        : _dateOnly(widget.initialSelectedDate!);
    _displayedMonth = _initialMonth();
    _selectedSlotId = widget.initialSelectedSlotId;
    _slots = _filterSlotsForDate(widget.initialSlots);
    _selectedSlot = _slots.where((s) => s.id == _selectedSlotId).firstOrNull;
    _hasLoadedSelectedDay =
        _selectedDate != null || widget.mode == SlotPickerMode.timeOnly;
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
    if (cfg.direction == DateDirection.past && cfg.maxDate != null) {
      final max = _dateOnly(cfg.maxDate!);
      if (max.isBefore(_dateOnly(now))) return _monthOnly(max);
    }
    return _monthOnly(now);
  }

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
        rangeStart =
            effectiveMin.isAfter(firstOfMonth) ? effectiveMin : firstOfMonth;
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
        rangeEnd =
            effectiveMax.isBefore(lastOfMonth) ? effectiveMax : lastOfMonth;

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

  // ── Navigation ────────────────────────────────────────────────────────────

  bool get _canGoToPreviousMonth {
    final cfg = widget.dateConfig;
    switch (cfg.direction) {
      case DateDirection.future:
        return _displayedMonth.isAfter(_monthOnly(DateTime.now()));
      case DateDirection.past:
      case DateDirection.all:
        if (cfg.minDate == null) {
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

  void _changeMonth(int delta) {
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    setState(() {
      _displayedMonth = next;
      if (_selectedDate == null || !_isSameMonth(_selectedDate!, next)) {
        _selectedDate = null;
        _selectedSlotId = null;
        _selectedSlot = null;
        _slots = const [];
        _isLoading = false;
        _hasLoadedSelectedDay = false;
        _hasError = false;
      }
    });
  }

  // ── Year picker ───────────────────────────────────────────────────────────

  /// Returns the inclusive (min, max) years selectable by the year picker,
  /// derived from [SlotDateConfig.minDate]/[maxDate] when present, with sane
  /// 10-year fallbacks matching [_canGoToPreviousMonth].
  (int min, int max) get _yearBounds {
    final cfg = widget.dateConfig;
    final now = DateTime.now();
    final int minYear;
    final int maxYear;

    switch (cfg.direction) {
      case DateDirection.future:
        minYear = (cfg.minDate ?? now).year;
        maxYear = cfg.maxDate?.year ?? now.year + 10;
      case DateDirection.past:
        minYear = cfg.minDate?.year ?? now.year - 10;
        maxYear = (cfg.maxDate ?? now).year;
      case DateDirection.all:
        minYear = cfg.minDate?.year ?? now.year - 10;
        maxYear = cfg.maxDate?.year ?? now.year + 10;
    }
    return (minYear, maxYear);
  }

  void _toggleYearPicker() {
    setState(() => _pickingYear = !_pickingYear);
  }

  void _selectYear(int year) {
    setState(() {
      _displayedMonth = DateTime(year, _displayedMonth.month);
      _pickingYear = false;
      if (_selectedDate != null && _selectedDate!.year != year) {
        _selectedDate = null;
        _selectedSlotId = null;
        _selectedSlot = null;
        _slots = const [];
        _isLoading = false;
        _hasLoadedSelectedDay = false;
        _hasError = false;
      }
    });
  }

  // ── Day selection ─────────────────────────────────────────────────────────

  Future<void> _selectDay(DateTime date) async {
    if (widget.mode == SlotPickerMode.dateOnly) {
      setState(() {
        _selectedDate = _dateOnly(date);
        _hasLoadedSelectedDay = true;
      });
      return;
    }

    setState(() {
      _selectedDate = _dateOnly(date);
      _selectedSlotId = null;
      _selectedSlot = null;
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

  List<SlotItem> _filterSlotsForDate(List<SlotItem> slots) {
    if (_selectedDate == null) return const [];
    return slots
        .where((s) => _dateOnly(s.date).isAtSameMomentAs(_selectedDate!))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  // ── Confirm ───────────────────────────────────────────────────────────────

  bool get _canConfirm {
    return switch (widget.mode) {
      SlotPickerMode.dateAndTime => _selectedSlot != null,
      SlotPickerMode.dateOnly => _selectedDate != null,
      SlotPickerMode.timeOnly => _selectedSlot != null,
    };
  }

  void _confirm() {
    if (!_canConfirm) return;
    if (widget.mode == SlotPickerMode.dateOnly) {
      widget.onDateSelected?.call(_selectedDate!);
    } else {
      widget.onTimeSlotSelected?.call(_selectedSlot!);
    }
    Navigator.of(context).pop();
  }

  // ── Times area ────────────────────────────────────────────────────────────

  Widget _buildTimesArea() {
    final t = widget.theme;
    final l = widget.labels;

    if (_isLoading) {
      return SizedBox(
        height: 150,
        child: Center(
          child: t.loadingBuilder?.call(context) ??
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

    final source =
        widget.mode == SlotPickerMode.timeOnly ? widget.initialSlots : _slots;
    final available = source.where((s) => !s.isBooked).toList();
    if (available.isEmpty) {
      return MessageStateWidget(message: l.noSlotsMessage, theme: t);
    }
    return TimeSlotsGrid(
      slots: available,
      selectedSlotId: _selectedSlotId,
      onSlotSelected: (slot) => setState(() {
        _selectedSlotId = slot.id;
        _selectedSlot = slot;
      }),
      theme: t,
      timeFormatter: widget.timeFormatter,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  bool get _isRtl {
    final lang = widget.locale.split('_').first.toLowerCase();
    const rtlLanguages = {'ar', 'fa', 'he', 'ur', 'ps', 'sd', 'yi'};
    return rtlLanguages.contains(lang);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final l = widget.labels;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final showDatePicker = widget.mode != SlotPickerMode.timeOnly;
    final showTimeSlots = widget.mode != SlotPickerMode.dateOnly;

    return DraggableScrollableSheet(
      initialChildSize: t.bottomSheetInitialSize,
      minChildSize: t.bottomSheetMinSize,
      maxChildSize: t.bottomSheetMaxSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: t.backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(t.bottomSheetBorderRadius),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.grey400.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: _isRtl
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: _CloseButton(
                          onTap: () => Navigator.of(context).pop(),
                          theme: t,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _SectionHeading(label: l.chooseDatePrompt, theme: t),
                      if (showDatePicker) ...[
                        const SizedBox(height: 18),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  alignment: Alignment.topCenter,
                                  child: child,
                                ),
                              );
                            },
                            child: _pickingYear
                                ? _YearGrid(
                                    key: const ValueKey('year-grid'),
                                    bounds: _yearBounds,
                                    selectedYear: _displayedMonth.year,
                                    locale: widget.locale,
                                    theme: t,
                                    onYearSelected: _selectYear,
                                  )
                                : MonthDayPicker(
                                    key: const ValueKey('month-grid'),
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
                          ),
                        ),
                      ],
                      if (showTimeSlots) ...[
                        const SizedBox(height: 28),
                        _SectionHeading(label: l.timeHeading, theme: t),
                        const SizedBox(height: 14),
                        _buildTimesArea(),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPadding + 16),
                child: t.confirmButtonBuilder?.call(
                      context,
                      _canConfirm ? _confirm : null,
                      l.confirmButtonLabel,
                    ) ??
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _canConfirm ? _confirm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.primaryColor,
                          disabledBackgroundColor:
                              t.primaryColor.withValues(alpha: 0.4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l.confirmButtonLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  final SlotPickerTheme theme;

  const _CloseButton({required this.onTap, required this.theme});

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

class _SectionHeading extends StatelessWidget {
  final String label;
  final SlotPickerTheme theme;

  const _SectionHeading({required this.label, required this.theme});

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

// ─── Year grid ────────────────────────────────────────────────────────────────

/// A 3-column grid of years rendered when the user taps the month heading.
///
/// Auto-scrolls so the currently displayed year is visible (handy for very
/// wide ranges like 1900-2026 in a DOB picker).
class _YearGrid extends StatefulWidget {
  final (int min, int max) bounds;
  final int selectedYear;
  final String locale;
  final SlotPickerTheme theme;
  final ValueChanged<int> onYearSelected;

  const _YearGrid({
    super.key,
    required this.bounds,
    required this.selectedYear,
    required this.locale,
    required this.theme,
    required this.onYearSelected,
  });

  @override
  State<_YearGrid> createState() => _YearGridState();
}

class _YearGridState extends State<_YearGrid> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      // Years are rendered newest → oldest, so the index of the selected
      // year is its offset from the top (`max - year`). Scroll to keep the
      // selection a couple of rows below the top so the user sees recent
      // years too, not just the selected one alone at the top.
      final (_, max) = widget.bounds;
      final index = max - widget.selectedYear;
      const rowHeight = 56.0 + 10.0;
      final row = (index / 3).floor();
      final raw = row * rowHeight - 80.0;
      final target = raw.clamp(0.0, _controller.position.maxScrollExtent);
      _controller.jumpTo(target);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final (min, max) = widget.bounds;
    final years = [for (var y = max; y >= min; y--) y]; // newest first

    return SizedBox(
      height: 280,
      child: GridView.builder(
        controller: _controller,
        padding: const EdgeInsets.symmetric(vertical: 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 56,
        ),
        itemCount: years.length,
        itemBuilder: (_, i) {
          final year = years[i];
          final selected = year == widget.selectedYear;
          final radius = BorderRadius.circular(12);

          return Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: () => widget.onYearSelected(year),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? t.primaryColor : Colors.transparent,
                  borderRadius: radius,
                  border: Border.all(
                    color: selected
                        ? t.primaryColor
                        : t.grey400.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  year.toString(),
                  style: TextStyle(
                    color: selected ? Colors.white : t.grey900,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
