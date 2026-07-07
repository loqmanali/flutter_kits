import 'package:flutter/material.dart';
import '../../models/slot_item.dart';
import '../../theme/slot_picker_theme.dart';
import 'time_slot_tile.dart';

class TimeSlotsGrid extends StatelessWidget {
  final List<SlotItem> slots;
  final int? selectedSlotId;
  final ValueChanged<SlotItem> onSlotSelected;
  final SlotPickerTheme theme;

  /// Optional builder to format how the time string is displayed in each chip.
  /// Defaults to the raw [SlotItem.time] value.
  final String Function(String time)? timeFormatter;

  const TimeSlotsGrid({
    super.key,
    required this.slots,
    required this.selectedSlotId,
    required this.onSlotSelected,
    required this.theme,
    this.timeFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final rowHeight = theme.timeSlotGridRowHeight;
    final crossAxisCount = theme.timeSlotGridCrossAxisCount;

    return GridView.builder(
      itemCount: slots.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio:
            (MediaQuery.of(context).size.width / crossAxisCount) / rowHeight,
        crossAxisSpacing: 14,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final slot = slots[index];
        return TimeSlotTile(
          label: timeFormatter?.call(slot.time) ?? slot.time,
          isSelected: selectedSlotId == slot.id,
          onTap: () => onSlotSelected(slot),
          theme: theme,
        );
      },
    );
  }
}
