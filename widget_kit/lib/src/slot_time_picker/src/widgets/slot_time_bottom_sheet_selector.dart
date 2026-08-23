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

part 'slot_time_bottom_sheet_selector/slot_picker_sheet.dart';

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
  /// Null → built from the ambient [ColorScheme]
  /// (see [SlotPickerTheme.fromScheme]).
  final SlotPickerTheme? theme;

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
    this.theme,
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
    final t =
        theme ?? SlotPickerTheme.fromScheme(Theme.of(context).colorScheme);
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
