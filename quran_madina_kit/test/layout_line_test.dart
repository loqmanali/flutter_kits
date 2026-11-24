import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/layout.dart';
import 'package:quran_madina_kit/src/models.dart';
import 'package:quran_madina_kit/src/repository.dart';

import 'support/fake_db.dart';

/// Line 4 of page 1 holds ayas 0..3 in reading order.
Future<MadinaDb> fourOnOneLine() => buildDb([
      (
        'س',
        [
          slot(1, [(4, 'واحد')]),
          slot(1, [(4, 'اثنان')]),
          slot(1, [(4, 'ثلاثة')]),
          slot(1, [(4, 'أربعة')]),
        ]
      )
    ]);

void main() {
  group('partOnLine', () {
    test('finds the part sitting on the given line', () {
      const aya = Aya(page: 1, parts: [
        RenderPart(line: 5, text: 'أ', stretch: 1),
        RenderPart(line: 6, text: 'ب', stretch: 1),
      ]);
      expect(partOnLine(aya, 6)!.text, 'ب');
    });

    test('returns null when the aya does not touch the line', () {
      const aya =
          Aya(page: 1, parts: [RenderPart(line: 5, text: 'أ', stretch: 1)]);
      expect(partOnLine(aya, 7), isNull);
    });
  });

  group('isLineStartPart', () {
    test('slot 0 is always a line start', () async {
      final db = await buildDb([
        (
          'س',
          [
            slot(1, [(1, 'عنوان')])
          ]
        )
      ]);
      expect(isLineStartPart(db, 0, 0, 1), isTrue);
    });

    test('true when the previous aya has no part on this line', () async {
      final db = await buildDb([
        (
          'س',
          [
            slot(1, [(1, 'أ')]),
            slot(1, [(2, 'ب')]),
          ]
        )
      ]);
      expect(isLineStartPart(db, 0, 1, 2), isTrue);
    });

    test('false when the previous aya also sits on this line', () async {
      final db = await buildDb([
        (
          'س',
          [
            slot(1, [(1, 'أ')]),
            slot(1, [(1, 'ب')]),
          ]
        )
      ]);
      expect(isLineStartPart(db, 0, 1, 1), isFalse,
          reason: 'aya 1 continues the line aya 0 started');
    });

    test('true when the previous aya is on another page', () async {
      final db = await buildDb([
        (
          'س',
          [
            slot(1, [(15, 'أ')]),
            slot(2, [(1, 'ب')]),
          ]
        )
      ]);
      expect(isLineStartPart(db, 0, 1, 1), isTrue);
    });

    test('true when the previous aya is not loaded (shard boundary)', () async {
      final db = await buildEmptyShardedDb();
      expect(isLineStartPart(db, 0, 3, 1), isTrue);
    });
  });

  group('lineContext', () {
    test('direction -1 collects the preceding text in reading order', () async {
      final db = await fourOnOneLine();
      final parts = lineContext(db,
          sura0: 0, page: 1, line: 4, ayaIndex: 2, direction: -1);
      expect(parts.map((p) => p.text).toList(), ['واحد', 'اثنان'],
          reason: 'walked back to the line start, kept reading order');
    });

    test('direction +1 collects the following text', () async {
      final db = await fourOnOneLine();
      final parts = lineContext(db,
          sura0: 0, page: 1, line: 4, ayaIndex: 1, direction: 1);
      expect(parts.map((p) => p.text).toList(), ['ثلاثة', 'أربعة']);
    });

    test('an aya that already starts the line has no preceding context',
        () async {
      final db = await fourOnOneLine();
      final parts = lineContext(db,
          sura0: 0, page: 1, line: 4, ayaIndex: 0, direction: -1);
      expect(parts, isEmpty);
    });

    test('stops at a page change', () async {
      final db = await buildDb([
        (
          'س',
          [
            slot(1, [(4, 'قديم')]),
            slot(2, [(4, 'جديد')]),
          ]
        )
      ]);
      expect(
        lineContext(db, sura0: 0, page: 2, line: 4, ayaIndex: 1, direction: -1),
        isEmpty,
      );
    });

    test('stops when the neighbour has no part on this line', () async {
      final db = await buildDb([
        (
          'س',
          [
            slot(1, [(3, 'سطر آخر')]),
            slot(1, [(4, 'هنا')]),
          ]
        )
      ]);
      expect(
        lineContext(db, sura0: 0, page: 1, line: 4, ayaIndex: 1, direction: -1),
        isEmpty,
      );
    });

    test('stops at an unloaded aya instead of throwing', () async {
      final db = await buildEmptyShardedDb();
      expect(
        lineContext(db, sura0: 0, page: 1, line: 1, ayaIndex: 3, direction: -1),
        isEmpty,
      );
    });
  });
}
