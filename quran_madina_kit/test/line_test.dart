import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/line.dart';
import 'package:quran_madina_kit/src/models.dart';
import 'package:quran_madina_kit/src/ranges.dart';
import 'package:quran_madina_kit/src/theme.dart';

const base = TextStyle(fontSize: 16, color: Color(0xFF000000));
final theme = MadinaTheme.light();

SpanBuildResult build(
  String text, {
  int counter = 0,
  WordRange? display,
  WordRange? highlight,
  WordRange? error,
}) =>
    buildWordSpans(
      text: text,
      counter: counter,
      displayRange: display,
      highlightRange: highlight,
      errorRange: error,
      base: base,
      theme: theme,
    );

/// The non-whitespace spans, in order.
List<TextSpan> visible(SpanBuildResult r) => r.spans
    .cast<TextSpan>()
    .where((s) => (s.text ?? '').trim().isNotEmpty)
    .toList();

void main() {
  _cacheTests();

  group('buildWordSpans', () {
    test('emits one span per token and preserves the whitespace between them',
        () {
      final r = build('ٱلْحَمْدُ لِلَّهِ');
      final joined = r.spans.cast<TextSpan>().map((s) => s.text).join();
      expect(joined, 'ٱلْحَمْدُ لِلَّهِ',
          reason: 'the concatenated spans must reproduce the source exactly');
    });

    test('preserves a leading space (mid-line continuation parts have one)',
        () {
      final r = build(' ٱهْدِنَا');
      expect(r.spans.cast<TextSpan>().map((s) => s.text).join(), ' ٱهْدِنَا');
    });

    test('advances the counter only for letter-bearing tokens', () {
      final r = build('ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ ﴿٢﴾');
      expect(r.counter, 4, reason: 'the aya marker is not a word');
    });

    test('resumes from a non-zero counter', () {
      expect(build('أ ب', counter: 10).counter, 12);
    });

    test('a word outside the display range is transparent, not removed', () {
      final r = build('واحد اثنان ثلاثة', display: const WordRange(2, 2));
      final words = visible(r);
      expect(words.length, 3, reason: 'geometry is preserved: nothing dropped');
      expect(words[0].style!.color, kInvisible);
      expect(words[1].style!.color, base.color, reason: 'the selected word');
      expect(words[2].style!.color, kInvisible);
    });

    test('a null display range hides nothing', () {
      final r = build('واحد اثنان');
      expect(visible(r).every((s) => s.style!.color == base.color), isTrue);
    });

    test('highlight paints a background without changing the box', () {
      final r = build('واحد اثنان ثلاثة', highlight: const WordRange(2, 2));
      final words = visible(r);
      expect(words[1].style!.backgroundColor, theme.highlight);
      expect(words[0].style!.backgroundColor, isNull);
    });

    test('error wins over highlight on an overlapping word', () {
      final r = build('واحد اثنان',
          highlight: const WordRange(1, 2), error: const WordRange(2, 2));
      final words = visible(r);
      expect(words[0].style!.backgroundColor, theme.highlight);
      expect(words[1].style!.backgroundColor, theme.error);
    });

    test('a marker inherits the state of the word it follows', () {
      final r = build('واحد اثنان ﴿٢﴾', display: const WordRange(1, 1));
      final tokens = visible(r);
      expect(tokens[2].text, '﴿٢﴾');
      expect(tokens[2].style!.color, kInvisible,
          reason: 'the marker follows the hidden word 2');
    });

    test('a marker after a marked word is marked too', () {
      final r = build('واحد اثنان ﴿٢﴾', highlight: const WordRange(2, 2));
      expect(visible(r)[2].style!.backgroundColor, theme.highlight);
    });

    test('a hidden word carries no mark background', () {
      final r = build('واحد اثنان',
          display: const WordRange(1, 1), highlight: const WordRange(2, 2));
      expect(visible(r)[1].style!.backgroundColor, isNull,
          reason: 'invisible words must not paint a coloured box');
    });
  });

  group('buildSpacerSpan', () {
    test('is fully transparent so it holds layout without showing', () {
      final s = buildSpacerSpan('نص سابق', base) as TextSpan;
      expect(s.text, 'نص سابق');
      expect(s.style!.color, kInvisible);
    });
  });

  group('resolveScaleX', () {
    List<InlineSpan> spans() => [
          const TextSpan(
              text: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ', style: base)
        ];

    test('a centred line is never scaled', () {
      expect(
        resolveScaleX(
          stretch: kCentredStretch,
          stretchScale: 1,
          mode: MadinaStretchMode.stored,
          spans: spans(),
          lineWidth: 270,
          style: base,
        ),
        1.0,
      );
    });

    test('stored mode multiplies the DB factor by the size correction', () {
      expect(
        resolveScaleX(
          stretch: 1.2,
          stretchScale: 1.05,
          mode: MadinaStretchMode.stored,
          spans: spans(),
          lineWidth: 270,
          style: base,
        ),
        closeTo(1.26, 1e-9),
      );
    });

    test('measured mode derives the factor from the real width', () {
      final s = resolveScaleX(
        stretch: 1.2,
        stretchScale: 1.05,
        mode: MadinaStretchMode.measured,
        spans: spans(),
        lineWidth: 270,
        style: base,
      );
      expect(s, greaterThan(0));
      expect(s, isNot(closeTo(1.26, 1e-9)),
          reason: 'measured ignores the stored factor entirely');
    });

    test('measured mode on empty spans falls back to 1', () {
      expect(
        resolveScaleX(
          stretch: 1.2,
          stretchScale: 1,
          mode: MadinaStretchMode.measured,
          spans: const [],
          lineWidth: 270,
          style: base,
        ),
        1.0,
      );
    });
  });

  group('MadinaLine widget', () {
    Widget host(Widget child) =>
        Directionality(textDirection: TextDirection.rtl, child: child);

    testWidgets('a stretched line gets a scaleX transform anchored top-right',
        (tester) async {
      await tester.pumpWidget(host(const MadinaLine(
        spans: [TextSpan(text: 'نص', style: base)],
        stretch: 1.5,
        stretchScale: 1,
        lineWidth: 270,
        mode: MadinaStretchMode.stored,
        style: base,
      )));
      final t = tester.widget<Transform>(find.byType(Transform).first);
      expect(t.alignment, Alignment.topRight);
      expect(t.transform.storage[0], 1.5);
    });

    testWidgets('stretchScale multiplies into the transform', (tester) async {
      await tester.pumpWidget(host(const MadinaLine(
        spans: [TextSpan(text: 'نص', style: base)],
        stretch: 1.2,
        stretchScale: 1.5,
        lineWidth: 270,
        mode: MadinaStretchMode.stored,
        style: base,
      )));
      final t = tester.widget<Transform>(find.byType(Transform).first);
      expect(t.transform.storage[0], closeTo(1.8, 1e-9));
    });

    testWidgets('a centred line is centred, not transformed', (tester) async {
      await tester.pumpWidget(host(const MadinaLine(
        spans: [TextSpan(text: 'سورة الفاتحة', style: base)],
        stretch: kCentredStretch,
        stretchScale: 1,
        lineWidth: 270,
        mode: MadinaStretchMode.stored,
        style: base,
      )));
      // Centring is geometric now, not a textAlign property: an RTL paragraph
      // asked to align itself inside a narrower box is unreliable, so the line
      // is laid out at its natural width and positioned by the OverflowBox.
      expect(find.byType(Transform), findsNothing,
          reason: 'a centred line is never scaled');
      final box = tester.widget<OverflowBox>(find.byType(OverflowBox));
      expect(box.alignment, Alignment.topCenter);
      expect(box.maxWidth, double.infinity,
          reason: 'the paragraph must keep its natural width');
    });

    testWidgets('never wraps and never clips the line', (tester) async {
      await tester.pumpWidget(host(MadinaLine(
        spans: [TextSpan(text: 'كلمة ' * 40, style: base)],
        stretch: 1,
        stretchScale: 1,
        lineWidth: 270,
        mode: MadinaStretchMode.stored,
        style: base,
      )));
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.softWrap, isFalse);
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.visible);
    });

    testWidgets('the line box is exactly lineWidth wide', (tester) async {
      await tester.pumpWidget(host(const Center(
        child: MadinaLine(
          spans: [TextSpan(text: 'نص', style: base)],
          stretch: 1,
          stretchScale: 1,
          lineWidth: 270,
          mode: MadinaStretchMode.stored,
          style: base,
        ),
      )));
      expect(tester.getSize(find.byType(MadinaLine)).width, 270);
    });

    testWidgets('ignores the platform text scale factor', (tester) async {
      // The Madina geometry is absolute: an OS-level text scale would break the
      // pre-computed stretch, so the line opts out.
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: host(const MadinaLine(
          spans: [TextSpan(text: 'نص', style: base)],
          stretch: 1,
          stretchScale: 1,
          lineWidth: 270,
          mode: MadinaStretchMode.stored,
          style: base,
        )),
      ));
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.textScaler, TextScaler.noScaling);
    });
  });
}

