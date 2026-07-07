import 'package:flutter/material.dart';
import '../../l10n/slot_picker_labels.dart';
import '../../models/slot_item.dart';
import '../../theme/slot_picker_theme.dart';
import 'message_state_widget.dart';
import 'time_slots_grid.dart';

/// The time-slot region shared by the inline and bottom-sheet pickers.
///
/// Renders one of four states based on the flags passed in: a loading
/// spinner, an error message, a "choose a date first" prompt, or the grid of
/// available slots (with an empty-state message when none are bookable).
class SlotTimesArea extends StatelessWidget {
  /// Slots already filtered to the selected day (the empty-state and
  /// booked filtering happen here).
  final List<SlotItem> slots;
  final int? selectedSlotId;
  final ValueChanged<SlotItem> onSlotSelected;
  final bool isLoading;
  final bool hasError;
  final bool hasLoadedSelectedDay;

  /// Height of the loading spinner box — 150 in the sheet, 132 inline.
  final double loadingHeight;

  final SlotPickerTheme theme;
  final SlotPickerLabels labels;
  final String Function(String time)? timeFormatter;

  const SlotTimesArea({
    super.key,
    required this.slots,
    required this.selectedSlotId,
    required this.onSlotSelected,
    required this.isLoading,
    required this.hasError,
    required this.hasLoadedSelectedDay,
    required this.loadingHeight,
    required this.theme,
    required this.labels,
    this.timeFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = labels;

    if (isLoading) {
      return SizedBox(
        height: loadingHeight,
        child: Center(
          child: t.loadingBuilder?.call(context) ??
              CircularProgressIndicator(color: t.primaryColor),
        ),
      );
    }
    if (hasError) {
      return MessageStateWidget(message: l.errorMessage, theme: t);
    }
    if (!hasLoadedSelectedDay) {
      return MessageStateWidget(message: l.chooseDatePrompt, theme: t);
    }

    final available = slots.where((s) => !s.isBooked).toList();
    if (available.isEmpty) {
      return MessageStateWidget(message: l.noSlotsMessage, theme: t);
    }
    return TimeSlotsGrid(
      slots: available,
      selectedSlotId: selectedSlotId,
      onSlotSelected: onSlotSelected,
      theme: t,
      timeFormatter: timeFormatter,
    );
  }
}
