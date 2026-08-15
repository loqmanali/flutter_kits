import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';

import 'support/pump.dart';

/// Probes whether Skia actually paints Amiri Quran Colored's COLRv0 table.
///
/// Tajweed colouring is the entire point of that font: if the glyphs come out
/// monochrome the kit must say so rather than advertise a feature it does not
/// deliver.
void main() {
  setUpMadinaTests();

  testWidgets('Amiri Quran Colored paints more than one ink colour',
      (tester) async {
    await pumpMadina(
      tester,
      madinaHost(
        RepaintBoundary(
          child: Container(
            width: 300,
            height: 120,
            color: const Color(0xFFFFFFFF),
            alignment: Alignment.center,
            child: const QuranMadinaView(sura: 2, aya: '1', quotes: false),
          ),
        ),
        config: const MadinaConfig(
          font: 'Amiri Quran Colored',
          fontSize: 24,
        ),
      ),
    );

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary).first,
    );
    late final ui.Image image;
    await tester.runAsync(() async {
      image = await boundary.toImage();
    });
    final data = await tester.runAsync(
      () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
    );

    final hues = <int>{};
    final bytes = data!.buffer.asUint8List();
    for (var i = 0; i < bytes.length; i += 4) {
      final r = bytes[i], g = bytes[i + 1], b = bytes[i + 2], a = bytes[i + 3];
      if (a < 200) continue;
      if (r > 240 && g > 240 && b > 240) continue; // background
      // Only count pixels with a real colour cast, not antialiased greys.
      final maxC = [r, g, b].reduce((x, y) => x > y ? x : y);
      final minC = [r, g, b].reduce((x, y) => x < y ? x : y);
      if (maxC - minC > 40) hues.add((r ~/ 32) << 6 | (g ~/ 32) << 3 | b ~/ 32);
    }
    // ignore: avoid_print
    print('COLOUR FONT: ${hues.length} distinct chromatic buckets');
    expect(hues, isNotEmpty,
        reason: 'COLRv0 tajweed colours did not paint — the font renders '
            'monochrome on this engine');
  });
}
