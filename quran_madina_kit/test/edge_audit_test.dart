import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';

import 'support/pump.dart';

/// Ground-truth justification audit.
///
/// Renders a page, then finds the leftmost and rightmost inked pixel of every
/// text row band. A fully justified line must reach both frame edges; anything
/// else is real raggedness, whatever the arithmetic says.
Future<List<String>> auditPage(
  WidgetTester tester, {
  required String font,
  required MadinaStretchMode mode,
  required int page,
}) async {
  await pumpMadina(
    tester,
    madinaHost(
      Center(
        child: RepaintBoundary(
          child: ColoredBox(
            color: const Color(0xFFFFFFFF),
            child: QuranMadinaView(page: page, headless: true),
          ),
        ),
      ),
      config: MadinaConfig(font: font, fontSize: 16, stretchMode: mode),
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
  final bytes = data!.buffer.asUint8List();
  final w = image.width, h = image.height;

  bool inked(int x, int y) {
    final i = (y * w + x) * 4;
    // Anything meaningfully darker than the white ground counts as ink.
    return bytes[i] < 200 || bytes[i + 1] < 200 || bytes[i + 2] < 200;
  }

  // Scan ink inside each MadinaLine's own rect, so every measurement is tied to
  // a known line rather than to a guessed row band.
  final finder = find.byType(MadinaLine);
  final origin = tester.getTopLeft(find.byType(RepaintBoundary).first);
  final report =
      StringBuffer('\nEDGE AUDIT  $font / ${mode.name} / page $page\n');
  final offenders = <String>[];

  for (var i = 0; i < finder.evaluate().length; i++) {
    final line = tester.widget<MadinaLine>(finder.at(i));
    final rect = tester.getRect(finder.at(i)).shift(-origin);
    final top = rect.top.floor().clamp(0, h - 1);
    final bottom = rect.bottom.ceil().clamp(0, h - 1);

    var left = w, right = -1;
    for (var y = top; y <= bottom; y++) {
      for (var x = 0; x < w; x++) {
        if (!inked(x, y)) continue;
        if (x < left) left = x;
        if (x > right) right = x;
      }
    }
    if (right < left) continue;

    // How far the ink sits outside the line's own box, in each direction.
    final overRight = right + 1 - rect.right;
    final overLeft = rect.left - left;
    // A centred line is meant to be short — the Mushaf centres sura titles,
    // basmalas and a surah's final line. Only justified lines must be flush.
    final off = !line.isCentred && (overRight.abs() > 2 || overLeft.abs() > 2);
    if (off) {
      offenders.add('L${i + 1} (s=${line.stretch.toStringAsFixed(3)}) '
          'dL=${overLeft.toStringAsFixed(0)} dR=${overRight.toStringAsFixed(0)}');
    }
    final flag = line.isCentred ? '   (centred)' : (off ? '   <-- OFF' : '');
    report.write('  L${(i + 1).toString().padLeft(2)}  '
        's=${line.stretch.toStringAsFixed(3).padLeft(6)}  '
        'box=[${rect.left.toStringAsFixed(0)}..${rect.right.toStringAsFixed(0)}]  '
        'ink=[$left..$right]  '
        'inkW=${right - left + 1}  '
        'dL=${overLeft.toStringAsFixed(0).padLeft(4)}  '
        'dR=${overRight.toStringAsFixed(0).padLeft(4)}$flag\n');
  }

  // ignore: avoid_print
  print(report.toString());
  return offenders;
}

void main() {
  setUpMadinaTests();

  for (final mode in MadinaStretchMode.values) {
    for (final font in ['Uthman', 'Hafs', 'me_quran']) {
      testWidgets('$font page 106 — ${mode.name}', (tester) async {
        final offenders =
            await auditPage(tester, font: font, mode: mode, page: 106);
        if (mode == MadinaStretchMode.measured) {
          // measured mode derives the scale from the real width, so every
          // justified line must reach both frame edges. Anything else is a
          // geometry bug, not font drift.
          expect(offenders, isEmpty,
              reason: 'justified lines must be flush on both edges');
        }
      });
    }
  }
}
