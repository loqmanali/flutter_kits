import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/models.dart';
import 'package:quran_madina_kit/src/ranges.dart';

RenderPart part(String t) => RenderPart(line: 1, text: t, stretch: 1);

void main() {
  group('isWordToken', () {
    test('accepts ordinary Arabic words', () {
      expect(isWordToken('بِسْمِ'), isTrue);
      expect(isWordToken('ٱلْحَمْدُ'), isTrue,
          reason: 'alef-wasla is in U+0671..U+06D3');
    });

    test('rejects aya-number ornaments', () {
      expect(isWordToken('﴿١﴾'), isFalse,
          reason: 'Hafs/Uthman/me_quran marker');
      expect(isWordToken('۝١'), isFalse, reason: 'Amiri marker');
    });

    test('rejects waqf and page ornaments', () {
      for (final m in ['ۖ', 'ۗ', 'ۘ', 'ۙ', 'ۚ', 'ۛ', 'ۜ', '۞', '۩']) {
        expect(isWordToken(m), isFalse,
            reason: 'ornament $m must not be countable');
      }
    });

    test('rejects the basmala ligature', () {
      expect(isWordToken(kBasmalaLigature), isFalse);
    });
  });

  group('slot predicates', () {
    test('basmala lives at slot 1 of every sura except Al-Fatiha', () {
      expect(isBasmalaSlot(1, 1), isTrue, reason: 'Al-Baqara');
      expect(isBasmalaSlot(0, 1), isFalse,
          reason: "Al-Fatiha's slot 1 is its title");
      expect(isBasmalaSlot(1, 0), isFalse, reason: 'slot 0 is the title');
      expect(isBasmalaSlot(8, 1), isTrue,
          reason: "At-Tawba's slot exists but renders blank");
    });

    test('titles never count as words', () {
      expect(isCountableAya(1, 0), isFalse, reason: 'title slot');
      expect(isCountableAya(1, 1), isTrue, reason: 'basmala counts');
      expect(isCountableAya(0, 1), isFalse,
          reason: "Al-Fatiha's title sits at slot 1");
      expect(isCountableAya(0, 2), isTrue,
          reason: "Al-Fatiha's basmala is real aya 1");
    });
  });

  group('counting', () {
    test('counts only letter-bearing tokens', () {
      expect(countPartWords(part('ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ ﴿٢﴾')),
          4);
    });

    test('an empty decoration slot counts zero', () {
      expect(countPartWords(part('')), 0);
    });

    test('sums across an aya split over lines', () {
      final aya = Aya(page: 1, parts: [
        part(' ٱهْدِنَا'),
        part('ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ ﴿٦﴾'),
      ]);
      expect(countAyaWords(aya), 3);
    });
  });

  group('parseSura', () {
    test('is 1-based on the wire, 0-based internally', () {
      expect(parseSura('1'), 0);
      expect(parseSura('114'), 113);
    });

    test('takes the first element of a range', () {
      expect(parseSura('2-3'), 1);
    });

    test('rejects garbage', () {
      expect(parseSura('abc'), isNull);
    });
  });

  group('parseAyaRange', () {
    test('adds the 2 decoration slots (offset +1)', () {
      expect(parseAyaRange('255'), (from: 256, to: 256));
      expect(parseAyaRange('1-3'), (from: 2, to: 4));
    });

    test('rejects garbage', () {
      expect(parseAyaRange('x'), isNull);
    });
  });

  group('parseWordsRange', () {
    test('a single index becomes a one-word range', () {
      expect(parseWordsRange('5'), const WordRange(5, 5));
    });

    test('accepts both separators', () {
      expect(parseWordsRange('3-10'), const WordRange(3, 10));
      expect(parseWordsRange('3:10'), const WordRange(3, 10));
    });

    test('rejects zero, negative, reversed and malformed', () {
      expect(parseWordsRange('0'), isNull);
      expect(parseWordsRange('0-4'), isNull);
      expect(parseWordsRange('10-3'), isNull,
          reason: 'start must not exceed end');
      expect(parseWordsRange('a-b'), isNull);
      expect(parseWordsRange('1-2-3'), isNull);
      expect(parseWordsRange(null), isNull);
    });
  });

  group('WordRange.capped', () {
    test('leaves a short range alone', () {
      expect(const WordRange(1, 10).capped, const WordRange(1, 10));
    });

    test('caps an over-long range at 500 words', () {
      expect(const WordRange(1, 9999).capped, const WordRange(1, 500));
      expect(const WordRange(10, 9999).capped, const WordRange(10, 509));
    });
  });

  group('clampedOrNull', () {
    test('passes an in-bounds range through', () {
      final logs = <String>[];
      expect(clampedOrNull('highlight', const WordRange(2, 3), 1, 9, logs.add),
          const WordRange(2, 3));
      expect(logs, isEmpty);
    });

    test('drops an out-of-bounds range with a warning instead of throwing', () {
      final logs = <String>[];
      expect(clampedOrNull('error', const WordRange(2, 30), 1, 9, logs.add),
          isNull);
      expect(logs.single, contains('outside displayed words 1-9'));
    });

    test('a null range stays null and logs nothing', () {
      final logs = <String>[];
      expect(clampedOrNull('highlight', null, 1, 9, logs.add), isNull);
      expect(logs, isEmpty);
    });
  });
}
