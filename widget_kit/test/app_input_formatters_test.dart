import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/widget_kit.dart';

void main() {
  group('InputFormatterMessages', () {
    test('resolves Arabic locale variants', () {
      expect(
        InputFormatterMessages.fromLanguageCode('ar_EG'),
        same(InputFormatterMessages.arabic),
      );
      expect(
        InputFormatterMessages.fromLanguageCode('ar-SA'),
        same(InputFormatterMessages.arabic),
      );
    });

    test('falls back to English for other locales', () {
      expect(
        InputFormatterMessages.fromLanguageCode('en_US'),
        same(InputFormatterMessages.english),
      );
      expect(
        InputFormatterMessages.fromLanguageCode('fr'),
        same(InputFormatterMessages.english),
      );
    });
  });

  group('AppInputFormatters localization', () {
    test('uses Arabic preset', () {
      String? error;
      final formatter = AppInputFormatters.numbersOnly(
        messages: InputFormatterMessages.arabic,
        onError: (message) => error = message,
      ).single;

      formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'a'),
      );

      expect(error, InputFormatterMessages.arabic.numbersOnly);
    });

    test('uses custom project-independent messages', () {
      String? error;
      const messages = InputFormatterMessages(
        lettersAndSpacesOnly: 'letters',
        arabicLettersOnly: 'arabic',
        englishLettersOnly: 'english',
        numbersOnly: 'custom numbers',
        numbersAndDecimalOnly: 'decimal',
        invalidPhoneFormat: 'phone',
        invalidEmailFormat: 'email',
        emailCannotStartWithNumber: 'email start',
        spacesNotAllowed: 'spaces',
        specialCharsNotAllowed: 'special',
        alphanumericWithUnderscoreAndDash: 'username',
        dateFormat: 'date',
        maxLengthExceeded: _customMaxLength,
        invalidNationalAddress: 'national address',
      );
      final formatter = AppInputFormatters.numbersOnly(
        messages: messages,
        onError: (message) => error = message,
      ).single;

      formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'x'),
      );

      expect(error, 'custom numbers');
    });
  });
}

String _customMaxLength(int maxLength) => 'max $maxLength';
