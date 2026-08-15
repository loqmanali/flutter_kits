import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/theme.dart';

void main() {
  group('relativeLuminance', () {
    test('black and white sit at the extremes', () {
      expect(relativeLuminance(const Color(0xFF000000)), closeTo(0, 1e-6));
      expect(relativeLuminance(const Color(0xFFFFFFFF)), closeTo(1, 1e-6));
    });

    test('matches the WCAG value for mid grey', () {
      expect(relativeLuminance(const Color(0xFF808080)), closeTo(0.2159, 1e-3));
    });
  });

  group('forAmbient', () {
    test('light ambient text (dark page) picks the dark mark pair', () {
      final t = MadinaTheme.light().forAmbient(const Color(0xFFFFFFFF));
      expect(t.highlight, const Color(0xFF5C4600));
      expect(t.error, const Color(0xFF6B1A24));
      expect(t.highlightText, const Color(0xFFFFFFFF));
    });

    test('dark ambient text (light page) keeps the light mark pair', () {
      final t = MadinaTheme.light().forAmbient(const Color(0xFF000000));
      expect(t.highlight, const Color(0xFFFFF3B0));
      expect(t.error, const Color(0xFFF5C6CB));
      expect(t.highlightText, const Color(0xFF1A1A1A));
    });

    test('keeps the caller\'s background and header either way', () {
      const custom = MadinaTheme(
        background: Color(0xFF102030),
        header: Color(0xFF405060),
        highlight: Color(0xFFFFF3B0),
        error: Color(0xFFF5C6CB),
        highlightText: Color(0xFF1A1A1A),
        errorText: Color(0xFF1A1A1A),
      );
      final t = custom.forAmbient(const Color(0xFFFFFFFF));
      expect(t.background, const Color(0xFF102030));
      expect(t.header, const Color(0xFF405060));
    });
  });

  group('mixWithTransparent', () {
    test('scales alpha without touching the channels', () {
      final c = mixWithTransparent(const Color(0xFF112233), 0.2);
      expect((c.a * 255).round(), (255 * 0.2).round());
      expect((c.r * 255).round(), 0x11);
      expect((c.g * 255).round(), 0x22);
      expect((c.b * 255).round(), 0x33);
    });
  });

  group('MadinaScope', () {
    testWidgets('provides config and theme down the tree', (tester) async {
      late MadinaScope seen;
      await tester.pumpWidget(MadinaScope(
        config: const MadinaConfig(font: 'Uthman', fontSize: 24),
        theme: MadinaTheme.light(),
        child: Builder(builder: (context) {
          seen = MadinaScope.of(context);
          return const SizedBox();
        }),
      ));
      expect(seen.config.font, 'Uthman');
      expect(seen.config.fontSize, 24);
    });

    testWidgets('falls back to defaults with no scope in the tree',
        (tester) async {
      late MadinaScope seen;
      await tester.pumpWidget(Builder(builder: (context) {
        seen = MadinaScope.of(context);
        return const SizedBox();
      }));
      expect(seen.config.name, 'Madina05');
      expect(seen.config.font, 'Hafs');
      expect(seen.config.fontSize, 16);
      expect(seen.config.stretchMode, MadinaStretchMode.stored);
    });
  });

  group('MadinaConfig equality', () {
    test('two identical configs compare equal', () {
      expect(
          const MadinaConfig(font: 'Hafs'), const MadinaConfig(font: 'Hafs'));
    });

    test('a differing field breaks equality', () {
      expect(const MadinaConfig(font: 'Hafs'),
          isNot(const MadinaConfig(font: 'Uthman')));
      expect(const MadinaConfig(fontSize: 16),
          isNot(const MadinaConfig(fontSize: 24)));
    });
  });
}
