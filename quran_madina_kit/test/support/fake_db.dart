import 'dart:typed_data';

import 'package:quran_madina_kit/src/repository.dart';
import 'package:quran_madina_kit/src/source.dart';

/// A source backed by in-memory maps, so each test states exactly what exists.
class FakeSource extends MadinaSource {
  FakeSource(this.files);

  final Map<String, Map<String, dynamic>> files;
  final List<String> requested = [];

  @override
  Future<Map<String, dynamic>?> loadJson(
    String path, {
    bool forceFresh = false,
  }) async {
    requested.add(path);
    return files[path];
  }

  @override
  Future<Uint8List?> loadFont(String url) async => Uint8List(0);

  @override
  void clearCache(String prefix) {}
}

/// One aya slot: its page, then its `(line, text)` parts.
typedef Slot = ({int page, List<(int, String)> parts});

Slot slot(int page, List<(int, String)> parts) => (page: page, parts: parts);

/// Builds a monolith-backed [MadinaDb] from a plain description, so layout
/// tests can state page/line placement directly instead of hand-writing JSON.
Future<MadinaDb> buildDb(List<(String, List<Slot>)> suras) async =>
    (await MadinaDb.boot(
      source: FakeSource({
        'db/Madina05-Hafs-16px.json': {
          'title': 't',
          'published': 1405,
          'font_family': 'Hafs',
          'font_url': 'f.woff2',
          'font_size': 16,
          'line_width': 270,
          'suras': [
            for (final (name, slots) in suras)
              {
                'name': name,
                'ayas': [
                  for (final s in slots)
                    {
                      'p': s.page,
                      'r': [
                        for (final (line, text) in s.parts)
                          {'l': line, 't': text, 's': 1},
                      ],
                    },
                ],
              },
          ],
        },
      }),
      name: 'Madina05',
      font: 'Hafs',
      fontSize: 16,
    ))!;

/// A sharded [MadinaDb] whose shards are never available, so every aya stays
/// null — the "unloaded shard boundary" case every walker must survive.
Future<MadinaDb> buildEmptyShardedDb({int slots = 5}) async =>
    (await MadinaDb.boot(
      source: FakeSource({
        'db/Madina05-Hafs-16px/manifest.json': {
          'title': 't',
          'published': 1405,
          'font_family': 'Hafs',
          'font_url': 'f.woff2',
          'font_size': 16,
          'line_width': 270,
          'suras': [
            ['س', slots]
          ],
          'juz': [
            [0, 1, 1]
          ],
          'pages': [
            [0, 0, 0, slots - 1]
          ],
        },
      }),
      name: 'Madina05',
      font: 'Hafs',
      fontSize: 16,
    ))!;
