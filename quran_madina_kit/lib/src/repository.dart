import 'models.dart';
import 'source.dart';

/// A loaded DB: the header, the (possibly sparse) sura skeleton, and lazy juz'
/// shard loading on top of a [MadinaSource].
class MadinaDb {
  MadinaDb._({
    required this.manifest,
    required this.dbStem,
    required MadinaSource source,
    required void Function(String) log,
  })  : _source = source,
        _log = log;

  final MadinaManifest manifest;

  /// e.g. `Madina05-Hafs-16px`.
  final String dbStem;

  final MadinaSource _source;
  final void Function(String) _log;

  final Set<int> _loadedJuz = {};

  List<SuraSkeleton> get suras => manifest.suras;

  String get shardBase => 'db/$dbStem/';

  /// The aya at (sura0, ayaIndex), or null when out of range or not yet loaded.
  ///
  /// Every caller must treat null as "not on this page / stop walking".
  Aya? aya(int sura0, int ayaIndex) {
    if (sura0 < 0 || sura0 >= manifest.suras.length) return null;
    final ayas = manifest.suras[sura0].ayas;
    if (ayaIndex < 0 || ayaIndex >= ayas.length) return null;
    return ayas[ayaIndex];
  }

  static String stemFor(String name, String font, double fontSize) {
    final f = font.replaceAll(' ', '_');
    final size = fontSize == fontSize.roundToDouble()
        ? fontSize.round().toString()
        : fontSize.toString();
    return '$name-$f-${size}px';
  }

  /// Sharded manifest first, monolith second, default-size fallback last.
  ///
  /// [previousHash] is the `content_hash` last seen for this stem; when it
  /// differs from the manifest's, [onCacheClear] is called with the shard base
  /// so stale shards cached from the old content are dropped.
  static Future<MadinaDb?> boot({
    required MadinaSource source,
    required String name,
    required String font,
    required double fontSize,
    void Function(String)? log,
    String? previousHash,
    void Function(String)? onCacheClear,
    double defaultFontSize = 16,
  }) async {
    final logger = log ?? (String _) {};
    final stem = stemFor(name, font, fontSize);
    final base = 'db/$stem/';

    final manifestJson =
        await source.loadJson('${base}manifest.json', forceFresh: true);
    if (manifestJson != null) {
      final manifest = MadinaManifest.fromManifestJson(manifestJson);
      final hash = manifest.contentHash;
      if (hash != null && previousHash != null && previousHash != hash) {
        (onCacheClear ?? source.clearCache)(base);
      }
      return MadinaDb._(
        manifest: manifest,
        dbStem: stem,
        source: source,
        log: logger,
      );
    }

    final monolith = await source.loadJson('db/$stem.json');
    if (monolith != null) {
      return MadinaDb._(
        manifest: MadinaManifest.fromMonolithJson(monolith),
        dbStem: stem,
        source: source,
        log: logger,
      );
    }

    if (fontSize != defaultFontSize) {
      logger('no DB for font: $font size: $fontSize, '
          'falling back to size: ${defaultFontSize.round()}');
      return boot(
        source: source,
        name: name,
        font: font,
        fontSize: defaultFontSize,
        log: log,
        previousHash: previousHash,
        onCacheClear: onCacheClear,
        defaultFontSize: defaultFontSize,
      );
    }
    logger('no manifest and no monolithic DB for $stem');
    return null;
  }

  /// Last juz' whose (sura, aya) start is at or before this position.
  ///
  /// Decoration slots (0 and 1) resolve as if they were aya 1, so a sura that
  /// opens a juz' keeps its title and basmala in the new juz'.
  int suraAyaToJuz(int sura0, int ayaIndex) {
    final juz = manifest.juz;
    if (juz == null) return -1;
    final pa = ayaIndex < 2 ? 2 : ayaIndex;
    var found = 0;
    for (var k = 0; k < juz.length; k++) {
      if (juz[k][0] < sura0 || (juz[k][0] == sura0 && juz[k][1] <= pa)) {
        found = k;
      } else {
        break;
      }
    }
    return found;
  }

  /// Fetches and merges any not-yet-loaded shards in [indices]. No-op in
  /// monolith mode.
  ///
  /// A shard that fails to load is marked loaded anyway, so it is not retried on
  /// every render — matching the web runtime.
  Future<void> ensureJuz(List<int> indices) async {
    final juz = manifest.juz;
    if (juz == null) return;
    final need = <int>{};
    for (final j in indices) {
      if (j >= 0 && j < juz.length && !_loadedJuz.contains(j)) need.add(j);
    }
    if (need.isEmpty) return;

    await Future.wait(need.map((j) async {
      final padded = (j + 1).toString().padLeft(2, '0');
      final data = await _source.loadJson('${shardBase}juz-$padded.json');
      if (data == null) {
        _log('failed to load juz ${j + 1}');
      } else {
        _merge(JuzShard.fromJson(data));
      }
      _loadedJuz.add(j);
    }));
  }

  void _merge(JuzShard shard) {
    for (final e in shard.entries) {
      manifest.suras[e.sura].ayas[e.ayaIndex] =
          Aya(page: e.page, parts: e.parts);
    }
  }

  /// `[suraFrom, ayaFrom, suraTo, ayaTo]` for a 1-based page, or null.
  ({int suraFrom, int ayaFrom, int suraTo, int ayaTo})? pageBounds(int page) {
    final pages = manifest.pages;
    if (pages == null) return _monolithPageBounds(page);
    if (page < 1 || page > pages.length) return null;
    final b = pages[page - 1];
    return (suraFrom: b[0], ayaFrom: b[1], suraTo: b[2], ayaTo: b[3]);
  }

  /// Monolith mode has no page table: derive the bounds by scanning aya pages,
  /// exactly as the web runtime does.
  ({int suraFrom, int ayaFrom, int suraTo, int ayaTo})? _monolithPageBounds(
    int page,
  ) {
    final s = manifest.suras;
    if (s.isEmpty) return null;
    const farFuture = 1 << 30;

    var suraFrom = 0;
    while (
        suraFrom < s.length - 1 && (s[suraFrom].ayas.last?.page ?? 0) < page) {
      suraFrom++;
    }
    var suraTo = suraFrom;
    while (suraTo < s.length - 1 &&
        (s[suraTo].ayas.first?.page ?? farFuture) <= page) {
      suraTo++;
    }
    suraTo--;
    if (suraTo < suraFrom) suraTo = suraFrom;

    var ayaFrom = 0;
    final fromAyas = s[suraFrom].ayas;
    while (ayaFrom < fromAyas.length - 1 &&
        (fromAyas[ayaFrom]?.page ?? 0) < page) {
      ayaFrom++;
    }
    final toAyas = s[suraTo].ayas;
    var ayaTo = toAyas.length - 1;
    while (ayaTo > 0 && (toAyas[ayaTo]?.page ?? farFuture) > page) {
      ayaTo--;
    }
    return (suraFrom: suraFrom, ayaFrom: ayaFrom, suraTo: suraTo, ayaTo: ayaTo);
  }
}
