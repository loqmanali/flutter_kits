import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter/widgets.dart';

import 'chrome.dart';
import 'interpolation.dart';
import 'layout.dart';
import 'line.dart';
import 'ranges.dart';
import 'render_plan.dart';
import 'repository.dart';
import 'source.dart';
import 'theme.dart';

void _log(String message) => debugPrint('quran_madina_kit> $message');

/// A booted DB plus its loaded font family, shared by every view using the same
/// configuration so several views cost one boot and one font load.
class _Booted {
  _Booted(this.db);

  final MadinaDb db;
}

final Map<String, Future<_Booted?>> _bootCache = {};

/// The `content_hash` last seen per shard base, so a rebuilt DB purges the
/// cached shards exactly once — the sessionStorage bookkeeping the web does.
final Map<String, String> _seenHashes = {};

/// Family the basmala ligature falls back to.
///
/// Only the Amiri fonts carry U+FDFD; Hafs, Uthman and me_quran do not, so the
/// glyph would render blank. A browser papers over this by falling back across
/// every installed system font — Flutter only consults the families you name,
/// so the kit loads one itself. The printed Mushaf shows an ornamental ligature
/// there, which is exactly what Amiri's glyph is.
const String kBasmalaFallbackFamily = 'QmhBasmalaLigature';
const String _basmalaFallbackAsset = 'assets/fonts/AmiriQuran.woff2';
Future<void>? _basmalaFallback;

@visibleForTesting
void resetMadinaBootCache() {
  _bootCache.clear();
  _seenHashes.clear();
  _basmalaFallback = null;
}

Future<void> _loadBasmalaFallback(MadinaSource source) =>
    _basmalaFallback ??= () async {
      final bytes = await source.loadFont(_basmalaFallbackAsset);
      if (bytes == null) {
        _log('basmala ligature fallback font unavailable; '
            '﷽ may render blank in fonts that lack U+FDFD');
        return;
      }
      await (FontLoader(kBasmalaFallbackFamily)
            ..addFont(Future.value(ByteData.sublistView(bytes))))
          .load();
    }();

Future<_Booted?> _boot(MadinaConfig config) {
  final key = '${config.name}|${config.font}|${config.fontSize}|'
      '${config.source.hashCode}';
  return _bootCache.putIfAbsent(key, () async {
    final source = config.source ?? MadinaAssetSource();
    final size = clampFontSize(config.fontSize, _log);

    // A non-anchor size has no DB of its own: fit it between the two anchors
    // and render the nearest anchor's data re-targeted to it.
    final overrides = await resolveSizeOverrides(
      source: source,
      name: config.name,
      font: config.font,
      requested: size,
      log: _log,
    );
    final dbSize = overrides?.nearestAnchor ?? size;

    final base = 'db/${MadinaDb.stemFor(config.name, config.font, dbSize)}/';
    final db = await MadinaDb.boot(
      source: source,
      name: config.name,
      font: config.font,
      fontSize: dbSize,
      log: _log,
      previousHash: _seenHashes[base],
      onCacheClear: source.clearCache,
    );
    if (db == null) return null;
    final hash = db.manifest.contentHash;
    if (hash != null) _seenHashes[db.shardBase] = hash;

    if (overrides != null) {
      db.manifest.fontSize = overrides.fontSize;
      db.manifest.lineWidth = overrides.lineWidth;
      db.manifest.stretchScale = overrides.stretchScale;
    }

    final bytes = await source.loadFont(db.manifest.fontUrl);
    if (bytes != null) {
      final loader = FontLoader(db.manifest.fontFamily)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    } else {
      _log('font ${db.manifest.fontUrl} unavailable; '
          'falling back to the platform default');
    }
    await _loadBasmalaFallback(source);
    return _Booted(db);
  });
}

/// Which juz' shards a pending render will read. Empty in monolith mode.
List<int> neededJuz(
  MadinaDb db, {
  int? page,
  int? sura,
  String? aya,
  String? words,
}) {
  final juz = db.manifest.juz;
  if (juz == null) return const [];

  if (sura != null && aya != null) {
    final s0 = parseSura(sura.toString());
    final range = parseAyaRange(aya);
    if (s0 == null || range == null) return const [];
    if (words != null) {
      // A words selection spills forward less than one juz'; from the last one
      // it wraps around to Al-Fatiha's, so the successor is taken modulo.
      final j = db.suraAyaToJuz(s0, range.from);
      return [j, (j + 1) % juz.length];
    }
    final from = db.suraAyaToJuz(s0, range.from);
    final to = db.suraAyaToJuz(s0, range.to);
    return [for (var k = from; k <= to; k++) k];
  }

  if (page != null) {
    final b = db.pageBounds(page);
    if (b == null) return const [];
    final from = db.suraAyaToJuz(b.suraFrom, b.ayaFrom);
    final to = db.suraAyaToJuz(b.suraTo, b.ayaTo);
    return [for (var k = from; k <= to; k++) k];
  }
  return const [];
}

