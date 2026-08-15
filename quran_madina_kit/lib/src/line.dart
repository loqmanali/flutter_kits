import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'models.dart';
import 'ranges.dart';
import 'theme.dart';

/// Transparent, so a hidden word or a context spacer still occupies its exact
/// advance width. Removing it would reflow the line and destroy the
/// pre-computed Madina justification.
const Color kInvisible = Color(0x00000000);

/// Whitespace runs and non-whitespace runs, in document order.
final RegExp _tokens = RegExp(r'\s+|\S+');

class SpanBuildResult {
  const SpanBuildResult({required this.spans, required this.counter});

  final List<InlineSpan> spans;

  /// The running 1-based word index after this text.
  final int counter;
}

/// Splits [text] into one span per whitespace-separated token.
///
/// Tokenising on whitespace never breaks an Arabic shaping run (letters do not
/// join across a space), which is exactly why the web version can use one
/// `<span>` per word; a single Dart paragraph is even safer, and gives correct
/// bidi ordering for free.
///
/// A non-word token (aya marker, waqf mark, ornament) is never counted, but it
/// attaches to the word it follows — the aya-end marker is appended to that
/// aya's last word at build time — so it inherits that word's visibility and
/// mark.
SpanBuildResult buildWordSpans({
  required String text,
  required int counter,
  required TextStyle base,
  required MadinaTheme theme,
  WordRange? displayRange,
  WordRange? highlightRange,
  WordRange? errorRange,
  GestureRecognizer? recognizer,
}) {
  final spans = <InlineSpan>[];
  var n = counter;

  // allMatches, not split: Dart's String.split drops a capturing group's match,
  // so splitting on `(\s+)` would silently swallow every space — unlike
  // JavaScript, where the capture is kept. The alternation instead walks
  // whitespace and non-whitespace runs in order, reproducing the text exactly.
  for (final match in _tokens.allMatches(text)) {
    final token = match[0]!;
    if (token.trim().isEmpty) {
      spans.add(TextSpan(text: token, style: base, recognizer: recognizer));
      continue;
    }
    if (isWordToken(token)) n++;

    final hidden = displayRange != null && !displayRange.contains(n);
    Color? background;
    var foreground = base.color;
    if (errorRange != null && errorRange.contains(n)) {
      background = theme.error;
      foreground = theme.errorText;
    } else if (highlightRange != null && highlightRange.contains(n)) {
      background = theme.highlight;
      foreground = theme.highlightText;
    }

    spans.add(TextSpan(
      text: token,
      // backgroundColor only — no padding, margin or border: every word's
      // measured width feeds the line's pre-computed stretch/kashida geometry,
      // so any added box size would visibly distort the justification.
      style: base.copyWith(
        color: hidden ? kInvisible : foreground,
        backgroundColor: hidden ? null : background,
      ),
      recognizer: recognizer,
    ));
  }
  return SpanBuildResult(spans: spans, counter: n);
}

/// Preceding/following page text rendered invisibly, so the line's own centring
/// or stretch places the first visible word exactly as on the page.
InlineSpan buildSpacerSpan(String text, TextStyle base) =>
    TextSpan(text: text, style: base.copyWith(color: kInvisible));

/// Natural size of a line, already measured, keyed by text + style.
///
/// A `measured`-mode line costs one TextPainter.layout() (~78us on an M-series
/// Mac, ~1.2ms for a 15-line page), and the same page is re-laid-out on every
/// rebuild — a scroll, a theme change, a setState above it. Memoising the
/// measurement makes every rebuild after the first free.
final Map<String, ({double width, double height})> _naturalSizes = {};

/// Bounded so a long reading session cannot grow it without limit. A whole
/// mushaf is ~8800 lines, so this holds several pages' worth and drops the lot
/// rather than carrying LRU bookkeeping for a cache this cheap to refill.
const int _widthCacheLimit = 2000;

@visibleForTesting
void resetMadinaWidthCache() => _naturalSizes.clear();

