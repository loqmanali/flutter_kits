import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';

import 'support/pump.dart';

/// Every rendered span's text, in order.
List<String> textsOf(WidgetTester tester) => tester
    .widgetList<MadinaLine>(find.byType(MadinaLine))
    .expand((l) => l.spans.cast<TextSpan>())
    .map((s) => s.text ?? '')
    .toList();

void main() {
  setUpMadinaTests();

  testWidgets('renders Al-Fatiha aya 1 from the bundled DB', (tester) async {
    await pumpMadina(
        tester, madinaHost(const QuranMadinaView(sura: 1, aya: '1')));
    expect(find.byType(MadinaLine), findsOneWidget);
    expect(textsOf(tester).join(), contains('بِسْمِ'));
  });

  testWidgets('a single-line verse renders inline (no frame column)',
      (tester) async {
    await pumpMadina(
        tester, madinaHost(const QuranMadinaView(sura: 1, aya: '1')));
    expect(find.byType(MadinaLine), findsOneWidget);
    expect(find.byType(Column), findsNothing);
  });

  testWidgets('a multi-line verse range renders as a column', (tester) async {
    await pumpMadina(
        tester, madinaHost(const QuranMadinaView(sura: 1, aya: '1-3')));
    expect(find.byType(MadinaLine), findsNWidgets(3));
    expect(find.byType(Column), findsOneWidget);
  });

  testWidgets('renders page 1 with its title, basmala and aya lines',
      (tester) async {
    await pumpMadina(tester, madinaHost(const QuranMadinaView(page: 1)));
    final texts = textsOf(tester);
    expect(find.byType(MadinaLine), findsNWidgets(8),
        reason: 'pages 1-2 are the decorative half-pages: 8 lines, not 15');
    expect(texts.join(), contains('سورة الفاتحة'));
    expect(texts, isNot(contains('﷽')),
        reason: "Al-Fatiha's basmala is real aya 1, so it renders as numbered "
            'text, not as the ornamental ligature');
    // Structural, not a byte-for-byte string match: the DB's Arabic carries
    // diacritics and joining forms that are easy to mistype in a test literal.
    expect(texts.any((t) => t.contains('﴿١﴾')), isTrue,
        reason: "its basmala is numbered aya 1");
  });

  testWidgets('a full page shows a normal sura\'s basmala as the ligature',
      (tester) async {
    await pumpMadina(tester, madinaHost(const QuranMadinaView(page: 2)));
    expect(textsOf(tester), contains('﷽'),
        reason: "Al-Baqara's basmala is a decoration slot, not a numbered aya");
  });

  testWidgets('page 3 renders the full 15 lines', (tester) async {
    // Pages 1-2 are the decorative half-pages; the full grid starts at page 3.
    await pumpMadina(tester, madinaHost(const QuranMadinaView(page: 3)));
    expect(find.byType(MadinaLine), findsNWidgets(15));
  });

  testWidgets('a page render lays lines out at the DB line width',
      (tester) async {
    await pumpMadina(tester, madinaHost(const QuranMadinaView(page: 1)));
    expect(tester.getSize(find.byType(MadinaLine).first).width, 270);
  });

  testWidgets('shows the loading widget while booting', (tester) async {
    await tester.pumpWidget(madinaHost(const QuranMadinaView(
      sura: 1,
      aya: '1',
      loading: Text('...'),
    )));
    expect(find.text('...'), findsOneWidget);
    await settleMadina(tester);
    expect(find.text('...'), findsNothing);
    expect(find.byType(MadinaLine), findsOneWidget);
  });

  testWidgets('bad arguments render nothing and do not throw', (tester) async {
    await pumpMadina(tester, madinaHost(const QuranMadinaView()));
    expect(tester.takeException(), isNull);
    expect(find.byType(MadinaLine), findsNothing);
  });

  testWidgets('an out-of-range page renders nothing and does not throw',
      (tester) async {
    await pumpMadina(tester, madinaHost(const QuranMadinaView(page: 9999)));
    expect(tester.takeException(), isNull);
    expect(find.byType(MadinaLine), findsNothing);
  });

  testWidgets('re-renders when the aya changes', (tester) async {
    await pumpMadina(
        tester, madinaHost(const QuranMadinaView(sura: 1, aya: '1')));
    expect(find.byType(MadinaLine), findsOneWidget);

    await tester
        .pumpWidget(madinaHost(const QuranMadinaView(sura: 1, aya: '1-3')));
    await settleMadina(tester);
    expect(find.byType(MadinaLine), findsNWidgets(3));
  });

  testWidgets('a verse starting mid-line gets invisible leading context',
      (tester) async {
    // Al-Fatiha aya 4 shares line 4 with aya 3.
    await pumpMadina(
      tester,
      madinaHost(
          const QuranMadinaView(sura: 1, aya: '4', inline: MadinaInline.no)),
    );
    final spans = tester
        .widget<MadinaLine>(find.byType(MadinaLine).first)
        .spans
        .cast<TextSpan>();
    expect(spans.any((s) => (s.style?.color?.a ?? 1) == 0), isTrue,
        reason: 'the preceding page text is rendered transparently');
  });

  testWidgets('loads a juz shard lazily for a late page', (tester) async {
    // Page 300 lives well past juz 1, so this exercises on-demand shard loading.
    await pumpMadina(tester, madinaHost(const QuranMadinaView(page: 300)));
    expect(find.byType(MadinaLine), findsNWidgets(15));
    expect(tester.takeException(), isNull);
  });
}