/// Renders Quran text laid out exactly as on the printed Madina Mushaf page.
///
/// Either [page] (a full page) or [sura] + [aya] (a verse range). When both are
/// given, [sura]/[aya] wins and [page] is ignored with a warning.
class QuranMadinaView extends StatefulWidget {
  const QuranMadinaView({
    super.key,
    this.page,
    this.sura,
    this.aya,
    this.words,
    this.highlight,
    this.error,
    this.headless = false,
    this.quotes = true,
    this.inline = MadinaInline.auto,
    this.notitle = false,
    this.loading,
  });

  /// 1-based page number, 1..604.
  final int? page;

  /// 1-based sura number, 1..114.
  final int? sura;

  /// 1-based aya, `"n"` or `"n-m"`.
  final String? aya;

  /// 1-based inclusive word range: `"n"`, `"n-m"` or `"n:m"`. Counted from
  /// [sura]/[aya] and may run past it, crossing page and sura boundaries.
  /// Ignored with [page].
  final String? words;

  /// 1-based inclusive word range to mark in soft yellow. Works in every mode.
  final String? highlight;

  /// 1-based inclusive word range to mark in soft red. Wins over [highlight].
  final String? error;

  /// Hide the header and frame chrome, keeping only the Quran text.
  final bool headless;

  /// Show quote marks around an inline (single-line) render.
  final bool quotes;

  /// Force or auto-detect the inline vs multiline layout.
  final MadinaInline inline;

  /// Hide a crossed-into sura's name text while keeping its decorated line.
  /// `words` path only.
  final bool notitle;

  /// Shown while the DB and font load.
  final Widget? loading;

  @override
  State<QuranMadinaView> createState() => _QuranMadinaViewState();
}

class _QuranMadinaViewState extends State<QuranMadinaView> {
  Future<MadinaDb?>? _ready;
  MadinaConfig? _config;

  /// Boot the DB and font, then pull in the juz' shards this render reads.
  ///
  /// Deliberately one future rather than two nested ones: the gap between them
  /// has no scheduled frame, which strands `pumpAndSettle` in tests and adds a
  /// pointless second placeholder flash at runtime.
  Future<MadinaDb?> _prepare(MadinaConfig config) async {
    final booted = await _boot(config);
    if (booted == null) return null;
    await booted.db.ensureJuz(neededJuz(
      booted.db,
      page: widget.page,
      sura: widget.sura,
      aya: widget.aya,
      words: widget.words,
    ));
    return booted.db;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final config = MadinaScope.of(context).config;
    if (config != _config || _ready == null) {
      _config = config;
      _ready = _prepare(config);
    }
  }

