import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/models.dart';

/// What one extra TextPainter.layout() per line actually costs, so the choice
/// of default is made on a number rather than a hunch.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('measured-mode layout cost per line', () async {
    const root = 'packages/quran_madina_kit/assets';
    final fontData = await rootBundle.load('$root/fonts/Hafs.ttf');
    await (FontLoader('Hafs')..addFont(Future.value(fontData))).load();

    final shard = JuzShard.fromJson(json.decode(await rootBundle.loadString(
      '$root/db/Madina05-Hafs-16px/juz-05.json',
    )) as Map<String, dynamic>);

    final texts = <String>[];
    for (final e in shard.entries) {
      for (final p in e.parts) {
        if (p.text.trim().isNotEmpty) texts.add(p.text);
      }
      if (texts.length >= 1500) break;
    }

    const style = TextStyle(fontFamily: 'Hafs', fontSize: 16);
    // Warm the shaping caches first; a cold first call is not representative.
    for (final t in texts.take(100)) {
      (TextPainter(
        text: TextSpan(text: t, style: style),
        textDirection: ui.TextDirection.rtl,
        maxLines: 1,
      )..layout())
          .dispose();
    }

    final sw = Stopwatch()..start();
    for (final t in texts) {
      (TextPainter(
        text: TextSpan(text: t, style: style),
        textDirection: ui.TextDirection.rtl,
        maxLines: 1,
      )..layout())
          .dispose();
    }
    sw.stop();

    final perLine = sw.elapsedMicroseconds / texts.length;
    // ignore: avoid_print
    print('PERF  ${texts.length} lines in ${sw.elapsedMilliseconds}ms  '
        '=> ${perLine.toStringAsFixed(1)}us/line  '
        '=> ${(perLine * 15 / 1000).toStringAsFixed(2)}ms for a 15-line page');
    expect(texts.length, greaterThan(200));
  });
}
