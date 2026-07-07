import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/src/inputs/phone_field/helpers.dart';
import 'package:widget_kit/widget_kit.dart';

void main() {
  group('isNumeric', () {
    test('true for plain digits', () {
      expect(isNumeric('12345'), isTrue);
    });

    test('true for a leading + (stripped before parsing)', () {
      expect(isNumeric('+201001234567'), isTrue);
    });

    test('false for empty string', () {
      expect(isNumeric(''), isFalse);
    });

    test('false for letters or mixed content', () {
      expect(isNumeric('abc'), isFalse);
      expect(isNumeric('12a3'), isFalse);
    });
  });

  group('removeDiacritics', () {
    test('strips accents to ASCII equivalents', () {
      expect(removeDiacritics('Café'), 'Cafe');
      expect(removeDiacritics('Núñez'), 'Nunez');
      expect(removeDiacritics('Åland'), 'Aland');
    });

    test('leaves plain ASCII unchanged', () {
      expect(removeDiacritics('Egypt'), 'Egypt');
    });

    test('handles an empty string', () {
      expect(removeDiacritics(''), '');
    });
  });

  group('CountryExtensions.stringSearch', () {
    test('finds a country by (partial) English name, case-insensitive', () {
      final result = countries.stringSearch('egy');
      expect(result.map((c) => c.code), contains('EG'));
    });

    test('matches a dial code when the query is numeric', () {
      final result = countries.stringSearch('20');
      expect(result.map((c) => c.code), contains('EG'));
    });

    test('a +<dial> query does not match (dialCodes are stored without +)', () {
      // Implementation detail worth pinning: dialCode is '20', not '+20', so a
      // query of '+20' matches nothing via `dialCode.contains('+20')`.
      final result = countries.stringSearch('+20');
      expect(result, isEmpty);
    });

    test('is diacritic-insensitive on the query', () {
      // Searching with an accent still finds the plain-named country.
      final withAccent = countries.stringSearch('égy');
      expect(withAccent.map((c) => c.code), contains('EG'));
    });

    test('returns empty for a nonsense query', () {
      expect(countries.stringSearch('zzzzzznotacountry'), isEmpty);
    });

    test('searches localized (translated) names too', () {
      // Arabic name for Egypt is مصر.
      final result = countries.stringSearch('مصر');
      expect(result.map((c) => c.code), contains('EG'));
    });
  });

  group('phoneNumberValidator', () {
    final egypt = countries.firstWhere((c) => c.code == 'EG');

    test('requires a value (returns the required message)', () {
      final error = phoneNumberValidator(null, egypt);
      expect(error, 'Phone number is required');
    });

    test('honours a custom required message', () {
      final error = phoneNumberValidator(
        '',
        egypt,
        phoneNumberRequired: 'Enter your phone',
      );
      expect(error, 'Enter your phone');
    });

    test('rejects non-numeric input', () {
      final error = phoneNumberValidator('12ab', egypt);
      expect(error, 'Invalid phone number');
    });

    test('rejects a number that is too short for the country', () {
      final error = phoneNumberValidator('123', egypt);
      expect(error, 'Invalid phone number length');
    });

    test('passes for a valid-length number (returns null by default)', () {
      // Egypt requires 10 digits; a valid number yields no error.
      final error = phoneNumberValidator('1001234567', egypt);
      expect(error, isNull);
    });

    test('disableLengthCheck skips the length rule', () {
      final error = phoneNumberValidator(
        '12',
        egypt,
        disableLengthCheck: true,
      );
      expect(error, isNull);
    });

    test('a custom maxLength overrides the country max', () {
      // Force max=5; a 10-digit number now fails.
      final error = phoneNumberValidator('1001234567', egypt, maxLength: 5);
      expect(error, 'Invalid phone number length');
    });
  });

  group('customPhoneNumberValidator', () {
    final egypt = countries.firstWhere((c) => c.code == 'EG');

    test('returns the custom validator result when it yields a String',
        () async {
      final result = await customPhoneNumberValidator(
        '123',
        egypt,
        (phone) => 'custom error',
      );
      expect(result, 'custom error');
    });

    test('returns null when the custom validator passes', () async {
      final result = await customPhoneNumberValidator(
        '1001234567',
        egypt,
        (phone) => null,
      );
      expect(result, isNull);
    });

    test('passes a PhoneNumber built from the value to the validator',
        () async {
      PhoneNumber? received;
      await customPhoneNumberValidator(
        '1001234567',
        egypt,
        (phone) {
          received = phone;
          return null;
        },
      );
      expect(received, isNotNull);
      expect(received!.countryISOCode, 'EG');
      expect(received!.number, '1001234567');
    });

    test('supports async custom validators', () async {
      final result = await customPhoneNumberValidator(
        '1',
        egypt,
        (phone) async {
          await Future<void>.delayed(Duration.zero);
          return 'async error';
        },
      );
      expect(result, 'async error');
    });
  });

  group('RemoveCountryCode.removeCountryCode', () {
    final egypt = countries.firstWhere((c) => c.code == 'EG');

    test('strips a +<dial> prefix using the selected country', () {
      final local = '+201001234567'.removeCountryCode('EG', egypt, countries);
      expect(local, '1001234567');
    });

    test('strips a bare <dial> prefix (no plus)', () {
      final local = '201001234567'.removeCountryCode('EG', egypt, countries);
      expect(local, '1001234567');
    });

    test('infers the country from a + prefix when countryCode is null', () {
      final local = '+201001234567'.removeCountryCode(null, egypt, countries);
      expect(local, '1001234567');
    });
  });
}
