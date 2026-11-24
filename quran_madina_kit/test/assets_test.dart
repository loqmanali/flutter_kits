import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled Hafs 16px manifest has the expected header shape', () async {
    final raw = await rootBundle.loadString(
      'packages/quran_madina_kit/assets/db/Madina05-Hafs-16px/manifest.json',
    );
    final m = json.decode(raw) as Map<String, dynamic>;

    expect(m['font_family'], 'Hafs');
    expect(m['font_size'], 16);
    expect(m['line_width'], 270);
    expect((m['suras'] as List).length, 114);
    expect((m['juz'] as List).length, 30);
    expect((m['pages'] as List).length, 604);
  });

  test('bundled juz-01 shard carries render parts', () async {
    final raw = await rootBundle.loadString(
      'packages/quran_madina_kit/assets/db/Madina05-Hafs-16px/juz-01.json',
    );
    final shard = json.decode(raw) as Map<String, dynamic>;

    expect(shard['j'], 0);
    final entries = shard['d'] as List;
    expect(entries, isNotEmpty);
    // [sura0, ayaIdx, page, parts]
    expect((entries.first as List).length, 4);
  });

  test('Hafs font asset loads', () async {
    final bytes = await rootBundle
        .load('packages/quran_madina_kit/assets/fonts/Hafs.ttf');
    expect(bytes.lengthInBytes, greaterThan(50000));
  });
}
