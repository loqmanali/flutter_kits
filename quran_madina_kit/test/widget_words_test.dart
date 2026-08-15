import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';

import 'support/pump.dart';

/// Every rendered word span with whether it is actually visible.
List<({String text, bool visible})> wordsOf(WidgetTester tester) => tester
    .widgetList<MadinaLine>(find.byType(MadinaLine))
    .expand((l) => l.spans.cast<TextSpan>())
    .where((s) => (s.text ?? '').trim().isNotEmpty)
    .map((s) => (text: s.text!, visible: (s.style?.color?.a ?? 1) != 0))
    .toList();

String allText(WidgetTester tester) =>
    wordsOf(tester).map((w) => w.text).join(' ');

String visibleText(WidgetTester tester) =>
    wordsOf(tester).where((w) => w.visible).map((w) => w.text).join(' ');

void main() {
  setUpMadinaTests();

  testWidgets('shows only the selected words, keeping the rest in place',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 1, aya: '1', words: '1:2')),
    );
    final words = wordsOf(tester);
    expect(words.where((w) => w.visible).length, greaterThanOrEqualTo(2));
    expect(words.where((w) => !w.visible), isNotEmpty,
        reason: 'the hidden remainder must still be rendered, transparently');
  });

  testWidgets('the hidden remainder preserves the line geometry',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 1, aya: '1', words: '1:2')),
    );
    // Same width as a full render: nothing was removed, only blanked.
    expect(tester.getSize(find.byType(MadinaLine).first).width, 270);
  });

  testWidgets('a selection crossing into the next sura shows its title',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 1, aya: '7', words: '1-14')),
    );
    expect(allText(tester), contains('البقرة'),
        reason: 'the crossed-into title renders for context');
  });

  testWidgets('notitle hides the crossed-into sura name but keeps its line',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(
        sura: 1,
        aya: '7',
        words: '1-14',
        notitle: true,
      )),
    );
    final title = wordsOf(tester).where((w) => w.text.contains('البقرة'));
    expect(title, isNotEmpty,
        reason: 'the name span still exists — it sizes the line');
    expect(title.every((w) => !w.visible), isTrue, reason: 'but it is blanked');
  });

  testWidgets('a malformed words falls back to the normal verse render',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 1, aya: '1', words: '5-2')),
    );
    expect(tester.takeException(), isNull);
    expect(wordsOf(tester).every((w) => w.visible), isTrue,
        reason: 'the fallback render hides nothing');
  });

  testWidgets('the selection is capped at 500 words', (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 1, aya: '1', words: '1-9999')),
    );
    expect(tester.takeException(), isNull);
    expect(
        wordsOf(tester).where((w) => w.visible).length, lessThanOrEqualTo(600),
        reason: '500 words plus their trailing markers');
  });

  testWidgets('words is ignored on a page render', (tester) async {
    await pumpMadina(
        tester, madinaHost(const QuranMadinaView(page: 3, words: '1-3')));
    expect(wordsOf(tester).every((w) => w.visible), isTrue);
  });

  testWidgets('a fully-selected basmala collapses to the ligature',
      (tester) async {
    // Al-Baqara aya 1 anchors the walk, which rewinds to its basmala: words 1-4.
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 2, aya: '1', words: '1-4')),
    );
    expect(allText(tester), contains('﷽'));
  });

  testWidgets('a partial basmala selection renders individual words',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 2, aya: '1', words: '1-2')),
    );
    expect(allText(tester), isNot(contains('﷽')));
    expect(visibleText(tester), contains('بِسْ'),
        reason: 'the first basmala word is selected and shown');
  });

  testWidgets('an aya-1 anchor counts its own basmala first', (tester) async {
    // Word 5 of an aya-1 anchor is the aya's own first word, since the basmala
    // occupies words 1-4 (the Tanzil flat indexing consumers count against).
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 2, aya: '1', words: '5-5')),
    );
    expect(visibleText(tester).trim(), isNot(contains('بِسْ')));
    expect(visibleText(tester).trim(), isNotEmpty);
  });

  testWidgets('a single-line selection renders inline', (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 1, aya: '1', words: '1-2')),
    );
    expect(find.byType(MadinaLine), findsOneWidget);
    expect(find.byType(Column), findsNothing);
  });

  testWidgets('inline:no forces the multiline frame for one line',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(
        sura: 1,
        aya: '1',
        words: '1-2',
        inline: MadinaInline.no,
      )),
    );
    expect(find.byType(Column), findsOneWidget);
  });

  testWidgets('trims lines entirely outside the selection', (tester) async {
    // Al-Fatiha words 20+ sit well past line 2, so the earlier lines are gone.
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 1, aya: '1', words: '20-22')),
    );
    final lines = tester.widgetList<MadinaLine>(find.byType(MadinaLine));
    for (final line in lines) {
      final visibleHere = line.spans
          .cast<TextSpan>()
          .where((s) => (s.text ?? '').trim().isNotEmpty)
          .any((s) => (s.style?.color?.a ?? 1) != 0);
      expect(visibleHere, isTrue,
          reason: 'every kept line must show at least one selected word');
    }
  });

  testWidgets('a words selection with a highlight marks inside it',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(
        sura: 1,
        aya: '1',
        words: '1-4',
        highlight: '2-2',
      )),
    );
    final marked = tester
        .widgetList<MadinaLine>(find.byType(MadinaLine))
        .expand((l) => l.spans.cast<TextSpan>())
        .where((s) => s.style?.backgroundColor != null);
    expect(marked.length, 1);
  });
}
