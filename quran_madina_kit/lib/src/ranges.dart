import 'models.dart';

/// The traditional basmala ligature (U+FDFD).
///
/// Shown whenever the complete basmala is displayed; the DB stores its 4 real
/// word tokens instead, so they can be counted and selected individually.
const String kBasmalaLigature = '﷽';

/// A `words=` selection is capped at this many words.
const int kMaxWordsSelection = 500;

/// A render token counts as a selectable word only if it carries an Arabic
/// letter.
///
/// Everything else in the Madina text is its own whitespace-separated token and
/// must not be counted, or the word index drifts: aya-number ornaments
/// (`﴿١﴾`, `۝١`), waqf marks (`ۖ ۗ ۘ ۙ ۚ ۛ ۜ`) and the `۞`/`۩` ornaments all
/// lack one.
///
/// Escapes rather than literals, matching the web runtime: U+0621-U+064A (basic
/// Arabic letters) and U+0671-U+06D3 (alef-wasla etc.).
final RegExp _arabicLetter = RegExp('[ء-يٱ-ۓ]');

final RegExp _whitespace = RegExp(r'\s+');

bool isWordToken(String token) => _arabicLetter.hasMatch(token);

/// Slot 1 is the basmala of every sura except Al-Fatiha, whose slot 1 holds its
/// title (its basmala is real aya 1). At-Tawba's slot exists but is blank.
bool isBasmalaSlot(int sura0, int ayaIndex) => ayaIndex == 1 && sura0 != 0;

/// Title slots never count as words: slot 0 everywhere, and Al-Fatiha's title
/// at slot 1.
bool isCountableAya(int sura0, int ayaIndex) =>
    ayaIndex >= (sura0 == 0 ? 2 : 1);

int countPartWords(RenderPart part) {
  var n = 0;
  for (final token in part.text.split(_whitespace)) {
    if (isWordToken(token)) n++;
  }
  return n;
}

int countAyaWords(Aya aya) {
  var n = 0;
  for (final part in aya.parts) {
    n += countPartWords(part);
  }
  return n;
}

/// `sura="2"` -> 0. A range's first element wins (the web forces from == to).
int? parseSura(String raw) {
  final n = int.tryParse(raw.split('-').first.trim());
  return n == null ? null : n - 1;
}

/// `aya="255"` -> (256, 256); `aya="1-3"` -> (2, 4).
///
/// The +1 skips the title and basmala decoration slots that precede every
/// sura's real ayas.
({int from, int to})? parseAyaRange(String raw) {
  final parts = raw.split('-').map((e) => int.tryParse(e.trim())).toList();
  if (parts.any((e) => e == null)) return null;
  if (parts.length == 2) return (from: parts[0]! + 1, to: parts[1]! + 1);
  if (parts.length == 1) return (from: parts[0]! + 1, to: parts[0]! + 1);
  return null;
}

/// A 1-based, inclusive word range.
class WordRange {
  const WordRange(this.start, this.end);

  final int start;
  final int end;

  int get length => end - start + 1;

  /// The same range capped at [kMaxWordsSelection] words.
  WordRange get capped => length > kMaxWordsSelection
      ? WordRange(start, start + kMaxWordsSelection - 1)
      : this;

  bool contains(int index) => index >= start && index <= end;

  @override
  bool operator ==(Object other) =>
      other is WordRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start-$end';
}

/// `"n"` -> [n, n]; `"n-m"` or `"n:m"` -> [n, m].
///
/// Null when malformed, when the start is below 1, or when the range runs
/// backwards.
WordRange? parseWordsRange(String? raw) {
  if (raw == null) return null;
  final parts =
      raw.split(RegExp('[-:]')).map((e) => int.tryParse(e.trim())).toList();
  if (parts.any((e) => e == null)) return null;
  final int start;
  final int end;
  if (parts.length == 1) {
    start = end = parts[0]!;
  } else if (parts.length == 2) {
    start = parts[0]!;
    end = parts[1]!;
  } else {
    return null;
  }
  if (start < 1 || end < start) return null;
  return WordRange(start, end);
}

/// Which mark class a rendered basmala ligature carries.
enum BasmalaMark { none, highlight, error }

/// How a basmala slot renders: the single ligature glyph, or its individual
/// word tokens so a partial selection/mark stays visible.
class BasmalaMode {
  const BasmalaMode({required this.ligature, this.mark = BasmalaMark.none});

  final bool ligature;
  final BasmalaMark mark;
}

/// Decides between the `﷽` ligature and the 4 individual tokens.
///
/// [counter] is the running 1-based word index *before* the basmala, so its
/// words occupy `counter+1 .. counter+basmalaWords`. Either way the caller
/// advances the counter by [basmalaWords].
BasmalaMode basmalaRenderMode({
  required int counter,
  required int basmalaWords,
  WordRange? displayRange,
  WordRange? highlightRange,
  WordRange? errorRange,
}) {
  bool fullyIn(WordRange? r) =>
      r == null || (counter + 1 >= r.start && counter + basmalaWords <= r.end);
  bool partiallyIn(WordRange? r) =>
      r != null &&
      !fullyIn(r) &&
      counter + basmalaWords >= r.start &&
      counter + 1 <= r.end;

  if (!fullyIn(displayRange)) return const BasmalaMode(ligature: false);
  // A mark cutting into only some of the 4 words forces the tokens so the
  // partial mark is actually visible.
  if (partiallyIn(highlightRange) || partiallyIn(errorRange)) {
    return const BasmalaMode(ligature: false);
  }
  if (errorRange != null && fullyIn(errorRange)) {
    return const BasmalaMode(ligature: true, mark: BasmalaMark.error);
  }
  if (highlightRange != null && fullyIn(highlightRange)) {
    return const BasmalaMode(ligature: true, mark: BasmalaMark.highlight);
  }
  return const BasmalaMode(ligature: true);
}

/// Validates a `highlight=`/`error=` range against the words actually being
/// displayed.
///
/// Out of bounds warns and drops the mark rather than aborting the render —
/// unlike a malformed `words=`, which falls back to the verse render.
WordRange? clampedOrNull(
  String label,
  WordRange? range,
  int minBound,
  int maxBound,
  void Function(String) log,
) {
  if (range == null) return null;
  if (range.start < minBound || range.end > maxBound) {
    log('$label range ${range.start}-${range.end} outside displayed words '
        '$minBound-$maxBound, ignoring');
    return null;
  }
  return range;
}
