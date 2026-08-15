import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';

import 'support/pump.dart';

/// Side-by-side goldens of the two stretch modes, so the justification
/// difference is judged by eye rather than by argument.
void main() {
  setUpMadinaTests();

  for (final font in ['Uthman', 'Hafs']) {
    for (final mode in MadinaStretchMode.values) {
      testWidgets('$font page 106 — ${mode.name}', (tester) async {
        await pumpMadina(
          tester,
          madinaHost(
            Center(
              child: RepaintBoundary(
                child: Container(
                  color: const Color(0xFFFDFBF3),
                  padding: const EdgeInsets.all(6),
                  child: const QuranMadinaView(page: 106, headless: true),
                ),
              ),
            ),
            config: MadinaConfig(font: font, fontSize: 16, stretchMode: mode),
          ),
        );
        await expectLater(
          find.byType(RepaintBoundary).first,
          matchesGoldenFile('goldens/stretch-$font-${mode.name}.png'),
        );
      });
    }
  }
}