  @override
  void didUpdateWidget(QuranMadinaView old) {
    super.didUpdateWidget(old);
    if (old.page != widget.page ||
        old.sura != widget.sura ||
        old.aya != widget.aya ||
        old.words != widget.words) {
      _ready = _prepare(_config!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = MadinaScope.of(context);
    return FutureBuilder<MadinaDb?>(
      future: _ready,
      builder: (context, snapshot) {
        final db = snapshot.data;
        if (db == null) return widget.loading ?? const SizedBox.shrink();
        return _build(context, db, scope);
      },
    );
  }

  Widget _build(BuildContext context, MadinaDb db, MadinaScope scope) {
    final ambient =
        DefaultTextStyle.of(context).style.color ?? const Color(0xFF000000);
    final theme = scope.theme.forAmbient(ambient);
    final manifest = db.manifest;

    final style = TextStyle(
      fontFamily: manifest.fontFamily,
      fontSize: manifest.fontSize,
      color: ambient,
      // me_quran's glyphs overshoot their em box; the web gives it a doubled
      // line box for the same reason.
      height: manifest.fontFamily == 'me_quran' ? 2.0 : null,
    );

    var highlightRange = parseWordsRange(widget.highlight);
    if (widget.highlight != null && highlightRange == null) {
      _log('Bad highlight parameter: ${widget.highlight}');
    }
    var errorRange = parseWordsRange(widget.error);
    if (widget.error != null && errorRange == null) {
      _log('Bad error parameter: ${widget.error}');
    }

    // words= has its own renderer: it is not bound to a single page or sura, so
    // the selection can run past the anchor aya across page and sura
    // boundaries. A malformed range falls through to the normal verse render.
    if (widget.words != null) {
      final wordsView = _buildWordsView(
        db,
        style: style,
        theme: theme,
        stretchMode: scope.config.stretchMode,
        highlightRange: highlightRange,
        errorRange: errorRange,
      );
      if (wordsView != null) return wordsView;
    }

    final plan = planVerseOrPage(
      db,
      page: widget.page,
      sura: widget.sura,
      aya: widget.aya,
      inline: widget.inline,
      log: _log,
    );
    if (plan == null) return const SizedBox.shrink();
    // Validated against the full verse/page: word 1 is the first word of the
    // first aya (a page never starts mid-aya, so this is always well-defined).
    highlightRange =
        clampedOrNull('highlight', highlightRange, 1, plan.totalWords, _log);
    errorRange = clampedOrNull('error', errorRange, 1, plan.totalWords, _log);
    final marking = highlightRange != null || errorRange != null;

    var counter = 0;
    final lines = <Widget>[];
    for (final planned in plan.lines) {
      final spans = <InlineSpan>[];
      final ayas = <AyaSpanRange>[];
      var offset = 0;
      for (final part in planned.leadingContext) {
        spans.add(buildSpacerSpan(part.text, style));
        offset += part.text.length;
      }
      for (final part in planned.parts) {
        final partStart = offset;
        offset += part.part.text.length;
        ayas.add(AyaSpanRange(
          sura: part.sura + 1,
          aya: part.ayaIndex - 1,
          start: partStart,
          end: offset,
        ));
        final basmalaWords = isBasmalaSlot(part.sura, part.ayaIndex)
            ? countPartWords(part.part)
            : 0;
        final mode = basmalaWords > 0
            ? basmalaRenderMode(
                counter: counter,
                basmalaWords: basmalaWords,
                highlightRange: marking ? highlightRange : null,
                errorRange: marking ? errorRange : null,
              )
            : const BasmalaMode(ligature: false);

        if (mode.ligature) {
          spans.add(TextSpan(
            text: kBasmalaLigature,
            style: _basmalaStyle(style, _markColour(mode.mark, theme)),
          ));
          counter += basmalaWords;
        } else if (!marking || !part.countable) {
          // No marks to place (or an uncountable title): one plain blob, the
          // web's untouched textContent path.
          spans.add(TextSpan(text: part.part.text, style: style));
        } else {
          final built = buildWordSpans(
            text: part.part.text,
            counter: counter,
            base: style,
            theme: theme,
            highlightRange: highlightRange,
            errorRange: errorRange,
          );
          spans.addAll(built.spans);
          counter = built.counter;
        }
        if (!marking && part.countable) {
          counter += countPartWords(part.part);
        }
      }
      for (final part in planned.trailingContext) {
        spans.add(buildSpacerSpan(part.text, style));
      }

      lines.add(_decorate(
        MadinaLine(
          spans: plan.multiline || !widget.quotes
              ? spans
              : withQuoteMarks(spans, style),
          stretch: planned.stretch,
          stretchScale: manifest.stretchScale,
          lineWidth: manifest.lineWidth,
          mode: scope.config.stretchMode,
          style: style,
        ),
        ayas: ayas,
        hasTitle: planned.hasTitle,
        suraName: plan.suraName,
        theme: theme,
        ambient: ambient,
      ));
    }

    return _frame(
      lines,
      multiline: plan.multiline,
      width: manifest.lineWidth,
      page: plan.page,
      theme: theme,
      header: widget.headless
          ? null
          : (
              name: plan.suraName,
              sura: plan.suraNumber,
              aya: plan.firstAyaNumber
            ),
    );
  }

  /// The `words=` render path.
  ///
  /// Returns null when the parameter cannot be honoured (used with `page`, or
  /// malformed), so the caller falls back to the normal verse render — the web
  /// runtime's behaviour.
  Widget? _buildWordsView(
    MadinaDb db, {
    required TextStyle style,
    required MadinaTheme theme,
    required MadinaStretchMode stretchMode,
    required WordRange? highlightRange,
    required WordRange? errorRange,
  }) {
    final verseMode = widget.sura != null && widget.aya != null;
    if (!verseMode) {
      _log('Ignoring words parameter with page!');
      return null;
    }
    final parsed = parseWordsRange(widget.words);
    if (parsed == null) {
      _log('Bad words parameter: ${widget.words}');
      return null;
    }
    final sura0 = parseSura(widget.sura.toString());
    final ayaRange = parseAyaRange(widget.aya!);
    if (sura0 == null || ayaRange == null) {
      _log('Bad arguments: Not rendering!');
      return null;
    }
    if (ayaRange.to != ayaRange.from) {
      _log('Ignoring aya range end with words parameter!');
    }
    final range = parsed.capped;
    if (range.end != parsed.end) {
      _log('words selection capped at $kMaxWordsSelection words');
    }
    // Marks are validated against the selection, not the whole verse.
    final highlight = clampedOrNull(
        'highlight', highlightRange, range.start, range.end, _log);
    final error =
        clampedOrNull('error', errorRange, range.start, range.end, _log);

    final collected = collectWordParts(
      db,
      suraStart: sura0,
      ayaStart: ayaRange.from,
      range: range,
    );
    if (collected.lines.isEmpty) return const SizedBox.shrink();

    final manifest = db.manifest;
    var counter = collected.counterStart;
    final widgets = <MadinaLine>[];
    final lineAyas = <List<AyaSpanRange>>[];
    final groupsOut = <CollectedLine>[];

    for (var i = 0; i < collected.lines.length; i++) {
      final group = collected.lines[i];
      final spans = <InlineSpan>[];
      final ayas = <AyaSpanRange>[];
      var offset = 0;
      final first = group.parts.first;

      // Only the leading line can begin mid-line; every later group enters a
      // line at its right start. Rebuilding the preceding page text invisibly
      // lets the line's own centring/stretch place the first visible word
      // exactly where it sits on the full page.
      if (i == 0 &&
          !isLineStartPart(db, first.sura, first.ayaIndex, first.part.line)) {
        for (final part in lineContext(
          db,
          sura0: first.sura,
          page: group.page,
          line: group.line,
          ayaIndex: first.ayaIndex,
          direction: -1,
        )) {
          spans.add(buildSpacerSpan(part.text, style));
          offset += part.text.length;
        }
      }

      for (final item in group.parts) {
        final partStart = offset;
        offset += item.part.text.length;
        ayas.add(AyaSpanRange(
          sura: item.sura + 1,
          aya: item.ayaIndex - 1,
          start: partStart,
          end: offset,
        ));
        if (!item.countable) {
          // A sura title, shown for context but never counted or markable.
          // notitle keeps its line and frame but blanks the name text.
          spans.add(widget.notitle
              ? buildSpacerSpan(item.part.text, style)
              : TextSpan(text: item.part.text, style: style));
          continue;
        }
        final basmalaWords = isBasmalaSlot(item.sura, item.ayaIndex)
            ? countPartWords(item.part)
            : 0;
        final mode = basmalaWords > 0
            ? basmalaRenderMode(
                counter: counter,
                basmalaWords: basmalaWords,
                displayRange: range,
                highlightRange: highlight,
                errorRange: error,
              )
            : const BasmalaMode(ligature: false);

        if (mode.ligature) {
          spans.add(TextSpan(
            text: kBasmalaLigature,
            style: _basmalaStyle(style, _markColour(mode.mark, theme)),
          ));
          counter += basmalaWords;
        } else {
          final built = buildWordSpans(
            text: item.part.text,
            counter: counter,
            base: style,
            theme: theme,
            displayRange: range,
            highlightRange: highlight,
            errorRange: error,
          );
          spans.addAll(built.spans);
          counter = built.counter;
        }
      }

      if (i == collected.lines.length - 1) {
        // The selection ends mid-line: rebuild the following text invisibly so
        // the last line stays laid out (and centred) exactly as on the page.
        final last = group.parts.last;
        for (final part in lineContext(
          db,
          sura0: last.sura,
          page: group.page,
          line: group.line,
          ayaIndex: last.ayaIndex,
          direction: 1,
        )) {
          spans.add(buildSpacerSpan(part.text, style));
        }
      }

      lineAyas.add(ayas);
      groupsOut.add(group);
      widgets.add(MadinaLine(
        spans: spans,
        stretch: group.stretch,
        stretchScale: manifest.stretchScale,
        lineWidth: manifest.lineWidth,
        mode: stretchMode,
        style: style,
      ));
    }

    final multiline =
        applyInlineOverride(widget.inline, widgets.length > 1, _log);
    final suraName = db.suras[collected.lines.first.parts.first.sura].name;
    final decorated = [
      for (var i = 0; i < widgets.length; i++)
        _decorate(
          multiline || !widget.quotes
              ? widgets[i]
              : _withQuotes(widgets[i], style),
          ayas: lineAyas[i],
          hasTitle: groupsOut[i]
              .parts
              .any((p) => p.ayaIndex == 0 || (p.sura == 0 && p.ayaIndex == 1)),
          suraName: suraName,
          theme: theme,
          ambient: style.color ?? const Color(0xFF000000),
        ),
    ];
    return _frame(
      decorated,
      multiline: multiline,
      width: manifest.lineWidth,
      page: collected.lines.first.page,
      theme: theme,
      header: widget.headless
          ? null
          : (
              name: suraName,
              sura: collected.lines.first.parts.first.sura + 1,
              aya: null
            ),
    );
  }

  /// Wraps one line in the chrome it needs: the decorative frame behind a sura
  /// title, and per-aya tap handling for the copy/translate popup.
  Widget _decorate(
    MadinaLine line, {
    required List<AyaSpanRange> ayas,
    required bool hasTitle,
    required String suraName,
    required MadinaTheme theme,
    required Color ambient,
  }) {
    final interactive = InteractiveMadinaLine(
      line: line,
      ayas: ayas,
      suraName: suraName,
      theme: theme,
    );
    return hasTitle
        ? SuraFrame(colour: ambient, child: interactive)
        : interactive;
  }

  /// The block-level chrome: header, page-parity gutter, and the frame width.
  /// An inline (single-line) render gets none of it.
  Widget _frame(
    List<Widget> lines, {
    required bool multiline,
    required double width,
    required int page,
    required MadinaTheme theme,
    ({String name, int sura, int? aya})? header,
  }) {
    if (!multiline) {
      return lines.isEmpty ? const SizedBox.shrink() : lines.single;
    }
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (header != null)
          MadinaHeader(
            suraName: header.name,
            theme: theme,
            onCopy: () => _copyAll(lines, header.name),
            onTranslate: () => openTranslate(
              context,
              header.aya != null
                  ? translateUri(sura: header.sura, aya: header.aya)
                  : translateUri(page: page),
              title: header.name,
            ),
          ),
        ...lines,
      ],
    );
    final sized = SizedBox(width: width + 10, child: column);
    return header == null ? sized : PageGutter(page: page, child: sized);
  }

