import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';

import 'support/pump.dart';

void main() {
  setUpMadinaTests();

  group('translateUri', () {
    test('a verse deep-links to the aya', () {
      expect(translateUri(sura: 2, aya: 255).toString(),
          'https://quran.com/2/255');
    });

    test('a page deep-links to the page', () {
      expect(translateUri(page: 106).toString(), 'https://quran.com/page/106');
    });
  });

  testWidgets('the header translate action runs the configured handler',
      (tester) async {
    Uri? opened;
    await pumpMadina(
      tester,
      madinaHost(
        const QuranMadinaView(sura: 2, aya: '8-10'),
        config: MadinaConfig(
          font: 'Hafs',
          fontSize: 16,
          onTranslate: (context, url) async => opened = url,
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.translate_rounded));
    await tester.pump();

    expect(opened, isNotNull, reason: 'the host app decides how to show it');
    expect(opened.toString(), startsWith('https://quran.com/2/'));
  });

  testWidgets('a page render translates to the page, not an aya',
      (tester) async {
    Uri? opened;
    await pumpMadina(
      tester,
      madinaHost(
        const QuranMadinaView(page: 106),
        config: MadinaConfig(
          font: 'Hafs',
          fontSize: 16,
          onTranslate: (context, url) async => opened = url,
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.translate_rounded));
    await tester.pump();
    expect(opened.toString(), 'https://quran.com/page/106');
  });

  testWidgets(
      'with no handler it pushes the in-app page — never leaves the app',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 2, aya: '8-10')),
    );
    await tester.tap(find.byIcon(Icons.translate_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(MadinaWebPage), findsOneWidget,
        reason: 'the default must stay inside the app');
  });

  testWidgets('the in-app page can be dismissed back to the Mushaf',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(const QuranMadinaView(sura: 2, aya: '8-10')),
    );
    await tester.tap(find.byIcon(Icons.translate_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(MadinaWebPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(MadinaWebPage), findsNothing);
    expect(find.byType(MadinaLine), findsWidgets);
  });

  testWidgets('a platform with no webview still offers the link',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MadinaWebPage(url: Uri.parse('https://quran.com/2/255')),
    ));
    await tester.pumpAndSettle();
    // Either the webview built, or the fallback did — never a crash, and the
    // URL is always reachable through the copy action.
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.link_rounded), findsOneWidget);
  });
}
