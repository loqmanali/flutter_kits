import 'models.dart';
import 'ranges.dart';
import 'repository.dart';

/// The aya's render part that falls on [line], or null.
RenderPart? partOnLine(Aya aya, int line) {
  for (final part in aya.parts) {
    if (part.line == line) return part;
  }
  return null;
}

/// True when this aya's part on [line] is the first (rightmost, RTL) on its
/// page-line — the previous aya does not also sit there.
///
/// The DB carries no pixel offset, so line starts are derived structurally: the
/// render walks ayas in order. A sura beginning mid-line counts as a line start
/// (its preceding text lives in the previous sura).
bool isLineStartPart(MadinaDb db, int sura0, int ayaIndex, int line) {
  if (ayaIndex <= 0) return true;
  final prev = db.aya(sura0, ayaIndex - 1);
  if (prev == null) return true; // not loaded (shard boundary): treat as start
  final current = db.aya(sura0, ayaIndex);
  if (current == null || prev.page != current.page) return true;
  return partOnLine(prev, line) == null;
}

/// Parts on (page, line) lying outside the selection on one side, in reading
/// order.
///
/// [direction] < 0 walks back from the first selected aya (the text preceding
/// it); > 0 walks forward from the last. Rendering these invisibly lets the
/// line's own centring or stretch place the visible text exactly where it sits
/// on the full page.
List<RenderPart> lineContext(
  MadinaDb db, {
  required int sura0,
  required int page,
  required int line,
  required int ayaIndex,
  required int direction,
}) {
  final parts = <RenderPart>[];
  if (sura0 < 0 || sura0 >= db.suras.length) return parts;
  final slots = db.suras[sura0].ayas.length;

  for (var a = ayaIndex + direction; a >= 0 && a < slots; a += direction) {
    final aya = db.aya(sura0, a);
    if (aya == null) break; // not-yet-loaded aya (shard boundary)
    if (aya.page != page) break;
    final match = partOnLine(aya, line);
    if (match == null) break;
    if (direction < 0) {
      parts.insert(0, match);
      if (isLineStartPart(db, sura0, a, line)) break; // reached the line start
    } else {
      parts.add(match);
    }
  }
  return parts;
}

/// One render part inside a collected visual line.
class CollectedPart {
  const CollectedPart({
    required this.sura,
    required this.ayaIndex,
    required this.part,
    required this.countable,
  });

  final int sura;
  final int ayaIndex;
  final RenderPart part;

  /// False for title slots, which are decoration and never counted or marked.
  final bool countable;
}

/// A visual line, keyed `"$page:$line"`.
class CollectedLine {
  CollectedLine({required this.key, required this.stretch});

  final String key;
  final double stretch;
  final List<CollectedPart> parts = [];

  /// Running countable-word index this line ends at; filled during trimming.
  int lastWord = 0;

  int get page => int.parse(key.split(':')[0]);
  int get line => int.parse(key.split(':')[1]);
}

class CollectedWords {
  const CollectedWords({required this.lines, required this.counterStart});

  final List<CollectedLine> lines;

  /// Words on dropped leading lines, so downstream visibility still lines up.
  final int counterStart;
}

/// Walks ayas in reading order from (suraStart, ayaStart), crossing page AND
/// sura boundaries, grouping parts into visual lines until [range]'s end word
/// is covered.
///
/// Past the last sura the walk WRAPS AROUND to the first, matching the flat
/// Tanzil indexing consumers count with modulo the Quran; the caller's 500-word
/// cap and the single-cycle bound keep the wrap finite.
CollectedWords collectWordParts(
  MadinaDb db, {
  required int suraStart,
  required int ayaStart,
  required WordRange range,
}) {
  final lines = <CollectedLine>[];
  CollectedLine? current;
  var counted = 0;
  final suraCount = db.suras.length;
  if (suraCount == 0) {
    return const CollectedWords(lines: [], counterStart: 0);
  }

  // Anchoring at a sura's first real aya rewinds to its basmala slot, so word 1
  // is بسم — the same Tanzil indexing as everywhere else. Al-Fatiha is exempt:
  // its slot 1 holds its *title* (its basmala is real aya 1).
  final anchorBegin = (ayaStart == 2 && suraStart > 0) ? 1 : ayaStart;

  for (var si = 0; si < suraCount; si++) {
    final s = (suraStart + si) % suraCount;
    final slots = db.suras[s].ayas.length;
    final ayaBegin = (si == 0) ? anchorBegin : 0;
    var reached = false;

    for (var a = ayaBegin; a < slots; a++) {
      final aya = db.aya(s, a);
      if (aya == null) break; // unloaded shard boundary: stop collecting
      final countable = isCountableAya(s, a);

      for (final part in aya.parts) {
        // Blank decoration placeholders (Al-Fatiha's slot 0, At-Tawba's
        // basmala-less slot 1) must not become empty rendered lines.
        if (part.text.isEmpty) continue;
        final key = '${aya.page}:${part.line}';
        if (current == null || current.key != key) {
          current = CollectedLine(key: key, stretch: part.stretch);
          lines.add(current);
        }
        current.parts.add(CollectedPart(
          sura: s,
          ayaIndex: a,
          part: part,
          countable: countable,
        ));
      }

      if (countable) {
        counted += countAyaWords(aya);
        if (counted >= range.end) {
          reached = true;
          break;
        }
      }
    }
    if (reached) break;
  }

  if (lines.isEmpty) return const CollectedWords(lines: [], counterStart: 0);

  // Annotate each line with the running countable-word index it ends at, then
  // drop the lines entirely outside the selection — leading lines before
  // range.start and trailing lines after range.end (the latter appear because
  // collection grabs whole ayas, which may run onto further lines). The block
  // then begins and ends on lines that actually show a selected word.
  var running = 0;
  for (final line in lines) {
    for (final item in line.parts) {
      if (item.countable) running += countPartWords(item.part);
    }
    line.lastWord = running;
  }

  var start = 0;
  while (start < lines.length - 1 && lines[start].lastWord < range.start) {
    start++;
  }
  var end = start;
  while (end < lines.length - 1 && lines[end].lastWord < range.end) {
    end++;
  }
  return CollectedWords(
    lines: lines.sublist(start, end + 1),
    counterStart: start > 0 ? lines[start - 1].lastWord : 0,
  );
}
