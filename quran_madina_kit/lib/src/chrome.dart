import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'line.dart';
import 'webview.dart';
import 'theme.dart';

/// The copy body: only spans that are actually visible, whitespace collapsed.
///
/// Built from the span model rather than from rendered text, so the header
/// chrome, the transparent layout spacers and the words hidden by a `words=`
/// selection are all excluded by construction.
String visibleTextOf(Iterable<InlineSpan> spans) {
  final buffer = StringBuffer();
  for (final span in spans) {
    if (span is! TextSpan) continue;
    if ((span.style?.color?.a ?? 1) == 0) continue;
    buffer.write(span.text ?? '');
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

String copyText({required String body, required String suraName}) =>
    '“$body”\n\n$suraName';

Uri translateUri({int? sura, int? aya, int? page}) =>
    (sura != null && aya != null)
        ? Uri.parse('https://quran.com/$sura/$aya')
        : Uri.parse('https://quran.com/page/$page');

/// Copies [text] and confirms it, matching the web's `alert` acknowledgement.
Future<void> copyAndNotify(BuildContext context, String text) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  await Clipboard.setData(ClipboardData(text: text));
  messenger?.showSnackBar(
    SnackBar(content: Text('⎘ تم نسخ:\n\n$text', maxLines: 4)),
  );
}

/// Runs the configured translate handler, defaulting to the kit's in-app page.
///
/// Nothing here ever leaves the app: handing a reader off to a browser loses
/// their place in the Mushaf.
Future<void> openTranslate(BuildContext context, Uri uri, {String? title}) {
  final handler = MadinaScope.of(context).config.onTranslate;
  if (handler != null) return handler(context, uri);
  return openMadinaWebPage(context, uri, title: title);
}

/// Opening and closing quote marks for an inline (single-line) render — its
/// only visual cue that the text is a quoted excerpt, since it has no header.
List<InlineSpan> withQuoteMarks(List<InlineSpan> spans, TextStyle base) {
  final mark = base.copyWith(
    color: mixWithTransparent(base.color ?? const Color(0xFF000000), 0.5),
  );
  return [
    TextSpan(text: '”', style: mark),
    ...spans,
    TextSpan(text: '“', style: mark),
  ];
}

/// Sura name plus copy and translate actions, above a multiline render.
class MadinaHeader extends StatelessWidget {
  const MadinaHeader({
    super.key,
    required this.suraName,
    required this.theme,
    required this.onCopy,
    required this.onTranslate,
  });

  final String suraName;
  final MadinaTheme theme;
  final VoidCallback onCopy;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) {
    final ambient =
        DefaultTextStyle.of(context).style.color ?? const Color(0xFF000000);
    final dim = mixWithTransparent(ambient, 0.6);
    return Container(
      height: 25,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.only(left: 5, right: 10),
      color: mixWithTransparent(theme.header, 0.2),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              suraName,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: dim, fontSize: 12),
            ),
          ),
          _IconButton(Icons.copy_rounded, colour: dim, onTap: onCopy),
          const SizedBox(width: 4),
          _IconButton(Icons.translate_rounded, colour: dim, onTap: onTranslate),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton(this.icon, {required this.colour, required this.onTap});

  final IconData icon;
  final Color colour;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: onTap,
        radius: 16,
        child: Icon(icon, size: 18, color: colour),
      );
}

/// The decorative frame behind a sura-title line.
///
/// The web uses `mask-image` + `currentColor` so the frame follows the ambient
/// text colour; `ColorFilter.mode(colour, srcIn)` is the direct equivalent. It
/// paints *behind* the child, so the name text stays visible.
class SuraFrame extends StatelessWidget {
  const SuraFrame({super.key, required this.child, required this.colour});

  final Widget child;
  final Color colour;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: FractionallySizedBox(
              widthFactor: 0.95,
              child: SvgPicture.asset(
                'assets/img/sura_border_sym4.svg',
                package: 'quran_madina_kit',
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(colour, BlendMode.srcIn),
              ),
            ),
          ),
          child,
        ],
      );
}

/// Copy and translate scoped to one aya, shown over it on tap.
class AyaPopup extends StatelessWidget {
  const AyaPopup({
    super.key,
    required this.theme,
    required this.onCopy,
    required this.onTranslate,
  });

  final MadinaTheme theme;
  final VoidCallback onCopy;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) => Material(
        color: mixWithTransparent(theme.header, 0.85),
        borderRadius: BorderRadius.circular(6),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconButton(Icons.copy_rounded,
                  colour: theme.background, onTap: onCopy),
              const SizedBox(width: 8),
              _IconButton(Icons.translate_rounded,
                  colour: theme.background, onTap: onTranslate),
            ],
          ),
        ),
      );
}

