import 'models.dart';
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
