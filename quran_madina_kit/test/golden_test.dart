import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';

import 'support/pump.dart';

/// An opaque frame that hugs its content, so a golden never has to guess a
/// height that fits (fonts differ wildly: me_quran uses a doubled line box).
Widget goldenFrame(Widget child, {double width = 320, double? height}) =>
    Center(
      child: RepaintBoundary(
        child: Container(
          width: width,
          height: height,
          color: const Color(0xFFFDFBF3),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    );

void main() {
  setUpMadinaTests();

  testWidgets('page 1 — Al-Fatiha', (tester) async {
    await pumpMadina(
      tester,
      madinaHost(goldenFrame(const QuranMadinaView(page: 1, headless: true))),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/page-001-hafs-16.png'),
    );
  });

  testWidgets('page 106 — the README reference page', (tester) async {
    await pumpMadina(
      tester,
      madinaHost(goldenFrame(
        const QuranMadinaView(page: 106, headless: true),
      )),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/page-106-hafs-16.png'),
    );
  });

  testWidgets('a verse range', (tester) async {
    await pumpMadina(
      tester,
      madinaHost(goldenFrame(
        const QuranMadinaView(sura: 2, aya: '8-10'),
      )),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/verse-002-008-010.png'),
    );
  });

  testWidgets('a words selection spanning into the next sura', (tester) async {
    await pumpMadina(
      tester,
      madinaHost(goldenFrame(
        const QuranMadinaView(sura: 1, aya: '7', words: '1-14'),
      )),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/words-001-007-1-14.png'),
    );
  });

  testWidgets('Amiri Quran Colored — tajweed colouring', (tester) async {
    await pumpMadina(
      tester,
      madinaHost(
        goldenFrame(const QuranMadinaView(page: 3, headless: true), width: 340),
        config: const MadinaConfig(font: 'Amiri Quran Colored', fontSize: 16),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/page-003-amiri-colored-16.png'),
    );
  });

  testWidgets('me_quran — its own frame width and doubled line box',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(
        goldenFrame(const QuranMadinaView(page: 3, headless: true), width: 380),
        config: const MadinaConfig(font: 'me_quran', fontSize: 16),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/page-003-me_quran-16.png'),
    );
  });

  testWidgets('highlight and error marks', (tester) async {
    await pumpMadina(
      tester,
      madinaHost(goldenFrame(
        const QuranMadinaView(sura: 1, aya: '1', highlight: '2-3', error: '4'),
      )),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/marks-001-001.png'),
    );
  });
}
