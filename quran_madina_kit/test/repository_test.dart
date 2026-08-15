import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
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

Map<String, dynamic> manifestJson({
  String family = 'Hafs',
  String? hash,
}) =>
    {
      'title': 't',
      'published': 1405,
      'font_family': family,
      'font_url': 'assets/fonts/$family.woff2',
      'font_size': 16,
      'line_width': 270,
      if (hash != null) 'content_hash': hash,
      'suras': [
        ['سورة الفاتحة', 9],
        ['سورة البقرة', 288],
      ],
      // [sura0, ayaIdx, startPage]
      'juz': [
        [0, 1, 1],
        [1, 142, 22],
      ],
      'pages': [
        [0, 0, 0, 8],
        [1, 0, 1, 7],
      ],
    };

Map<String, dynamic> monolithJson(List<Map<String, dynamic>> suras) => {
      'title': 't',
      'published': 1405,
      'font_family': 'Hafs',
      'font_url': 'f.woff2',
      'font_size': 16,
      'line_width': 270,
      'suras': suras,
    };

Future<MadinaDb> shardedDb([FakeSource? source]) async => (await MadinaDb.boot(
      source: source ??
          FakeSource({'db/Madina05-Hafs-16px/manifest.json': manifestJson()}),
      name: 'Madina05',
      font: 'Hafs',
      fontSize: 16,
    ))!;

