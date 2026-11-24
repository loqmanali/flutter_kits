/// The JSON DB shape shared with the `quran-madina-html` web runtime.
///
/// The DBs are consumed byte-for-byte as published; nothing here rewrites them.
library;

/// A part's `s` of -1 means "centre this line" rather than a scaleX factor.
const double kCentredStretch = -1;

/// One run of text on one page-line. The DB's `{l, t, s}`.
class RenderPart {
  const RenderPart({
    required this.line,
    required this.text,
    required this.stretch,
  });

  factory RenderPart.fromJson(Map<String, dynamic> j) => RenderPart(
        line: j['l'] as int,
        text: j['t'] as String,
        stretch: (j['s'] as num).toDouble(),
      );

  /// Line number within the page, 1..15.
  final int line;

  /// The text as laid out, including any build-inserted kashidas and the
  /// aya-number ornament appended to the aya's last word.
  final String text;

  /// scaleX factor filling the line, or [kCentredStretch].
  final double stretch;

  bool get isCentred => stretch == kCentredStretch;
}

/// One aya (or decoration slot) and the page-lines it occupies.
class Aya {
  const Aya({required this.page, required this.parts});

  factory Aya.fromJson(Map<String, dynamic> j) => Aya(
        page: j['p'] as int,
        parts: partsFromJson(j['r'] as List<dynamic>),
      );

  final int page;
  final List<RenderPart> parts;

  static List<RenderPart> partsFromJson(List<dynamic> raw) => raw
      .map((e) => RenderPart.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
}

/// A sura's name plus its aya slots.
///
/// Slots stay null until the owning juz' shard is merged, so every reader must
/// treat null as "not loaded — not on this page, stop walking".
class SuraSkeleton {
  SuraSkeleton({required this.name, required this.ayas});

  final String name;
  final List<Aya?> ayas;
}

/// One `[sura, ayaIndex, page, parts]` tuple from a juz' shard.
class JuzEntry {
  const JuzEntry({
    required this.sura,
    required this.ayaIndex,
    required this.page,
    required this.parts,
  });

  final int sura;
  final int ayaIndex;
  final int page;
  final List<RenderPart> parts;
}

/// `juz-NN.json`: `{"j": index, "d": [[sura, aya, page, parts], ...]}`.
class JuzShard {
  const JuzShard({required this.index, required this.entries});

  factory JuzShard.fromJson(Map<String, dynamic> j) => JuzShard(
        index: j['j'] as int,
        entries: (j['d'] as List<dynamic>).map((e) {
          final t = e as List<dynamic>;
          return JuzEntry(
            sura: t[0] as int,
            ayaIndex: t[1] as int,
            page: t[2] as int,
            parts: Aya.partsFromJson(t[3] as List<dynamic>),
          );
        }).toList(growable: false),
      );

  final int index;
  final List<JuzEntry> entries;
}

/// The DB header plus the sura skeleton, from either the sharded `manifest.json`
/// or a monolithic `<stem>.json`.
class MadinaManifest {
  MadinaManifest({
    required this.title,
    required this.published,
    required this.fontFamily,
    required this.fontUrl,
    required this.fontSize,
    required this.lineWidth,
    required this.suras,
    this.contentHash,
    this.juz,
    this.pages,
  });

  factory MadinaManifest.fromManifestJson(Map<String, dynamic> j) =>
      MadinaManifest(
        title: j['title'] as String,
        published: j['published'] as int,
        fontFamily: j['font_family'] as String,
        fontUrl: j['font_url'] as String,
        fontSize: (j['font_size'] as num).toDouble(),
        lineWidth: (j['line_width'] as num).toDouble(),
        contentHash: j['content_hash'] as String?,
        suras: (j['suras'] as List<dynamic>).map((e) {
          final pair = e as List<dynamic>;
          return SuraSkeleton(
            name: pair[0] as String,
            ayas: List<Aya?>.filled(pair[1] as int, null),
          );
        }).toList(growable: false),
        juz: j['juz'] == null ? null : _intTable(j['juz']),
        pages: j['pages'] == null ? null : _intTable(j['pages']),
      );

  factory MadinaManifest.fromMonolithJson(Map<String, dynamic> j) =>
      MadinaManifest(
        title: j['title'] as String,
        published: j['published'] as int,
        fontFamily: j['font_family'] as String,
        fontUrl: j['font_url'] as String,
        fontSize: (j['font_size'] as num).toDouble(),
        lineWidth: (j['line_width'] as num).toDouble(),
        contentHash: j['content_hash'] as String?,
        suras: (j['suras'] as List<dynamic>).map((e) {
          final s = e as Map<String, dynamic>;
          return SuraSkeleton(
            name: s['name'] as String,
            ayas: (s['ayas'] as List<dynamic>)
                .map<Aya?>((a) =>
                    a == null ? null : Aya.fromJson(a as Map<String, dynamic>))
                .toList(),
          );
        }).toList(growable: false),
      );

  final String title;
  final int published;
  final String fontFamily;
  final String fontUrl;

  /// Mutable: a non-anchor font size overrides these after interpolation.
  double fontSize;
  double lineWidth;

  /// Applied to every stored stretch factor; 1 unless the size is interpolated.
  double stretchScale = 1;

  /// sha256 prefix over the whole DB. A change means cached shards are stale.
  final String? contentHash;

  final List<SuraSkeleton> suras;

  /// `[sura, ayaIndex, startPage]` x30, or null in monolith mode.
  final List<List<int>>? juz;

  /// `[suraFrom, ayaFrom, suraTo, ayaTo]` x604, or null in monolith mode.
  final List<List<int>>? pages;

  bool get isSharded => juz != null;

  static List<List<int>> _intTable(Object? raw) => (raw as List<dynamic>)
      .map((e) => (e as List<dynamic>).cast<int>())
      .toList(growable: false);
}
