import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization_kit/localization_kit.dart';

void main() {
  group('LanguageState defaults', () {
    test('has English defaults and no error / loading', () {
      const state = LanguageState();

      expect(state.languages, isEmpty);
      expect(state.locale, const Locale('en'));
      expect(state.apiCode, 'en_US');
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });
  });

  group('LanguageState RTL / language helpers', () {
    test('isEnglish + LTR for an English locale', () {
      const state = LanguageState(locale: Locale('en'));

      expect(state.isEnglish, isTrue);
      expect(state.isArabic, isFalse);
      expect(state.textDirection, TextDirection.ltr);
    });

    test('isArabic + RTL for an Arabic locale', () {
      const state = LanguageState(locale: Locale('ar'), apiCode: 'ar_EG');

      expect(state.isArabic, isTrue);
      expect(state.isEnglish, isFalse);
      expect(state.textDirection, TextDirection.rtl);
    });
  });

  group('LanguageState.copyWith', () {
    const base = LanguageState(
      locale: Locale('en'),
      apiCode: 'en_US',
      errorMessage: 'boom',
    );

    test('overrides only the provided fields', () {
      final next = base.copyWith(
        locale: const Locale('ar'),
        apiCode: 'ar_EG',
        isLoading: true,
      );

      expect(next.locale, const Locale('ar'));
      expect(next.apiCode, 'ar_EG');
      expect(next.isLoading, isTrue);
      // Untouched field is preserved.
      expect(next.errorMessage, 'boom');
    });

    test('preserves existing errorMessage when not passed', () {
      final next = base.copyWith(isLoading: true);
      expect(next.errorMessage, 'boom');
    });

    test('clearError wins over an explicit errorMessage value', () {
      final cleared = base.copyWith(
        errorMessage: 'ignored',
        clearError: true,
      );
      expect(cleared.errorMessage, isNull);
    });

    test('equality only tracks the languageCode of the locale, not country',
        () {
      // props uses locale.languageCode (not the full Locale), so two states
      // that differ only by country code compare equal.
      const a = LanguageState(locale: Locale('en'));
      const b = LanguageState(locale: Locale('en', 'US'));

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('states with different apiCode are not equal', () {
      const a = LanguageState(apiCode: 'en_US');
      const b = LanguageState(apiCode: 'en_GB');
      expect(a, isNot(b));
    });
  });
}