void main() {
  group('boot', () {
    test('prefers the sharded manifest', () async {
      final db = await shardedDb();
      expect(db.dbStem, 'Madina05-Hafs-16px');
      expect(db.manifest.isSharded, isTrue);
      expect(db.suras.length, 2);
    });

    test('falls back to the monolith when there is no manifest', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px.json': monolithJson([
          {
            'name': 'سورة الفاتحة',
            'ayas': [
              {
                'p': 1,
                'r': [
                  {'l': 1, 't': '', 's': -1}
                ]
              }
            ]
          }
        ]),
      });
      final db = await MadinaDb.boot(
          source: source, name: 'Madina05', font: 'Hafs', fontSize: 16);
      expect(db!.manifest.isSharded, isFalse);
      expect(db.aya(0, 0), isNotNull,
          reason: 'monolith data is present immediately');
    });

    test('falls back to size 16 when the requested size has no DB', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px/manifest.json': manifestJson(),
      });
      final logs = <String>[];
      final db = await MadinaDb.boot(
        source: source,
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 24,
        log: logs.add,
      );
      expect(db!.dbStem, 'Madina05-Hafs-16px');
      expect(logs.join(), contains('falling back to size: 16'));
    });

    test('returns null when nothing at all is available', () async {
      final db = await MadinaDb.boot(
          source: FakeSource({}), name: 'Madina05', font: 'Hafs', fontSize: 16);
      expect(db, isNull);
    });

    test('clears cached shards when the content hash changed', () async {
      final cleared = <String>[];
      await MadinaDb.boot(
        source: FakeSource(
            {'db/Madina05-Hafs-16px/manifest.json': manifestJson(hash: 'v2')}),
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
        previousHash: 'v1',
        onCacheClear: cleared.add,
      );
      expect(cleared.single, 'db/Madina05-Hafs-16px/');
    });

    test('does not clear when the hash is unchanged', () async {
      final cleared = <String>[];
      await MadinaDb.boot(
        source: FakeSource(
            {'db/Madina05-Hafs-16px/manifest.json': manifestJson(hash: 'v1')}),
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
        previousHash: 'v1',
        onCacheClear: cleared.add,
      );
      expect(cleared, isEmpty);
    });

    test('normalises a spaced font name to underscores', () async {
      final source = FakeSource({
        'db/Madina05-Amiri_Quran-16px/manifest.json':
            manifestJson(family: 'Amiri Quran'),
      });
      final db = await MadinaDb.boot(
          source: source, name: 'Madina05', font: 'Amiri Quran', fontSize: 16);
      expect(db!.dbStem, 'Madina05-Amiri_Quran-16px');
    });

    test('a fractional font size keeps its decimal in the stem', () {
      expect(
          MadinaDb.stemFor('Madina05', 'Hafs', 18.5), 'Madina05-Hafs-18.5px');
      expect(MadinaDb.stemFor('Madina05', 'Hafs', 18), 'Madina05-Hafs-18px');
    });
  });

  group('suraAyaToJuz', () {
    late MadinaDb db;

    setUp(() async {
      db = await shardedDb();
    });

    test('maps into the last juz whose start is at or before the position', () {
      expect(db.suraAyaToJuz(0, 2), 0);
      expect(db.suraAyaToJuz(1, 3), 0,
          reason: 'Al-Baqara aya 2 is still juz 1');
      expect(db.suraAyaToJuz(1, 143), 1);
      expect(db.suraAyaToJuz(1, 200), 1);
    });

    test(
        'decoration slots follow aya 1, so a sura opening a juz keeps its '
        'title there', () {
      expect(db.suraAyaToJuz(1, 0), db.suraAyaToJuz(1, 2));
      expect(db.suraAyaToJuz(1, 1), db.suraAyaToJuz(1, 2));
    });
  });

  group('ensureJuz', () {
    test('fetches only the missing shards and merges them in place', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px/manifest.json': manifestJson(),
        'db/Madina05-Hafs-16px/juz-01.json': {
          'j': 0,
          'd': [
            [
              0,
              2,
              1,
              [
                {'l': 2, 't': 'بِسْمِ ٱللَّهِ', 's': -1}
              ]
            ]
          ]
        },
      });
      final db = await shardedDb(source);
      expect(db.aya(0, 2), isNull, reason: 'not loaded yet');

      await db.ensureJuz([0]);
      expect(db.aya(0, 2)!.parts.single.text, 'بِسْمِ ٱللَّهِ');

      final before = source.requested.length;
      await db.ensureJuz([0]);
      expect(source.requested.length, before,
          reason: 'already loaded, no refetch');
    });

    test('a failed shard is marked loaded so it is not retried forever',
        () async {
      final source =
          FakeSource({'db/Madina05-Hafs-16px/manifest.json': manifestJson()});
      final db = await shardedDb(source);
      await db.ensureJuz([0]);
      final after = source.requested.length;
      await db.ensureJuz([0]);
      expect(source.requested.length, after);
    });

    test('ignores indices outside the juz table', () async {
      final source =
          FakeSource({'db/Madina05-Hafs-16px/manifest.json': manifestJson()});
      final db = await shardedDb(source);
      await db.ensureJuz([-1, 99]);
      expect(source.requested.where((p) => p.contains('juz-')), isEmpty);
    });

    test('is a no-op in monolith mode', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px.json': monolithJson([]),
      });
      final db = (await MadinaDb.boot(
        source: source,
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
      ))!;
      await db.ensureJuz([0, 1, 2]);
      expect(source.requested.where((p) => p.contains('juz-')), isEmpty);
    });
  });

  group('pageBounds', () {
    test('reads the sharded page table', () async {
      final db = await shardedDb();
      expect(db.pageBounds(1), (suraFrom: 0, ayaFrom: 0, suraTo: 0, ayaTo: 8));
      expect(db.pageBounds(2), (suraFrom: 1, ayaFrom: 0, suraTo: 1, ayaTo: 7));
    });

    test('returns null for a page outside the table', () async {
      final db = await shardedDb();
      expect(db.pageBounds(999), isNull);
      expect(db.pageBounds(0), isNull);
    });
  });

  group('aya', () {
    test('returns null out of range rather than throwing', () async {
      final db = await shardedDb();
      expect(db.aya(-1, 0), isNull);
      expect(db.aya(99, 0), isNull);
      expect(db.aya(0, -1), isNull);
      expect(db.aya(0, 9999), isNull);
    });
  });
}