  void _copyAll(List<Widget> lines, String suraName) {
    final body = lines
        .map(_lineOf)
        .whereType<MadinaLine>()
        .map((l) => visibleTextOf(l.spans))
        .where((t) => t.isNotEmpty)
        .join(' ');
    copyAndNotify(context, copyText(body: body, suraName: suraName));
  }

  /// Unwraps whatever chrome [_decorate] put around a line.
  MadinaLine? _lineOf(Widget w) => switch (w) {
        MadinaLine line => line,
        InteractiveMadinaLine i => i.line,
        SuraFrame f => _lineOf(f.child),
        _ => null,
      };
}

/// The ligature keeps the Mushaf font first, so Amiri (which has U+FDFD) uses
/// its own glyph and the others fall through to the loaded fallback family.
TextStyle _basmalaStyle(TextStyle base, Color? background) => base.copyWith(
      backgroundColor: background,
      fontFamilyFallback: const [kBasmalaFallbackFamily],
    );

Color? _markColour(BasmalaMark mark, MadinaTheme theme) => switch (mark) {
      BasmalaMark.error => theme.error,
      BasmalaMark.highlight => theme.highlight,
      BasmalaMark.none => null,
    };

/// Re-wraps a line's spans with the inline quote marks.
MadinaLine _withQuotes(MadinaLine line, TextStyle style) => MadinaLine(
      spans: withQuoteMarks(line.spans, style),
      stretch: line.stretch,
      stretchScale: line.stretchScale,
      lineWidth: line.lineWidth,
      mode: line.mode,
      style: line.style,
    );
