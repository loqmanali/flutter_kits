# quran_madina_kit

Renders Quran pages **visually identical to the printed Madina Mushaf — without images**. Every
glyph is real, selectable, copyable text, laid out from pre-computed JSON databases.

A Flutter port of [`quran-madina-html`](https://github.com/tarekeldeeb/quran-madina-html). It
consumes that project's JSON databases **byte-for-byte**; only the runtime half is reimplemented.

## Install

```yaml
dependencies:
  quran_madina_kit:
    git:
      url: https://github.com/loqmanali/flutter_kits.git
      path: quran_madina_kit
      ref: v0.1.0
```

## Use

Put a `MadinaScope` near the app root, then drop views anywhere below it.

```dart
MadinaScope(
  config: const MadinaConfig(font: 'Hafs', fontSize: 16),
  child: MaterialApp(home: ...),
)
```

```dart
QuranMadinaView(page: 106, headless: true)                     // a full page
QuranMadinaView(sura: 2, aya: '8-10')                          // a verse range
QuranMadinaView(sura: 1, aya: '7', words: '1-14')              // a word range
QuranMadinaView(sura: 1, aya: '1', highlight: '2-3', error: '5')
```

### Parameters

| Parameter | Type | What it does |
|---|---|---|
| `page` | `int?` | 1-based page, 1..604. Renders the whole page. |
| `sura` | `int?` | 1-based sura, 1..114. Needs `aya`. |
| `aya` | `String?` | 1-based, `"n"` or `"n-m"`. |
| `words` | `String?` | 1-based inclusive, `"n"` / `"n-m"` / `"n:m"`. Counted from `sura`/`aya`, may run past it across page **and** sura boundaries, wrapping An-Nas → Al-Fatiha. Ignored with `page`. Capped at 500 words. |
| `highlight` | `String?` | Same range format; marks words in soft yellow. Works in **every** mode. |
| `error` | `String?` | Same, soft red. Wins over `highlight` on overlap. |
| `headless` | `bool` | Drop the header and gutter chrome, keep only the text. |
| `quotes` | `bool` | Quote marks around an inline (single-line) render. Default true. |
| `inline` | `MadinaInline` | `auto` (default) / `no` (force the multiline frame). `yes` is not implemented and warns. |
| `notitle` | `bool` | Blank a crossed-into sura's name while keeping its decorated line. `words` path only. |
| `loading` | `Widget?` | Shown while the DB and font load. |

`page` and `sura`/`aya` are mutually exclusive: **`sura`/`aya` wins** and `page` is ignored with a
warning.

Bad input never throws. A malformed `words` falls back to the normal verse render; a malformed or
out-of-bounds `highlight`/`error` is dropped and the render continues. Both log to `debugPrint`.

### Word indexing

Every sura carries two decoration slots before its real ayas: the **title** (never counted) and the
**basmala** (counted as **4 real words**, matching the flat Tanzil indexing most consumers use).
Al-Fatiha is inverted — its basmala *is* real aya 1 — and At-Tawba has none.

Display follows the printed Mushaf: when all 4 basmala words are shown, they collapse to the `﷽`
ligature; a partial selection or a mark cutting into only some of them renders the 4 words instead.
Either way the basmala occupies 4 word indices.

### Themes

```dart
MadinaScope(
  theme: const MadinaTheme(
    background: Color(0xFFF5F5DC),
    header: Color(0xFF000000),
    highlight: Color(0xFFFFF3B0),
    error: Color(0xFFF5C6CB),
    highlightText: Color(0xFF1A1A1A),
    errorText: Color(0xFF1A1A1A),
  ),
  ...
)
```

Mark colours auto-swap to a dark-background pair when the host's ambient text colour is light
(WCAG relative luminance > 0.5), so `highlight`/`error` stay legible however the host implements
dark mode.

## Fidelity

The stretch factors in the DB were measured in headless Chrome. `test/fidelity_test.dart` re-measures
every justified line of the whole Mushaf with Flutter's own text engine:

```
8788 justified lines, Hafs 16px, Flutter 3.44.8 / macOS
median drift 0.63%   p95 0.77%   max 2.67%   lines over 2%: 1
```

0.63% of a 270px line is under 2 physical pixels. **`MadinaStretchMode.stored` is verified faithful
and is the default.** `MadinaStretchMode.measured` is available as an alternative: it ignores the
stored factor and derives `scaleX = lineWidth / measuredWidth` per line, which self-corrects and
needs no font-size interpolation. The fidelity test guards these bounds — if it ever fails, that is
a signal to switch the default, not to loosen the numbers.

## Data sources

```dart
MadinaConfig(source: MadinaAssetSource())            // default: bundled, offline
MadinaConfig(source: MadinaNetworkSource(
  base: 'https://your-cdn/',
  cacheDir: someDirectory,                           // optional disk cache
))
```

The DB loads sharded: a small `manifest.json` first, then each juz' shard on demand as pages render.
A monolithic `<stem>.json` is the fallback. Concurrent requests for the same shard are coalesced, and
a changed `content_hash` purges stale cached shards.

> **`MadinaNetworkSource` and fonts:** the published `quran-madina-html` CDN serves `.woff2`, which
> Flutter cannot parse. Point `base` at a mirror serving `.ttf`, or keep the fonts bundled.

### Bundled assets

The kit ships **Hafs at 16px** (≈1.9 MB of JSON) plus all five converted `.ttf` fonts, so it works
offline out of the box. The other nine font/size databases (≈19 MB total) are **not** bundled — copy
the folders you need from the upstream repo into your own app's assets and point
`MadinaAssetSource(package: ...)` at it, or serve them.

`tool/convert_fonts.py` regenerates the `.ttf` files from the upstream `.woff2` (fontTools + brotli).
woff2 is only a compressed sfnt container, so the conversion is lossless and the glyph advances the
DB was measured against are preserved exactly.

## Known limitations

- **Basmala ligature.** Hafs, Uthman and me_quran do not contain U+FDFD. A browser silently falls
  back across every installed system font; Flutter only consults families you name, so the kit loads
  Amiri Quran as a dedicated fallback for that one glyph. Its shape differs slightly from whatever
  font a given browser picks.
- **Amiri Quran Colored** is a COLRv0 colour font. Skia supports COLRv0, but this has not been
  verified on every target platform yet.
- **Arbitrary font sizes** (anything other than 16/24) render the nearest anchor's data with the
  interpolated `line_width` and a global stretch correction — same approach as the web.
- `inline: MadinaInline.yes` is accepted but not implemented, matching upstream.

## Architecture

Pure Dart, no Flutter widget imports: `models`, `source`, `repository`, `interpolation`, `ranges`,
`layout`, `render_plan`. Rendering: `theme`, `line`, `widget`, `chrome`.

Each visual line is **one `Text.rich` with one `TextSpan` per whitespace token**. Words outside a
`words` selection are painted transparent rather than removed, so the pre-computed Madina
justification survives untouched — the same trick the web version plays with `visibility:hidden`.
