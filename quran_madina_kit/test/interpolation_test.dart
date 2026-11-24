import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/interpolation.dart';
import 'package:quran_madina_kit/src/source.dart';

class FakeSource extends MadinaSource {
  FakeSource(this.files);

  final Map<String, Map<String, dynamic>> files;

  @override
  Future<Map<String, dynamic>?> loadJson(
    String path, {
    bool forceFresh = false,
  }) async =>
      files[path];

  @override
  Future<Uint8List?> loadFont(String url) async => Uint8List(0);

  @override
  void clearCache(String prefix) {}
}

void main() {
  group('clampFontSize', () {
    test('accepts anything inside 6..100', () {
      final logs = <String>[];
      expect(clampFontSize(6, logs.add), 6);
      expect(clampFontSize(18.5, logs.add), 18.5);
      expect(clampFontSize(100, logs.add), 100);
      expect(logs, isEmpty);
    });

    test('falls back to 16 and warns outside the range', () {
      final logs = <String>[];
      expect(clampFontSize(5, logs.add), 16);
      expect(clampFontSize(101, logs.add), 16);
      expect(logs.length, 2);
      expect(logs.first, contains('outside 6..100'));
    });
  });

  group('interpolate', () {
    // Hafs anchors: 270px@16, 410px@24 — deliberately NOT proportional
    // (proportional would be 405@24), which is why interpolation exists.
    test('an anchor size needs no overrides', () {
      expect(interpolate(requested: 16, lineWidth16: 270, lineWidth24: 410),
          isNull);
      expect(interpolate(requested: 24, lineWidth16: 270, lineWidth24: 410),
          isNull);
    });

    test('reads line_width off the fitted line', () {
      final o = interpolate(requested: 20, lineWidth16: 270, lineWidth24: 410)!;
      expect(o.fontSize, 20);
      expect(o.lineWidth, 340, reason: '270 + (410-270) * (20-16)/8');
    });

    test('rounds the interpolated width', () {
      final o = interpolate(requested: 18, lineWidth16: 270, lineWidth24: 410)!;
      expect(o.lineWidth, 305);
    });

    test('corrects stretch against the nearest anchor', () {
      // 18 is nearer 16: stretchScale = lw(18) * 16 / (lw(16) * 18)
      final o = interpolate(requested: 18, lineWidth16: 270, lineWidth24: 410)!;
      expect(o.nearestAnchor, 16);
      expect(o.stretchScale, closeTo(305 * 16 / (270 * 18), 1e-9));
    });

    test('a size past the midpoint uses the 24px anchor', () {
      final o = interpolate(requested: 22, lineWidth16: 270, lineWidth24: 410)!;
      expect(o.nearestAnchor, 24);
      expect(o.lineWidth, 375);
      expect(o.stretchScale, closeTo(375 * 24 / (410 * 22), 1e-9));
    });

    test('the exact midpoint prefers the lower anchor', () {
      expect(
          interpolate(requested: 20, lineWidth16: 270, lineWidth24: 410)!
              .nearestAnchor,
          16,
          reason: 'the web uses (S - lo <= hi - S), so a tie picks lo');
    });

    test('extrapolates below and above the anchors', () {
      expect(
          interpolate(requested: 8, lineWidth16: 270, lineWidth24: 410)!
              .lineWidth,
          130);
      expect(
          interpolate(requested: 32, lineWidth16: 270, lineWidth24: 410)!
              .lineWidth,
          550);
    });
  });

  group('resolveSizeOverrides', () {
    Map<String, dynamic> header(double lineWidth) => {
          'title': 't',
          'published': 1405,
          'font_family': 'Hafs',
          'font_url': 'f.woff2',
          'font_size': 16,
          'line_width': lineWidth,
          'suras': <dynamic>[],
        };

    test('fits between both anchors read from their manifests', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px/manifest.json': header(270),
        'db/Madina05-Hafs-24px/manifest.json': header(410),
      });
      final o = await resolveSizeOverrides(
        source: source,
        name: 'Madina05',
        font: 'Hafs',
        requested: 20,
      );
      expect(o!.lineWidth, 340);
      expect(o.nearestAnchor, 16);
    });

    test('falls back to the monolith header when a manifest is absent',
        () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px.json': header(270),
        'db/Madina05-Hafs-24px/manifest.json': header(410),
      });
      final o = await resolveSizeOverrides(
        source: source,
        name: 'Madina05',
        font: 'Hafs',
        requested: 20,
      );
      expect(o!.lineWidth, 340);
    });

    test('returns null and logs when an anchor is missing', () async {
      final logs = <String>[];
      final o = await resolveSizeOverrides(
        source:
            FakeSource({'db/Madina05-Hafs-16px/manifest.json': header(270)}),
        name: 'Madina05',
        font: 'Hafs',
        requested: 20,
        log: logs.add,
      );
      expect(o, isNull);
      expect(logs.join(), contains('missing anchor DB'));
    });

    test('returns null for an anchor size (its DB is used as-is)', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px/manifest.json': header(270),
        'db/Madina05-Hafs-24px/manifest.json': header(410),
      });
      expect(
        await resolveSizeOverrides(
          source: source,
          name: 'Madina05',
          font: 'Hafs',
          requested: 16,
        ),
        isNull,
      );
    });
  });
}
