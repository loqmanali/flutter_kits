import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';

import 'support/pump.dart';

/// Every font/size the kit bundles a database for.
const _fonts = [
  (font: 'Hafs', lineWidth16: 270.0, lineWidth24: 410.0),
  (font: 'Uthman', lineWidth16: 270.0, lineWidth24: 400.0),
  (font: 'Amiri Quran', lineWidth16: 270.0, lineWidth24: 410.0),
  (font: 'Amiri Quran Colored', lineWidth16: 270.0, lineWidth24: 410.0),
  (font: 'me_quran', lineWidth16: 300.0, lineWidth24: 450.0),
];

void main() {
  setUpMadinaTests();

  for (final f in _fonts) {
    for (final size in [16.0, 24.0]) {
      testWidgets('${f.font} @${size.toInt()}px renders page 3',
          (tester) async {
        await pumpMadina(
          tester,
          madinaHost(
            QuranMadinaView(page: 3, headless: true),
            config: MadinaConfig(font: f.font, fontSize: size),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(MadinaLine), findsNWidgets(15),
            reason: '${f.font} @$size must lay out the full 15-line grid');
        expect(
          tester.getSize(find.byType(MadinaLine).first).width,
          size == 16 ? f.lineWidth16 : f.lineWidth24,
          reason: 'each font/size has its own hand-tuned frame width',
        );
      });
    }
  }

  testWidgets('a spaced font name resolves its underscored DB stem',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(
        const QuranMadinaView(sura: 1, aya: '1'),
        config: const MadinaConfig(font: 'Amiri Quran', fontSize: 16),
      ),
    );
    expect(find.byType(MadinaLine), findsOneWidget);
  });

  testWidgets('an interpolated size fits between the two anchors',
      (tester) async {
    // Hafs: 270@16, 410@24 -> 20px must land on 340, not the proportional 337.
    await pumpMadina(
      tester,
      madinaHost(
        const QuranMadinaView(page: 3, headless: true),
        config: const MadinaConfig(font: 'Hafs', fontSize: 20),
      ),
    );
    expect(tester.getSize(find.byType(MadinaLine).first).width, 340);
  });

  testWidgets('an out-of-range size falls back to 16', (tester) async {
    await pumpMadina(
      tester,
      madinaHost(
        const QuranMadinaView(page: 3, headless: true),
        config: const MadinaConfig(font: 'Hafs', fontSize: 500),
      ),
    );
    expect(tester.getSize(find.byType(MadinaLine).first).width, 270);
  });

  testWidgets('an unknown font renders nothing rather than throwing',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(
        const QuranMadinaView(page: 3),
        config: const MadinaConfig(font: 'NoSuchFont', fontSize: 16),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(MadinaLine), findsNothing);
  });
}
