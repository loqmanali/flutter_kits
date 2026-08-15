import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/models.dart';

void main() {
  group('RenderPart', () {
    test('reads l/t/s', () {
      final p = RenderPart.fromJson(
          json.decode('{"l":3,"t":"بِسْمِ","s":1.25}') as Map<String, dynamic>);
      expect(p.line, 3);
      expect(p.text, 'بِسْمِ');
      expect(p.stretch, 1.25);
    });

    test('s == -1 means centred, not a scale factor', () {
      final p = RenderPart.fromJson(json
          .decode('{"l":1,"t":"سورة الفاتحة","s":-1}') as Map<String, dynamic>);
      expect(p.stretch, kCentredStretch);
      expect(p.isCentred, isTrue);
    });

    test('an integer s decodes as a double', () {
      final p = RenderPart.fromJson(
          json.decode('{"l":1,"t":"x","s":1}') as Map<String, dynamic>);
      expect(p.stretch, 1.0);
    });
  });

  group('MadinaManifest.fromManifestJson', () {
    final raw = json.decode('''
      {"title":"t","published":1405,"font_family":"Hafs","font_url":"assets/fonts/Hafs.woff2",
       "font_size":16,"line_width":270,"content_hash":"abc123",
       "suras":[["سورة الفاتحة",9],["سورة البقرة",288]],
       "juz":[[0,1,1],[1,142,22]],
       "pages":[[0,0,0,8],[1,0,1,7]]}
    ''') as Map<String, dynamic>;

    test('builds a sparse sura skeleton sized by the slot count', () {
      final m = MadinaManifest.fromManifestJson(raw);
      expect(m.suras.length, 2);
      expect(m.suras[0].name, 'سورة الفاتحة');
      expect(m.suras[0].ayas.length, 9);
      expect(m.suras[0].ayas.every((a) => a == null), isTrue,
          reason: 'a manifest carries no render data — shards fill it in');
    });

    test('keeps header, juz and page tables', () {
      final m = MadinaManifest.fromManifestJson(raw);
      expect(m.fontFamily, 'Hafs');
      expect(m.fontUrl, 'assets/fonts/Hafs.woff2');
      expect(m.fontSize, 16.0);
      expect(m.lineWidth, 270.0);
      expect(m.contentHash, 'abc123');
      expect(m.juz![1], [1, 142, 22]);
      expect(m.pages![0], [0, 0, 0, 8]);
      expect(m.isSharded, isTrue);
    });
  });

  group('MadinaManifest.fromMonolithJson', () {
    test('populates ayas eagerly and leaves juz/pages null', () {
      final raw = json.decode('''
        {"title":"t","published":1405,"font_family":"Hafs","font_url":"f.woff2",
         "font_size":16,"line_width":270,
         "suras":[{"name":"سورة الفاتحة","ayas":[
            {"p":1,"r":[{"l":1,"t":"","s":-1}]},
            {"p":1,"r":[{"l":1,"t":"سورة الفاتحة","s":-1}]}]}]}
      ''') as Map<String, dynamic>;
      final m = MadinaManifest.fromMonolithJson(raw);
      expect(m.juz, isNull, reason: 'monolith mode has no shard tables');
      expect(m.pages, isNull);
      expect(m.isSharded, isFalse);
      expect(m.suras[0].ayas.length, 2);
      expect(m.suras[0].ayas[1]!.parts.single.text, 'سورة الفاتحة');
    });
  });

  group('JuzShard', () {
    test('decodes the [sura, aya, page, parts] tuples', () {
      final raw = json.decode('''
        {"j":0,"d":[[0,2,1,[{"l":2,"t":"بِسْمِ ٱللَّهِ","s":-1}]]]}
      ''') as Map<String, dynamic>;
      final s = JuzShard.fromJson(raw);
      expect(s.index, 0);
      expect(s.entries.single.sura, 0);
      expect(s.entries.single.ayaIndex, 2);
      expect(s.entries.single.page, 1);
      expect(s.entries.single.parts.single.line, 2);
    });
  });
}
