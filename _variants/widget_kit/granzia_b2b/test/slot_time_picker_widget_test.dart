import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

List<SlotItem> _slots(DateTime day) => [
      SlotItem(id: 1, date: day, time: '09:00 AM'),
      SlotItem(id: 2, date: day, time: '10:00 AM'),
      SlotItem(id: 3, date: day, time: '11:00 AM', isBooked: true),
    ];

void main() {
  final today = DateTime(2026, 6, 9);

  // The date strip formats month/day names via intl's DateFormat, which needs
  // locale data initialized first. Apps that render the strip must do the same
  // at startup (initializeDateFormatting()).
  setUpAll(() async => initializeDateFormatting());

  group('InlineSlotTimePicker — construction asserts', () {
    test('dateAndTime requires onDaySelected', () {
      expect(
        () => InlineSlotTimePicker(
          onTimeSlotSelected: (_) {},
          // onDaySelected missing
        ),
        throwsAssertionError,
      );
    });

    test('dateOnly requires onDateSelected', () {
      expect(
        () => InlineSlotTimePicker(
          mode: SlotPickerMode.dateOnly,
          // onDateSelected missing
        ),
        throwsAssertionError,
      );
    });

    test('timeOnly requires onTimeSlotSelected', () {
      expect(
        () => InlineSlotTimePicker(
          mode: SlotPickerMode.timeOnly,
          // onTimeSlotSelected missing
        ),
        throwsAssertionError,
      );
    });

    test('valid dateAndTime config constructs', () {
      expect(
        () => InlineSlotTimePicker(
          onDaySelected: (_) async => const <SlotItem>[],
          onTimeSlotSelected: (_) {},
        ),
        returnsNormally,
      );
    });
  });

  group('InlineSlotTimePicker — dateAndTime mode', () {
    testWidgets('shows the choose-date prompt before a day is selected',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          InlineSlotTimePicker(
            onDaySelected: (_) async => const <SlotItem>[],
            onTimeSlotSelected: (_) {},
            labels: const SlotPickerLabels(chooseDatePrompt: 'Pick a date first'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Pick a date first'), findsOneWidget);
    });

    testWidgets('renders the time heading section', (tester) async {
      await tester.pumpWidget(
        _wrap(
          InlineSlotTimePicker(
            onDaySelected: (_) async => const <SlotItem>[],
            onTimeSlotSelected: (_) {},
            labels: const SlotPickerLabels(timeHeading: 'Available times'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Available times'), findsOneWidget);
    });
  });

  group('InlineSlotTimePicker — timeOnly mode', () {
    testWidgets('renders slot time labels from initialSlots', (tester) async {
      await tester.pumpWidget(
        _wrap(
          InlineSlotTimePicker(
            mode: SlotPickerMode.timeOnly,
            onTimeSlotSelected: (_) {},
            initialSlots: _slots(today),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('09:00 AM'), findsOneWidget);
      expect(find.text('10:00 AM'), findsOneWidget);
    });

    testWidgets('tapping a slot reports it via onTimeSlotSelected',
        (tester) async {
      SlotItem? picked;
      await tester.pumpWidget(
        _wrap(
          InlineSlotTimePicker(
            mode: SlotPickerMode.timeOnly,
            onTimeSlotSelected: (s) => picked = s,
            initialSlots: _slots(today),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('10:00 AM'));
      await tester.pump();

      expect(picked, isNotNull);
      expect(picked!.id, 2);
    });

    testWidgets('shows the no-slots message when there are none', (tester) async {
      await tester.pumpWidget(
        _wrap(
          InlineSlotTimePicker(
            mode: SlotPickerMode.timeOnly,
            onTimeSlotSelected: (_) {},
            initialSlots: const [],
            labels: const SlotPickerLabels(noSlotsMessage: 'Nothing free today'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Nothing free today'), findsOneWidget);
    });

    testWidgets('a custom timeFormatter transforms the displayed label',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          InlineSlotTimePicker(
            mode: SlotPickerMode.timeOnly,
            onTimeSlotSelected: (_) {},
            initialSlots: [SlotItem(id: 1, date: today, time: '09:00 AM')],
            timeFormatter: (raw) => 'at $raw',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('at 09:00 AM'), findsOneWidget);
      expect(find.text('09:00 AM'), findsNothing);
    });
  });

  group('InlineSlotTimePicker — dateOnly mode', () {
    testWidgets('renders the day strip (no time grid)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          InlineSlotTimePicker(
            mode: SlotPickerMode.dateOnly,
            onDateSelected: (_) {},
            labels: const SlotPickerLabels(timeHeading: 'TIME_HEADING'),
          ),
        ),
      );
      await tester.pump();
      // The time heading must NOT appear in date-only mode.
      expect(find.text('TIME_HEADING'), findsNothing);
    });
  });

  group('SlotTimeBottomSheetSelector', () {
    testWidgets('renders its collapsed label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SlotTimeBottomSheetSelector(
            onDaySelected: (_) async => const <SlotItem>[],
            onTimeSlotSelected: (_) {},
            labels: const SlotPickerLabels(chooseDatePrompt: 'Tap to choose'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Tap to choose'), findsOneWidget);
    });
  });
}