/// The measured-mode width cache: a real second call must not re-layout.
void _cacheTests() {
  group('measured-mode width cache', () {
    setUp(resetMadinaWidthCache);

    test('a repeat measurement is served from the cache', () {
      List<InlineSpan> spans() => [
            const TextSpan(
                text: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ', style: base)
          ];

      double time(void Function() body) {
        final sw = Stopwatch()..start();
        for (var i = 0; i < 200; i++) {
          body();
        }
        return sw.elapsedMicroseconds / 200;
      }

      double measure() => resolveScaleX(
            stretch: 1.1,
            stretchScale: 1,
            mode: MadinaStretchMode.measured,
            spans: spans(),
            lineWidth: 270,
            style: base,
          );

      final first = measure();
      final warm = time(measure);
      expect(measure(), first, reason: 'the cached value must be identical');
      expect(warm, lessThan(20),
          reason: 'a cache hit must be far cheaper than the ~78us layout, '
              'was ${warm.toStringAsFixed(1)}us');
    });

    test('a different font size is measured separately', () {
      const other = TextStyle(fontSize: 24, color: Color(0xFF000000));
      final a = resolveScaleX(
        stretch: 1,
        stretchScale: 1,
        mode: MadinaStretchMode.measured,
        spans: const [TextSpan(text: 'نص', style: base)],
        lineWidth: 270,
        style: base,
      );
      final b = resolveScaleX(
        stretch: 1,
        stretchScale: 1,
        mode: MadinaStretchMode.measured,
        spans: const [TextSpan(text: 'نص', style: other)],
        lineWidth: 270,
        style: other,
      );
      expect(a, isNot(b), reason: 'the key must include the style');
    });
  });
}
