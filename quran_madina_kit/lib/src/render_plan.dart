import 'layout.dart';
import 'models.dart';
import 'ranges.dart';
import 'repository.dart';
import 'theme.dart';

/// One render part placed on a planned line.
class PlannedPart {
  const PlannedPart({
    required this.sura,
    required this.ayaIndex,
    required this.part,
    required this.countable,
  });

  final int sura;
  final int ayaIndex;
  final RenderPart part;
  final bool countable;
}

/// One visual line of the plan, with the invisible page text that flanks it.
class PlannedLine {
  PlannedLine({required this.line, this.stretch = 1});

  final int line;
  double stretch;
  final List<PlannedPart> parts = [];
  final List<RenderPart> leadingContext = [];
  final List<RenderPart> trailingContext = [];

  /// A line holding a sura title gets the decorative frame.
  bool get hasTitle =>
      parts.any((p) => p.ayaIndex == 0 || (p.sura == 0 && p.ayaIndex == 1));
}

/// A complete, render-ready description of what to draw.
class RenderPlan {
  const RenderPlan({
    required this.lines,
    required this.multiline,
    required this.page,
    required this.suraName,
    required this.suraNumber,
    required this.firstAyaNumber,
    required this.totalWords,
  });

  final List<PlannedLine> lines;
  final bool multiline;
  final int page;
  final String suraName;

  /// 1-based, for the translate deep-link.
  final int suraNumber;

  /// 1-based real aya number of the first rendered aya, or null for a page
  /// render (whose translate link targets the page instead).
  final int? firstAyaNumber;

  /// Countable words displayed — the bound `highlight=`/`error=` validate
  /// against.
  final int totalWords;
}

int countVerseRangeWords(MadinaDb db, int sura0, int ayaFrom, int ayaTo) {
  var n = 0;
  for (var a = ayaFrom; a <= ayaTo; a++) {
    final aya = db.aya(sura0, a);
    if (aya != null && isCountableAya(sura0, a)) n += countAyaWords(aya);
  }
  return n;
}

/// A flat count over a page's real ayas, deliberately not reusing the plan's
/// line-grouping bookkeeping — that exists only to build lines.
int countPageWords(
  MadinaDb db, {
  required int suraFrom,
  required int ayaFrom,
  required int suraTo,
  required int ayaTo,
  required int page,
}) {
  var n = 0;
  for (var s = suraFrom; s <= suraTo; s++) {
    if (s < 0 || s >= db.suras.length) continue;
    final slots = db.suras[s].ayas.length;
    final from = (s == suraFrom) ? ayaFrom : 0;
    final to = (s == suraTo) ? ayaTo : slots - 1;
    for (var a = from; a <= to; a++) {
      final aya = db.aya(s, a);
      if (aya == null || aya.page != page) continue;
      if (isCountableAya(s, a)) n += countAyaWords(aya);
    }
  }
  return n;
}

/// `inline="no"` forces the multiline layout; `"yes"` is not implemented and
/// falls back to auto with a warning, matching the web runtime.
bool applyInlineOverride(
  MadinaInline inline,
  bool multiline,
  void Function(String) log,
) {
  switch (inline) {
    case MadinaInline.auto:
      return multiline;
    case MadinaInline.no:
      return true;
    case MadinaInline.yes:
      log('inline="yes" is not implemented yet; falling back to "auto"');
      return multiline;
  }
}

