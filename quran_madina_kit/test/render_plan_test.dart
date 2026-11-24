import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/render_plan.dart';
import 'package:quran_madina_kit/src/repository.dart';
import 'package:quran_madina_kit/src/theme.dart';

import 'support/fake_db.dart';

/// Page 1 of a toy sura. Slots: 0 blank, 1 title (L1), 2 aya1 (L2),
/// 3 aya2 (L3), 4 aya3 (L3 continuation).
Future<MadinaDb> toyDb() => buildDb([
      (
        'سورة الفاتحة',
        [
          slot(1, [(1, '')]),
          slot(1, [(1, 'سورة الفاتحة')]),
          slot(1, [(2, 'ٱلْحَمْدُ لِلَّهِ ﴿١﴾')]),
          slot(1, [(3, 'رَبِّ ٱلْعَـٰلَمِينَ ﴿٢﴾')]),
          slot(1, [(3, ' ٱلرَّحْمَـٰنِ ﴿٣﴾')]),
        ]
      ),
    ]);

void main() {
  group('word counting for mark bounds', () {
    test('counts a verse range', () async {
      final db = await toyDb();
      expect(countVerseRangeWords(db, 0, 2, 2), 2, reason: 'ٱلْحَمْدُ لِلَّهِ');
      expect(countVerseRangeWords(db, 0, 2, 4), 5);
    });

    test('skips title slots', () async {
      final db = await toyDb();
      expect(countVerseRangeWords(db, 0, 1, 2), 2,
          reason: 'the title at slot 1 contributes nothing');
    });

    test('counts a page', () async {
      final db = await toyDb();
      expect(
        countPageWords(db,
            suraFrom: 0, ayaFrom: 0, suraTo: 0, ayaTo: 4, page: 1),
        5,
      );
    });
  });

  group('planVerseOrPage — verse mode', () {
    test('plans the lines the verse occupies', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, sura: 1, aya: '1', log: (_) {})!;
      expect(plan.lines.length, 1);
      expect(plan.lines.single.line, 2);
      expect(plan.multiline, isFalse, reason: 'a single line renders inline');
    });

    test('a verse spanning two lines is multiline', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, sura: 1, aya: '1-2', log: (_) {})!;
      expect(plan.lines.map((l) => l.line).toList(), [2, 3]);
      expect(plan.multiline, isTrue);
    });

    test('carries the stored stretch per line', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, sura: 1, aya: '1-2', log: (_) {})!;
      expect(plan.lines.every((l) => l.stretch == 1), isTrue);
    });

    test('adds trailing context for a verse ending mid-line', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, sura: 1, aya: '1-2', log: (_) {})!;
      expect(plan.lines.last.trailingContext.map((p) => p.text).toList(),
          [' ٱلرَّحْمَـٰنِ ﴿٣﴾']);
    });

    test('adds leading context for a verse starting mid-line', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db,
          sura: 1, aya: '3', inline: MadinaInline.no, log: (_) {})!;
      expect(plan.lines.single.leadingContext.map((p) => p.text).toList(),
          ['رَبِّ ٱلْعَـٰلَمِينَ ﴿٢﴾']);
    });

    test('reports sura and first aya numbers for the translate link', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, sura: 1, aya: '2', log: (_) {})!;
      expect(plan.suraNumber, 1);
      expect(plan.firstAyaNumber, 2);
    });

    test('inline="no" forces the multiline layout', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db,
          sura: 1, aya: '1', inline: MadinaInline.no, log: (_) {})!;
      expect(plan.multiline, isTrue);
    });

    test('inline="yes" warns and behaves as auto', () async {
      final db = await toyDb();
      final logs = <String>[];
      final plan = planVerseOrPage(db,
          sura: 1, aya: '1-2', inline: MadinaInline.yes, log: logs.add)!;
      expect(plan.multiline, isTrue);
      expect(logs.join(), contains('not implemented yet'));
    });

    test('sura+aya wins over page and warns', () async {
      final db = await toyDb();
      final logs = <String>[];
      final plan =
          planVerseOrPage(db, page: 1, sura: 1, aya: '1', log: logs.add)!;
      expect(plan.multiline, isFalse, reason: 'planned as a verse, not a page');
      expect(logs.join(), contains('Ignoring page parameter'));
    });

    test('an aya beyond the sura returns null', () async {
      final db = await toyDb();
      expect(planVerseOrPage(db, sura: 1, aya: '99', log: (_) {}), isNull);
    });
  });

  group('planVerseOrPage — page mode', () {
    test('plans every line the page occupies and is always multiline',
        () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, page: 1, log: (_) {})!;
      expect(plan.multiline, isTrue);
      expect(plan.lines.map((l) => l.line).toList(), [1, 2, 3]);
    });

    test('a page render has no context spacers', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, page: 1, log: (_) {})!;
      expect(
        plan.lines.every(
            (l) => l.leadingContext.isEmpty && l.trailingContext.isEmpty),
        isTrue,
      );
    });

    test('flags the title line so it gets the decorative frame', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, page: 1, log: (_) {})!;
      expect(plan.lines.first.hasTitle, isTrue);
      expect(plan.lines.last.hasTitle, isFalse);
    });

    test('has no first aya number (its translate link targets the page)',
        () async {
      final db = await toyDb();
      expect(planVerseOrPage(db, page: 1, log: (_) {})!.firstAyaNumber, isNull);
    });

    test('ignores inline with a warning', () async {
      final db = await toyDb();
      final logs = <String>[];
      planVerseOrPage(db, page: 1, inline: MadinaInline.no, log: logs.add);
      expect(logs.join(), contains('Ignoring inline parameter with page'));
    });
  });

  group('planVerseOrPage — bad arguments', () {
    test('returns null and logs when neither page nor sura+aya is given',
        () async {
      final db = await toyDb();
      final logs = <String>[];
      expect(planVerseOrPage(db, log: logs.add), isNull);
      expect(logs.join(), contains('Bad arguments'));
    });

    test('returns null for a page outside the sharded page table', () async {
      // Sharded mode has an explicit 604-entry page table to bound against.
      // Monolith mode has none, so it clamps to the last aya instead — the web
      // runtime's scan loop runs off the end there and throws; clamping is the
      // safer equivalent and is exercised by the repository tests.
      final db = await buildEmptyShardedDb();
      expect(planVerseOrPage(db, page: 9999, log: (_) {}), isNull);
    });

    test('returns null for a malformed aya', () async {
      final db = await toyDb();
      expect(planVerseOrPage(db, sura: 1, aya: 'abc', log: (_) {}), isNull);
    });
  });
}
