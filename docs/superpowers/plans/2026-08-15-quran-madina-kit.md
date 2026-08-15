# quran_madina_kit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A Flutter package that renders Quran pages visually identical to the printed Madina Mushaf without images, driven by the same JSON databases the `quran-madina-html` web runtime consumes.

**Architecture:** Five pure-Dart layers (models → source → repository → ranges → layout) carry all the logic and are tested with plain `dart test`. Four Flutter layers (theme → line → widget → chrome) render. Every visual line is a single `Text.rich` with one `TextSpan` per whitespace token; unselected words become transparent rather than being removed, so the pre-computed Madina justification geometry survives.

**Tech Stack:** Flutter, `flutter_svg`, `http`, `url_launcher`. Python `fontTools` for a one-off font conversion.

**Spec:** `docs/superpowers/specs/2026-08-15-quran-madina-kit-design.md` — read it before Task 1. It carries the exact porting rules (§4) and the CSS→Flutter mapping table (§5) that tasks below reference by section number.

## Global Constraints

- Package root: `quran_madina_kit/` at the `flutter_kits` monorepo root. `publish_to: "none"`.
- `environment: sdk: ">=3.0.0 <4.0.0"`, `flutter: ">=3.10.0"` — matches sibling kits.
- **Do not use `Color.withValues()`** (Flutter 3.27+). Use `color.withAlpha((255 * fraction).round())` — the `color-mix(... N%, transparent)` equivalent that works at the declared floor.
- Dependencies are exactly: `flutter_svg`, `http`, `url_launcher`. **No `path_provider`** — `MadinaNetworkSource` takes an optional `Directory cacheDir` from the host app.
- `dart analyze` must be clean and `dart format` applied before every commit.
- Pure-logic files (`models.dart`, `source.dart`, `repository.dart`, `ranges.dart`, `layout.dart`) must not import `package:flutter/widgets.dart` or `material.dart`. `dart:ui` is allowed only in `line.dart` and above.
- The JSON DBs are consumed **as-is**. Never modify, regenerate, or "fix" them.
- Source repo for reference (read-only, never edit): `/Users/loqman/Documents/projects/Flutter/quran-madina-html`.

---

### Task 1: Package scaffold, fonts, and bundled DB assets

**Files:**
- Create: `quran_madina_kit/pubspec.yaml`
- Create: `quran_madina_kit/analysis_options.yaml`
- Create: `quran_madina_kit/tool/convert_fonts.py`
- Create: `quran_madina_kit/lib/quran_madina_kit.dart`
- Create: `quran_madina_kit/assets/fonts/*.ttf` (generated)
- Create: `quran_madina_kit/assets/db/Madina05-Hafs-16px/*.json` (copied)
- Create: `quran_madina_kit/assets/img/sura_border_sym4.svg` (copied)
- Test: `quran_madina_kit/test/assets_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: the package skeleton every later task builds in; asset paths `assets/db/<stem>/manifest.json`, `assets/db/<stem>/juz-NN.json`, `assets/fonts/<Family>.ttf`, `assets/img/sura_border_sym4.svg`.

- [ ] **Step 1: Create the package skeleton**

```bash
cd /Users/loqman/Documents/projects/Flutter/flutter_kits
mkdir -p quran_madina_kit/{lib/src,tool,assets/fonts,assets/img,assets/db,test,example}
```

`quran_madina_kit/pubspec.yaml`:

```yaml
name: quran_madina_kit
description: Renders Quran pages visually identical to the printed Madina Mushaf without images, driven by pre-computed JSON databases. A Flutter port of the quran-madina-html web runtime.
version: 0.1.0
publish_to: "none"

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter

  # Decorative sura-title frame (assets/img/sura_border_sym4.svg), recoloured to
  # the ambient text colour — the mask-image + currentColor trick from the web CSS.
  flutter_svg: ^2.0.9

  # MadinaNetworkSource: fetches manifest/juz shards from a CDN.
  http: ^1.2.0

  # The translate action deep-links to quran.com.
  url_launcher: ^6.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  assets:
    - assets/img/
    - assets/fonts/
    - assets/db/Madina05-Hafs-16px/
```

`quran_madina_kit/analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
```

- [ ] **Step 2: Write the font converter**

`quran_madina_kit/tool/convert_fonts.py`:

```python
"""Convert the quran-madina-html .woff2 fonts to .ttf for Flutter.

woff2 is only a Brotli-compressed sfnt container: clearing `flavor` and re-saving
writes the identical glyph/metric tables back out uncompressed. Nothing is lost,
so the glyph advances the JSON DB's stretch factors were measured against are
preserved exactly.

Run once; commit the .ttf output.

    python3 tool/convert_fonts.py ../../quran-madina-html/assets/fonts assets/fonts
"""
import os
import sys
import glob
from fontTools.ttLib import TTFont

def main(src_dir, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    sources = sorted(glob.glob(os.path.join(src_dir, "*.woff2")))
    if not sources:
        sys.exit(f"no .woff2 files under {src_dir}")
    for src in sources:
        font = TTFont(src)
        font.flavor = None  # drop the woff2 wrapper, keep every table
        out = os.path.join(out_dir, os.path.basename(src).replace(".woff2", ".ttf"))
        font.save(out)
        print(f"{os.path.basename(out):28} {os.path.getsize(out):>8} bytes  "
              f"glyphs={font['maxp'].numGlyphs:<5} upem={font['head'].unitsPerEm}")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
```

- [ ] **Step 3: Run the converter and copy the assets**

```bash
cd /Users/loqman/Documents/projects/Flutter/flutter_kits/quran_madina_kit
SRC=/Users/loqman/Documents/projects/Flutter/quran-madina-html
python3 tool/convert_fonts.py "$SRC/assets/fonts" assets/fonts
cp "$SRC/assets/img/sura_border_sym4.svg" assets/img/
mkdir -p assets/db/Madina05-Hafs-16px
cp "$SRC/assets/db/Madina05-Hafs-16px/"*.json assets/db/Madina05-Hafs-16px/
ls -la assets/fonts assets/db/Madina05-Hafs-16px | head -20
```

Expected: 5 `.ttf` files, `manifest.json` + `juz-01.json`..`juz-30.json`, and the SVG.

- [ ] **Step 4: Write the failing asset smoke test**

`quran_madina_kit/test/assets_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled Hafs 16px manifest has the expected header shape', () async {
    final raw = await rootBundle
        .loadString('packages/quran_madina_kit/assets/db/Madina05-Hafs-16px/manifest.json');
    final m = json.decode(raw) as Map<String, dynamic>;

    expect(m['font_family'], 'Hafs');
    expect(m['font_size'], 16);
    expect(m['line_width'], 270);
    expect((m['suras'] as List).length, 114);
    expect((m['juz'] as List).length, 30);
    expect((m['pages'] as List).length, 604);
  });

  test('bundled juz-01 shard carries render parts', () async {
    final raw = await rootBundle
        .loadString('packages/quran_madina_kit/assets/db/Madina05-Hafs-16px/juz-01.json');
    final shard = json.decode(raw) as Map<String, dynamic>;

    expect(shard['j'], 0);
    final entries = shard['d'] as List;
    expect(entries, isNotEmpty);
    // [sura0, ayaIdx, page, parts]
    expect((entries.first as List).length, 4);
  });

  test('Hafs font asset loads', () async {
    final bytes = await rootBundle.load('packages/quran_madina_kit/assets/fonts/Hafs.ttf');
    expect(bytes.lengthInBytes, greaterThan(50000));
  });
}
```

- [ ] **Step 5: Run the test**

```bash
cd quran_madina_kit && flutter pub get && flutter test test/assets_test.dart
```

Expected: PASS. If the manifest assertions fail, the asset copy in Step 3 went wrong — do **not** relax the assertions.

- [ ] **Step 6: Add the stub barrel and verify analysis**

`quran_madina_kit/lib/quran_madina_kit.dart`:

```dart
/// Renders Quran pages visually identical to the printed Madina Mushaf,
/// without images, from pre-computed JSON databases.
library quran_madina_kit;
```

```bash
dart format . && dart analyze
```

Expected: no issues.

- [ ] **Step 7: Commit**

```bash
cd /Users/loqman/Documents/projects/Flutter/flutter_kits
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): package scaffold, ttf fonts, bundled Hafs 16px DB"
```

---

### Task 2: Data models

**Files:**
- Create: `quran_madina_kit/lib/src/models.dart`
- Test: `quran_madina_kit/test/models_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `class RenderPart { final int line; final String text; final double stretch; RenderPart.fromJson(Map<String,dynamic>) }`
  - `class Aya { final int page; final List<RenderPart> parts; Aya.fromJson(Map<String,dynamic>) }`
  - `class SuraSkeleton { final String name; final List<Aya?> ayas; }`
  - `class MadinaManifest { title, published, fontFamily, fontUrl, fontSize, lineWidth, contentHash, suras (List<SuraSkeleton>), juz (List<List<int>>?), pages (List<List<int>>?); MadinaManifest.fromManifestJson(...); MadinaManifest.fromMonolithJson(...) }`
  - `class JuzShard { final int index; final List<JuzEntry> entries; JuzShard.fromJson(...) }`, `class JuzEntry { final int sura, ayaIndex, page; final List<RenderPart> parts; }`
  - `const double kCentredStretch = -1;`

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/models_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/models.dart';

