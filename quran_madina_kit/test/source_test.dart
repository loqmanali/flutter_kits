import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_madina_kit/src/source.dart';

http.Response jsonResponse(Object body) => http.Response.bytes(
      utf8.encode(json.encode(body)),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MadinaAssetSource', () {
    final source = MadinaAssetSource();

    test('loads a bundled manifest', () async {
      final m = await source.loadJson('db/Madina05-Hafs-16px/manifest.json');
      expect(m, isNotNull);
      expect(m!['font_family'], 'Hafs');
    });

    test('returns null for a missing asset instead of throwing', () async {
      expect(await source.loadJson('db/Nope-99px/manifest.json'), isNull);
    });

    test('maps a .woff2 font url to the bundled .ttf', () async {
      final bytes = await source.loadFont('assets/fonts/Hafs.woff2');
      expect(bytes, isNotNull);
      expect(bytes!.lengthInBytes, greaterThan(50000));
    });

    test('serves a repeat read from cache', () async {
      final a = await source.loadJson('db/Madina05-Hafs-16px/manifest.json');
      final b = await source.loadJson('db/Madina05-Hafs-16px/manifest.json');
      expect(identical(a, b), isTrue);
    });
  });

  group('MadinaNetworkSource', () {
    test('fetches and decodes JSON', () async {
      final client =
          MockClient((req) async => jsonResponse({'font_family': 'Hafs'}));
      final source = MadinaNetworkSource(client: client);
      final m = await source.loadJson('db/x/manifest.json');
      expect(m!['font_family'], 'Hafs');
    });

    test('returns null on a non-200 instead of throwing', () async {
      final client = MockClient((req) async => http.Response('nope', 404));
      final source = MadinaNetworkSource(client: client);
      expect(await source.loadJson('db/x/manifest.json'), isNull);
    });

    test('coalesces concurrent requests for the same path into one fetch',
        () async {
      var hits = 0;
      final client = MockClient((req) async {
        hits++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return jsonResponse({'ok': true});
      });
      final source = MadinaNetworkSource(client: client);
      await Future.wait([
        source.loadJson('db/x/juz-01.json'),
        source.loadJson('db/x/juz-01.json'),
        source.loadJson('db/x/juz-01.json'),
      ]);
      expect(hits, 1,
          reason: 'three widgets needing the same juz must fire one request');
    });

    test('serves a repeat request from cache', () async {
      var hits = 0;
      final client = MockClient((req) async {
        hits++;
        return jsonResponse({'ok': true});
      });
      final source = MadinaNetworkSource(client: client);
      await source.loadJson('db/x/juz-01.json');
      await source.loadJson('db/x/juz-01.json');
      expect(hits, 1);
    });

    test('clearCache drops only the matching prefix', () async {
      var hits = 0;
      final client = MockClient((req) async {
        hits++;
        return jsonResponse({'ok': true});
      });
      final source = MadinaNetworkSource(client: client);
      await source.loadJson('db/a/juz-01.json');
      await source.loadJson('db/b/juz-01.json');
      expect(hits, 2);
      source.clearCache('db/a/');
      await source.loadJson('db/a/juz-01.json');
      await source.loadJson('db/b/juz-01.json');
      expect(hits, 3, reason: 'only db/a was refetched');
    });

    test('forceFresh bypasses the cache (used for manifest.json)', () async {
      var hits = 0;
      final client = MockClient((req) async {
        hits++;
        return jsonResponse({'ok': true});
      });
      final source = MadinaNetworkSource(client: client);
      await source.loadJson('db/x/manifest.json');
      await source.loadJson('db/x/manifest.json', forceFresh: true);
      expect(hits, 2);
    });

    test('decodes UTF-8 Arabic even without a charset header', () async {
      final client = MockClient((req) async => http.Response.bytes(
            utf8.encode(json.encode({'name': 'سورة الفاتحة'})),
            200,
            headers: {'content-type': 'application/json'},
          ));
      final source = MadinaNetworkSource(client: client);
      final m = await source.loadJson('db/x/manifest.json');
      expect(m!['name'], 'سورة الفاتحة');
    });

    test('loads font bytes', () async {
      final client = MockClient((req) async =>
          http.Response.bytes(Uint8List.fromList([0, 1, 2, 3]), 200));
      final source = MadinaNetworkSource(client: client);
      expect(
          (await source.loadFont('assets/fonts/Hafs.woff2'))!.lengthInBytes, 4);
    });

    test('a network error returns null instead of throwing', () async {
      final client = MockClient((req) async => throw const SocketFailure());
      final source = MadinaNetworkSource(client: client);
      expect(await source.loadJson('db/x/manifest.json'), isNull);
      expect(await source.loadFont('f.ttf'), isNull);
    });
  });
}

/// Stand-in for a transport failure; MockClient has no built-in way to throw.
class SocketFailure implements Exception {
  const SocketFailure();
}
