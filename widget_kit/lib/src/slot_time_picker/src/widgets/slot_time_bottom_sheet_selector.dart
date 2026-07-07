import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/slot_date_config.dart';
import '../l10n/slot_picker_labels.dart';
import '../models/slot_item.dart';
import '../theme/slot_picker_theme.dart';
import '../utils/slot_date_math.dart';
import 'inline_slot_time_picker.dart';
import 'internal/month_day_picker.dart';
import 'internal/section_heading.dart';
import 'internal/sheet_close_button.dart';
import 'internal/sheet_confirm_bar.dart';
import 'internal/slot_times_area.dart';
import 'internal/year_grid.dart';

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

  bool get _isRtl => isRtlLocale(locale);

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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
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
        : SlotDateMath.dateOnly(widget.initialSelectedDate!);
    _displayedMonth =
        SlotDateMath.initialMonth(_selectedDate, widget.dateConfig);
    _selectedSlotId = widget.initialSelectedSlotId;
    _slots =
        SlotDateMath.filterSlotsForDate(widget.initialSlots, _selectedDate);
    _selectedSlot = _slots.where((s) => s.id == _selectedSlotId).firstOrNull;
    _hasLoadedSelectedDay =
        _selectedDate != null || widget.mode == SlotPickerMode.timeOnly;
  }

  // ── Derived state ───────────────────────────────────────────────────────────

  List<DateTime> get _visibleDays =>
      SlotDateMath.buildDays(_displayedMonth, widget.dateConfig);

  bool get _canGoToPreviousMonth =>
      SlotDateMath.canGoToPreviousMonth(_displayedMonth, widget.dateConfig);

  bool get _canGoToNextMonth =>
      SlotDateMath.canGoToNextMonth(_displayedMonth, widget.dateConfig);

  bool get _scrollToEnd => SlotDateMath.scrollToEnd(widget.dateConfig);

  (int min, int max) get _yearBounds =>
      SlotDateMath.yearBounds(widget.dateConfig);

  bool get _isRtl => isRtlLocale(widget.locale);

  // ── Navigation ────────────────────────────────────────────────────────────

  void _changeMonth(int delta) {
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    setState(() {
      _displayedMonth = next;
      if (_selectedDate == null ||
          !SlotDateMath.isSameMonth(_selectedDate!, next)) {
        _clearSelection();
      }
    });
  }

  // ── Year picker ───────────────────────────────────────────────────────────

  void _toggleYearPicker() {
    setState(() => _pickingYear = !_pickingYear);
  }

  void _selectYear(int year) {
    setState(() {
      _displayedMonth = DateTime(year, _displayedMonth.month);
      _pickingYear = false;
      if (_selectedDate != null && _selectedDate!.year != year) {
        _clearSelection();
      }
    });
  }

  /// Resets all per-day selection/loading state. Caller is responsible for
  /// being inside a [setState].
  void _clearSelection() {
    _selectedDate = null;
    _selectedSlotId = null;
    _selectedSlot = null;
    _slots = const [];
    _isLoading = false;
    _hasLoadedSelectedDay = false;
    _hasError = false;
  }

  // ── Day selection ─────────────────────────────────────────────────────────

  Future<void> _selectDay(DateTime date) async {
    if (widget.mode == SlotPickerMode.dateOnly) {
      setState(() {
        _selectedDate = SlotDateMath.dateOnly(date);
        _hasLoadedSelectedDay = true;
      });
      return;
    }

    setState(() {
      _selectedDate = SlotDateMath.dateOnly(date);
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final l = widget.labels;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final showDatePicker = widget.mode != SlotPickerMode.timeOnly;
    final showTimeSlots = widget.mode != SlotPickerMode.dateOnly;
    final timesSource =
        widget.mode == SlotPickerMode.timeOnly ? widget.initialSlots : _slots;

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
                        child: SheetCloseButton(
                          onTap: () => Navigator.of(context).pop(),
                          theme: t,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SectionHeading(label: l.chooseDatePrompt, theme: t),
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
                                ? YearGrid(
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
                        SectionHeading(label: l.timeHeading, theme: t),
                        const SizedBox(height: 14),
                        SlotTimesArea(
                          slots: timesSource,
                          selectedSlotId: _selectedSlotId,
                          onSlotSelected: (slot) => setState(() {
                            _selectedSlotId = slot.id;
                            _selectedSlot = slot;
                          }),
                          isLoading: _isLoading,
                          hasError: _hasError,
                          hasLoadedSelectedDay: _hasLoadedSelectedDay,
                          loadingHeight: 150,
                          theme: t,
                          labels: l,
                          timeFormatter: widget.timeFormatter,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SheetConfirmBar(
                onConfirm: _canConfirm ? _confirm : null,
                label: l.confirmButtonLabel,
                bottomPadding: bottomPadding,
                theme: t,
              ),
            ],
          ),
        );
      },
    );
  }
}