void main() {
  group('RenderPart', () {
    test('reads l/t/s', () {
      final p = RenderPart.fromJson(json.decode('{"l":3,"t":"بِسْمِ","s":1.25}'));
      expect(p.line, 3);
      expect(p.text, 'بِسْمِ');
      expect(p.stretch, 1.25);
    });

    test('s == -1 means centred, not a scale factor', () {
      final p = RenderPart.fromJson(json.decode('{"l":1,"t":"سورة الفاتحة","s":-1}'));
      expect(p.stretch, kCentredStretch);
      expect(p.isCentred, isTrue);
    });

    test('an integer s decodes as a double', () {
      final p = RenderPart.fromJson(json.decode('{"l":1,"t":"x","s":1}'));
      expect(p.stretch, 1.0);
    });
  });

  group('MadinaManifest.fromManifestJson', () {
    final raw = json.decode('''
      {"title":"t","published":1405,"font_family":"Hafs","font_url":"assets/fonts/Hafs.woff2",
       "font_size":16,"line_width":270,"content_hash":"abc123",
       "suras":[["سورة الفاتحة",9],["سورة البقرة",288]],
       "juz":[[0,1,1],[1,142,22]],
       "pages":[[0,0,0,8],[1,0,1,7]]}
    ''') as Map<String, dynamic>;

    test('builds a sparse sura skeleton sized by the slot count', () {
      final m = MadinaManifest.fromManifestJson(raw);
      expect(m.suras.length, 2);
      expect(m.suras[0].name, 'سورة الفاتحة');
      expect(m.suras[0].ayas.length, 9);
      expect(m.suras[0].ayas.every((a) => a == null), isTrue,
          reason: 'a manifest carries no render data — shards fill it in');
    });

    test('keeps header, juz and page tables', () {
      final m = MadinaManifest.fromManifestJson(raw);
      expect(m.fontFamily, 'Hafs');
      expect(m.fontUrl, 'assets/fonts/Hafs.woff2');
      expect(m.fontSize, 16.0);
      expect(m.lineWidth, 270.0);
      expect(m.contentHash, 'abc123');
      expect(m.juz![1], [1, 142, 22]);
      expect(m.pages![0], [0, 0, 0, 8]);
    });
  });

  group('MadinaManifest.fromMonolithJson', () {
    test('populates ayas eagerly and leaves juz/pages null', () {
      final raw = json.decode('''
        {"title":"t","published":1405,"font_family":"Hafs","font_url":"f.woff2",
         "font_size":16,"line_width":270,
         "suras":[{"name":"سورة الفاتحة","ayas":[
            {"p":1,"r":[{"l":1,"t":"","s":-1}]},
            {"p":1,"r":[{"l":1,"t":"سورة الفاتحة","s":-1}]}]}]}
      ''') as Map<String, dynamic>;
      final m = MadinaManifest.fromMonolithJson(raw);
      expect(m.juz, isNull, reason: 'monolith mode has no shard tables');
      expect(m.pages, isNull);
      expect(m.suras[0].ayas.length, 2);
      expect(m.suras[0].ayas[1]!.parts.single.text, 'سورة الفاتحة');
    });
  });

  group('JuzShard', () {
    test('decodes the [sura, aya, page, parts] tuples', () {
      final raw = json.decode('''
        {"j":0,"d":[[0,2,1,[{"l":2,"t":"بِسْمِ ٱللَّهِ","s":-1}]]]}
      ''') as Map<String, dynamic>;
      final s = JuzShard.fromJson(raw);
      expect(s.index, 0);
      expect(s.entries.single.sura, 0);
      expect(s.entries.single.ayaIndex, 2);
      expect(s.entries.single.page, 1);
      expect(s.entries.single.parts.single.line, 2);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
cd quran_madina_kit && flutter test test/models_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:quran_madina_kit/src/models.dart'`.

- [ ] **Step 3: Write the implementation**

`quran_madina_kit/lib/src/models.dart`:

```dart
/// The JSON DB shape shared with the `quran-madina-html` web runtime.
///
/// The DBs are consumed byte-for-byte as published; nothing here rewrites them.
library;

/// A part's `s` of -1 means "centre this line" rather than a scaleX factor.
const double kCentredStretch = -1;

/// One run of text on one page-line. The DB's `{l, t, s}`.
class RenderPart {
  const RenderPart({required this.line, required this.text, required this.stretch});

  /// Line number within the page, 1..15.
  final int line;

  /// The text as laid out, including any build-inserted kashidas and the
  /// aya-number ornament appended to the aya's last word.
  final String text;

  /// scaleX factor filling the line, or [kCentredStretch].
  final double stretch;

  bool get isCentred => stretch == kCentredStretch;

  factory RenderPart.fromJson(Map<String, dynamic> j) => RenderPart(
        line: j['l'] as int,
        text: j['t'] as String,
        stretch: (j['s'] as num).toDouble(),
      );
}

/// One aya (or decoration slot) and the page-lines it occupies.
class Aya {
  const Aya({required this.page, required this.parts});

  final int page;
  final List<RenderPart> parts;

  factory Aya.fromJson(Map<String, dynamic> j) => Aya(
        page: j['p'] as int,
        parts: (j['r'] as List)
            .map((e) => RenderPart.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );

  static List<RenderPart> partsFromJson(List<dynamic> raw) => raw
      .map((e) => RenderPart.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
}

/// A sura's name plus its aya slots. Slots stay null until the owning juz'
/// shard is merged, so every reader must treat null as "not loaded".
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

  final int index;
  final List<JuzEntry> entries;

  factory JuzShard.fromJson(Map<String, dynamic> j) => JuzShard(
        index: j['j'] as int,
        entries: (j['d'] as List).map((e) {
          final t = e as List;
          return JuzEntry(
            sura: t[0] as int,
            ayaIndex: t[1] as int,
            page: t[2] as int,
            parts: Aya.partsFromJson(t[3] as List),
          );
        }).toList(growable: false),
      );
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

  static List<List<int>> _intTable(Object? raw) => (raw as List)
      .map((e) => (e as List).cast<int>())
      .toList(growable: false);

  factory MadinaManifest.fromManifestJson(Map<String, dynamic> j) => MadinaManifest(
        title: j['title'] as String,
        published: j['published'] as int,
        fontFamily: j['font_family'] as String,
        fontUrl: j['font_url'] as String,
        fontSize: (j['font_size'] as num).toDouble(),
        lineWidth: (j['line_width'] as num).toDouble(),
        contentHash: j['content_hash'] as String?,
        suras: (j['suras'] as List).map((e) {
          final pair = e as List;
          return SuraSkeleton(
            name: pair[0] as String,
            ayas: List<Aya?>.filled(pair[1] as int, null, growable: false),
          );
        }).toList(growable: false),
        juz: j['juz'] == null ? null : _intTable(j['juz']),
        pages: j['pages'] == null ? null : _intTable(j['pages']),
      );

  factory MadinaManifest.fromMonolithJson(Map<String, dynamic> j) => MadinaManifest(
        title: j['title'] as String,
        published: j['published'] as int,
        fontFamily: j['font_family'] as String,
        fontUrl: j['font_url'] as String,
        fontSize: (j['font_size'] as num).toDouble(),
        lineWidth: (j['line_width'] as num).toDouble(),
        contentHash: j['content_hash'] as String?,
        suras: (j['suras'] as List).map((e) {
          final s = e as Map<String, dynamic>;
          return SuraSkeleton(
            name: s['name'] as String,
            ayas: (s['ayas'] as List)
                .map<Aya?>((a) => a == null ? null : Aya.fromJson(a as Map<String, dynamic>))
                .toList(growable: false),
          );
        }).toList(growable: false),
      );
}
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/models_test.dart && dart format . && dart analyze
```

Expected: all PASS, analyzer clean.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): JSON DB models"
```

---

### Task 3: Range parsing and word counting

Implements spec §4.1, §4.2, §4.3.

**Files:**
- Create: `quran_madina_kit/lib/src/ranges.dart`
- Test: `quran_madina_kit/test/ranges_test.dart`

**Interfaces:**
- Consumes: `RenderPart`, `Aya`, `SuraSkeleton` from `models.dart`.
- Produces:
  - `bool isWordToken(String token)`
  - `bool isBasmalaSlot(int sura0, int ayaIndex)`
  - `bool isCountableAya(int sura0, int ayaIndex)`
  - `int countPartWords(RenderPart part)` / `int countAyaWords(Aya aya)`
  - `int? parseSura(String raw)` → 0-based sura index
  - `({int from, int to})? parseAyaRange(String raw)` → internal slot indices
  - `class WordRange { final int start, end; const WordRange(this.start, this.end); }`
  - `WordRange? parseWordsRange(String? raw)`
  - `WordRange? clampedOrNull(String label, WordRange? range, int minBound, int maxBound, void Function(String) log)`
  - `const int kMaxWordsSelection = 500;`
  - `const String kBasmalaLigature = '﷽';`

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/ranges_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/models.dart';
import 'package:quran_madina_kit/src/ranges.dart';

RenderPart part(String t) => RenderPart(line: 1, text: t, stretch: 1);

void main() {
  group('isWordToken', () {
    test('accepts ordinary Arabic words', () {
      expect(isWordToken('بِسْمِ'), isTrue);
      expect(isWordToken('ٱلْحَمْدُ'), isTrue, reason: 'alef-wasla is in U+0671..U+06D3');
    });

    test('rejects aya-number ornaments', () {
      expect(isWordToken('﴿١﴾'), isFalse, reason: 'Hafs/Uthman/me_quran marker');
      expect(isWordToken('۝١'), isFalse, reason: 'Amiri marker');
    });

    test('rejects waqf and page ornaments', () {
      for (final m in ['ۖ', 'ۗ', 'ۘ', 'ۙ', 'ۚ', 'ۛ', 'ۜ', '۞', '۩']) {
        expect(isWordToken(m), isFalse, reason: 'ornament $m must not be countable');
      }
    });

    test('rejects the basmala ligature', () {
      expect(isWordToken(kBasmalaLigature), isFalse);
    });
  });

  group('slot predicates', () {
    test('basmala lives at slot 1 of every sura except Al-Fatiha', () {
      expect(isBasmalaSlot(1, 1), isTrue, reason: 'Al-Baqara');
      expect(isBasmalaSlot(0, 1), isFalse, reason: "Al-Fatiha's slot 1 is its title");
      expect(isBasmalaSlot(1, 0), isFalse, reason: 'slot 0 is the title');
      expect(isBasmalaSlot(8, 1), isTrue, reason: "At-Tawba's slot exists but renders blank");
    });

    test('titles never count as words', () {
      expect(isCountableAya(1, 0), isFalse, reason: 'title slot');
      expect(isCountableAya(1, 1), isTrue, reason: 'basmala counts');
      expect(isCountableAya(0, 1), isFalse, reason: "Al-Fatiha's title sits at slot 1");
      expect(isCountableAya(0, 2), isTrue, reason: "Al-Fatiha's basmala is real aya 1");
    });
  });

  group('counting', () {
    test('counts only letter-bearing tokens', () {
      expect(countPartWords(part('ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ ﴿٢﴾')), 4);
    });

    test('an empty decoration slot counts zero', () {
      expect(countPartWords(part('')), 0);
    });

    test('sums across an aya split over lines', () {
      final aya = Aya(page: 1, parts: [part(' ٱهْدِنَا'), part('ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ ﴿٦﴾')]);
      expect(countAyaWords(aya), 3);
    });
  });

  group('parseSura', () {
    test('is 1-based on the wire, 0-based internally', () {
      expect(parseSura('1'), 0);
      expect(parseSura('114'), 113);
    });

    test('takes the first element of a range', () {
      expect(parseSura('2-3'), 1);
    });

    test('rejects garbage', () {
      expect(parseSura('abc'), isNull);
    });
  });

  group('parseAyaRange', () {
    test('adds the 2 decoration slots (offset +1)', () {
      expect(parseAyaRange('255'), (from: 256, to: 256));
      expect(parseAyaRange('1-3'), (from: 2, to: 4));
    });

    test('rejects garbage', () {
      expect(parseAyaRange('x'), isNull);
    });
  });

  group('parseWordsRange', () {
    test('a single index becomes a one-word range', () {
      expect(parseWordsRange('5'), const WordRange(5, 5));
    });

    test('accepts both separators', () {
      expect(parseWordsRange('3-10'), const WordRange(3, 10));
      expect(parseWordsRange('3:10'), const WordRange(3, 10));
    });

    test('rejects zero, negative, reversed and malformed', () {
      expect(parseWordsRange('0'), isNull);
      expect(parseWordsRange('0-4'), isNull);
      expect(parseWordsRange('10-3'), isNull, reason: 'start must not exceed end');
      expect(parseWordsRange('a-b'), isNull);
      expect(parseWordsRange('1-2-3'), isNull);
      expect(parseWordsRange(null), isNull);
    });
  });

  group('clampedOrNull', () {
    test('passes an in-bounds range through', () {
      final logs = <String>[];
      expect(clampedOrNull('highlight', const WordRange(2, 3), 1, 9, logs.add),
          const WordRange(2, 3));
      expect(logs, isEmpty);
    });

    test('drops an out-of-bounds range with a warning instead of throwing', () {
      final logs = <String>[];
      expect(clampedOrNull('error', const WordRange(2, 30), 1, 9, logs.add), isNull);
      expect(logs.single, contains('outside displayed words 1-9'));
    });

    test('a null range stays null and logs nothing', () {
      final logs = <String>[];
      expect(clampedOrNull('highlight', null, 1, 9, logs.add), isNull);
      expect(logs, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/ranges_test.dart
```

Expected: FAIL — `ranges.dart` does not exist.

- [ ] **Step 3: Write the implementation**

`quran_madina_kit/lib/src/ranges.dart`:

```dart
import 'models.dart';

/// The traditional basmala ligature (U+FDFD). Shown whenever the complete
/// basmala is displayed; the DB stores its 4 real word tokens instead so they
/// can be counted and selected individually.
const String kBasmalaLigature = '﷽';

/// A `words=` selection is capped at this many words.
const int kMaxWordsSelection = 500;

/// A render token counts as a selectable word only if it carries an Arabic
/// letter. Everything else in the Madina text is its own whitespace-separated
/// token and must not be counted, or the word index drifts: aya-number
/// ornaments (`﴿١﴾`, `۝١`), waqf marks (`ۖ ۗ ۘ ۙ ۚ ۛ ۜ`) and the `۞`/`۩`
/// ornaments all lack one. Ranges: U+0621-U+064A and U+0671-U+06D3.
final RegExp _arabicLetter = RegExp(r'[ء-يٱ-ۓ]');

bool isWordToken(String token) => _arabicLetter.hasMatch(token);

/// Slot 1 is the basmala of every sura except Al-Fatiha, whose slot 1 holds its
/// title (its basmala is real aya 1). At-Tawba's slot exists but is blank.
bool isBasmalaSlot(int sura0, int ayaIndex) => ayaIndex == 1 && sura0 != 0;

/// Title slots never count as words: slot 0 everywhere, and Al-Fatiha's title
/// at slot 1.
bool isCountableAya(int sura0, int ayaIndex) => ayaIndex >= (sura0 == 0 ? 2 : 1);

int countPartWords(RenderPart part) {
  var n = 0;
  for (final token in part.text.split(RegExp(r'\s+'))) {
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

/// `aya="255"` -> (256, 256); `aya="1-3"` -> (2, 4). The +1 skips the title and
/// basmala decoration slots that precede every sura's real ayas.
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
  WordRange get capped =>
      length > kMaxWordsSelection ? WordRange(start, start + kMaxWordsSelection - 1) : this;

  bool contains(int index) => index >= start && index <= end;

  @override
  bool operator ==(Object other) =>
      other is WordRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start-$end';
}

/// `"n"` -> [n, n]; `"n-m"` or `"n:m"` -> [n, m]. Null when malformed, when the
/// start is below 1, or when the range runs backwards.
WordRange? parseWordsRange(String? raw) {
  if (raw == null) return null;
  final parts = raw.split(RegExp(r'[-:]')).map((e) => int.tryParse(e.trim())).toList();
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

/// Validates a `highlight=`/`error=` range against the words actually being
/// displayed. Out of bounds warns and drops the mark rather than aborting the
/// render — unlike a malformed `words=`, which falls back to the verse render.
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
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/ranges_test.dart && dart format . && dart analyze
```

Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): range parsing and word counting"
```

---

### Task 4: Basmala render mode

Implements spec §4.4. Split from Task 3 because the fully-in/partially-in interaction between three ranges is the single subtlest rule in the port and deserves its own review gate.

**Files:**
- Modify: `quran_madina_kit/lib/src/ranges.dart`
- Test: `quran_madina_kit/test/basmala_test.dart`

**Interfaces:**
- Consumes: `WordRange` from Task 3.
- Produces: `enum BasmalaMark { none, highlight, error }`, `class BasmalaMode { final bool ligature; final BasmalaMark mark; }`, `BasmalaMode basmalaRenderMode({required int counter, required int basmalaWords, WordRange? displayRange, WordRange? highlightRange, WordRange? errorRange})`.

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/basmala_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/ranges.dart';

BasmalaMode mode({
  int counter = 0,
  int words = 4,
  WordRange? display,
  WordRange? highlight,
  WordRange? error,
}) =>
    basmalaRenderMode(
      counter: counter,
      basmalaWords: words,
      displayRange: display,
      highlightRange: highlight,
      errorRange: error,
    );

void main() {
  test('no display range (plain page/verse render) shows the ligature', () {
    expect(mode().ligature, isTrue);
    expect(mode().mark, BasmalaMark.none);
  });

  test('all 4 words inside the selection shows the ligature', () {
    expect(mode(display: const WordRange(1, 10)).ligature, isTrue);
  });

  test('a partial selection shows the individual tokens', () {
    expect(mode(display: const WordRange(1, 2)).ligature, isFalse,
        reason: 'words 1-2 of 4 — the selection must stay visible');
    expect(mode(display: const WordRange(3, 8)).ligature, isFalse);
  });

  test('a selection that misses the basmala entirely shows tokens', () {
    expect(mode(counter: 10, display: const WordRange(1, 5)).ligature, isFalse);
  });

  test('a mark covering all 4 words keeps the ligature and marks it', () {
    final m = mode(display: const WordRange(1, 10), highlight: const WordRange(1, 4));
    expect(m.ligature, isTrue);
    expect(m.mark, BasmalaMark.highlight);
  });

  test('a mark cutting into only some words forces the tokens', () {
    expect(mode(display: const WordRange(1, 10), highlight: const WordRange(2, 3)).ligature,
        isFalse);
    expect(mode(display: const WordRange(1, 10), error: const WordRange(4, 6)).ligature,
        isFalse);
  });

  test('a mark that misses the basmala leaves the ligature unmarked', () {
    final m = mode(display: const WordRange(1, 10), highlight: const WordRange(6, 8));
    expect(m.ligature, isTrue);
    expect(m.mark, BasmalaMark.none);
  });

  test('error wins over highlight when both fully cover it', () {
    final m = mode(
      display: const WordRange(1, 10),
      highlight: const WordRange(1, 4),
      error: const WordRange(1, 4),
    );
    expect(m.mark, BasmalaMark.error);
  });

  test('respects a non-zero running counter', () {
    // Counter 9 means the basmala occupies words 10..13.
    expect(mode(counter: 9, display: const WordRange(1, 14)).ligature, isTrue);
    expect(mode(counter: 9, display: const WordRange(1, 12)).ligature, isFalse);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/basmala_test.dart
```

Expected: FAIL — `basmalaRenderMode` undefined.

- [ ] **Step 3: Append the implementation to `ranges.dart`**

```dart
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
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/basmala_test.dart test/ranges_test.dart && dart format . && dart analyze
```

Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): basmala ligature vs tokens decision"
```

---

### Task 5: Data sources

**Files:**
- Create: `quran_madina_kit/lib/src/source.dart`
- Test: `quran_madina_kit/test/source_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces:
  - `abstract class MadinaSource { Future<Map<String,dynamic>?> loadJson(String path); Future<Uint8List?> loadFont(String url); void clearCache(String prefix); }`
  - `class MadinaAssetSource extends MadinaSource { MadinaAssetSource({String package = 'quran_madina_kit', String root = 'assets/'}) }`
  - `class MadinaNetworkSource extends MadinaSource { MadinaNetworkSource({String base = 'https://unpkg.com/quran-madina-html/', Directory? cacheDir, http.Client? client}) }`
  - Both return `null` (never throw) when a resource is missing — callers fall back.
  - Concurrent calls for the same path share one future (request coalescing).

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/source_test.dart`:

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_madina_kit/src/source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MadinaAssetSource', () {
    final source = MadinaAssetSource();

    test('loads a bundled manifest', () async {
      final m = await source.loadJson('db/Madina05-Hafs-16px/manifest.json');
      expect(m, isNotNull);
      expect(m!['font_family'], 'Hafs');
    });

    test('returns null for a missing asset instead of throwing', () async {
      expect(await source.loadJson('db/Nope-99px/manifest.json'), isNull);
    });

    test('maps a .woff2 font url to the bundled .ttf', () async {
      final bytes = await source.loadFont('assets/fonts/Hafs.woff2');
      expect(bytes, isNotNull);
      expect(bytes!.lengthInBytes, greaterThan(50000));
    });
  });

  group('MadinaNetworkSource', () {
    test('fetches and decodes JSON', () async {
      final client = MockClient((req) async =>
          http.Response(json.encode({'font_family': 'Hafs'}), 200,
              headers: {'content-type': 'application/json; charset=utf-8'}));
      final source = MadinaNetworkSource(client: client);
      final m = await source.loadJson('db/x/manifest.json');
      expect(m!['font_family'], 'Hafs');
    });

    test('returns null on a non-200 instead of throwing', () async {
      final client = MockClient((req) async => http.Response('nope', 404));
      final source = MadinaNetworkSource(client: client);
      expect(await source.loadJson('db/x/manifest.json'), isNull);
    });

    test('coalesces concurrent requests for the same path into one fetch', () async {
      var hits = 0;
      final client = MockClient((req) async {
        hits++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return http.Response(json.encode({'ok': true}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      });
      final source = MadinaNetworkSource(client: client);
      await Future.wait([
        source.loadJson('db/x/juz-01.json'),
        source.loadJson('db/x/juz-01.json'),
        source.loadJson('db/x/juz-01.json'),
      ]);
      expect(hits, 1, reason: 'three widgets needing the same juz must fire one request');
    });

    test('serves a repeat request from cache', () async {
      var hits = 0;
      final client = MockClient((req) async {
        hits++;
        return http.Response(json.encode({'ok': true}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      });
      final source = MadinaNetworkSource(client: client);
      await source.loadJson('db/x/juz-01.json');
      await source.loadJson('db/x/juz-01.json');
      expect(hits, 1);
    });

    test('clearCache drops only the matching prefix', () async {
      var hits = 0;
      final client = MockClient((req) async {
        hits++;
        return http.Response(json.encode({'ok': true}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      });
      final source = MadinaNetworkSource(client: client);
      await source.loadJson('db/a/juz-01.json');
      await source.loadJson('db/b/juz-01.json');
      expect(hits, 2);
      source.clearCache('db/a/');
      await source.loadJson('db/a/juz-01.json');
      await source.loadJson('db/b/juz-01.json');
      expect(hits, 3, reason: 'only db/a was refetched');
    });

    test('forceFresh bypasses the cache (used for manifest.json)', () async {
      var hits = 0;
      final client = MockClient((req) async {
        hits++;
        return http.Response(json.encode({'ok': true}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      });
      final source = MadinaNetworkSource(client: client);
      await source.loadJson('db/x/manifest.json');
      await source.loadJson('db/x/manifest.json', forceFresh: true);
      expect(hits, 2);
    });

    test('decodes UTF-8 Arabic correctly', () async {
      final client = MockClient((req) async => http.Response.bytes(
            utf8.encode(json.encode({'name': 'سورة الفاتحة'})),
            200,
            headers: {'content-type': 'application/json'},
          ));
      final source = MadinaNetworkSource(client: client);
      final m = await source.loadJson('db/x/manifest.json');
      expect(m!['name'], 'سورة الفاتحة');
    });

    test('loads font bytes', () async {
      final client = MockClient(
          (req) async => http.Response.bytes(Uint8List.fromList([0, 1, 2, 3]), 200));
      final source = MadinaNetworkSource(client: client);
      expect((await source.loadFont('assets/fonts/Hafs.woff2'))!.lengthInBytes, 4);
    });
  });
}
```

Add `http: ^1.2.0` is already a dependency; `package:http/testing.dart` ships with it, so no new dev dependency is needed.

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/source_test.dart
```

Expected: FAIL — `source.dart` does not exist.

- [ ] **Step 3: Write the implementation**

`quran_madina_kit/lib/src/source.dart`:

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory, File;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

/// Where the JSON DB, fonts and images come from.
///
/// Implementations never throw for a missing resource — they return null so the
/// caller can fall back (manifest -> monolith -> default font size), mirroring
/// the web runtime's XHR error paths.
abstract class MadinaSource {
  /// [path] is relative to the source's root, e.g.
  /// `db/Madina05-Hafs-16px/manifest.json`.
  ///
  /// [forceFresh] skips the cache. Used for `manifest.json` only: it is small,
  /// and always refetching it is what lets a changed `content_hash` be noticed
  /// on every load instead of once per session.
  Future<Map<String, dynamic>?> loadJson(String path, {bool forceFresh = false});

  /// [url] is the DB header's `font_url`, e.g. `assets/fonts/Hafs.woff2`.
  Future<Uint8List?> loadFont(String url);

  /// Drops every cached entry whose path starts with [prefix].
  void clearCache(String prefix);
}

/// Reads everything from the package's bundled assets. Works fully offline.
class MadinaAssetSource extends MadinaSource {
  MadinaAssetSource({this.package = 'quran_madina_kit', this.root = 'assets/'});

  final String package;
  final String root;

  final Map<String, Map<String, dynamic>> _cache = {};
  final Map<String, Future<Map<String, dynamic>?>> _pending = {};

  String _key(String path) => 'packages/$package/$root$path';

  @override
  Future<Map<String, dynamic>?> loadJson(String path, {bool forceFresh = false}) {
    if (!forceFresh && _cache.containsKey(path)) {
      return Future.value(_cache[path]);
    }
    final inFlight = _pending[path];
    if (inFlight != null) return inFlight;

    final future = () async {
      try {
        final raw = await rootBundle.loadString(_key(path));
        final data = json.decode(raw) as Map<String, dynamic>;
        _cache[path] = data;
        return data;
      } catch (_) {
        return null; // asset absent or malformed: let the caller fall back
      } finally {
        _pending.remove(path);
      }
    }();
    _pending[path] = future;
    return future;
  }

  @override
  Future<Uint8List?> loadFont(String url) async {
    // The DB header names the web asset (.woff2); the bundle ships the .ttf
    // Flutter can load. Same tables, so the metrics are identical.
    final name = url.split('/').last.replaceAll('.woff2', '.ttf');
    try {
      final data = await rootBundle.load('packages/$package/${root}fonts/$name');
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  @override
  void clearCache(String prefix) =>
      _cache.removeWhere((key, _) => key.startsWith(prefix));
}

/// Fetches from a CDN, with an in-memory cache and an optional on-disk cache.
///
/// No `path_provider` dependency: the host app supplies [cacheDir] if it wants
/// persistence across launches.
class MadinaNetworkSource extends MadinaSource {
  MadinaNetworkSource({
    this.base = 'https://unpkg.com/quran-madina-html/',
    this.cacheDir,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String base;
  final Directory? cacheDir;
  final http.Client _client;

  final Map<String, Map<String, dynamic>> _cache = {};
  final Map<String, Future<Map<String, dynamic>?>> _pending = {};

  Uri _uri(String path) => Uri.parse('$base$path');

  File? _cacheFile(String path) {
    final dir = cacheDir;
    if (dir == null) return null;
    return File('${dir.path}/${path.replaceAll('/', '_')}');
  }

  @override
  Future<Map<String, dynamic>?> loadJson(String path, {bool forceFresh = false}) {
    if (!forceFresh) {
      final hit = _cache[path];
      if (hit != null) return Future.value(hit);
      final inFlight = _pending[path];
      if (inFlight != null) return inFlight;
    }

    final future = () async {
      try {
        if (!forceFresh) {
          final file = _cacheFile(path);
          if (file != null && file.existsSync()) {
            final data = json.decode(await file.readAsString()) as Map<String, dynamic>;
            _cache[path] = data;
            return data;
          }
        }
        final res = await _client.get(_uri(path));
        if (res.statusCode != 200) return null;
        // Decode from bytes, not res.body: a server that omits charset=utf-8
        // would otherwise mangle the Arabic text into latin-1.
        final data = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        _cache[path] = data;
        final file = _cacheFile(path);
        if (file != null) {
          try {
            await file.parent.create(recursive: true);
            await file.writeAsString(utf8.decode(res.bodyBytes));
          } catch (_) {
            // Disk cache is best-effort; the memory cache still holds it.
          }
        }
        return data;
      } catch (_) {
        return null;
      } finally {
        _pending.remove(path);
      }
    }();
    if (!forceFresh) _pending[path] = future;
    return future;
  }

  @override
  Future<Uint8List?> loadFont(String url) async {
    try {
      final uri = url.startsWith(RegExp(r'^(https?:)?//'))
          ? Uri.parse(url)
          : _uri(url.replaceFirst(RegExp(r'^/'), ''));
      final res = await _client.get(uri);
      return res.statusCode == 200 ? res.bodyBytes : null;
    } catch (_) {
      return null;
    }
  }

  @override
  void clearCache(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
    final dir = cacheDir;
    if (dir == null || !dir.existsSync()) return;
    final filePrefix = prefix.replaceAll('/', '_');
    for (final entry in dir.listSync()) {
      if (entry is File && entry.uri.pathSegments.last.startsWith(filePrefix)) {
        try {
          entry.deleteSync();
        } catch (_) {
          // Best-effort.
        }
      }
    }
  }
}
```

> **Note for the implementer:** `MadinaNetworkSource` fetches `.woff2` directly. Flutter cannot
> parse woff2, so the network source is only usable with a CDN that serves `.ttf`. Document this in
> the README (Task 16) and default `MadinaConfig.source` to `MadinaAssetSource`.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/source_test.dart && dart format . && dart analyze
```

Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): asset and network data sources with request coalescing"
```

---

### Task 6: Repository — boot, shard merging, page and juz' lookup

Implements spec §4.7, §4.8, and the boot fallback chain in §7.

**Files:**
- Create: `quran_madina_kit/lib/src/repository.dart`
- Test: `quran_madina_kit/test/repository_test.dart`

**Interfaces:**
- Consumes: `MadinaManifest`, `SuraSkeleton`, `Aya`, `JuzShard` (Task 2); `MadinaSource` (Task 5).
- Produces:
  - `class MadinaDb { MadinaManifest get manifest; List<SuraSkeleton> get suras; Aya? aya(int sura0, int ayaIndex); }`
  - `static Future<MadinaDb?> MadinaDb.boot({required MadinaSource source, required String name, required String font, required double fontSize, void Function(String)? log})`
  - `int suraAyaToJuz(int sura0, int ayaIndex)`
  - `Future<void> ensureJuz(List<int> indices)`
  - `({int suraFrom, int ayaFrom, int suraTo, int ayaTo})? pageBounds(int page)`
  - `String get dbStem` (e.g. `Madina05-Hafs-16px`)

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/repository_test.dart`:

```dart
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/repository.dart';
import 'package:quran_madina_kit/src/source.dart';

/// A source backed by in-memory maps, so tests state exactly what exists.
class FakeSource extends MadinaSource {
  FakeSource(this.files);

  final Map<String, Map<String, dynamic>> files;
  final List<String> requested = [];

  @override
  Future<Map<String, dynamic>?> loadJson(String path, {bool forceFresh = false}) async {
    requested.add(path);
    return files[path];
  }

  @override
  Future<Uint8List?> loadFont(String url) async => Uint8List(0);

  @override
  void clearCache(String prefix) {}
}

Map<String, dynamic> manifestJson({
  String family = 'Hafs',
  double lineWidth = 270,
  double fontSize = 16,
  String? hash,
}) =>
    {
      'title': 't',
      'published': 1405,
      'font_family': family,
      'font_url': 'assets/fonts/$family.woff2',
      'font_size': fontSize,
      'line_width': lineWidth,
      if (hash != null) 'content_hash': hash,
      'suras': [
        ['سورة الفاتحة', 9],
        ['سورة البقرة', 288],
      ],
      // [sura0, ayaIdx, startPage]
      'juz': [
        [0, 1, 1],
        [1, 142, 22],
      ],
      'pages': [
        [0, 0, 0, 8],
        [1, 0, 1, 7],
      ],
    };

void main() {
  group('boot', () {
    test('prefers the sharded manifest', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px/manifest.json': manifestJson(),
      });
      final db = await MadinaDb.boot(
          source: source, name: 'Madina05', font: 'Hafs', fontSize: 16);
      expect(db, isNotNull);
      expect(db!.dbStem, 'Madina05-Hafs-16px');
      expect(db.manifest.isSharded, isTrue);
      expect(db.suras.length, 2);
    });

    test('falls back to the monolith when there is no manifest', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px.json': {
          'title': 't',
          'published': 1405,
          'font_family': 'Hafs',
          'font_url': 'f.woff2',
          'font_size': 16,
          'line_width': 270,
          'suras': [
            {
              'name': 'سورة الفاتحة',
              'ayas': [
                {
                  'p': 1,
                  'r': [
                    {'l': 1, 't': '', 's': -1}
                  ]
                }
              ]
            }
          ],
        },
      });
      final db = await MadinaDb.boot(
          source: source, name: 'Madina05', font: 'Hafs', fontSize: 16);
      expect(db!.manifest.isSharded, isFalse);
      expect(db.aya(0, 0), isNotNull, reason: 'monolith data is present immediately');
    });

    test('falls back to size 16 when the requested size has no DB', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px/manifest.json': manifestJson(),
      });
      final logs = <String>[];
      final db = await MadinaDb.boot(
          source: source,
          name: 'Madina05',
          font: 'Hafs',
          fontSize: 24,
          log: logs.add);
      expect(db!.dbStem, 'Madina05-Hafs-16px');
      expect(logs.join(), contains('falling back to size: 16'));
    });

    test('returns null when nothing at all is available', () async {
      final db = await MadinaDb.boot(
          source: FakeSource({}), name: 'Madina05', font: 'Hafs', fontSize: 16);
      expect(db, isNull);
    });

    test('clears cached shards when the content hash changed', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px/manifest.json': manifestJson(hash: 'v2'),
      });
      final cleared = <String>[];
      await MadinaDb.boot(
        source: source,
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
        previousHash: 'v1',
        onCacheClear: cleared.add,
      );
      expect(cleared.single, 'db/Madina05-Hafs-16px/');
    });

    test('does not clear when the hash is unchanged', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px/manifest.json': manifestJson(hash: 'v1'),
      });
      final cleared = <String>[];
      await MadinaDb.boot(
        source: source,
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
        previousHash: 'v1',
        onCacheClear: cleared.add,
      );
      expect(cleared, isEmpty);
    });

    test('normalises a spaced font name to underscores', () async {
      final source = FakeSource({
        'db/Madina05-Amiri_Quran-16px/manifest.json': manifestJson(family: 'Amiri Quran'),
      });
      final db = await MadinaDb.boot(
          source: source, name: 'Madina05', font: 'Amiri Quran', fontSize: 16);
      expect(db!.dbStem, 'Madina05-Amiri_Quran-16px');
    });
  });

  group('suraAyaToJuz', () {
    late MadinaDb db;

    setUp(() async {
      db = (await MadinaDb.boot(
        source: FakeSource({'db/Madina05-Hafs-16px/manifest.json': manifestJson()}),
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
      ))!;
    });

    test('maps into the last juz whose start is at or before the position', () {
      expect(db.suraAyaToJuz(0, 2), 0);
      expect(db.suraAyaToJuz(1, 3), 0, reason: 'Al-Baqara aya 2 is still juz 1');
      expect(db.suraAyaToJuz(1, 143), 1);
      expect(db.suraAyaToJuz(1, 200), 1);
    });

    test('decoration slots follow aya 1, so a sura opening a juz keeps its title there', () {
      expect(db.suraAyaToJuz(1, 0), db.suraAyaToJuz(1, 2));
      expect(db.suraAyaToJuz(1, 1), db.suraAyaToJuz(1, 2));
    });
  });

  group('ensureJuz', () {
    test('fetches only the missing shards and merges them in place', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px/manifest.json': manifestJson(),
        'db/Madina05-Hafs-16px/juz-01.json': {
          'j': 0,
          'd': [
            [
              0,
              2,
              1,
              [
                {'l': 2, 't': 'بِسْمِ ٱللَّهِ', 's': -1}
              ]
            ]
          ]
        },
      });
      final db = (await MadinaDb.boot(
        source: source,
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
      ))!;
      expect(db.aya(0, 2), isNull, reason: 'not loaded yet');

      await db.ensureJuz([0]);
      expect(db.aya(0, 2)!.parts.single.text, 'بِسْمِ ٱللَّهِ');

      final before = source.requested.length;
      await db.ensureJuz([0]);
      expect(source.requested.length, before, reason: 'already loaded, no refetch');
    });

    test('a failed shard is marked loaded so it is not retried forever', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px/manifest.json': manifestJson(),
      });
      final db = (await MadinaDb.boot(
        source: source,
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
      ))!;
      await db.ensureJuz([0]);
      final after = source.requested.length;
      await db.ensureJuz([0]);
      expect(source.requested.length, after);
    });

    test('is a no-op in monolith mode', () async {
      final source = FakeSource({
        'db/Madina05-Hafs-16px.json': {
          'title': 't',
          'published': 1405,
          'font_family': 'Hafs',
          'font_url': 'f.woff2',
          'font_size': 16,
          'line_width': 270,
          'suras': <dynamic>[],
        },
      });
      final db = (await MadinaDb.boot(
        source: source,
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
      ))!;
      await db.ensureJuz([0, 1, 2]);
      expect(source.requested.where((p) => p.contains('juz-')), isEmpty);
    });
  });

  group('pageBounds', () {
    test('reads the sharded page table', () async {
      final db = (await MadinaDb.boot(
        source: FakeSource({'db/Madina05-Hafs-16px/manifest.json': manifestJson()}),
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
      ))!;
      expect(db.pageBounds(1), (suraFrom: 0, ayaFrom: 0, suraTo: 0, ayaTo: 8));
      expect(db.pageBounds(2), (suraFrom: 1, ayaFrom: 0, suraTo: 1, ayaTo: 7));
    });

    test('returns null for a page outside the table', () async {
      final db = (await MadinaDb.boot(
        source: FakeSource({'db/Madina05-Hafs-16px/manifest.json': manifestJson()}),
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
      ))!;
      expect(db.pageBounds(999), isNull);
      expect(db.pageBounds(0), isNull);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/repository_test.dart
```

Expected: FAIL — `repository.dart` does not exist.

- [ ] **Step 3: Write the implementation**

`quran_madina_kit/lib/src/repository.dart`:

```dart
import 'models.dart';
import 'source.dart';

/// Loaded DB: the header, the (possibly sparse) sura skeleton, and lazy juz'
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

  String get _shardBase => 'db/$dbStem/';

  /// The aya at (sura0, ayaIndex), or null when out of range or not yet loaded.
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

  /// Sharded manifest first, monolith second, size-16 fallback last.
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
    final logger = log ?? (_) {};
    final stem = stemFor(name, font, fontSize);
    final shardBase = 'db/$stem/';

    final manifestJson = await source.loadJson('${shardBase}manifest.json', forceFresh: true);
    if (manifestJson != null) {
      final manifest = MadinaManifest.fromManifestJson(manifestJson);
      final hash = manifest.contentHash;
      if (hash != null && previousHash != null && previousHash != hash) {
        (onCacheClear ?? source.clearCache)(shardBase);
      }
      return MadinaDb._(
          manifest: manifest, dbStem: stem, source: source, log: logger);
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
  /// Decoration slots (0 and 1) are resolved as if they were aya 1, so a sura
  /// that opens a juz' keeps its title and basmala in the new juz'.
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
  /// monolith mode. A shard that fails to load is marked loaded anyway so it is
  /// not retried on every render — matching the web runtime.
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
      final data = await _source.loadJson('${_shardBase}juz-$padded.json');
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
      manifest.suras[e.sura].ayas[e.ayaIndex] = Aya(page: e.page, parts: e.parts);
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
  ({int suraFrom, int ayaFrom, int suraTo, int ayaTo})? _monolithPageBounds(int page) {
    final s = manifest.suras;
    if (s.isEmpty) return null;
    var suraFrom = 0;
    while (suraFrom < s.length - 1 && (s[suraFrom].ayas.last?.page ?? 0) < page) {
      suraFrom++;
    }
    var suraTo = suraFrom;
    while (suraTo < s.length - 1 && (s[suraTo].ayas.first?.page ?? 1 << 30) <= page) {
      suraTo++;
    }
    suraTo--;
    if (suraTo < suraFrom) suraTo = suraFrom;
    var ayaFrom = 0;
    final fromAyas = s[suraFrom].ayas;
    while (ayaFrom < fromAyas.length - 1 && (fromAyas[ayaFrom]?.page ?? 0) < page) {
      ayaFrom++;
    }
    final toAyas = s[suraTo].ayas;
    var ayaTo = toAyas.length - 1;
    while (ayaTo > 0 && (toAyas[ayaTo]?.page ?? 1 << 30) > page) {
      ayaTo--;
    }
    return (suraFrom: suraFrom, ayaFrom: ayaFrom, suraTo: suraTo, ayaTo: ayaTo);
  }
}
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/repository_test.dart && dart format . && dart analyze
```

Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): DB repository with lazy juz shard loading"
```

---

### Task 7: Arbitrary font sizes (anchor interpolation)

Implements spec §4.11.

**Files:**
- Create: `quran_madina_kit/lib/src/interpolation.dart`
- Test: `quran_madina_kit/test/interpolation_test.dart`

**Interfaces:**
- Consumes: `MadinaSource` (Task 5), `MadinaDb` (Task 6).
- Produces:
  - `const List<double> kAnchorSizes = [16, 24];`
  - `const List<double> kFontSizeRange = [6, 100];`
  - `class SizeOverrides { final double fontSize, lineWidth, stretchScale; }`
  - `double clampFontSize(double requested, void Function(String) log)`
  - `SizeOverrides? interpolate({required double requested, required double lineWidth16, required double lineWidth24})`
  - `Future<SizeOverrides?> resolveSizeOverrides({required MadinaSource source, required String name, required String font, required double requested, void Function(String)? log})`

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/interpolation_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/interpolation.dart';

void main() {
  group('clampFontSize', () {
    test('accepts anything inside 6..100', () {
      final logs = <String>[];
      expect(clampFontSize(6, logs.add), 6);
      expect(clampFontSize(18.5, logs.add), 18.5);
      expect(clampFontSize(100, logs.add), 100);
      expect(logs, isEmpty);
    });

    test('falls back to 16 and warns outside the range', () {
      final logs = <String>[];
      expect(clampFontSize(5, logs.add), 16);
      expect(clampFontSize(101, logs.add), 16);
      expect(logs.length, 2);
      expect(logs.first, contains('outside 6..100'));
    });
  });

  group('interpolate', () {
    // Hafs anchors: 270px@16, 410px@24 — deliberately NOT proportional
    // (proportional would be 405@24), which is why interpolation exists.
    test('an anchor size needs no overrides', () {
      expect(interpolate(requested: 16, lineWidth16: 270, lineWidth24: 410), isNull);
      expect(interpolate(requested: 24, lineWidth16: 270, lineWidth24: 410), isNull);
    });

    test('reads line_width off the fitted line', () {
      final o = interpolate(requested: 20, lineWidth16: 270, lineWidth24: 410)!;
      expect(o.fontSize, 20);
      expect(o.lineWidth, 340, reason: '270 + (410-270) * (20-16)/8');
    });

    test('rounds the interpolated width', () {
      final o = interpolate(requested: 18, lineWidth16: 270, lineWidth24: 410)!;
      expect(o.lineWidth, 305);
    });

    test('corrects stretch against the nearest anchor', () {
      // 18 is nearer 16: stretch_scale = lw(18) * 16 / (lw(16) * 18)
      final o = interpolate(requested: 18, lineWidth16: 270, lineWidth24: 410)!;
      expect(o.nearestAnchor, 16);
      expect(o.stretchScale, closeTo(305 * 16 / (270 * 18), 1e-9));
    });

    test('a size past the midpoint uses the 24px anchor', () {
      final o = interpolate(requested: 22, lineWidth16: 270, lineWidth24: 410)!;
      expect(o.nearestAnchor, 24);
      expect(o.lineWidth, 375);
      expect(o.stretchScale, closeTo(375 * 24 / (410 * 22), 1e-9));
    });

    test('the exact midpoint prefers the lower anchor', () {
      expect(interpolate(requested: 20, lineWidth16: 270, lineWidth24: 410)!.nearestAnchor, 16,
          reason: 'JS uses (S - lo <= hi - S), so a tie picks lo');
    });

    test('extrapolates below and above the anchors', () {
      expect(interpolate(requested: 8, lineWidth16: 270, lineWidth24: 410)!.lineWidth, 130);
      expect(interpolate(requested: 32, lineWidth16: 270, lineWidth24: 410)!.lineWidth, 550);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/interpolation_test.dart
```

Expected: FAIL — `interpolation.dart` does not exist.

- [ ] **Step 3: Write the implementation**

`quran_madina_kit/lib/src/interpolation.dart`:

```dart
import 'repository.dart';
import 'source.dart';

/// Every font ships a pre-built DB at exactly these sizes.
const List<double> kAnchorSizes = [16, 24];

/// Accepted `fontSize` bounds; anything else falls back to [kDefaultFontSize].
const double kMinFontSize = 6;
const double kMaxFontSize = 100;
const double kDefaultFontSize = 16;

/// Header values re-targeting a nearest-anchor DB to a requested size.
class SizeOverrides {
  const SizeOverrides({
    required this.fontSize,
    required this.lineWidth,
    required this.stretchScale,
    required this.nearestAnchor,
  });

  /// The size actually rendered at.
  final double fontSize;

  /// The frame width for that size, read off the fitted line.
  final double lineWidth;

  /// Multiplier applied to every stored stretch factor.
  final double stretchScale;

  /// Which anchor's DB supplies the render data.
  final double nearestAnchor;
}

double clampFontSize(double requested, void Function(String) log) {
  if (requested < kMinFontSize || requested > kMaxFontSize) {
    log('font-size $requested outside ${kMinFontSize.round()}..${kMaxFontSize.round()}, '
        'using ${kDefaultFontSize.round()}');
    return kDefaultFontSize;
  }
  return requested;
}

/// Null for an anchor size (its DB is used as-is).
///
/// The per-size line widths are hand-tuned, NOT proportional to the size (Hafs
/// is 270@16 but 410@24), so the width for size S is read off the line fitted
/// through the two anchor points. Glyph widths DO grow proportionally with the
/// size while that fitted width does not, so every justified line's scaleX gets
/// one global correction:
///
///     natural width at S  = natural(anchor) * S / anchor
///     needed stretch at S = stored * lw(S) * anchor / (lw(anchor) * S)
SizeOverrides? interpolate({
  required double requested,
  required double lineWidth16,
  required double lineWidth24,
}) {
  final lo = kAnchorSizes[0];
  final hi = kAnchorSizes[1];
  if (requested == lo || requested == hi) return null;

  final lw =
      (lineWidth16 + (lineWidth24 - lineWidth16) * (requested - lo) / (hi - lo))
          .roundToDouble();
  // A tie prefers the lower anchor, matching the JS `S - lo <= hi - S`.
  final nearest = (requested - lo <= hi - requested) ? lo : hi;
  final nearestWidth = nearest == lo ? lineWidth16 : lineWidth24;

  return SizeOverrides(
    fontSize: requested,
    lineWidth: lw,
    stretchScale: (lw * nearest) / (nearestWidth * requested),
    nearestAnchor: nearest,
  );
}

/// Fetches both anchor headers and fits the requested size between them.
/// Returns null when either anchor is missing — the caller then falls back to
/// [kDefaultFontSize].
Future<SizeOverrides?> resolveSizeOverrides({
  required MadinaSource source,
  required String name,
  required String font,
  required double requested,
  void Function(String)? log,
}) async {
  final logger = log ?? (_) {};
  final widths = <double, double>{};
  for (final size in kAnchorSizes) {
    final stem = MadinaDb.stemFor(name, font, size);
    // The small sharded manifest when available, else the monolith (large, but
    // it lands in the same cache the render will read from anyway).
    final header = await source.loadJson('db/$stem/manifest.json') ??
        await source.loadJson('db/$stem.json');
    if (header == null) {
      logger('missing anchor DB for font-size interpolation ($stem)');
      return null;
    }
    widths[size] = (header['line_width'] as num).toDouble();
  }
  final overrides = interpolate(
    requested: requested,
    lineWidth16: widths[kAnchorSizes[0]]!,
    lineWidth24: widths[kAnchorSizes[1]]!,
  );
  if (overrides != null) {
    logger('font-size $requested interpolated from ${kAnchorSizes[0]}/'
        '${kAnchorSizes[1]} anchors: line_width ${overrides.lineWidth}, '
        'render data from ${overrides.nearestAnchor}px');
  }
  return overrides;
}
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/interpolation_test.dart && dart format . && dart analyze
```

Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): arbitrary font sizes via anchor interpolation"
```

---

### Task 8: Line geometry — line starts and context spacers

Implements spec §4.5.

**Files:**
- Create: `quran_madina_kit/lib/src/layout.dart`
- Test: `quran_madina_kit/test/layout_line_test.dart`

**Interfaces:**
- Consumes: `Aya`, `RenderPart` (Task 2); `MadinaDb` (Task 6).
- Produces:
  - `RenderPart? partOnLine(Aya aya, int line)`
  - `bool isLineStartPart(MadinaDb db, int sura0, int ayaIndex, int line)`
  - `List<RenderPart> lineContext(MadinaDb db, {required int sura0, required int page, required int line, required int ayaIndex, required int direction})`

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/layout_line_test.dart`:

```dart
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/layout.dart';
import 'package:quran_madina_kit/src/models.dart';
import 'package:quran_madina_kit/src/repository.dart';
import 'package:quran_madina_kit/src/source.dart';

class FakeSource extends MadinaSource {
  FakeSource(this.files);
  final Map<String, Map<String, dynamic>> files;
  @override
  Future<Map<String, dynamic>?> loadJson(String path, {bool forceFresh = false}) async =>
      files[path];
  @override
  Future<Uint8List?> loadFont(String url) async => Uint8List(0);
  @override
  void clearCache(String prefix) {}
}

/// Builds a monolith DB from `[[page, [[line, text], ...]], ...]` per aya slot.
Future<MadinaDb> buildDb(List<List<List<Object>>> suraAyas) async {
  final ayas = suraAyas
      .map((aya) => {
            'p': aya[0][0],
            'r': (aya[1] as List)
                .map((p) => {'l': (p as List)[0], 't': p[1], 's': 1})
                .toList(),
          })
      .toList();
  return (await MadinaDb.boot(
    source: FakeSource({
      'db/Madina05-Hafs-16px.json': {
        'title': 't',
        'published': 1405,
        'font_family': 'Hafs',
        'font_url': 'f.woff2',
        'font_size': 16,
        'line_width': 270,
        'suras': [
          {'name': 'س', 'ayas': ayas}
        ],
      },
    }),
    name: 'Madina05',
    font: 'Hafs',
    fontSize: 16,
  ))!;
}

void main() {
  group('partOnLine', () {
    test('finds the part sitting on the given line', () {
      final aya = Aya(page: 1, parts: const [
        RenderPart(line: 5, text: 'أ', stretch: 1),
        RenderPart(line: 6, text: 'ب', stretch: 1),
      ]);
      expect(partOnLine(aya, 6)!.text, 'ب');
    });

    test('returns null when the aya does not touch the line', () {
      final aya = Aya(page: 1, parts: const [RenderPart(line: 5, text: 'أ', stretch: 1)]);
      expect(partOnLine(aya, 7), isNull);
    });
  });

  group('isLineStartPart', () {
    test('slot 0 is always a line start', () async {
      final db = await buildDb([
        [
          [1],
          [
            [1, 'عنوان']
          ]
        ],
      ]);
      expect(isLineStartPart(db, 0, 0, 1), isTrue);
    });

    test('true when the previous aya has no part on this line', () async {
      // aya 0 on line 1; aya 1 on line 2 -> aya 1 starts line 2.
      final db = await buildDb([
        [
          [1],
          [
            [1, 'أ']
          ]
        ],
        [
          [1],
          [
            [2, 'ب']
          ]
        ],
      ]);
      expect(isLineStartPart(db, 0, 1, 2), isTrue);
    });

    test('false when the previous aya also sits on this line', () async {
      final db = await buildDb([
        [
          [1],
          [
            [1, 'أ']
          ]
        ],
        [
          [1],
          [
            [1, 'ب']
          ]
        ],
      ]);
      expect(isLineStartPart(db, 0, 1, 1), isFalse,
          reason: 'aya 1 continues the line aya 0 started');
    });

    test('true when the previous aya is on another page', () async {
      final db = await buildDb([
        [
          [1],
          [
            [15, 'أ']
          ]
        ],
        [
          [2],
          [
            [1, 'ب']
          ]
        ],
      ]);
      expect(isLineStartPart(db, 0, 1, 1), isTrue);
    });

    test('true when the previous aya is not loaded (shard boundary)', () async {
      final db = (await MadinaDb.boot(
        source: FakeSource({
          'db/Madina05-Hafs-16px/manifest.json': {
            'title': 't',
            'published': 1405,
            'font_family': 'Hafs',
            'font_url': 'f.woff2',
            'font_size': 16,
            'line_width': 270,
            'suras': [
              ['س', 5]
            ],
            'juz': [
              [0, 1, 1]
            ],
            'pages': [
              [0, 0, 0, 4]
            ],
          },
        }),
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
      ))!;
      expect(isLineStartPart(db, 0, 3, 1), isTrue);
    });
  });

  group('lineContext', () {
    late MadinaDb db;

    setUp(() async {
      // Line 4 of page 1 holds ayas 0, 1, 2, 3 in reading order.
      db = await buildDb([
        [
          [1],
          [
            [4, 'واحد']
          ]
        ],
        [
          [1],
          [
            [4, 'اثنان']
          ]
        ],
        [
          [1],
          [
            [4, 'ثلاثة']
          ]
        ],
        [
          [1],
          [
            [4, 'أربعة']
          ]
        ],
      ]);
    });

    test('direction -1 collects the preceding text in reading order', () {
      final parts = lineContext(db, sura0: 0, page: 1, line: 4, ayaIndex: 2, direction: -1);
      expect(parts.map((p) => p.text).toList(), ['واحد', 'اثنان'],
          reason: 'walked back to the line start, kept reading order');
    });

    test('direction +1 collects the following text', () {
      final parts = lineContext(db, sura0: 0, page: 1, line: 4, ayaIndex: 1, direction: 1);
      expect(parts.map((p) => p.text).toList(), ['ثلاثة', 'أربعة']);
    });

    test('an aya that already starts the line has no preceding context', () {
      final parts = lineContext(db, sura0: 0, page: 1, line: 4, ayaIndex: 0, direction: -1);
      expect(parts, isEmpty);
    });

    test('stops at a page change', () async {
      final other = await buildDb([
        [
          [1],
          [
            [4, 'قديم']
          ]
        ],
        [
          [2],
          [
            [4, 'جديد']
          ]
        ],
      ]);
      expect(lineContext(other, sura0: 0, page: 2, line: 4, ayaIndex: 1, direction: -1),
          isEmpty);
    });

    test('stops when the neighbour has no part on this line', () async {
      final other = await buildDb([
        [
          [1],
          [
            [3, 'سطر آخر']
          ]
        ],
        [
          [1],
          [
            [4, 'هنا']
          ]
        ],
      ]);
      expect(lineContext(other, sura0: 0, page: 1, line: 4, ayaIndex: 1, direction: -1),
          isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/layout_line_test.dart
```

Expected: FAIL — `layout.dart` does not exist.

- [ ] **Step 3: Write the implementation**

`quran_madina_kit/lib/src/layout.dart`:

```dart
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
/// [direction] < 0 walks back from the first selected aya (text preceding it);
/// > 0 walks forward from the last. Rendering these invisibly lets the line's
/// own centring or stretch place the visible text exactly where it sits on the
/// full page.
List<RenderPart> lineContext(
  MadinaDb db, {
  required int sura0,
  required int page,
  required int line,
  required int ayaIndex,
  required int direction,
}) {
  final parts = <RenderPart>[];
  final slots = db.suras[sura0].ayas.length;
  for (var a = ayaIndex + direction; a >= 0 && a < slots; a += direction) {
    final aya = db.aya(sura0, a);
    if (aya == null) break; // not-yet-loaded aya (shard boundary)
    if (aya.page != page) break;
    final match = partOnLine(aya, line);
    if (match == null) break;
    if (direction < 0) {
      parts.insert(0, match);
      if (isLineStartPart(db, sura0, a, line)) break; // reached the line's start
    } else {
      parts.add(match);
    }
  }
  return parts;
}
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/layout_line_test.dart && dart format . && dart analyze
```

Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): structural line starts and context spacers"
```

---

### Task 9: The `words=` walk (`collectWordParts`)

Implements spec §4.6. This is the largest single piece of logic in the port: the anchor rewind, the
An-Nas → Al-Fatiha wrap-around, and the leading/trailing line trim each have their own history of
being subtly wrong in the web version (see its 0.9.0 / 0.9.3 / 0.9.5 changelog entries).

**Files:**
- Modify: `quran_madina_kit/lib/src/layout.dart`
- Test: `quran_madina_kit/test/layout_words_test.dart`

**Interfaces:**
- Consumes: `WordRange`, `isCountableAya`, `countPartWords`, `countAyaWords` (Tasks 3–4); `MadinaDb` (Task 6).
- Produces:
  - `class CollectedPart { final int sura, ayaIndex; final RenderPart part; final bool countable; }`
  - `class CollectedLine { final String key; final double stretch; final List<CollectedPart> parts; int lastWord; }`
  - `class CollectedWords { final List<CollectedLine> lines; final int counterStart; }`
  - `CollectedWords collectWordParts(MadinaDb db, {required int suraStart, required int ayaStart, required WordRange range})`

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/layout_words_test.dart`:

```dart
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/layout.dart';
import 'package:quran_madina_kit/src/ranges.dart';
import 'package:quran_madina_kit/src/repository.dart';
import 'package:quran_madina_kit/src/source.dart';

class FakeSource extends MadinaSource {
  FakeSource(this.files);
  final Map<String, Map<String, dynamic>> files;
  @override
  Future<Map<String, dynamic>?> loadJson(String path, {bool forceFresh = false}) async =>
      files[path];
  @override
  Future<Uint8List?> loadFont(String url) async => Uint8List(0);
  @override
  void clearCache(String prefix) {}
}

/// One aya slot: page, then `[line, text]` pairs.
typedef Slot = ({int page, List<(int, String)> parts});

Slot slot(int page, List<(int, String)> parts) => (page: page, parts: parts);

Future<MadinaDb> buildDb(List<(String name, List<Slot> slots)> suras) async {
  return (await MadinaDb.boot(
    source: FakeSource({
      'db/Madina05-Hafs-16px.json': {
        'title': 't',
        'published': 1405,
        'font_family': 'Hafs',
        'font_url': 'f.woff2',
        'font_size': 16,
        'line_width': 270,
        'suras': suras
            .map((s) => {
                  'name': s.$1,
                  'ayas': s.$2
                      .map((a) => {
                            'p': a.page,
                            'r': a.parts
                                .map((p) => {'l': p.$1, 't': p.$2, 's': 1})
                                .toList(),
                          })
                      .toList(),
                })
            .toList(),
      },
    }),
    name: 'Madina05',
    font: 'Hafs',
    fontSize: 16,
  ))!;
}

/// Al-Fatiha (title at slot 1, basmala is real aya 1 at slot 2) followed by a
/// normal sura with a title at slot 0 and a 4-word basmala at slot 1.
Future<MadinaDb> fatihaThenBaqara() => buildDb([
      (
        'سورة الفاتحة',
        [
          slot(1, [(1, '')]), // slot 0: blank
          slot(1, [(1, 'سورة الفاتحة')]), // slot 1: title
          slot(1, [(2, 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ ﴿١﴾')]), // slot 2: real aya 1
          slot(1, [(3, 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ ﴿٢﴾')]), // real aya 2
        ]
      ),
      (
        'سورة البقرة',
        [
          slot(2, [(1, 'سورة البقرة')]), // slot 0: title
          slot(2, [(2, 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ')]), // slot 1: basmala, 4 words
          slot(2, [(3, 'الٓمٓ ﴿١﴾')]), // real aya 1
          slot(2, [(4, 'ذَٰلِكَ ٱلْكِتَـٰبُ ﴿٢﴾')]), // real aya 2
        ]
      ),
    ]);

List<String> textsOf(CollectedWords c) =>
    c.lines.expand((l) => l.parts.map((p) => p.part.text)).toList();

void main() {
  group('basic collection', () {
    test('groups parts into visual lines keyed by page:line', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 2, range: const WordRange(1, 4));
      expect(c.lines.first.key, '1:2');
      expect(c.counterStart, 0);
    });

    test('skips blank decoration placeholders', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 0, range: const WordRange(1, 2));
      expect(textsOf(c), isNot(contains('')),
          reason: "Al-Fatiha's blank slot 0 must not become an empty line");
    });

    test('marks title slots as not countable', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 1, range: const WordRange(1, 4));
      final title = c.lines
          .expand((l) => l.parts)
          .firstWhere((p) => p.part.text == 'سورة الفاتحة');
      expect(title.countable, isFalse);
    });
  });

  group('anchor rewind', () {
    test("anchoring at a normal sura's aya 1 rewinds to its basmala", () async {
      final db = await fatihaThenBaqara();
      // suraStart 1, ayaStart 2 == Al-Baqara aya 1 -> must begin at slot 1.
      final c = collectWordParts(db,
          suraStart: 1, ayaStart: 2, range: const WordRange(1, 4));
      expect(textsOf(c).first, contains('بِسْمِ'),
          reason: 'word 1 of an aya-1 anchor is بسم, matching Tanzil indexing');
    });

    test('Al-Fatiha is exempt from the rewind (its slot 1 is a title)', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 2, range: const WordRange(1, 1));
      expect(textsOf(c).first, contains('بِسْمِ'));
      expect(textsOf(c), isNot(contains('سورة الفاتحة')),
          reason: 'no rewind, so the title is never entered');
    });
  });

  group('crossing suras', () {
    test('crosses into the next sura and counts its basmala as 4 words',
        () async {
      final db = await fatihaThenBaqara();
      // Al-Fatiha aya 2 has 4 words; then Al-Baqara title (0) + basmala (4) + الٓمٓ (1).
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 3, range: const WordRange(1, 9));
      final texts = textsOf(c);
      expect(texts, contains('سورة البقرة'), reason: 'title shown for context');
      expect(texts.any((t) => t.contains('الٓمٓ')), isTrue,
          reason: '4 + 4 basmala + 1 = word 9 lands on الٓمٓ');
    });

    test("a crossed-into sura's title is collected but not counted", () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 3, range: const WordRange(1, 9));
      final title = c.lines
          .expand((l) => l.parts)
          .firstWhere((p) => p.part.text == 'سورة البقرة');
      expect(title.countable, isFalse);
    });
  });

  group('wrap-around', () {
    test('past the last sura the walk wraps to the first', () async {
      final db = await fatihaThenBaqara();
      // Anchor in the LAST sura near its end; the remaining words must come
      // from the first sura.
      final c = collectWordParts(db,
          suraStart: 1, ayaStart: 3, range: const WordRange(1, 6));
      expect(c.lines.any((l) => l.parts.any((p) => p.sura == 0)), isTrue,
          reason: 'the walk wrapped back to sura 0');
    });
  });

  group('trimming', () {
    test('drops leading lines entirely before the selection', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 2, range: const WordRange(5, 8));
      expect(c.lines.first.key, '1:3',
          reason: 'line 1:2 holds words 1-4, all outside the selection');
      expect(c.counterStart, 4, reason: 'the 4 skipped words are carried over');
    });

    test('drops trailing lines entirely after the selection', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 2, range: const WordRange(1, 2));
      expect(c.lines.length, 1);
      expect(c.lines.single.key, '1:2');
    });

    test('annotates each line with the running word index it ends at', () async {
      final db = await fatihaThenBaqara();
      final c = collectWordParts(db,
          suraStart: 0, ayaStart: 2, range: const WordRange(1, 8));
      expect(c.lines.first.lastWord, 4);
      expect(c.lines.last.lastWord, 8);
    });
  });

  group('shard boundaries', () {
    test('stops collecting at an unloaded aya', () async {
      final db = (await MadinaDb.boot(
        source: FakeSource({
          'db/Madina05-Hafs-16px/manifest.json': {
            'title': 't',
            'published': 1405,
            'font_family': 'Hafs',
            'font_url': 'f.woff2',
            'font_size': 16,
            'line_width': 270,
            'suras': [
              ['س', 5]
            ],
            'juz': [
              [0, 1, 1]
            ],
            'pages': [
              [0, 0, 0, 4]
            ],
          },
        }),
        name: 'Madina05',
        font: 'Hafs',
        fontSize: 16,
      ))!;
      final c =
          collectWordParts(db, suraStart: 0, ayaStart: 0, range: const WordRange(1, 5));
      expect(c.lines, isEmpty, reason: 'nothing loaded: collect nothing, do not throw');
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/layout_words_test.dart
```

Expected: FAIL — `collectWordParts` undefined.

- [ ] **Step 3: Append the implementation to `layout.dart`**

```dart
import 'ranges.dart';

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
/// Tanzil indexing consumers count with modulo the Quran; the caller's ≤500-word
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
  if (lines.isEmpty) return const CollectedWords(lines: [], counterStart: 0);

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
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/layout_words_test.dart test/layout_line_test.dart && dart format . && dart analyze
```

Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): words= collection walk with anchor rewind, wrap and trim"
```

---

### Task 10: Theme, config and scope

Implements spec §6 (theme) and the CSS custom properties from §5.

**Files:**
- Create: `quran_madina_kit/lib/src/theme.dart`
- Test: `quran_madina_kit/test/theme_test.dart`

**Interfaces:**
- Consumes: `MadinaSource` (Task 5).
- Produces:
  - `enum MadinaStretchMode { stored, measured }`
  - `enum MadinaInline { auto, no, yes }`
  - `class MadinaTheme { background, header, highlight, error, highlightText, errorText; MadinaTheme.light(); MadinaTheme.dark(); MadinaTheme forAmbient(Color ambientTextColour); }`
  - `class MadinaConfig { name, font, fontSize, source, stretchMode }`
  - `class MadinaScope extends InheritedWidget { static MadinaScope of(BuildContext); final MadinaConfig config; final MadinaTheme theme; }`
  - `double relativeLuminance(Color c)`
  - `Color mixWithTransparent(Color c, double fraction)` — the `color-mix(in srgb, X N%, transparent)` equivalent

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/theme_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/theme.dart';

void main() {
  group('relativeLuminance', () {
    test('black and white sit at the extremes', () {
      expect(relativeLuminance(const Color(0xFF000000)), closeTo(0, 1e-6));
      expect(relativeLuminance(const Color(0xFFFFFFFF)), closeTo(1, 1e-6));
    });

    test('matches the WCAG value for mid grey', () {
      expect(relativeLuminance(const Color(0xFF808080)), closeTo(0.2159, 1e-3));
    });
  });

  group('forAmbient', () {
    test('light ambient text (dark page) picks the dark mark pair', () {
      final t = MadinaTheme.light().forAmbient(const Color(0xFFFFFFFF));
      expect(t.highlight, const Color(0xFF5C4600));
      expect(t.error, const Color(0xFF6B1A24));
      expect(t.highlightText, const Color(0xFFFFFFFF));
    });

    test('dark ambient text (light page) keeps the light mark pair', () {
      final t = MadinaTheme.light().forAmbient(const Color(0xFF000000));
      expect(t.highlight, const Color(0xFFFFF3B0));
      expect(t.error, const Color(0xFFF5C6CB));
      expect(t.highlightText, const Color(0xFF1A1A1A));
    });
  });

  group('mixWithTransparent', () {
    test('scales alpha without touching the channels', () {
      final c = mixWithTransparent(const Color(0xFF112233), 0.2);
      expect(c.alpha, (255 * 0.2).round());
      expect(c.red, 0x11);
      expect(c.green, 0x22);
      expect(c.blue, 0x33);
    });
  });

  group('MadinaScope', () {
    testWidgets('provides config and theme down the tree', (tester) async {
      late MadinaScope seen;
      await tester.pumpWidget(MadinaScope(
        config: const MadinaConfig(font: 'Uthman', fontSize: 24),
        theme: MadinaTheme.light(),
        child: Builder(builder: (context) {
          seen = MadinaScope.of(context);
          return const SizedBox();
        }),
      ));
      expect(seen.config.font, 'Uthman');
      expect(seen.config.fontSize, 24);
    });

    testWidgets('falls back to defaults with no scope in the tree', (tester) async {
      late MadinaScope seen;
      await tester.pumpWidget(Builder(builder: (context) {
        seen = MadinaScope.of(context);
        return const SizedBox();
      }));
      expect(seen.config.name, 'Madina05');
      expect(seen.config.font, 'Hafs');
      expect(seen.config.fontSize, 16);
      expect(seen.config.stretchMode, MadinaStretchMode.stored);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/theme_test.dart
```

Expected: FAIL — `theme.dart` does not exist.

- [ ] **Step 3: Write the implementation**

`quran_madina_kit/lib/src/theme.dart`:

```dart
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'source.dart';

/// How a justified line's scaleX is obtained.
enum MadinaStretchMode {
  /// Use the DB's stored factor times the size correction — byte-for-byte the
  /// web runtime's behaviour.
  stored,

  /// Measure the line and derive `lineWidth / measuredWidth`. Self-correcting,
  /// and needs no font-size interpolation.
  measured,
}

/// `inline="auto" | "no" | "yes"`.
enum MadinaInline { auto, no, yes }

/// WCAG relative luminance, used to pick a mark pair that contrasts with the
/// host app's actual ambient text colour — not a guess from the platform
/// brightness, which need not match how the host implements dark mode.
double relativeLuminance(Color c) {
  double lin(int channel) {
    final v = channel / 255;
    return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * lin(c.red) + 0.7152 * lin(c.green) + 0.0722 * lin(c.blue);
}

/// The `color-mix(in srgb, X N%, transparent)` equivalent.
///
/// `withValues` is deliberately avoided: it needs Flutter 3.27+, above this
/// package's declared floor.
Color mixWithTransparent(Color c, double fraction) =>
    c.withAlpha((255 * fraction).round().clamp(0, 255));

/// The six CSS custom properties the web stylesheet exposes.
class MadinaTheme {
  const MadinaTheme({
    required this.background,
    required this.header,
    required this.highlight,
    required this.error,
    required this.highlightText,
    required this.errorText,
  });

  /// `--qmh-background: #F5F5DC` (beige), `--qmh-header: black`.
  factory MadinaTheme.light() => const MadinaTheme(
        background: Color(0xFFF5F5DC),
        header: Color(0xFF000000),
        highlight: Color(0xFFFFF3B0),
        error: Color(0xFFF5C6CB),
        highlightText: Color(0xFF1A1A1A),
        errorText: Color(0xFF1A1A1A),
      );

  /// The `[data-qmh-text-scheme="dark"]` mark pair.
  factory MadinaTheme.dark() => const MadinaTheme(
        background: Color(0xFFF5F5DC),
        header: Color(0xFF000000),
        highlight: Color(0xFF5C4600),
        error: Color(0xFF6B1A24),
        highlightText: Color(0xFFFFFFFF),
        errorText: Color(0xFFFFFFFF),
      );

  final Color background;
  final Color header;
  final Color highlight;
  final Color error;
  final Color highlightText;
  final Color errorText;

  /// Swaps in the dark mark pair when the ambient text colour is light, so
  /// `highlight=`/`error=` stay legible on any host background.
  MadinaTheme forAmbient(Color ambientTextColour) {
    if (relativeLuminance(ambientTextColour) <= 0.5) return this;
    final dark = MadinaTheme.dark();
    return MadinaTheme(
      background: background,
      header: header,
      highlight: dark.highlight,
      error: dark.error,
      highlightText: dark.highlightText,
      errorText: dark.errorText,
    );
  }
}

/// The loader-script config: `data-name`, `data-font`, `data-font-size`, plus
/// the Flutter-only source and stretch-mode choices.
class MadinaConfig {
  const MadinaConfig({
    this.name = 'Madina05',
    this.font = 'Hafs',
    this.fontSize = 16,
    this.source,
    this.stretchMode = MadinaStretchMode.stored,
  });

  final String name;
  final String font;
  final double fontSize;

  /// Defaults to [MadinaAssetSource] when null, so the kit works offline out of
  /// the box.
  final MadinaSource? source;

  final MadinaStretchMode stretchMode;
}

/// Supplies config and theme to every [QuranMadinaView] below it.
class MadinaScope extends InheritedWidget {
  MadinaScope({
    super.key,
    MadinaConfig? config,
    MadinaTheme? theme,
    required super.child,
  })  : config = config ?? const MadinaConfig(),
        theme = theme ?? MadinaTheme.light();

  final MadinaConfig config;
  final MadinaTheme theme;

  /// Returns a default scope when none is in the tree, so a bare
  /// `QuranMadinaView` still renders.
  static MadinaScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MadinaScope>() ??
      MadinaScope(child: const SizedBox.shrink());

  @override
  bool updateShouldNotify(MadinaScope old) =>
      old.config != config || old.theme != theme;
}
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/theme_test.dart && dart format . && dart analyze
```

Expected: all PASS. `MadinaConfig` needs `==`/`hashCode` for `updateShouldNotify` to be meaningful — add them if the analyzer or a failing test asks; identity comparison is acceptable for the first pass since configs are normally `const`.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): theme, config and inherited scope"
```

---

### Task 11: The line renderer

Implements spec §5 — the central "one `Text.rich` per visual line" decision — plus §4.10 stretch.

**Files:**
- Create: `quran_madina_kit/lib/src/line.dart`
- Test: `quran_madina_kit/test/line_test.dart`

**Interfaces:**
- Consumes: `RenderPart`, `kCentredStretch` (Task 2); `WordRange`, `isWordToken`, `BasmalaMark` (Tasks 3–4); `MadinaTheme`, `MadinaStretchMode` (Task 10).
- Produces:
  - `class SpanBuildResult { final List<InlineSpan> spans; final int counter; }`
  - `SpanBuildResult buildWordSpans({required String text, required int counter, WordRange? displayRange, WordRange? highlightRange, WordRange? errorRange, required TextStyle base, required MadinaTheme theme, String? ayaKey, GestureRecognizer? recognizer})`
  - `InlineSpan buildSpacerSpan(String text, TextStyle base)`
  - `class MadinaLine extends StatelessWidget { final List<InlineSpan> spans; final double stretch; final double lineWidth; final double stretchScale; final MadinaStretchMode mode; final TextStyle style; }`
  - `double resolveScaleX({required double stretch, required double stretchScale, required MadinaStretchMode mode, required List<InlineSpan> spans, required double lineWidth, required TextStyle style})`

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/line_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/line.dart';
import 'package:quran_madina_kit/src/models.dart';
import 'package:quran_madina_kit/src/ranges.dart';
import 'package:quran_madina_kit/src/theme.dart';

const base = TextStyle(fontSize: 16, color: Color(0xFF000000));
final theme = MadinaTheme.light();

SpanBuildResult build(
  String text, {
  int counter = 0,
  WordRange? display,
  WordRange? highlight,
  WordRange? error,
}) =>
    buildWordSpans(
      text: text,
      counter: counter,
      displayRange: display,
      highlightRange: highlight,
      errorRange: error,
      base: base,
      theme: theme,
    );

List<TextSpan> visible(SpanBuildResult r) =>
    r.spans.cast<TextSpan>().where((s) => (s.text ?? '').trim().isNotEmpty).toList();

void main() {
  group('buildWordSpans', () {
    test('emits one span per token and preserves the whitespace between them', () {
      final r = build('ٱلْحَمْدُ لِلَّهِ');
      final joined = r.spans.cast<TextSpan>().map((s) => s.text).join();
      expect(joined, 'ٱلْحَمْدُ لِلَّهِ',
          reason: 'the concatenated spans must reproduce the source text exactly');
    });

    test('advances the counter only for letter-bearing tokens', () {
      final r = build('ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ ﴿٢﴾');
      expect(r.counter, 4, reason: 'the aya marker is not a word');
    });

    test('resumes from a non-zero counter', () {
      expect(build('أ ب', counter: 10).counter, 12);
    });

    test('a word outside the display range is transparent, not removed', () {
      final r = build('واحد اثنان ثلاثة', display: const WordRange(2, 2));
      final words = visible(r);
      expect(words.length, 3, reason: 'geometry is preserved: nothing is dropped');
      expect(words[0].style!.color, const Color(0x00000000));
      expect(words[1].style!.color, base.color, reason: 'the selected word shows');
      expect(words[2].style!.color, const Color(0x00000000));
    });

    test('a null display range hides nothing', () {
      final r = build('واحد اثنان');
      expect(visible(r).every((s) => s.style!.color == base.color), isTrue);
    });

    test('highlight paints a background without changing the box', () {
      final r = build('واحد اثنان ثلاثة', highlight: const WordRange(2, 2));
      final words = visible(r);
      expect(words[1].style!.backgroundColor, theme.highlight);
      expect(words[0].style!.backgroundColor, isNull);
    });

    test('error wins over highlight on an overlapping word', () {
      final r = build('واحد اثنان',
          highlight: const WordRange(1, 2), error: const WordRange(2, 2));
      final words = visible(r);
      expect(words[0].style!.backgroundColor, theme.highlight);
      expect(words[1].style!.backgroundColor, theme.error);
    });

    test('a marker inherits the state of the word it follows', () {
      // ﴿٢﴾ trails word 2; hiding word 2 must hide its marker too.
      final r = build('واحد اثنان ﴿٢﴾', display: const WordRange(1, 1));
      final tokens = visible(r);
      expect(tokens[2].text, '﴿٢﴾');
      expect(tokens[2].style!.color, const Color(0x00000000),
          reason: 'the marker follows the hidden word 2');
    });

    test('a marker after a marked word is marked too', () {
      final r = build('واحد اثنان ﴿٢﴾', highlight: const WordRange(2, 2));
      expect(visible(r)[2].style!.backgroundColor, theme.highlight);
    });
  });

  group('buildSpacerSpan', () {
    test('is fully transparent so it holds layout without showing', () {
      final s = buildSpacerSpan('نص سابق', base) as TextSpan;
      expect(s.text, 'نص سابق');
      expect(s.style!.color, const Color(0x00000000));
    });
  });

  group('resolveScaleX', () {
    List<InlineSpan> spans() =>
        [TextSpan(text: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ', style: base)];

    test('a centred line is never scaled', () {
      expect(
        resolveScaleX(
          stretch: kCentredStretch,
          stretchScale: 1,
          mode: MadinaStretchMode.stored,
          spans: spans(),
          lineWidth: 270,
          style: base,
        ),
        1.0,
      );
    });

    test('stored mode multiplies the DB factor by the size correction', () {
      expect(
        resolveScaleX(
          stretch: 1.2,
          stretchScale: 1.05,
          mode: MadinaStretchMode.stored,
          spans: spans(),
          lineWidth: 270,
          style: base,
        ),
        closeTo(1.26, 1e-9),
      );
    });

    test('measured mode derives the factor from the real width', () {
      final s = resolveScaleX(
        stretch: 1.2,
        stretchScale: 1.05,
        mode: MadinaStretchMode.measured,
        spans: spans(),
        lineWidth: 270,
        style: base,
      );
      expect(s, greaterThan(0));
      expect(s, isNot(closeTo(1.26, 1e-9)),
          reason: 'measured ignores the stored factor entirely');
    });
  });

  group('MadinaLine widget', () {
    testWidgets('a stretched line gets a scaleX transform anchored top-right',
        (tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.rtl,
        child: MadinaLine(
          spans: [TextSpan(text: 'نص', style: base)],
          stretch: 1.5,
          stretchScale: 1,
          lineWidth: 270,
          mode: MadinaStretchMode.stored,
          style: base,
        ),
      ));
      final t = tester.widget<Transform>(find.byType(Transform).first);
      expect(t.alignment, Alignment.topRight);
      expect(t.transform.storage[0], 1.5);
    });

    testWidgets('a centred line is centred, not transformed', (tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.rtl,
        child: MadinaLine(
          spans: [TextSpan(text: 'سورة الفاتحة', style: base)],
          stretch: kCentredStretch,
          stretchScale: 1,
          lineWidth: 270,
          mode: MadinaStretchMode.stored,
          style: base,
        ),
      ));
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('never wraps and never clips the line', (tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.rtl,
        child: MadinaLine(
          spans: [TextSpan(text: 'كلمة ' * 40, style: base)],
          stretch: 1,
          stretchScale: 1,
          lineWidth: 270,
          mode: MadinaStretchMode.stored,
          style: base,
        ),
      ));
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.softWrap, isFalse);
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.visible);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/line_test.dart
```

Expected: FAIL — `line.dart` does not exist.

- [ ] **Step 3: Write the implementation**

`quran_madina_kit/lib/src/line.dart`:

```dart
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'models.dart';
import 'ranges.dart';
import 'theme.dart';

/// Transparent, so a hidden word or a context spacer still occupies its exact
/// advance width. Removing it would reflow the line and destroy the
/// pre-computed Madina justification.
const Color _invisible = Color(0x00000000);

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

  for (final token in text.split(RegExp(r'(\s+)'))) {
    if (token.isEmpty) continue;
    if (RegExp(r'^\s+$').hasMatch(token)) {
      spans.add(TextSpan(text: token, style: base));
      continue;
    }
    if (isWordToken(token)) n++;

    final hidden = displayRange != null && !displayRange.contains(n);
    Color? background;
    Color? foreground = base.color;
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
        color: hidden ? _invisible : foreground,
        backgroundColor: hidden ? null : background,
      ),
      recognizer: recognizer,
    ));
  }
  return SpanBuildResult(spans: spans, counter: n);
}

/// Preceding/following page text rendered invisibly, so the line's own
/// centring or stretch places the first visible word exactly as on the page.
InlineSpan buildSpacerSpan(String text, TextStyle base) =>
    TextSpan(text: text, style: base.copyWith(color: _invisible));

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

  final painter = TextPainter(
    text: TextSpan(children: spans, style: style),
    textDirection: TextDirection.rtl,
    maxLines: 1,
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

  bool get _centred => stretch == kCentredStretch;

  @override
  Widget build(BuildContext context) {
    final text = Text.rich(
      TextSpan(children: spans, style: style),
      textDirection: TextDirection.rtl,
      textAlign: _centred ? TextAlign.center : TextAlign.right,
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.visible,
    );

    if (_centred) return SizedBox(width: lineWidth, child: text);

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
        // transform-origin: top right — the RTL line grows leftwards from its
        // right edge, matching the web's `transform-origin: top right`.
        alignment: Alignment.topRight,
        transform: Matrix4.diagonal3Values(scaleX, 1, 1),
        child: text,
      ),
    );
  }
}
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/line_test.dart && dart format . && dart analyze
```

Expected: all PASS. If `Text.rich` is not found by `find.byType(Text)`, the widget tree wraps it —
adjust the finder, not the widget.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): line renderer with word spans and stretch modes"
```

---

### Task 12: `QuranMadinaView` — page and verse rendering

Implements spec §4.8, §4.9, §6 (API surface), §7 (error handling).

**Files:**
- Create: `quran_madina_kit/lib/src/widget.dart`
- Create: `quran_madina_kit/lib/src/render_plan.dart`
- Test: `quran_madina_kit/test/render_plan_test.dart`
- Test: `quran_madina_kit/test/widget_page_test.dart`

**Interfaces:**
- Consumes: everything from Tasks 2–11.
- Produces:
  - `class PlannedLine { final int line; final double stretch; final List<PlannedPart> parts; final List<RenderPart> leadingContext, trailingContext; }`
  - `class PlannedPart { final int sura, ayaIndex; final RenderPart part; final bool countable; }`
  - `class RenderPlan { final List<PlannedLine> lines; final bool multiline; final int page; final String suraName; final int totalWords; }`
  - `RenderPlan? planVerseOrPage(MadinaDb db, {int? page, int? sura, String? aya, MadinaInline inline = MadinaInline.auto, required void Function(String) log})`
  - `int countVerseRangeWords(MadinaDb db, int sura0, int ayaFrom, int ayaTo)`
  - `int countPageWords(MadinaDb db, {required int suraFrom, required int ayaFrom, required int suraTo, required int ayaTo, required int page})`
  - `class QuranMadinaView extends StatefulWidget` with named args `page, sura, aya, words, highlight, error, headless, quotes, inline, notitle`

- [ ] **Step 1: Write the failing planner tests**

`quran_madina_kit/test/render_plan_test.dart`:

```dart
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/render_plan.dart';
import 'package:quran_madina_kit/src/repository.dart';
import 'package:quran_madina_kit/src/source.dart';
import 'package:quran_madina_kit/src/theme.dart';

class FakeSource extends MadinaSource {
  FakeSource(this.files);
  final Map<String, Map<String, dynamic>> files;
  @override
  Future<Map<String, dynamic>?> loadJson(String path, {bool forceFresh = false}) async =>
      files[path];
  @override
  Future<Uint8List?> loadFont(String url) async => Uint8List(0);
  @override
  void clearCache(String prefix) {}
}

/// Page 1 of a two-sura toy DB. Sura 0 slots: blank, title, aya1(L2), aya2(L3),
/// aya3(L3 continuation).
Future<MadinaDb> toyDb() async => (await MadinaDb.boot(
      source: FakeSource({
        'db/Madina05-Hafs-16px.json': {
          'title': 't',
          'published': 1405,
          'font_family': 'Hafs',
          'font_url': 'f.woff2',
          'font_size': 16,
          'line_width': 270,
          'suras': [
            {
              'name': 'سورة الفاتحة',
              'ayas': [
                {
                  'p': 1,
                  'r': [
                    {'l': 1, 't': '', 's': -1}
                  ]
                },
                {
                  'p': 1,
                  'r': [
                    {'l': 1, 't': 'سورة الفاتحة', 's': -1}
                  ]
                },
                {
                  'p': 1,
                  'r': [
                    {'l': 2, 't': 'ٱلْحَمْدُ لِلَّهِ ﴿١﴾', 's': 1.1}
                  ]
                },
                {
                  'p': 1,
                  'r': [
                    {'l': 3, 't': 'رَبِّ ٱلْعَـٰلَمِينَ ﴿٢﴾', 's': 1.2}
                  ]
                },
                {
                  'p': 1,
                  'r': [
                    {'l': 3, 't': ' ٱلرَّحْمَـٰنِ ﴿٣﴾', 's': 1.2}
                  ]
                },
              ]
            },
          ],
        },
      }),
      name: 'Madina05',
      font: 'Hafs',
      fontSize: 16,
    ))!;

void main() {
  group('word counting for mark bounds', () {
    test('counts a verse range', () async {
      final db = await toyDb();
      expect(countVerseRangeWords(db, 0, 2, 2), 2, reason: 'ٱلْحَمْدُ لِلَّهِ');
      expect(countVerseRangeWords(db, 0, 2, 4), 5);
    });

    test('skips title slots', () async {
      final db = await toyDb();
      expect(countVerseRangeWords(db, 0, 1, 2), 2,
          reason: 'the title at slot 1 contributes nothing');
    });

    test('counts a page', () async {
      final db = await toyDb();
      expect(
          countPageWords(db, suraFrom: 0, ayaFrom: 0, suraTo: 0, ayaTo: 4, page: 1), 5);
    });
  });

  group('planVerseOrPage — verse mode', () {
    test('plans the lines the verse occupies', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, sura: 1, aya: '1', log: (_) {})!;
      expect(plan.lines.length, 1);
      expect(plan.lines.single.line, 2);
      expect(plan.multiline, isFalse, reason: 'a single line renders inline');
    });

    test('a verse spanning two lines is multiline', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, sura: 1, aya: '1-2', log: (_) {})!;
      expect(plan.lines.map((l) => l.line).toList(), [2, 3]);
      expect(plan.multiline, isTrue);
    });

    test('carries the stored stretch per line', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, sura: 1, aya: '1-2', log: (_) {})!;
      expect(plan.lines[0].stretch, 1.1);
      expect(plan.lines[1].stretch, 1.2);
    });

    test('adds trailing context for a verse ending mid-line', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, sura: 1, aya: '2', log: (_) {})!;
      expect(plan.lines.single.trailingContext.map((p) => p.text).toList(),
          [' ٱلرَّحْمَـٰنِ ﴿٣﴾']);
    });

    test('adds leading context for a verse starting mid-line', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, sura: 1, aya: '3', log: (_) {})!;
      expect(plan.lines.single.leadingContext.map((p) => p.text).toList(),
          ['رَبِّ ٱلْعَـٰلَمِينَ ﴿٢﴾']);
    });

    test('inline="no" forces the multiline layout', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db,
          sura: 1, aya: '1', inline: MadinaInline.no, log: (_) {})!;
      expect(plan.multiline, isTrue);
    });

    test('inline="yes" warns and behaves as auto', () async {
      final db = await toyDb();
      final logs = <String>[];
      final plan = planVerseOrPage(db,
          sura: 1, aya: '1-2', inline: MadinaInline.yes, log: logs.add)!;
      expect(plan.multiline, isTrue);
      expect(logs.join(), contains('not implemented yet'));
    });

    test('sura+aya wins over page and warns', () async {
      final db = await toyDb();
      final logs = <String>[];
      final plan = planVerseOrPage(db, page: 1, sura: 1, aya: '1', log: logs.add)!;
      expect(plan.multiline, isFalse, reason: 'planned as a verse, not a page');
      expect(logs.join(), contains('Ignoring page parameter'));
    });
  });

  group('planVerseOrPage — page mode', () {
    test('plans every line the page occupies and is always multiline', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, page: 1, log: (_) {})!;
      expect(plan.multiline, isTrue);
      expect(plan.lines.map((l) => l.line).toList(), [1, 2, 3]);
    });

    test('a page render has no context spacers', () async {
      final db = await toyDb();
      final plan = planVerseOrPage(db, page: 1, log: (_) {})!;
      expect(plan.lines.every((l) => l.leadingContext.isEmpty && l.trailingContext.isEmpty),
          isTrue);
    });

    test('ignores inline with a warning', () async {
      final db = await toyDb();
      final logs = <String>[];
      planVerseOrPage(db, page: 1, inline: MadinaInline.no, log: logs.add);
      expect(logs.join(), contains('Ignoring inline parameter with page'));
    });
  });

  group('planVerseOrPage — bad arguments', () {
    test('returns null and logs when neither page nor sura+aya is given', () async {
      final db = await toyDb();
      final logs = <String>[];
      expect(planVerseOrPage(db, log: logs.add), isNull);
      expect(logs.join(), contains('Bad arguments'));
    });

    test('returns null for an out-of-range page', () async {
      final db = await toyDb();
      expect(planVerseOrPage(db, page: 9999, log: (_) {}), isNull);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/render_plan_test.dart
```

Expected: FAIL — `render_plan.dart` does not exist.

- [ ] **Step 3: Write the planner**

`quran_madina_kit/lib/src/render_plan.dart`:

```dart
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

/// One visual line of the plan, with the invisible page text that must flank it.
class PlannedLine {
  PlannedLine({required this.line, required this.stretch});

  final int line;
  double stretch;
  final List<PlannedPart> parts = [];
  final List<RenderPart> leadingContext = [];
  final List<RenderPart> trailingContext = [];
}

/// A complete, render-ready description of what to draw.
class RenderPlan {
  const RenderPlan({
    required this.lines,
    required this.multiline,
    required this.page,
    required this.suraName,
    required this.totalWords,
  });

  final List<PlannedLine> lines;
  final bool multiline;
  final int page;
  final String suraName;

  /// Countable words displayed — the bound `highlight=`/`error=` validate against.
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
bool _applyInlineOverride(MadinaInline inline, bool multiline, void Function(String) log) {
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

/// Plans a `page` or `sura`+`aya` render. Returns null (after logging) rather
/// than throwing on bad arguments.
RenderPlan? planVerseOrPage(
  MadinaDb db, {
  int? page,
  int? sura,
  String? aya,
  MadinaInline inline = MadinaInline.auto,
  required void Function(String) log,
}) {
  final verseMode = sura != null && aya != null;
  int suraFrom, suraTo, ayaFrom, ayaTo, targetPage;
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
    if (inline != MadinaInline.auto) log('Ignoring inline parameter with page!');
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
  if (page == null || verseMode) {
    multiline = _applyInlineOverride(inline, multiline, log);
  }

  final lines = <PlannedLine>[];
  var ayaCurrent = ayaFrom;
  var suraCurrent = suraFrom;

  for (var l = lineFrom; l <= lineTo; l++) {
    final planned = PlannedLine(line: l, stretch: 1);
    if (multiline && verseMode && l == lineFrom) {
      planned.leadingContext.addAll(lineContext(db,
          sura0: suraFrom, page: targetPage, line: lineFrom, ayaIndex: ayaFrom, direction: -1));
    }

    final lookAhead =
        (suraFrom == suraTo) ? ayaTo : db.suras[suraCurrent].ayas.length - 1;
    // The +5 window and the sura-jump peek can probe an unloaded aya, but any
    // such aya is necessarily off this page, so null means "not here".
    for (var a = ayaCurrent; a <= (ayaCurrent + 5 < lookAhead ? ayaCurrent + 5 : lookAhead); a++) {
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

      final nextSuraSlot0 =
          (suraCurrent < db.suras.length - 1) ? db.aya(suraCurrent + 1, 0) : null;
      if (ayaCurrent >= lookAhead &&
          nextSuraSlot0 != null &&
          nextSuraSlot0.page == targetPage &&
          nextSuraSlot0.parts.first.line == l + 1) {
        suraCurrent++;
        ayaCurrent = 0;
      }
    }

    if (multiline && verseMode && l == lineTo) {
      planned.trailingContext.addAll(lineContext(db,
          sura0: suraTo, page: targetPage, line: lineTo, ayaIndex: ayaTo, direction: 1));
    }
    lines.add(planned);
  }

  final total = verseMode
      ? countVerseRangeWords(db, suraFrom, ayaFrom, ayaTo)
      : countPageWords(db,
          suraFrom: suraFrom,
          ayaFrom: ayaFrom,
          suraTo: suraTo,
          ayaTo: ayaTo,
          page: targetPage);

  return RenderPlan(
    lines: lines,
    multiline: multiline,
    page: targetPage,
    suraName: db.suras[suraFrom].name,
    totalWords: total,
  );
}
```

- [ ] **Step 4: Run the planner tests**

```bash
flutter test test/render_plan_test.dart
```

Expected: all PASS.

- [ ] **Step 5: Write the failing widget tests**

`quran_madina_kit/test/widget_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';
import 'package:quran_madina_kit/src/line.dart';

Widget host(Widget child) => MaterialApp(
      home: MadinaScope(
        config: const MadinaConfig(font: 'Hafs', fontSize: 16),
        child: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  testWidgets('renders Al-Fatiha aya 1 from the bundled DB', (tester) async {
    await tester.pumpWidget(host(const QuranMadinaView(sura: 1, aya: '1')));
    await tester.pumpAndSettle();
    expect(find.byType(MadinaLine), findsOneWidget);
  });

  testWidgets('renders page 1 as 7 lines', (tester) async {
    await tester.pumpWidget(host(const QuranMadinaView(page: 1, headless: true)));
    await tester.pumpAndSettle();
    // Page 1 of the Madina Mushaf uses lines 1..7 (title, basmala, 5 ayat lines).
    expect(find.byType(MadinaLine), findsNWidgets(7));
  });

  testWidgets('shows a placeholder while loading, then the text', (tester) async {
    await tester.pumpWidget(host(const QuranMadinaView(sura: 1, aya: '1')));
    expect(find.byType(MadinaLine), findsNothing);
    await tester.pumpAndSettle();
    expect(find.byType(MadinaLine), findsOneWidget);
  });

  testWidgets('bad arguments render nothing and do not throw', (tester) async {
    await tester.pumpWidget(host(const QuranMadinaView()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(MadinaLine), findsNothing);
  });

  testWidgets('re-renders when the aya changes', (tester) async {
    await tester.pumpWidget(host(const QuranMadinaView(sura: 1, aya: '1')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(host(const QuranMadinaView(sura: 1, aya: '1-3')));
    await tester.pumpAndSettle();
    expect(find.byType(MadinaLine), findsNWidgets(3));
  });
}
```

- [ ] **Step 6: Write the widget**

`quran_madina_kit/lib/src/widget.dart` — a `StatefulWidget` that:

1. In `initState`/`didUpdateWidget`, resolves `MadinaScope.of(context)` config into a boot future:
   `clampFontSize` → `resolveSizeOverrides` (only when the size is not an anchor) →
   `MadinaDb.boot` → apply overrides to `manifest.fontSize/lineWidth/stretchScale` →
   `FontLoader(manifest.fontFamily)..addFont(source.loadFont(manifest.fontUrl))`.
   Cache the booted `MadinaDb` and the loaded font family in a module-level map keyed by
   `dbStem`, so several views share one boot.
2. Calls `db.ensureJuz(neededJuz(...))` before building, where `neededJuz` follows spec §4.7.
3. Builds the plan with `planVerseOrPage`, converts each `PlannedLine` to `MadinaLine`:
   - `leadingContext` → `buildSpacerSpan` per part, prepended
   - each `PlannedPart` → `buildWordSpans` (basmala slots use `kBasmalaLigature` when
     `basmalaRenderMode(...).ligature`, still advancing the counter by its word count)
   - `trailingContext` → `buildSpacerSpan` per part, appended
4. Wraps the lines in a `Column` of width `manifest.lineWidth + 10` when `multiline`,
   with the page-parity gutter gradient, or returns the single `MadinaLine` when inline.
5. Text style: `TextStyle(fontFamily: manifest.fontFamily, fontSize: manifest.fontSize,
   height: manifest.fontFamily == 'me_quran' ? 2.0 : null, color: ambient)`.

Public constructor:

```dart
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
  });

  final int? page;
  final int? sura;
  final String? aya;
  final String? words;
  final String? highlight;
  final String? error;
  final bool headless;
  final bool quotes;
  final MadinaInline inline;
  final bool notitle;
  ...
}
```

`neededJuz` (put it next to the widget, or in `repository.dart` if it reads more naturally there):

```dart
List<int> neededJuz(MadinaDb db, {int? page, int? sura, String? aya, String? words}) {
  if (!db.manifest.isSharded) return const [];
  final juzCount = db.manifest.juz!.length;
  if (sura != null && aya != null) {
    final s0 = parseSura(sura.toString());
    final range = parseAyaRange(aya);
    if (s0 == null || range == null) return const [];
    if (words != null) {
      // words spill forward less than one juz'; from the last juz' they wrap
      // around to Al-Fatiha's, so the successor is taken modulo the count.
      final j = db.suraAyaToJuz(s0, range.from);
      return [j, (j + 1) % juzCount];
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
```

Export from `lib/quran_madina_kit.dart`:

```dart
export 'src/theme.dart'
    show MadinaConfig, MadinaScope, MadinaTheme, MadinaStretchMode, MadinaInline;
export 'src/source.dart' show MadinaSource, MadinaAssetSource, MadinaNetworkSource;
export 'src/widget.dart' show QuranMadinaView;
```

- [ ] **Step 7: Run the widget tests**

```bash
flutter test test/widget_page_test.dart && dart format . && dart analyze
```

Expected: all PASS. If the page-1 line count differs from 7, read the bundled
`assets/db/Madina05-Hafs-16px/juz-01.json` and correct the *test's* expectation to what the DB
actually says — never change the renderer to match a guessed number.

- [ ] **Step 8: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): QuranMadinaView with page and verse rendering"
```

---

### Task 13: The `words=` render path

**Files:**
- Modify: `quran_madina_kit/lib/src/widget.dart`
- Test: `quran_madina_kit/test/widget_words_test.dart`

**Interfaces:**
- Consumes: `collectWordParts`, `CollectedWords` (Task 9); `buildWordSpans` (Task 11).
- Produces: a `_buildWordsSpan(...)` branch inside `QuranMadinaView`, taken before the
  page/verse plan whenever `words` parses.

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/widget_words_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';
import 'package:quran_madina_kit/src/line.dart';

Widget host(Widget child) => MaterialApp(
      home: MadinaScope(
        config: const MadinaConfig(font: 'Hafs', fontSize: 16),
        child: Scaffold(body: Center(child: child)),
      ),
    );

/// Every rendered word span, in order, with whether it is visible.
List<(String, bool)> wordsOf(WidgetTester tester) {
  final out = <(String, bool)>[];
  for (final line in tester.widgetList<MadinaLine>(find.byType(MadinaLine))) {
    for (final span in line.spans.cast<TextSpan>()) {
      final t = span.text ?? '';
      if (t.trim().isEmpty) continue;
      out.add((t, span.style?.color?.alpha != 0));
    }
  }
  return out;
}

void main() {
  testWidgets('shows only the selected words, keeping the rest in place',
      (tester) async {
    await tester
        .pumpWidget(host(const QuranMadinaView(sura: 1, aya: '1', words: '1:2')));
    await tester.pumpAndSettle();
    final words = wordsOf(tester);
    expect(words.where((w) => w.$2).length, greaterThanOrEqualTo(2));
    expect(words.where((w) => !w.$2), isNotEmpty,
        reason: 'the hidden remainder must still be rendered, transparently');
  });

  testWidgets('a selection crossing into the next sura shows its title',
      (tester) async {
    await tester
        .pumpWidget(host(const QuranMadinaView(sura: 1, aya: '7', words: '1-14')));
    await tester.pumpAndSettle();
    final texts = wordsOf(tester).map((w) => w.$1).join(' ');
    expect(texts, contains('البقرة'), reason: 'the crossed-into title renders for context');
  });

  testWidgets('notitle hides the crossed-into sura name but keeps its line',
      (tester) async {
    await tester.pumpWidget(host(
        const QuranMadinaView(sura: 1, aya: '7', words: '1-14', notitle: true)));
    await tester.pumpAndSettle();
    final title = wordsOf(tester).where((w) => w.$1.contains('البقرة'));
    expect(title, isNotEmpty, reason: 'the name span still exists (it sizes the line)');
    expect(title.every((w) => !w.$2), isTrue, reason: 'but it is invisible');
  });

  testWidgets('a malformed words falls back to the normal verse render',
      (tester) async {
    await tester
        .pumpWidget(host(const QuranMadinaView(sura: 1, aya: '1', words: '5-2')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(wordsOf(tester).every((w) => w.$2), isTrue,
        reason: 'the fallback render hides nothing');
  });

  testWidgets('the selection is capped at 500 words', (tester) async {
    await tester
        .pumpWidget(host(const QuranMadinaView(sura: 1, aya: '1', words: '1-9999')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(wordsOf(tester).where((w) => w.$2).length, lessThanOrEqualTo(520),
        reason: '500 words plus their trailing markers');
  });

  testWidgets('words is ignored on a page render', (tester) async {
    await tester
        .pumpWidget(host(const QuranMadinaView(page: 1, words: '1-3')));
    await tester.pumpAndSettle();
    expect(wordsOf(tester).every((w) => w.$2), isTrue);
  });

  testWidgets('a fully-selected basmala collapses to the ligature', (tester) async {
    // Al-Baqara aya 1 anchors the walk, which rewinds to its basmala: words 1-4.
    await tester
        .pumpWidget(host(const QuranMadinaView(sura: 2, aya: '1', words: '1-4')));
    await tester.pumpAndSettle();
    expect(wordsOf(tester).map((w) => w.$1).join(), contains('﷽'));
  });

  testWidgets('a partial basmala selection renders individual words',
      (tester) async {
    await tester
        .pumpWidget(host(const QuranMadinaView(sura: 2, aya: '1', words: '1-2')));
    await tester.pumpAndSettle();
    final texts = wordsOf(tester).map((w) => w.$1).join(' ');
    expect(texts, isNot(contains('﷽')));
    expect(texts, contains('بِسْمِ'));
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/widget_words_test.dart
```

Expected: FAIL — the `words` argument is currently ignored.

- [ ] **Step 3: Implement the branch**

In `QuranMadinaView`'s build, before planning:

```dart
// words= has its own renderer, spanning pages and suras from the start aya.
if (widget.words != null) {
  if (widget.page != null && widget.sura == null) {
    log('Ignoring words parameter with page!');
  } else {
    final parsed = parseWordsRange(widget.words);
    if (parsed == null) {
      log('Bad words parameter: ${widget.words}');
      // fall through to the normal verse render
    } else {
      if (ayaTo != ayaFrom) log('Ignoring aya range end with words parameter!');
      final range = parsed.capped;
      if (range != parsed) log('words selection capped at $kMaxWordsSelection words');
      highlightRange = clampedOrNull('highlight', highlightRange, range.start, range.end, log);
      errorRange = clampedOrNull('error', errorRange, range.start, range.end, log);
      return _buildWordsSpan(db, suraFrom, ayaFrom, range, highlightRange, errorRange);
    }
  }
}
```

`_buildWordsSpan` walks `collectWordParts(...)`, seeding the counter with `counterStart`, and for
each `CollectedLine` builds a `MadinaLine` whose spans are:

- leading `buildSpacerSpan`s from `lineContext(..., direction: -1)` **only** when the first part of
  the first line is not a line start (`isLineStartPart`) — only the leading line can begin mid-line
- one `buildWordSpans` call per `CollectedPart`, except:
  - a basmala slot whose `basmalaRenderMode(...).ligature` is true → one `kBasmalaLigature` span,
    counter advanced by `countPartWords(part)`
  - a title slot under `notitle` → one fully transparent span with the title text
  - a title slot otherwise → one plain visible span (never counted, never markable)
- trailing `buildSpacerSpan`s from `lineContext(..., direction: 1)` on the last line

`multiline = _applyInlineOverride(inline, lines.length > 1, log)`.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/widget_words_test.dart && dart format . && dart analyze
```

Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): words= selection render path"
```

---

### Task 14: `highlight=` and `error=` in every render mode

**Files:**
- Modify: `quran_madina_kit/lib/src/widget.dart`
- Test: `quran_madina_kit/test/widget_marks_test.dart`

**Interfaces:**
- Consumes: `clampedOrNull` (Task 3), `basmalaRenderMode` (Task 4), `MadinaTheme.forAmbient` (Task 10).
- Produces: mark ranges threaded through both render paths with a running `wordCounter`.

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/widget_marks_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';
import 'package:quran_madina_kit/src/line.dart';

Widget host(Widget child, {Color text = const Color(0xFF000000)}) => MaterialApp(
      home: MadinaScope(
        config: const MadinaConfig(font: 'Hafs', fontSize: 16),
        child: Scaffold(
          body: DefaultTextStyle(
            style: TextStyle(color: text),
            child: Center(child: child),
          ),
        ),
      ),
    );

List<TextSpan> spansOf(WidgetTester tester) => tester
    .widgetList<MadinaLine>(find.byType(MadinaLine))
    .expand((l) => l.spans.cast<TextSpan>())
    .where((s) => (s.text ?? '').trim().isNotEmpty)
    .toList();

void main() {
  testWidgets('marks words on a plain verse render with no words=', (tester) async {
    await tester
        .pumpWidget(host(const QuranMadinaView(sura: 1, aya: '1', highlight: '2-3')));
    await tester.pumpAndSettle();
    final marked = spansOf(tester).where((s) => s.style?.backgroundColor != null);
    expect(marked.length, greaterThanOrEqualTo(2));
  });

  testWidgets('marks words on a full page render', (tester) async {
    await tester
        .pumpWidget(host(const QuranMadinaView(page: 1, highlight: '1-2')));
    await tester.pumpAndSettle();
    expect(spansOf(tester).where((s) => s.style?.backgroundColor != null), isNotEmpty);
  });

  testWidgets('error wins over highlight on overlap', (tester) async {
    await tester.pumpWidget(host(
        const QuranMadinaView(sura: 1, aya: '1', highlight: '1-4', error: '2-2')));
    await tester.pumpAndSettle();
    final colours = spansOf(tester)
        .map((s) => s.style?.backgroundColor)
        .whereType<Color>()
        .toSet();
    expect(colours, contains(MadinaTheme.light().error));
    expect(colours, contains(MadinaTheme.light().highlight));
  });

  testWidgets('an out-of-bounds mark is dropped, not fatal', (tester) async {
    await tester
        .pumpWidget(host(const QuranMadinaView(sura: 1, aya: '1', highlight: '50-60')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(spansOf(tester).where((s) => s.style?.backgroundColor != null), isEmpty);
  });

  testWidgets('a malformed mark is dropped, not fatal', (tester) async {
    await tester
        .pumpWidget(host(const QuranMadinaView(sura: 1, aya: '1', error: 'abc')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('marks combine with a words= selection', (tester) async {
    await tester.pumpWidget(host(
        const QuranMadinaView(sura: 1, aya: '1', words: '1-4', highlight: '2-2')));
    await tester.pumpAndSettle();
    expect(spansOf(tester).where((s) => s.style?.backgroundColor != null).length, 1);
  });

  testWidgets('light ambient text picks the dark mark pair', (tester) async {
    await tester.pumpWidget(host(
      const QuranMadinaView(sura: 1, aya: '1', highlight: '2-2'),
      text: const Color(0xFFFFFFFF),
    ));
    await tester.pumpAndSettle();
    final marked = spansOf(tester)
        .firstWhere((s) => s.style?.backgroundColor != null);
    expect(marked.style!.backgroundColor, MadinaTheme.dark().highlight);
  });

  testWidgets('a mark cutting into part of the basmala forces its tokens',
      (tester) async {
    await tester.pumpWidget(host(const QuranMadinaView(sura: 2, aya: '1', highlight: '2-3')));
    await tester.pumpAndSettle();
    final texts = spansOf(tester).map((s) => s.text).join(' ');
    expect(texts, isNot(contains('﷽')));
  });

  testWidgets('a mark covering the whole basmala keeps the ligature',
      (tester) async {
    await tester.pumpWidget(host(const QuranMadinaView(sura: 2, aya: '1', highlight: '1-4')));
    await tester.pumpAndSettle();
    final lig = spansOf(tester).where((s) => s.text == '﷽');
    expect(lig, isNotEmpty);
    expect(lig.single.style?.backgroundColor, isNotNull);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/widget_marks_test.dart
```

Expected: FAIL — marks are not yet applied in the page/verse path.

- [ ] **Step 3: Implement**

In the page/verse path, mirror the web's `wordMarkMode` gate:

```dart
var highlightRange = parseWordsRange(widget.highlight);
if (widget.highlight != null && highlightRange == null) {
  log('Bad highlight parameter: ${widget.highlight}');
}
var errorRange = parseWordsRange(widget.error);
if (widget.error != null && errorRange == null) {
  log('Bad error parameter: ${widget.error}');
}
// Validated against the full verse/page: word 1 is the first word of ayaFrom
// (verse mode) or of the page's first aya (a page never starts mid-aya).
highlightRange = clampedOrNull('highlight', highlightRange, 1, plan.totalWords, log);
errorRange = clampedOrNull('error', errorRange, 1, plan.totalWords, log);
final wordMarkMode = highlightRange != null || errorRange != null;
```

Thread a `wordCounter` across the whole line loop. For each `PlannedPart`:

- `!wordMarkMode || !part.countable` → the plain path: one span with the part's text
  (a basmala slot renders `kBasmalaLigature` unless its text is empty)
- otherwise → `buildWordSpans`, except a basmala slot whose `basmalaRenderMode(counter, words,
  displayRange: null, ...)` returns `ligature: true`, which emits one ligature span carrying the
  mode's mark colour and advances the counter by its word count

Theme: `MadinaScope.of(context).theme.forAmbient(DefaultTextStyle.of(context).style.color ??
const Color(0xFF000000))`.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/widget_marks_test.dart && dart format . && dart analyze
```

Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): highlight= and error= word marking in every render mode"
```

---

### Task 15: Chrome — header, copy, translate, aya popup, hover, sura frame

Implements the remaining rows of spec §5 plus the copy format in §6.

**Files:**
- Create: `quran_madina_kit/lib/src/chrome.dart`
- Modify: `quran_madina_kit/lib/src/widget.dart`
- Test: `quran_madina_kit/test/chrome_test.dart`

**Interfaces:**
- Consumes: `MadinaTheme` (Task 10), `RenderPlan` / `CollectedWords` (Tasks 12–13).
- Produces:
  - `String copyText({required String body, required String suraName})`
  - `String visibleTextOf(List<InlineSpan> spans)` — the copy body, built from the span model
  - `Uri translateUri({int? sura, int? aya, int? page})`
  - `class MadinaHeader extends StatelessWidget { final String suraName; final VoidCallback onCopy, onTranslate; }`
  - `class SuraFrame extends StatelessWidget { final Widget child; final Color colour; }`
  - `class AyaHoverScope extends InheritedWidget { final ValueNotifier<String?> hovered; }`
  - `void showAyaPopup(BuildContext, {required Rect anchor, required String text, required String suraName, required int sura, required int aya, required MadinaTheme theme})`
  - `List<InlineSpan> withQuoteMarks(List<InlineSpan> spans, TextStyle base)`

- [ ] **Step 1: Write the failing tests**

`quran_madina_kit/test/chrome_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';
import 'package:quran_madina_kit/src/chrome.dart';

const base = TextStyle(fontSize: 16, color: Color(0xFF000000));
const invisible = TextStyle(fontSize: 16, color: Color(0x00000000));

void main() {
  group('visibleTextOf', () {
    test('keeps only visible spans and collapses whitespace', () {
      final text = visibleTextOf(const [
        TextSpan(text: 'نص سابق', style: invisible),
        TextSpan(text: 'ٱلْحَمْدُ', style: base),
        TextSpan(text: '   ', style: base),
        TextSpan(text: 'لِلَّهِ', style: base),
        TextSpan(text: 'مخفي', style: invisible),
      ]);
      expect(text, 'ٱلْحَمْدُ لِلَّهِ');
    });

    test('an all-invisible line yields an empty string', () {
      expect(visibleTextOf(const [TextSpan(text: 'x', style: invisible)]), '');
    });
  });

  group('copyText', () {
    test('wraps the body in typographic quotes above the sura name', () {
      expect(copyText(body: 'ٱلْحَمْدُ لِلَّهِ', suraName: 'سورة الفاتحة'),
          '“ٱلْحَمْدُ لِلَّهِ”\n\nسورة الفاتحة');
    });
  });

  group('translateUri', () {
    test('verse mode deep-links to the aya', () {
      expect(translateUri(sura: 2, aya: 255).toString(), 'https://quran.com/2/255');
    });

    test('page mode deep-links to the page', () {
      expect(translateUri(page: 106).toString(), 'https://quran.com/page/106');
    });
  });

  group('withQuoteMarks', () {
    test('adds an opening and a closing mark around an inline render', () {
      final spans = withQuoteMarks(
          [const TextSpan(text: 'نص', style: base)], base);
      expect((spans.first as TextSpan).text, '”');
      expect((spans.last as TextSpan).text, '“');
    });

    test('the marks are dimmed relative to the text', () {
      final spans = withQuoteMarks(
          [const TextSpan(text: 'نص', style: base)], base);
      expect((spans.first as TextSpan).style!.color!.alpha, lessThan(255));
    });
  });

  group('header', () {
    testWidgets('shows the sura name and both actions', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MadinaHeader(
            suraName: 'سورة الفاتحة',
            theme: MadinaTheme.light(),
            onCopy: () {},
            onTranslate: () {},
          ),
        ),
      ));
      expect(find.text('سورة الفاتحة'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.translate_rounded), findsOneWidget);
    });
  });

  group('integration', () {
    testWidgets('a multiline render shows the header; headless hides it',
        (tester) async {
      Widget host(bool headless) => MaterialApp(
            home: MadinaScope(
              config: const MadinaConfig(font: 'Hafs', fontSize: 16),
              child: Scaffold(
                body: Center(
                  child: QuranMadinaView(sura: 1, aya: '1-3', headless: headless),
                ),
              ),
            ),
          );

      await tester.pumpWidget(host(false));
      await tester.pumpAndSettle();
      expect(find.byType(MadinaHeader), findsOneWidget);

      await tester.pumpWidget(host(true));
      await tester.pumpAndSettle();
      expect(find.byType(MadinaHeader), findsNothing);
    });

    testWidgets('the header copy button writes visible text plus the sura name',
        (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );

      await tester.pumpWidget(MaterialApp(
        home: MadinaScope(
          config: const MadinaConfig(font: 'Hafs', fontSize: 16),
          child: const Scaffold(
            body: Center(child: QuranMadinaView(sura: 1, aya: '1-3')),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pumpAndSettle();

      expect(copied, isNotNull);
      expect(copied, startsWith('“'));
      expect(copied, contains('سورة الفاتحة'));
      expect(copied, isNot(contains('نص')), reason: 'spacers are never copied');
    });

    testWidgets('an inline render gets quote marks; quotes:false opts out',
        (tester) async {
      Widget host(bool quotes) => MaterialApp(
            home: MadinaScope(
              config: const MadinaConfig(font: 'Hafs', fontSize: 16),
              child: Scaffold(
                body: Center(child: QuranMadinaView(sura: 1, aya: '1', quotes: quotes)),
              ),
            ),
          );

      await tester.pumpWidget(host(true));
      await tester.pumpAndSettle();
      expect(find.textContaining('”', findRichText: true), findsWidgets);

      await tester.pumpWidget(host(false));
      await tester.pumpAndSettle();
      expect(find.textContaining('”', findRichText: true), findsNothing);
    });

    testWidgets('tapping an aya opens a popup with copy and translate',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MadinaScope(
          config: const MadinaConfig(font: 'Hafs', fontSize: 16),
          child: const Scaffold(
            body: Center(child: QuranMadinaView(sura: 1, aya: '1-3')),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tapAt(tester.getCenter(find.byType(QuranMadinaView)));
      await tester.pumpAndSettle();
      expect(find.byType(AyaPopup), findsOneWidget);
    });

    testWidgets('a decoration slot is not tappable', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MadinaScope(
          config: const MadinaConfig(font: 'Hafs', fontSize: 16),
          child: const Scaffold(
            body: Center(child: QuranMadinaView(page: 1, headless: true)),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      // The title line is line 1; tapping it must not open a popup, because a
      // title has nothing to copy and no quran.com verse to link.
      final line = tester.getTopLeft(find.byType(QuranMadinaView));
      await tester.tapAt(Offset(line.dx + 10, line.dy + 5));
      await tester.pumpAndSettle();
      expect(find.byType(AyaPopup), findsNothing);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/chrome_test.dart
```

Expected: FAIL — `chrome.dart` does not exist.

- [ ] **Step 3: Write `chrome.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme.dart';

/// The copy body: only spans that are actually visible, whitespace collapsed.
///
/// Built from the span model rather than from rendered text, so the header
/// chrome, the transparent layout spacers and the words hidden by a `words=`
/// selection are all excluded by construction.
String visibleTextOf(List<InlineSpan> spans) {
  final buffer = StringBuffer();
  for (final span in spans) {
    if (span is! TextSpan) continue;
    if ((span.style?.color?.alpha ?? 255) == 0) continue;
    buffer.write(span.text ?? '');
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

String copyText({required String body, required String suraName}) =>
    '“$body”\n\n$suraName';

Uri translateUri({int? sura, int? aya, int? page}) => (sura != null && aya != null)
    ? Uri.parse('https://quran.com/$sura/$aya')
    : Uri.parse('https://quran.com/page/$page');

Future<void> copyAndNotify(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(content: Text('⎘ تم نسخ:\n\n$text')),
  );
}

Future<void> openTranslate(Uri uri) async {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Opening and closing quote marks for an inline (single-line) render — its
/// only visual cue that the text is a quoted excerpt, since it has no header.
List<InlineSpan> withQuoteMarks(List<InlineSpan> spans, TextStyle base) {
  final mark = base.copyWith(color: mixWithTransparent(base.color!, 0.5));
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
    final ambient = DefaultTextStyle.of(context).style.color ?? const Color(0xFF000000);
    return Container(
      height: 25,
      padding: const EdgeInsets.only(left: 10, right: 5),
      margin: const EdgeInsets.only(bottom: 5),
      color: mixWithTransparent(theme.header, 0.2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              suraName,
              style: TextStyle(color: mixWithTransparent(ambient, 0.6), fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            color: mixWithTransparent(ambient, 0.6),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onCopy,
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.translate_rounded, size: 20),
            color: mixWithTransparent(ambient, 0.6),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onTranslate,
          ),
        ],
      ),
    );
  }
}

/// The decorative frame behind a sura-title line.
///
/// The web uses `mask-image` + `currentColor` so the frame follows the ambient
/// text colour; `ColorFilter.mode(colour, srcIn)` is the direct equivalent. It
/// paints *behind* the child so the name text stays visible.
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

/// The currently hovered aya key (`"sura:aya"`), shared across a render so all
/// line fragments of one aya highlight together.
class AyaHoverScope extends InheritedWidget {
  const AyaHoverScope({super.key, required this.hovered, required super.child});

  final ValueNotifier<String?> hovered;

  static ValueNotifier<String?>? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AyaHoverScope>()
      ?.hovered;

  @override
  bool updateShouldNotify(AyaHoverScope old) => old.hovered != hovered;
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
              IconButton(
                icon: Icon(Icons.copy_rounded, size: 20, color: theme.background),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: onCopy,
              ),
              IconButton(
                icon: Icon(Icons.translate_rounded, size: 20, color: theme.background),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: onTranslate,
              ),
            ],
          ),
        ),
      );
}
```

Popup presentation uses a single module-level `OverlayEntry`, closed on outside tap or Escape,
positioned above the tapped aya's rect and flipped below when that would leave the screen:

```dart
OverlayEntry? _openPopup;

void closeAyaPopup() {
  _openPopup?.remove();
  _openPopup = null;
}

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
  const estHeight = 34.0;
  final top = anchor.top - estHeight - 6 > 0 ? anchor.top - estHeight - 6 : anchor.bottom + 6;
  final entry = OverlayEntry(
    builder: (ctx) => Stack(children: [
      Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: closeAyaPopup,
        ),
      ),
      Positioned(
        left: anchor.left.clamp(4.0, double.infinity),
        top: top,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: AyaPopup(
            theme: theme,
            onCopy: () {
              copyAndNotify(context, copyText(body: text, suraName: suraName));
              closeAyaPopup();
            },
            onTranslate: () {
              openTranslate(translateUri(sura: sura, aya: aya));
              closeAyaPopup();
            },
          ),
        ),
      ),
    ]),
  );
  _openPopup = entry;
  Overlay.of(context).insert(entry);
}
```

- [ ] **Step 4: Wire it into `widget.dart`**

- Multiline + `!headless` → `MadinaHeader` above the lines, `onCopy` joining
  `visibleTextOf` over every line's spans, `onTranslate` → `translateUri(sura:, aya:)`
  for a verse render or `translateUri(page:)` for a page render.
- Multiline → wrap the `Column` in a `SizedBox(width: lineWidth + 10)` and, when `!headless`,
  a gutter gradient on the right for an odd page and the left for an even one.
- Inline + `quotes` → `withQuoteMarks` around the single line's spans.
- A line containing a title part → wrap that `MadinaLine` in `SuraFrame(colour: ambient)`.
- Each countable part's spans get a shared `TapGestureRecognizer` that resolves the tapped
  aya's rect and calls `showAyaPopup`; parts with `ayaIndex < 1` get none (decoration slots stay
  non-tappable, deliberately: a title has nothing to copy and no verse to link).
- Each part's spans get `onEnter`/`onExit` updating the `AyaHoverScope` notifier keyed
  `"$sura:$aya"`; a `ValueListenableBuilder` repaints matching parts with a light-grey background.
- Re-render (`didUpdateWidget`) calls `closeAyaPopup()` — the overlay outlives the rebuild.

- [ ] **Step 5: Run the tests**

```bash
flutter test test/chrome_test.dart && dart format . && dart analyze
```

Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add quran_madina_kit
git commit -m "feat(quran_madina_kit): header, copy, translate, aya popup, hover and sura frame"
```

---

### Task 16: Remaining fonts, fidelity check, goldens, example and docs

Implements spec §8 and §9 (milestone 7–8) and §10.

**Files:**
- Modify: `quran_madina_kit/pubspec.yaml` (declare the remaining DB asset folders)
- Create: `quran_madina_kit/test/fidelity_test.dart`
- Create: `quran_madina_kit/test/golden_test.dart`
- Create: `quran_madina_kit/example/lib/main.dart`, `quran_madina_kit/example/pubspec.yaml`
- Create: `quran_madina_kit/README.md`
- Modify: `README.md` (monorepo package table)
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: everything.
- Produces: no new API — verification and documentation.

- [ ] **Step 1: Write the fidelity check**

This is the decisive test: it measures whether Flutter's HarfBuzz shaping matches the Chrome
measurements baked into the DB.

`quran_madina_kit/test/fidelity_test.dart`:

```dart
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every justified line fills the frame within 2% at Hafs 16px', () async {
    // Load the real font so shaping uses the same glyphs the DB was measured on.
    final fontData = await rootBundle.load('packages/quran_madina_kit/assets/fonts/Hafs.ttf');
    final loader = FontLoader('Hafs')..addFont(Future.value(fontData));
    await loader.load();

    final manifest = MadinaManifest.fromManifestJson(json.decode(await rootBundle
        .loadString('packages/quran_madina_kit/assets/db/Madina05-Hafs-16px/manifest.json'))
        as Map<String, dynamic>);

    // Group every part by (page, line) so a line's full text is measured, not
    // one aya's fragment of it.
    final lines = <String, ({StringBuffer text, double stretch})>{};
    for (var j = 1; j <= 30; j++) {
      final shard = JuzShard.fromJson(json.decode(await rootBundle.loadString(
        'packages/quran_madina_kit/assets/db/Madina05-Hafs-16px/'
        'juz-${j.toString().padLeft(2, '0')}.json',
      )) as Map<String, dynamic>);
      for (final e in shard.entries) {
        for (final p in e.parts) {
          if (p.isCentred) continue; // centred lines are not justified
          final key = '${e.page}:${p.line}';
          lines.putIfAbsent(key, () => (text: StringBuffer(), stretch: p.stretch));
          lines[key]!.text.write(p.text);
        }
      }
    }

    final style = TextStyle(fontFamily: manifest.fontFamily, fontSize: manifest.fontSize);
    final failures = <String>[];
    var checked = 0;

    lines.forEach((key, line) {
      final painter = TextPainter(
        text: TextSpan(text: line.text.toString(), style: style),
        textDirection: ui.TextDirection.rtl,
        maxLines: 1,
      )..layout();
      final filled = painter.width * line.stretch;
      painter.dispose();
      checked++;
      final drift = (filled - manifest.lineWidth).abs() / manifest.lineWidth;
      if (drift > 0.02) {
        failures.add('$key: ${filled.toStringAsFixed(1)}px vs '
            '${manifest.lineWidth}px (${(drift * 100).toStringAsFixed(1)}% off)');
      }
    });

    expect(checked, greaterThan(5000), reason: 'the whole mushaf must be measured');
    expect(
      failures.length / checked,
      lessThan(0.02),
      reason: 'Flutter shaping drifts from the Chrome measurements on '
          '${failures.length}/$checked lines. Worst:\n'
          '${failures.take(20).join('\n')}',
    );
  }, timeout: const Timeout(Duration(minutes: 5)));
}
```

- [ ] **Step 2: Run the fidelity check and record the result**

```bash
flutter test test/fidelity_test.dart
```

**This test's outcome is a finding, not a pass/fail to force.**

- Passes → `MadinaStretchMode.stored` is verified faithful; keep it as the default.
- Fails → do **not** loosen the threshold. Record the actual drift in `README.md` under a
  "Fidelity" heading, change `MadinaConfig.stretchMode`'s default to
  `MadinaStretchMode.measured`, and re-run the golden tests. Report the numbers to the user
  either way.

- [ ] **Step 3: Add the remaining fonts and DBs**

```bash
cd quran_madina_kit
SRC=/Users/loqman/Documents/projects/Flutter/quran-madina-html
for stem in Madina05-Hafs-24px Madina05-Uthman-16px Madina05-Uthman-24px \
            Madina05-Amiri_Quran-16px Madina05-Amiri_Quran-24px \
            Madina05-Amiri_Quran_Colored-16px Madina05-Amiri_Quran_Colored-24px \
            Madina05-me_quran-16px Madina05-me_quran-24px; do
  mkdir -p "assets/db/$stem"
  cp "$SRC/assets/db/$stem/"*.json "assets/db/$stem/"
done
du -sh assets/db
```

Add every folder to `pubspec.yaml`'s `assets:` list.

> **Weigh this before committing:** all ten DBs total roughly 19 MB. If that is too heavy for the
> default kit, ship only `Madina05-Hafs-16px` and `Madina05-Hafs-24px` bundled, document how a host
> app declares the others in its own `pubspec.yaml`, and point `MadinaAssetSource`'s `package`
> argument at the host. Raise the trade-off with the user rather than deciding silently.

- [ ] **Step 4: Verify Amiri Quran Colored actually renders in colour**

Write a throwaway golden of `QuranMadinaView(page: 106)` with
`MadinaConfig(font: 'Amiri Quran Colored')` and inspect it. The font is COLRv0 (verified), which
Skia supports, but confirm on a real target before advertising it. Record the result in the README
— including "not supported on platform X" if that is the truth.

- [ ] **Step 5: Write the goldens**

`quran_madina_kit/test/golden_test.dart` renders `QuranMadinaView(page: 1, headless: true)` and
`QuranMadinaView(page: 106, headless: true)` at Hafs 16px inside a fixed-size `RepaintBoundary`,
with the font loaded via `FontLoader` (test fonts are Ahem by default, so this is required), and
compares against `test/goldens/page-001-hafs-16.png` and `page-106-hafs-16.png`.

```bash
flutter test --update-goldens test/golden_test.dart
flutter test test/golden_test.dart
```

Open both PNGs and compare them by eye against
`/Users/loqman/Documents/projects/Flutter/quran-madina-html/demo/img/p106-hafs.png`. Same line
breaks, same justification, same page shape. **A golden that is accepted without being looked at is
worthless** — it locks in whatever bug exists.

- [ ] **Step 6: Write the example app**

`quran_madina_kit/example/lib/main.dart`: a scaffold with a segmented control over the four modes —
page (`page: 106`), verse (`sura: 2, aya: '8-10'`), words (`sura: 1, aya: '7', words: '1-14'`),
highlight (`sura: 1, aya: '1', highlight: '2-3'`) — plus a font dropdown and a font-size slider
(6–100) so the interpolation path is exercised interactively.

```bash
cd example && flutter pub get && flutter run -d macos
```

- [ ] **Step 7: Write the docs**

`quran_madina_kit/README.md` covering: what it is and its upstream origin, install as a git
dependency pinned to a ref, `MadinaScope` setup, all four render modes with code, the full
attribute table, `MadinaStretchMode`, the asset-vs-network trade-off (**including that
`MadinaNetworkSource` needs a CDN serving `.ttf`, since Flutter cannot parse `.woff2`**), theming,
the fidelity result from Step 2, and the Amiri Colored result from Step 4.

Add a `quran_madina_kit` row to the monorepo `README.md` package table and a `CHANGELOG.md` entry.

- [ ] **Step 8: Full suite and commit**

```bash
cd quran_madina_kit && flutter test && dart format . && dart analyze
cd .. && git add . && git commit -m "feat(quran_madina_kit): all fonts, fidelity check, goldens, example and docs"
```

---

## Self-review notes

**Spec coverage.** §2 layout → Tasks 1–15 (`interpolation.dart` and `render_plan.dart` were split
out of `repository.dart`/`widget.dart` during planning; update the spec's file list if that split
survives review). §3 data contract → Task 2. §4.1–4.4 → Tasks 3–4. §4.5–4.6 → Tasks 8–9. §4.7–4.9 →
Tasks 6, 12. §4.10 → Task 11. §4.11 → Task 7. §5 → Tasks 11, 15. §6 → Tasks 10, 12, 15. §7 → spread
across Tasks 6, 12, 13, 14 with a dedicated test in each. §8 → Task 16. §10 → Task 16 Step 4.

**Known gaps to resolve during execution, not to paper over:**

1. **Line height and vertical rhythm.** The web relies on the browser's default line box plus a
   `2×` override for me_quran. Flutter's default differs. If page renders come out vertically
   compressed or stretched against the reference screenshots, add an explicit `height` to the text
   style derived from the reference — and say so in the README.
2. **Per-aya rect for the popup.** `RenderParagraph.getBoxesForSelection` needs the aya's character
   offsets within the line's span tree. Track them while building spans in Task 15 rather than
   re-deriving them.
3. **Asset weight.** Task 16 Step 3 flags the 19 MB question for the user.

