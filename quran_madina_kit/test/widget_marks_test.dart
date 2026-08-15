import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';

import 'support/pump.dart';

List<TextSpan> spansOf(WidgetTester tester) => tester
    .widgetList<MadinaLine>(find.byType(MadinaLine))
    .expand((l) => l.spans.cast<TextSpan>())
    .where((s) => (s.text ?? '').trim().isNotEmpty)
    .toList();

Iterable<TextSpan> markedIn(WidgetTester tester) =>
    spansOf(tester).where((s) => s.style?.backgroundColor != null);

void main() {
  setUpMadinaTests();

  testWidgets('marks words on a plain verse render with no words=',
      (tester) async {
    await pumpMadina(tester,
        madinaHost(const QuranMadinaView(sura: 1, aya: '1', highlight: '2-3')));
    expect(markedIn(tester).length, greaterThanOrEqualTo(2));
  });

  testWidgets('marks words on a full page render', (tester) async {
    await pumpMadina(
        tester, madinaHost(const QuranMadinaView(page: 3, highlight: '1-2')));
    expect(markedIn(tester), isNotEmpty);
  });

  testWidgets('error wins over highlight on overlap', (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(
          sura: 1, aya: '1', highlight: '1-4', error: '2-2')),
    );
    final colours =
        markedIn(tester).map((s) => s.style!.backgroundColor!).toSet();
    expect(colours, contains(MadinaTheme.light().error));
    expect(colours, contains(MadinaTheme.light().highlight));
  });

  testWidgets('an out-of-bounds mark is dropped, not fatal', (tester) async {
    await pumpMadina(
        tester,
        madinaHost(
            const QuranMadinaView(sura: 1, aya: '1', highlight: '50-60')));
    expect(tester.takeException(), isNull);
    expect(markedIn(tester), isEmpty);
  });

  testWidgets('a malformed mark is dropped, not fatal', (tester) async {
    await pumpMadina(tester,
        madinaHost(const QuranMadinaView(sura: 1, aya: '1', error: 'abc')));
    expect(tester.takeException(), isNull);
    expect(find.byType(MadinaLine), findsOneWidget);
  });

  testWidgets('an unmarked verse keeps its single plain span per part',
      (tester) async {
    await pumpMadina(
        tester, madinaHost(const QuranMadinaView(sura: 1, aya: '1')));
    expect(spansOf(tester).length, 1,
        reason: 'no marks: the whole part stays one blob, as on the web');
  });

  testWidgets('light ambient text picks the dark mark pair', (tester) async {
    await pumpMadina(
      tester,
      madinaHost(
        const QuranMadinaView(sura: 1, aya: '1', highlight: '2-2'),
        textColour: const Color(0xFFFFFFFF),
      ),
    );
    expect(markedIn(tester).first.style!.backgroundColor,
        MadinaTheme.dark().highlight);
  });

  // A verse render never contains a basmala — it is a decoration slot before
  // the sura's real ayas. Page 2 opens Al-Baqara, so its words 1-4 ARE the
  // basmala (the title above it is never counted).
  testWidgets('a mark cutting into part of the basmala forces its tokens',
      (tester) async {
    await pumpMadina(
        tester, madinaHost(const QuranMadinaView(page: 2, highlight: '2-3')));
    final texts = spansOf(tester).map((s) => s.text).join(' ');
    expect(texts, isNot(contains('﷽')),
        reason: 'a partial mark must be visible, so the 4 tokens render');
    expect(markedIn(tester).length, 2);
  });

  testWidgets('a mark covering the whole basmala keeps the ligature',
      (tester) async {
    await pumpMadina(
        tester, madinaHost(const QuranMadinaView(page: 2, highlight: '1-4')));
    final lig = spansOf(tester).where((s) => s.text == '﷽');
    expect(lig, isNotEmpty);
    expect(lig.single.style?.backgroundColor, isNotNull);
  });

  testWidgets('a mark past the basmala still lands on the right word',
      (tester) async {
    // Words 1-4 are the basmala, so word 5 is the sura's first real word.
    await pumpMadina(
        tester, madinaHost(const QuranMadinaView(page: 2, highlight: '5-5')));
    expect(spansOf(tester).map((s) => s.text), contains('﷽'),
        reason: 'the untouched basmala still collapses to the ligature');
    // 2 spans, not 1: the aya-end marker trails word 5 and inherits its mark,
    // the same rule the web runtime applies.
    expect(markedIn(tester).length, 2);
    expect(markedIn(tester).map((s) => s.text), isNot(contains('﷽')));
  });

  testWidgets('marks never add padding that would distort the line',
      (tester) async {
    await pumpMadina(tester,
        madinaHost(const QuranMadinaView(sura: 1, aya: '1', highlight: '2-3')));
    // Width is still exactly the DB's line width: a mark paints background
    // only, never a box that would change the pre-computed justification.
    expect(tester.getSize(find.byType(MadinaLine).first).width, 270);
  });
}
