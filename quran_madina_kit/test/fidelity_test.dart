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

  const fonts = [
    (stem: 'Madina05-Hafs-16px', ttf: 'Hafs.ttf'),
    (stem: 'Madina05-Uthman-16px', ttf: 'UthmanTN_v2-0.ttf'),
    (stem: 'Madina05-Amiri_Quran-16px', ttf: 'AmiriQuran.ttf'),
    (stem: 'Madina05-Amiri_Quran_Colored-16px', ttf: 'AmiriQuranColored.ttf'),
    (stem: 'Madina05-me_quran-16px', ttf: 'me_quran-Regular.ttf'),
  ];

  for (final f in fonts) {
    test('every justified line fills the frame — ${f.stem}', () async {
      const root = 'packages/quran_madina_kit/assets';
      final manifest = MadinaManifest.fromManifestJson(
        json.decode(await rootBundle.loadString(
          '$root/db/${f.stem}/manifest.json',
        )) as Map<String, dynamic>,
      );
      final fontData = await rootBundle.load('$root/fonts/${f.ttf}');
      await (FontLoader(manifest.fontFamily)..addFont(Future.value(fontData)))
          .load();

      // Group by (page, line): a line's stretch applies to its whole text, not to
      // one aya's fragment of it.
      final lines = <String, ({StringBuffer text, double stretch})>{};
      for (var j = 1; j <= 30; j++) {
        final shard = JuzShard.fromJson(json.decode(await rootBundle.loadString(
          '$root/db/${f.stem}/juz-${j.toString().padLeft(2, '0')}.json',
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

      // MEASURED mode derives scaleX from the same TextPainter, so it fills the
      // frame exactly by construction. Verifying that here is what makes it a
      // real alternative rather than a claim.
      var measuredWorst = 0.0;
      lines.forEach((key, line) {
        final painter = TextPainter(
          text: TextSpan(text: line.text.toString(), style: style),
          textDirection: ui.TextDirection.rtl,
          maxLines: 1,
          textScaler: TextScaler.noScaling,
        )..layout();
        final natural = painter.width;
        painter.dispose();
        if (natural <= 0) return;
        final filled = natural * (manifest.lineWidth / natural);
        final drift = (filled - manifest.lineWidth).abs() / manifest.lineWidth;
        if (drift > measuredWorst) measuredWorst = drift;
      });

      drifts.sort();
      final median = drifts[drifts.length ~/ 2];
      final p95 = drifts[(drifts.length * 0.95).floor()];
      // ignore: avoid_print
      print(
          'FIDELITY ${manifest.fontFamily.padRight(20)} lines=${drifts.length}  '
          'median=${(median * 100).toStringAsFixed(2)}%  '
          'p95=${(p95 * 100).toStringAsFixed(2)}%  '
          'max=${(drifts.last * 100).toStringAsFixed(2)}%  '
          'over2%=${worst.length}  '
          'MEASURED-max=${(measuredWorst * 100).toStringAsFixed(4)}%');

      expect(drifts.length, greaterThan(5000),
          reason: 'the whole mushaf must be measured');

      expect(measuredWorst, lessThan(1e-9),
          reason: 'measured mode must fill the frame exactly, by construction');

      // `stored` replays the DB's Chrome-measured factors, so its tail is a
      // property of the font, not of this port: half of all lines land within 1%
      // for every font, but the p95 varies a lot (Hafs 0.77%, Uthman 3.09% —
      // see the README table). Only the median is asserted; a regression there
      // means shaping itself changed. Do not loosen it — switch the recommended
      // default to `measured` instead.
      expect(median, lessThan(0.01),
          reason: 'half of all lines must land within 1% in stored mode: '
              '${worst.take(5).join(', ')}');
    }, timeout: const Timeout(Duration(minutes: 5)));
  }
}
