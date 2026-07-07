import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

void main() {
  group('countries list', () {
    test('is non-empty and contains expected ISO codes', () {
      expect(countries, isNotEmpty);
      final codes = countries.map((c) => c.code).toSet();
      expect(codes, containsAll(<String>['EG', 'IN', 'SA', 'US']));
    });

    test('every country has a non-empty dialCode and a flag', () {
      for (final c in countries) {
        expect(c.dialCode, isNotEmpty, reason: '${c.code} has empty dialCode');
        expect(c.flag, isNotEmpty, reason: '${c.code} has empty flag');
        expect(
          c.minLength,
          lessThanOrEqualTo(c.maxLength),
          reason: '${c.code} min>max',
        );
      }
    });
  });

  group('Country', () {
    final egypt = countries.firstWhere((c) => c.code == 'EG');

    test('fullCountryCode is dialCode + regionCode', () {
      expect(egypt.regionCode, '');
      expect(egypt.fullCountryCode, egypt.dialCode);
      expect(egypt.fullCountryCode, '20');
    });

    test('displayCC returns dialCode when no region code', () {
      expect(egypt.displayCC, '20');
    });

    test('localizedName resolves exact, case-insensitive, and fallback', () {
      // Exact key.
      expect(egypt.localizedName('ar'), 'مصر');
      // Case-insensitive key match (translations use lowercase keys).
      expect(egypt.localizedName('AR'), 'مصر');
      // Missing locale falls back to the default English name.
      expect(egypt.localizedName('xx'), egypt.name);
    });
  });

  group('PhoneNumber.getCountry', () {
    test('returns India for empty input', () {
      expect(PhoneNumber.getCountry('').code, 'IN');
    });

    test('matches Egypt by leading + dial code', () {
      expect(PhoneNumber.getCountry('+201001234567').code, 'EG');
    });

    test('matches by dial code without plus prefix', () {
      expect(PhoneNumber.getCountry('201001234567').code, 'EG');
    });

    test('falls back to India on invalid characters', () {
      expect(PhoneNumber.getCountry('abc123').code, 'IN');
    });
  });

  group('PhoneNumber.fromCompleteNumber', () {
    test('returns empty model for empty string', () {
      final p = PhoneNumber.fromCompleteNumber(completeNumber: '');
      expect(p.countryISOCode, '');
      expect(p.countryCode, '');
      expect(p.number, '');
    });

    test('parses an Egyptian number with + prefix', () {
      final p = PhoneNumber.fromCompleteNumber(completeNumber: '+201001234567');
      expect(p.countryISOCode, 'EG');
      expect(p.countryCode, '20');
      expect(p.number, '1001234567');
      expect(p.completeNumber, '201001234567');
    });

    test('parses a number without + prefix', () {
      final p = PhoneNumber.fromCompleteNumber(completeNumber: '201001234567');
      expect(p.countryISOCode, 'EG');
      expect(p.number, '1001234567');
    });
  });

  group('PhoneNumber.isValidNumber', () {
    test('true when number length is within min/max for the country', () {
      // Egypt requires exactly 10 digits.
      final valid = PhoneNumber(
        countryISOCode: 'EG',
        countryCode: '20',
        number: '1001234567',
      );
      expect(valid.isValidNumber(), isTrue);
    });

    test('false when number is too short', () {
      final tooShort = PhoneNumber(
        countryISOCode: 'EG',
        countryCode: '20',
        number: '12345',
      );
      expect(tooShort.isValidNumber(), isFalse);
    });
  });
}
