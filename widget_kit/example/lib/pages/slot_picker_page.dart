import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../gallery/demo_section.dart';
import '../gallery/gallery_scaffold.dart';

/// Documents the slot/time picker — inline + bottom-sheet, across its modes.
class SlotPickerPage extends StatelessWidget {
  const SlotPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Slot / Time Picker',
      intro:
          'Pick a date and a time slot, inline or in a bottom sheet. Three '
          'modes: date+time, date-only, time-only. Async slot loading per day.',
      sections: const [_InlineDateTimeDemo(), _TimeOnlyDemo()],
    );
  }
}

// Demo slots for a given day.
List<SlotItem> _slotsFor(DateTime day) => [
  for (var i = 0; i < 6; i++)
    SlotItem(
      id: day.day * 100 + i,
      date: day,
      time: '${(9 + i).toString().padLeft(2, '0')}:00',
      isBooked: i == 2, // one pre-booked slot
    ),
];

class _InlineDateTimeDemo extends StatefulWidget {
  const _InlineDateTimeDemo();

  @override
  State<_InlineDateTimeDemo> createState() => _InlineDateTimeDemoState();
}

class _InlineDateTimeDemoState extends State<_InlineDateTimeDemo> {
  SlotItem? _picked;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'InlineSlotTimePicker (date + time)',
      description:
          'A day strip plus a time-slot grid. onDaySelected is an async '
          'loader: return the slots for the tapped day.',
      demoBackground: false,
      demo: Column(
        children: [
          InlineSlotTimePicker(
            onDaySelected: (day) async {
              await Future<void>.delayed(const Duration(milliseconds: 300));
              return _slotsFor(day);
            },
            onTimeSlotSelected: (slot) => setState(() => _picked = slot),
          ),
          const SizedBox(height: 8),
          Text(
            _picked == null ? 'No slot selected' : 'Picked: ${_picked!.time}',
          ),
        ],
      ),
      code: '''
InlineSlotTimePicker(
  onDaySelected: (day) async => await api.slotsFor(day),
  onTimeSlotSelected: (slot) => setState(() => picked = slot),
)''',
    );
  }
}

class _TimeOnlyDemo extends StatefulWidget {
  const _TimeOnlyDemo();

  @override
  State<_TimeOnlyDemo> createState() => _TimeOnlyDemoState();
}

class _TimeOnlyDemoState extends State<_TimeOnlyDemo> {
  SlotItem? _picked;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return DemoSection(
      title: 'Time-only mode',
      description:
          'Skip the date strip and just show slots from initialSlots — '
          'good when the day is already chosen.',
      demoBackground: false,
      demo: Column(
        children: [
          InlineSlotTimePicker(
            mode: SlotPickerMode.timeOnly,
            initialSlots: _slotsFor(today),
            onTimeSlotSelected: (slot) => setState(() => _picked = slot),
          ),
          const SizedBox(height: 8),
          Text(_picked == null ? 'No slot' : 'Picked: ${_picked!.time}'),
        ],
      ),
      code: '''
InlineSlotTimePicker(
  mode: SlotPickerMode.timeOnly,
  initialSlots: slots,
  onTimeSlotSelected: (s) => ...,
)''',
    );
  }
}
