import 'package:docs/core/dart_syntax.dart';
import 'package:docs/data/catalog.dart';
import 'package:docs/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveRoute', () {
    test('/ is the home', () {
      expect(resolveRoute('/').kind, RouteKind.home);
    });

    test('a kit slug resolves to its landing page', () {
      final r = resolveRoute('/widget_kit');
      expect(r.kind, RouteKind.kitLanding);
      expect(r.title, 'widget_kit');
      expect(r.child, isNotNull);
    });

    test('a page slug resolves to that page', () {
      final r = resolveRoute('/widget_kit/app-button');
      expect(r.kind, RouteKind.page);
      expect(r.title, 'AppButton');
      expect(r.child, isNotNull);
    });

    test('a trailing slash is ignored', () {
      expect(resolveRoute('/widget_kit/').kind, RouteKind.kitLanding);
    });

    // The address bar is user input: a stale link must land on a 404, not throw.
    test('unknown kit and unknown page both resolve to notFound', () {
      expect(resolveRoute('/nope').kind, RouteKind.notFound);
      expect(resolveRoute('/widget_kit/nope').kind, RouteKind.notFound);
    });

    test('every catalog route resolves', () {
      for (final kit in catalog) {
        expect(resolveRoute('/${kit.slug}').kind, RouteKind.kitLanding);
        for (final page in kit.pages) {
          expect(
            resolveRoute(page.routeFor(kit.slug)).kind,
            RouteKind.page,
            reason: '${page.routeFor(kit.slug)} should resolve',
          );
        }
      }
    });
  });

  group('DartSyntax', () {
    final theme = ThemeData.light();

    test('preserves the source exactly', () {
      const code = "// hi\nfinal x = AppButton(label: 'Go', size: 3);";
      final flat = _flatten(DartSyntax.highlight(code, theme));
      expect(flat, code);
    });

    test('colours keywords, strings, types and comments differently', () {
      const code = "final AppButton b = 'x'; // note";
      final spans = DartSyntax.highlight(code, theme).children!
          .cast<TextSpan>()
          .where((s) => s.style?.color != null);
      final colours = spans.map((s) => s.style!.color).toSet();
      expect(colours.length, greaterThanOrEqualTo(4));
    });
  });
}

/// Re-joins a highlighted span tree back into plain text.
String _flatten(TextSpan span) {
  final buffer = StringBuffer(span.text ?? '');
  for (final child in span.children ?? const <InlineSpan>[]) {
    buffer.write(_flatten(child as TextSpan));
  }
  return buffer.toString();
}
