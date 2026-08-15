import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/layout.dart';
import 'package:quran_madina_kit/src/ranges.dart';
import 'package:quran_madina_kit/src/repository.dart';

import 'support/fake_db.dart';

/// Al-Fatiha (blank slot 0, title at slot 1, basmala is real aya 1 at slot 2)
/// followed by a normal sura: title at slot 0, 4-word basmala at slot 1.
Future<MadinaDb> fatihaThenBaqara() => buildDb([
      (
        'سورة الفاتحة',
        [
          slot(1, [(1, '')]),
          slot(1, [(1, 'سورة الفاتحة')]),
          slot(1, [(2, 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ ﴿١﴾')]),
          slot(1, [(3, 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ ﴿٢﴾')]),
        ]
      ),
      (
        'سورة البقرة',
        [
          slot(2, [(1, 'سورة البقرة')]),
          slot(2, [(2, 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ')]),
          slot(2, [(3, 'الٓمٓ ﴿١﴾')]),
          slot(2, [(4, 'ذَٰلِكَ ٱلْكِتَـٰبُ ﴿٢﴾')]),
        ]
      ),
    ]);

List<String> textsOf(CollectedWords c) =>
    c.lines.expand((l) => l.parts.map((p) => p.part.text)).toList();

void main() {
  group('basic collection', () {
    test('groups parts into visual lines keyed by page:line', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 2, range: const WordRange(1, 4));
      expect(c.lines.first.key, '1:2');
      expect(c.lines.first.page, 1);
      expect(c.lines.first.line, 2);
      expect(c.counterStart, 0);
    });

    test('skips blank decoration placeholders', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 0, range: const WordRange(1, 2));
      expect(textsOf(c), isNot(contains('')),
          reason: "Al-Fatiha's blank slot 0 must not become an empty line");
    });

    test('a leading title-only line is trimmed away', () async {
      final db = await fatihaThenBaqara();
      // Anchored on Al-Fatiha's title (slot 1). The title counts 0 words, so
      // its line ends at word 0 — entirely before the selection — and the trim
      // drops it, exactly as the web runtime does.
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 1, range: const WordRange(1, 4));
      expect(c.lines.first.key, '1:2');
      expect(textsOf(c), isNot(contains('سورة الفاتحة')));
    });

    test('carries the line stretch through', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 2, range: const WordRange(1, 4));
      expect(c.lines.first.stretch, 1);
    });
  });

  group('anchor rewind', () {
    test("anchoring at a normal sura's aya 1 rewinds to its basmala", () async {
      final db = await fatihaThenBaqara();
      // suraStart 1, ayaStart 2 == Al-Baqara aya 1 -> must begin at slot 1.
      final c = collectWordParts(db,
          suraStart: 1, ayaStart: 2, range: const WordRange(1, 4));
      expect(textsOf(c).first, contains('بِسْمِ'),
          reason: 'word 1 of an aya-1 anchor is بسم, matching Tanzil indexing');
    });

    test('Al-Fatiha is exempt from the rewind (its slot 1 is a title)',
        () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 2, range: const WordRange(1, 1));
      expect(textsOf(c).first, contains('بِسْمِ'));
      expect(textsOf(c), isNot(contains('سورة الفاتحة')),
          reason: 'no rewind, so the title is never entered');
    });

    test('anchoring past aya 1 does not rewind', () async {
      final db = await fatihaThenBaqara();
      // Slot 3 is Al-Baqara aya 2; only ayaStart == 2 triggers the rewind.
      final c = collectWordParts(db,
          suraStart: 1, ayaStart: 3, range: const WordRange(1, 1));
      expect(textsOf(c).first, contains('ذَٰلِكَ'));
      expect(textsOf(c),
          isNot(contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ')));
    });
  });

  group('crossing suras', () {
    test('crosses into the next sura and counts its basmala as 4 words',
        () async {
      final db = await fatihaThenBaqara();
      // Al-Fatiha aya 2 has 4 words; then Al-Baqara title (0) + basmala (4)
      // + الٓمٓ (1) -> word 9 lands on الٓمٓ.
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 3, range: const WordRange(1, 9));
      final texts = textsOf(c);
      expect(texts, contains('سورة البقرة'),
          reason: 'the crossed-into title renders for context');
      expect(texts.any((t) => t.contains('الٓمٓ')), isTrue);
    });

    test("a crossed-into sura's title is collected but not counted", () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 3, range: const WordRange(1, 9));
      final title = c.lines
          .expand((l) => l.parts)
          .firstWhere((p) => p.part.text == 'سورة البقرة');
      expect(title.countable, isFalse);
    });

    test('a crossed-into basmala IS counted', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 3, range: const WordRange(1, 9));
      final basmala = c.lines
          .expand((l) => l.parts)
          .firstWhere((p) => p.sura == 1 && p.ayaIndex == 1);
      expect(basmala.countable, isTrue);
    });
  });

  group('wrap-around', () {
    test('past the last sura the walk wraps to the first', () async {
      final db = await fatihaThenBaqara();
      // Anchored near the end of the LAST sura, the remaining words must come
      // from the first sura.
      final c = collectWordParts(db,
          suraStart: 1, ayaStart: 3, range: const WordRange(1, 6));
      expect(c.lines.any((l) => l.parts.any((p) => p.sura == 0)), isTrue,
          reason: 'the walk wrapped back to sura 0');
    });
  });

  group('trimming', () {
    test('drops leading lines entirely before the selection', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 2, range: const WordRange(5, 8));
      expect(c.lines.first.key, '1:3',
          reason: 'line 1:2 holds words 1-4, all outside the selection');
      expect(c.counterStart, 4, reason: 'the 4 skipped words are carried over');
    });

    test('drops trailing lines entirely after the selection', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 2, range: const WordRange(1, 2));
      expect(c.lines.length, 1);
      expect(c.lines.single.key, '1:2');
    });

    test('annotates each line with the running word index it ends at',
        () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 2, range: const WordRange(1, 8));
      expect(c.lines.first.lastWord, 4);
      expect(c.lines.last.lastWord, 8);
    });
  });

  group('shard boundaries', () {
    test('stops collecting at an unloaded aya', () async {
      final db = await buildEmptyShardedDb();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 0, range: const WordRange(1, 5));
      expect(c.lines, isEmpty,
          reason: 'nothing loaded: collect nothing, do not throw');
      expect(c.counterStart, 0);
    });
  });
}