OverlayEntry? _openPopup;

void closeAyaPopup() {
  _openPopup?.remove();
  _openPopup = null;
}

/// Shows the per-aya popup above [anchor], flipping below when that would run
/// off the top of the screen.
void showAyaPopup(
  BuildContext context, {
  required Rect anchor,
  required String text,
  required String suraName,
  required int sura,
  required int aya,
  required MadinaTheme theme,
}) {
  closeAyaPopup();
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  const estHeight = 34.0;
  final top = anchor.top - estHeight - 6 > 0
      ? anchor.top - estHeight - 6
      : anchor.bottom + 6;

  final entry = OverlayEntry(
    builder: (_) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: closeAyaPopup,
          ),
        ),
        Positioned(
          left: anchor.left.clamp(4.0, double.infinity),
          top: top,
          child: AyaPopup(
            theme: theme,
            onCopy: () {
              copyAndNotify(context, copyText(body: text, suraName: suraName));
              closeAyaPopup();
            },
            onTranslate: () {
              openTranslate(context, translateUri(sura: sura, aya: aya),
                  title: suraName);
              closeAyaPopup();
            },
          ),
        ),
      ],
    ),
  );
  _openPopup = entry;
  overlay.insert(entry);
}

/// The inset "gutter" shadow of the printed page: on the right for an odd
/// (right-hand) page, on the left for an even one.
///
/// Flutter has no inset box-shadow, so this is the same effect drawn as a thin
/// gradient over the frame edge.
class PageGutter extends StatelessWidget {
  const PageGutter({super.key, required this.child, required this.page});

  final Widget child;
  final int page;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: page.isOdd
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    end: page.isOdd
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    stops: const [0, 0.03],
                    colors: [
                      const Color(0xFF333333).withValues(alpha: 0.28),
                      const Color(0x00333333),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

/// Marks every span of one aya so a tap or hover can find them again.
///
/// The line renderer emits one paragraph per line, so an aya's spans are a
/// contiguous slice of it; recording that slice is what lets the popup position
/// itself over the aya rather than at the raw tap point.
class AyaSpanRange {
  const AyaSpanRange({
    required this.sura,
    required this.aya,
    required this.start,
    required this.end,
  });

  /// 1-based sura number.
  final int sura;

  /// 1-based real aya number.
  final int aya;

  /// Character offsets within the line's plain text.
  final int start;
  final int end;
}

/// Renders one line's spans with hover highlight and per-aya tap handling.
class InteractiveMadinaLine extends StatefulWidget {
  const InteractiveMadinaLine({
    super.key,
    required this.line,
    required this.ayas,
    required this.suraName,
    required this.theme,
  });

  final MadinaLine line;
  final List<AyaSpanRange> ayas;
  final String suraName;
  final MadinaTheme theme;

  @override
  State<InteractiveMadinaLine> createState() => _InteractiveMadinaLineState();
}

class _InteractiveMadinaLineState extends State<InteractiveMadinaLine> {
  final GlobalKey _key = GlobalKey();

  AyaSpanRange? _hitTest(Offset local) {
    final box = _key.currentContext?.findRenderObject();
    if (box is! RenderBox) return null;
    final painter = TextPainter(
      text: TextSpan(children: widget.line.spans, style: widget.line.style),
      textDirection: TextDirection.rtl,
      maxLines: 1,
      textScaler: TextScaler.noScaling,
    )..layout(maxWidth: widget.line.lineWidth);
    final offset = painter.getPositionForOffset(local).offset;
    painter.dispose();
    for (final aya in widget.ayas) {
      if (offset >= aya.start && offset < aya.end) return aya;
    }
    return null;
  }

  void _onTap(TapUpDetails details) {
    final hit = _hitTest(details.localPosition);
    // Decoration slots are deliberately non-tappable: a title has nothing to
    // copy, and the basmala has no quran.com verse of its own to link.
    if (hit == null || hit.aya < 1) return;
    final box = _key.currentContext?.findRenderObject();
    if (box is! RenderBox) return;
    final origin = box.localToGlobal(Offset.zero);
    showAyaPopup(
      context,
      anchor: origin & box.size,
      text: visibleTextOf(widget.line.spans),
      suraName: widget.suraName,
      sura: hit.sura,
      aya: hit.aya,
      theme: widget.theme,
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: widget.ayas.isEmpty ? null : _onTap,
        child: KeyedSubtree(key: _key, child: widget.line),
      );
}