({double width, double height}) naturalLineSize(
  List<InlineSpan> spans,
  TextStyle style,
) {
  final buffer = StringBuffer()
    ..write(style.fontFamily)
    ..write('|')
    ..write(style.fontSize)
    ..write('|')
    ..write(style.height);
  for (final span in spans) {
    if (span is TextSpan) buffer.write(span.text ?? '');
  }
  final key = buffer.toString();

  final hit = _naturalSizes[key];
  if (hit != null) return hit;

  final painter = TextPainter(
    text: TextSpan(children: spans, style: style),
    textDirection: TextDirection.rtl,
    maxLines: 1,
    textScaler: TextScaler.noScaling,
  )..layout();
  final size = (width: painter.width, height: painter.height);
  painter.dispose();

  if (_naturalSizes.length >= _widthCacheLimit) _naturalSizes.clear();
  return _naturalSizes[key] = size;
}

/// The scaleX to apply to a line. 1.0 for a centred line.
double resolveScaleX({
  required double stretch,
  required double stretchScale,
  required MadinaStretchMode mode,
  required List<InlineSpan> spans,
  required double lineWidth,
  required TextStyle style,
}) {
  if (stretch == kCentredStretch) return 1;
  if (mode == MadinaStretchMode.stored) return stretch * stretchScale;

  final natural = naturalLineSize(spans, style).width;
  if (natural <= 0) return 1;
  return lineWidth / natural;
}

/// One visual line of the Mushaf: a single non-wrapping RTL paragraph, either
/// scaled horizontally to fill the frame or centred.
class MadinaLine extends StatelessWidget {
  const MadinaLine({
    super.key,
    required this.spans,
    required this.stretch,
    required this.stretchScale,
    required this.lineWidth,
    required this.mode,
    required this.style,
  });

  final List<InlineSpan> spans;
  final double stretch;
  final double stretchScale;
  final double lineWidth;
  final MadinaStretchMode mode;
  final TextStyle style;

  bool get isCentred => stretch == kCentredStretch;

  @override
  Widget build(BuildContext context) {
    // Two rules make the geometry come out right, and both are easy to get
    // subtly wrong:
    //
    // 1. The paragraph must be laid out at its NATURAL width. Asking an RTL
    //    paragraph to align itself inside a narrower box is not consistent —
    //    a line wider than the box lands flush right, a narrower one flush
    //    left — so the box is never allowed to decide.
    // 2. The widget that positions it must let it EXCEED the frame. Align and
    //    Stack loosen constraints but still cap the child at the parent's
    //    width, which re-clamps a compressed line and paints it from the wrong
    //    origin: lines with stretch < 1 came out shifted right by up to 23px —
    //    correct width, wrong position, ink outside the frame. OverflowBox
    //    hands the child unbounded width and, unlike UnconstrainedBox, treats
    //    the deliberate overflow as normal rather than a debug warning.
    //
    // The measured size supplies the bounded height OverflowBox needs, and is
    // the same cached measurement `measured` mode already uses.
    final natural = naturalLineSize(spans, style);
    final text = Text.rich(
      TextSpan(children: spans, style: style),
      textDirection: TextDirection.rtl,
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.visible,
      textScaler: TextScaler.noScaling,
    );

    Widget framed(Alignment alignment) => SizedBox(
          width: lineWidth,
          height: natural.height,
          child: OverflowBox(
            alignment: alignment,
            minWidth: 0,
            maxWidth: double.infinity,
            minHeight: 0,
            maxHeight: natural.height,
            child: text,
          ),
        );

    if (isCentred) return framed(Alignment.topCenter);

    return Transform(
      // The RTL line grows leftwards from its right edge, matching the web's
      // `transform-origin: top right`.
      alignment: Alignment.topRight,
      transform: Matrix4.diagonal3Values(
        resolveScaleX(
          stretch: stretch,
          stretchScale: stretchScale,
          mode: mode,
          spans: spans,
          lineWidth: lineWidth,
          style: style,
        ),
        1,
        1,
      ),
      child: framed(Alignment.topRight),
    );
  }
}
