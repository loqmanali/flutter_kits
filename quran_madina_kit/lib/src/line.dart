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

/// The scaleX to apply to a line. 1.0 for a centred line.
double resolveScaleX({
  required double stretch,
  required double stretchScale,
  required MadinaStretchMode mode,
  required List<InlineSpan> spans,
  required double lineWidth,
  required TextStyle style,
  double? textScaleFactor,
}) {
  if (stretch == kCentredStretch) return 1;
  if (mode == MadinaStretchMode.stored) return stretch * stretchScale;

  final painter = TextPainter(
    text: TextSpan(children: spans, style: style),
    textDirection: TextDirection.rtl,
    maxLines: 1,
    textScaler: textScaleFactor == null
        ? TextScaler.noScaling
        : TextScaler.linear(textScaleFactor),
  )..layout();
  final natural = painter.width;
  painter.dispose();
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
    final text = Text.rich(
      TextSpan(children: spans, style: style),
      textDirection: TextDirection.rtl,
      textAlign: isCentred ? TextAlign.center : TextAlign.right,
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.visible,
      textScaler: TextScaler.noScaling,
    );

    if (isCentred) return SizedBox(width: lineWidth, child: text);

    final scaleX = resolveScaleX(
      stretch: stretch,
      stretchScale: stretchScale,
      mode: mode,
      spans: spans,
      lineWidth: lineWidth,
      style: style,
    );
    return SizedBox(
      width: lineWidth,
      child: Transform(
        // The RTL line grows leftwards from its right edge, matching the web's
        // `transform-origin: top right`.
        alignment: Alignment.topRight,
        transform: Matrix4.diagonal3Values(scaleX, 1, 1),
        child: text,
      ),
    );
  }
}