/// Plans a `page` or `sura`+`aya` render.
///
/// Returns null (after logging) rather than throwing on bad arguments, so a
/// misconfigured widget renders nothing instead of crashing the host app.
RenderPlan? planVerseOrPage(
  MadinaDb db, {
  int? page,
  int? sura,
  String? aya,
  MadinaInline inline = MadinaInline.auto,
  required void Function(String) log,
}) {
  final verseMode = sura != null && aya != null;
  final int suraFrom;
  final int suraTo;
  final int ayaFrom;
  final int ayaTo;
  final int targetPage;
  bool multiline;

  if (verseMode) {
    final s0 = parseSura(sura.toString());
    final range = parseAyaRange(aya);
    if (s0 == null || range == null) {
      log('Bad arguments: Not rendering!');
      return null;
    }
    suraFrom = suraTo = s0;
    ayaFrom = range.from;
    ayaTo = range.to;
    if (page != null) log('Ignoring page parameter!');
    final anchor = db.aya(suraFrom, ayaFrom);
    if (anchor == null) {
      log('Bad arguments: Not rendering!');
      return null;
    }
    targetPage = anchor.page;
    multiline = false;
  } else if (page != null) {
    final bounds = db.pageBounds(page);
    if (bounds == null) {
      log('Bad arguments: Not rendering!');
      return null;
    }
    suraFrom = bounds.suraFrom;
    ayaFrom = bounds.ayaFrom;
    suraTo = bounds.suraTo;
    ayaTo = bounds.ayaTo;
    targetPage = page;
    multiline = true;
    if (inline != MadinaInline.auto) {
      log('Ignoring inline parameter with page!');
    }
  } else {
    log('Bad arguments: Not rendering!');
    return null;
  }

  final firstAya = db.aya(suraFrom, ayaFrom);
  final lastAya = db.aya(suraTo, ayaTo);
  if (firstAya == null || lastAya == null) {
    log('Bad arguments: Not rendering!');
    return null;
  }
  final lineFrom = firstAya.parts.first.line;
  final lineTo = lastAya.parts.last.line;
  if (lineFrom != lineTo) multiline = true;
  if (verseMode) multiline = applyInlineOverride(inline, multiline, log);

  final lines = <PlannedLine>[];
  var ayaCurrent = ayaFrom;
  var suraCurrent = suraFrom;

  for (var l = lineFrom; l <= lineTo; l++) {
    final planned = PlannedLine(line: l);
    if (multiline && verseMode && l == lineFrom) {
      planned.leadingContext.addAll(lineContext(
        db,
        sura0: suraFrom,
        page: targetPage,
        line: lineFrom,
        ayaIndex: ayaFrom,
        direction: -1,
      ));
    }

    final lookAhead =
        (suraFrom == suraTo) ? ayaTo : db.suras[suraCurrent].ayas.length - 1;
    final windowEnd = ayaCurrent + 5 < lookAhead ? ayaCurrent + 5 : lookAhead;
    // The +5 window and the sura-jump peek can probe an unloaded aya, but any
    // such aya is necessarily off this page, so null means "not here".
    for (var a = ayaCurrent; a <= windowEnd; a++) {
      final ayaA = db.aya(suraCurrent, a);
      if (ayaA == null || ayaA.page != targetPage) continue;
      final match = partOnLine(ayaA, l);
      if (match == null) continue;

      planned.stretch = match.stretch;
      planned.parts.add(PlannedPart(
        sura: suraCurrent,
        ayaIndex: a,
        part: match,
        countable: isCountableAya(suraCurrent, a),
      ));
      ayaCurrent = a;

      final nextSuraSlot0 = (suraCurrent < db.suras.length - 1)
          ? db.aya(suraCurrent + 1, 0)
          : null;
      if (ayaCurrent >= lookAhead &&
          nextSuraSlot0 != null &&
          nextSuraSlot0.page == targetPage &&
          nextSuraSlot0.parts.first.line == l + 1) {
        suraCurrent++;
        ayaCurrent = 0;
      }
    }

    if (multiline && verseMode && l == lineTo) {
      planned.trailingContext.addAll(lineContext(
        db,
        sura0: suraTo,
        page: targetPage,
        line: lineTo,
        ayaIndex: ayaTo,
        direction: 1,
      ));
    }
    lines.add(planned);
  }

  final total = verseMode
      ? countVerseRangeWords(db, suraFrom, ayaFrom, ayaTo)
      : countPageWords(
          db,
          suraFrom: suraFrom,
          ayaFrom: ayaFrom,
          suraTo: suraTo,
          ayaTo: ayaTo,
          page: targetPage,
        );

  return RenderPlan(
    lines: lines,
    multiline: multiline,
    page: targetPage,
    suraName: db.suras[suraFrom].name,
    suraNumber: suraFrom + 1,
    firstAyaNumber: verseMode ? ayaFrom - 1 : null,
    totalWords: total,
  );
}
