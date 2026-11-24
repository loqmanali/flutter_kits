part of '../slot_time_bottom_sheet_selector.dart';

// The modal sheet the selector opens.
class _SlotPickerSheet extends StatefulWidget {
  final DateTime? initialSelectedDate;
  final int? initialSelectedSlotId;
  final List<SlotItem> initialSlots;
  final SlotDayLoader? onDaySelected;
  final ValueChanged<SlotItem>? onTimeSlotSelected;
  final ValueChanged<DateTime>? onDateSelected;
  final SlotPickerMode mode;
  final SlotDateConfig dateConfig;
  final SlotPickerTheme? theme;
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
    this.theme,
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
    final t = widget.theme ??
        SlotPickerTheme.fromScheme(Theme.of(context).colorScheme);
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
