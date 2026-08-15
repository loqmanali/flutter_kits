import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/models.dart';

/// Measures whether Flutter's shaping matches the headless-Chrome measurements
/// baked into the JSON DB.
///
/// Every justified line stores a scaleX that, times its natural width, should
/// exactly fill `line_width`. If Flutter measures the same glyphs the same way,
/// `stored` mode is faithful; if not, `measured` mode is the honest default.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every justified line fills the frame at Hafs 16px', () async {
    const root = 'packages/quran_madina_kit/assets';
    final fontData = await rootBundle.load('$root/fonts/Hafs.ttf');
    await (FontLoader('Hafs')..addFont(Future.value(fontData))).load();

    final manifest = MadinaManifest.fromManifestJson(
      json.decode(await rootBundle.loadString(
        '$root/db/Madina05-Hafs-16px/manifest.json',
      )) as Map<String, dynamic>,
    );

    // Group by (page, line): a line's stretch applies to its whole text, not to
    // one aya's fragment of it.
    final lines = <String, ({StringBuffer text, double stretch})>{};
    for (var j = 1; j <= 30; j++) {
      final shard = JuzShard.fromJson(json.decode(await rootBundle.loadString(
        '$root/db/Madina05-Hafs-16px/juz-${j.toString().padLeft(2, '0')}.json',
      )) as Map<String, dynamic>);
      for (final e in shard.entries) {
        for (final p in e.parts) {
          if (p.isCentred) continue; // centred lines are not justified
          final key = '${e.page}:${p.line}';
          lines.putIfAbsent(
              key, () => (text: StringBuffer(), stretch: p.stretch));
          lines[key]!.text.write(p.text);
        }
      }
    }

    final style = TextStyle(
      fontFamily: manifest.fontFamily,
      fontSize: manifest.fontSize,
    );
    final drifts = <double>[];
    final worst = <String>[];

    lines.forEach((key, line) {
      final painter = TextPainter(
        text: TextSpan(text: line.text.toString(), style: style),
        textDirection: ui.TextDirection.rtl,
        maxLines: 1,
        textScaler: TextScaler.noScaling,
      )..layout();
      final filled = painter.width * line.stretch;
      painter.dispose();
      final drift = (filled - manifest.lineWidth) / manifest.lineWidth;
      drifts.add(drift.abs());
      if (drift.abs() > 0.02) {
        worst.add('$key ${(drift * 100).toStringAsFixed(1)}%');
      }
    });

    drifts.sort();
    final median = drifts[drifts.length ~/ 2];
    final p95 = drifts[(drifts.length * 0.95).floor()];
    // ignore: avoid_print
    print('FIDELITY  lines=${drifts.length}  '
        'median=${(median * 100).toStringAsFixed(2)}%  '
        'p95=${(p95 * 100).toStringAsFixed(2)}%  '
        'max=${(drifts.last * 100).toStringAsFixed(2)}%  '
        'over2%=${worst.length}');
    // ignore: avoid_print
    print('worst: ${worst.take(8).join(', ')}');

    expect(drifts.length, greaterThan(5000),
        reason: 'the whole mushaf must be measured');

    // Measured on Flutter 3.44.8 / macOS: median 0.63%, p95 0.77%, max 2.67%,
    // with exactly 1 line of 8788 over 2%. These bounds leave headroom for
    // engine differences while still failing loudly if shaping regresses.
    //
    // If this ever fails, do NOT loosen the numbers: it means `stored` mode no
    // longer reproduces the DB's Chrome-measured geometry, and
    // MadinaStretchMode.measured should become the documented default.
    expect(p95, lessThan(0.015), reason: '95% of lines within 1.5%');
    expect(worst.length, lessThan(10),
        reason: 'at most a handful of lines may drift over 2%: '
            '${worst.take(10).join(', ')}');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
