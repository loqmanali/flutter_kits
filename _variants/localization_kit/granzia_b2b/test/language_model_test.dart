import 'package:flutter_test/flutter_test.dart';
import 'package:localization_kit/localization_kit.dart';

void main() {
  group('LanguageModel', () {
    const en = LanguageModel(code: 'en_US', name: 'English', isoCode: 'en');

    test('fromJson maps iso_code key to isoCode', () {
      final model = LanguageModel.fromJson(const {
        'code': 'ar_EG',
        'name': 'العربية',
        'iso_code': 'ar',
      });

      expect(model.code, 'ar_EG');
      expect(model.name, 'العربية');
      expect(model.isoCode, 'ar');
    });

    test('toJson emits iso_code key (round-trips through fromJson)', () {
      final json = en.toJson();

      expect(json, {
        'code': 'en_US',
        'name': 'English',
        'iso_code': 'en',
      });

      // Round-trip equality via Equatable.
      expect(LanguageModel.fromJson(json), en);
    });

    test('fromJsonList parses a list of language maps', () {
      final list = LanguageModel.fromJsonList(const [
        {'code': 'en_US', 'name': 'English', 'iso_code': 'en'},
        {'code': 'ar_EG', 'name': 'العربية', 'iso_code': 'ar'},
      ]);

      expect(list, hasLength(2));
      expect(list.first, en);
      expect(list[1].isoCode, 'ar');
    });

    test('equality is value-based over code, name and isoCode', () {
      const same = LanguageModel(code: 'en_US', name: 'English', isoCode: 'en');
      const differentCode =
          LanguageModel(code: 'en_GB', name: 'English', isoCode: 'en');

      expect(en, same);
      expect(en.hashCode, same.hashCode);
      expect(en, isNot(differentCode));
      expect(en.props, ['en_US', 'English', 'en']);
    });
  });
}
