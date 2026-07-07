import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

void main() {
  group('SlotDateConfig defaults & presets', () {
    test('default direction is future', () {
      const config = SlotDateConfig();
      expect(config.direction, DateDirection.future);
      expect(config.minDate, isNull);
      expect(config.maxDate, isNull);
      expect(config.disabledDates, isEmpty);
    });

    test('.future preset sets the future direction', () {
      final config = SlotDateConfig.future(maxDate: DateTime(2026, 12, 31));
      expect(config.direction, DateDirection.future);
      expect(config.maxDate, DateTime(2026, 12, 31));
    });

    test('.past preset sets the past direction', () {
      final config = SlotDateConfig.past(minDate: DateTime(2020));
      expect(config.direction, DateDirection.past);
      expect(config.minDate, DateTime(2020));
    });

    test('.range preset sets the all direction with bounds', () {
      final config = SlotDateConfig.range(
        minDate: DateTime(2025),
        maxDate: DateTime(2025, 12, 31),
      );
      expect(config.direction, DateDirection.all);
      expect(config.minDate, DateTime(2025));
      expect(config.maxDate, DateTime(2025, 12, 31));
    });
  });

  group('SlotDateConfig.isDayDisabled', () {
    test('a day with no constraints is enabled', () {
      const config = SlotDateConfig();
      expect(config.isDayDisabled(DateTime(2026, 6, 9)), isFalse);
    });

    test('a date in disabledDates is disabled', () {
      final config = SlotDateConfig(disabledDates: [DateTime(2026, 6, 9)]);
      expect(config.isDayDisabled(DateTime(2026, 6, 9)), isTrue);
    });

    test('disabledDates compares date-only (ignores time component)', () {
      final config = SlotDateConfig(disabledDates: [DateTime(2026, 6, 9)]);
      // Same calendar day, different time → still disabled.
      expect(config.isDayDisabled(DateTime(2026, 6, 9, 23, 59)), isTrue);
    });

    test('a date not in disabledDates is enabled', () {
      final config = SlotDateConfig(disabledDates: [DateTime(2026, 6, 9)]);
      expect(config.isDayDisabled(DateTime(2026, 6, 10)), isFalse);
    });

    test('isDateDisabled predicate disables matching days (e.g. weekends)', () {
      final config = SlotDateConfig(
        isDateDisabled: (d) =>
            d.weekday == DateTime.saturday || d.weekday == DateTime.sunday,
      );
      // 2026-06-13 is a Saturday, 2026-06-15 is a Monday.
      expect(config.isDayDisabled(DateTime(2026, 6, 13)), isTrue);
      expect(config.isDayDisabled(DateTime(2026, 6, 15)), isFalse);
    });

    test('predicate receives a time-stripped date', () {
      DateTime? seen;
      final config = SlotDateConfig(
        isDateDisabled: (d) {
          seen = d;
          return false;
        },
      );
      config.isDayDisabled(DateTime(2026, 6, 9, 14, 30));
      expect(seen, DateTime(2026, 6, 9)); // hours/minutes stripped
    });

    test('predicate and disabledDates combine (either disables)', () {
      final config = SlotDateConfig(
        disabledDates: [DateTime(2026, 1, 1)],
        isDateDisabled: (d) => d.day == 15,
      );
      expect(config.isDayDisabled(DateTime(2026, 1, 1)), isTrue); // via list
      expect(config.isDayDisabled(DateTime(2026, 3, 15)), isTrue); // via predicate
      expect(config.isDayDisabled(DateTime(2026, 3, 16)), isFalse);
    });
  });

  group('SlotItem', () {
    test('equality is by id only', () {
      final a = SlotItem(id: 1, date: DateTime(2026), time: '09:00');
      final b = SlotItem(id: 1, date: DateTime(2030), time: '23:00', isBooked: true);
      final c = SlotItem(id: 2, date: DateTime(2026), time: '09:00');

      expect(a == b, isTrue, reason: 'same id → equal regardless of other fields');
      expect(a == c, isFalse);
    });

    test('hashCode matches id hashCode (so sets dedupe by id)', () {
      final a = SlotItem(id: 7, date: DateTime(2026), time: '1');
      final b = SlotItem(id: 7, date: DateTime(2027), time: '2');
      expect({a, b}, hasLength(1));
      expect(a.hashCode, 7.hashCode);
    });

    test('defaults: not booked, no extra', () {
      final s = SlotItem(id: 1, date: DateTime(2026), time: '09:00');
      expect(s.isBooked, isFalse);
      expect(s.extra, isNull);
    });

    test('carries an optional extra payload', () {
      final s = SlotItem(
        id: 1,
        date: DateTime(2026),
        time: '09:00',
        extra: {'room': 'A'},
      );
      expect(s.extra, {'room': 'A'});
    });
  });

  group('SlotPickerLabels', () {
    test('English defaults', () {
      const labels = SlotPickerLabels();
      expect(labels.chooseDatePrompt, 'Choose the best date & time');
      expect(labels.timeHeading, 'Time');
      expect(labels.confirmButtonLabel, 'Next');
    });

    test('Arabic preset uses Arabic strings', () {
      const labels = SlotPickerLabels.arabic();
      expect(labels.timeHeading, 'الوقت');
      expect(labels.confirmButtonLabel, 'التالي');
    });

    test('individual overrides are honoured', () {
      const labels = SlotPickerLabels(confirmButtonLabel: 'Book');
      expect(labels.confirmButtonLabel, 'Book');
      // Untouched fields keep defaults.
      expect(labels.timeHeading, 'Time');
    });
  });

  group('enums', () {
    test('DateDirection has future/past/all', () {
      expect(DateDirection.values,
          [DateDirection.future, DateDirection.past, DateDirection.all]);
    });

    test('SlotPickerMode has dateAndTime/dateOnly/timeOnly', () {
      expect(SlotPickerMode.values, [
        SlotPickerMode.dateAndTime,
        SlotPickerMode.dateOnly,
        SlotPickerMode.timeOnly,
      ]);
    });
  });
}
