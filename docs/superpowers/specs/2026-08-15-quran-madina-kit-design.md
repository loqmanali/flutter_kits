# quran_madina_kit — Design

A Flutter port of [`quran-madina-html`](https://github.com/tarekeldeeb/quran-madina-html): renders
Quran pages visually identical to the printed Madina Mushaf **without images**, driven by the same
pre-computed JSON databases.

Status: approved 2026-08-15. Source of truth read: `quran-madina-html@1.0.1`
(`src/quran-madina-html.js`, `src/quran-madina-html.css`, `assets/db/*`).

---

## 1. Scope

Full behavioural parity with the web runtime. **The Python DB generator is out of scope** — the
JSON databases are consumed as-is, byte-for-byte. This kit is a port of the *runtime half* only.

In scope:

- Three render modes: `page`, `sura`+`aya`, `sura`+`aya`+`words`
- `highlight` / `error` word marking in every render mode
- `headless`, `notitle`, `quotes`, `inline` modifiers
- Copy-to-clipboard, translate deep-link, per-aya tap popup, aya hover highlight
- All five fonts (Hafs, Uthman, Amiri Quran, Amiri Quran Colored, me_quran)
- Arbitrary font sizes 6–100 via anchor interpolation
- Sharded lazy DB loading (manifest + 30 juz' shards) with monolith fallback

Out of scope: DB generation, new fonts, new mushaf editions.

---

## 2. Package layout

New kit in the `flutter_kits` monorepo, following existing conventions
(`publish_to: "none"`, git dependency, `dart analyze` clean, `dart format` standard).

```
quran_madina_kit/
  pubspec.yaml
  analysis_options.yaml
  lib/
    quran_madina_kit.dart      public exports only
    src/
      models.dart              Manifest, SuraSkeleton, Aya, RenderPart, JuzShard
      source.dart              MadinaSource + MadinaAssetSource + MadinaNetworkSource
      repository.dart          MadinaDb: boot, ensureJuz, merge, page/juz lookup
      ranges.dart              range parsing, word counting, basmala slot rules
      layout.dart              line grouping, lineContext, collectWordParts
      theme.dart               MadinaTheme + MadinaScope + MadinaConfig
      widget.dart              QuranMadinaView
      line.dart                MadinaLine — one visual line
      chrome.dart              header, aya popup, copy, translate, sura frame
  tool/
    convert_fonts.py           woff2 -> ttf (fontTools + brotli)
  assets/
    db/Madina05-Hafs-16px/     manifest.json + juz-01..30.json (default, bundled)
    fonts/Hafs.ttf
    img/sura_border_sym4.svg
  test/
  example/
```

**Boundary rule:** `models`, `source`, `repository`, `ranges`, `layout` import **no Flutter widget
code** (`dart:ui` only where unavoidable). They are testable with plain `dart test`. `theme`,
`widget`, `line`, `chrome` are the rendering layer.

### Dependencies

| Package | Why |
|---|---|
| `flutter_svg` | sura-title decorative frame (already used by `widget_kit`) |
| `http` | `MadinaNetworkSource` |
| `url_launcher` | translate deep-link to quran.com |

Deliberately **not** `path_provider`: `MadinaNetworkSource` takes an optional `Directory cacheDir`
from the host app; without it, caching is in-memory only.

---

## 3. Data contract (unchanged from the web DB)

### `manifest.json`

```jsonc
{
  "title": "...", "published": 1405,
  "font_family": "Hafs", "font_url": "assets/fonts/Hafs.woff2",
  "font_size": 16, "line_width": 270,
  "content_hash": "c4209f94d682",
  "suras": [["سورة الفاتحة", 9], ...],          // [name, ayaSlotCount] x114
  "juz":   [[sura0, ayaIdx, startPage], ...],   // x30
  "pages": [[suraFrom, ayaFrom, suraTo, ayaTo], ...]  // x604, 0-based indices
}
```

### `juz-NN.json`

```jsonc
{ "j": 0, "d": [ [sura0, ayaIdx, page, [ {"l":1,"t":"...","s":-1}, ... ] ], ... ] }
```

`l` = line 1–15, `t` = text, `s` = scaleX; **`s == -1` means centre this line, do not stretch**.
There is no pixel offset field — mid-line starts are positioned by re-flowing preceding text
invisibly.

### Decoration slot invariant

Every sura carries **2 decoration slots** before its real ayas:

| Slot | Normal sura | Al-Fatiha (sura0 = 0) | At-Tawba (sura0 = 8) |
|---|---|---|---|
| 0 | sura title | *blank* | sura title |
| 1 | basmala (4 real counted words) | sura title | *blank* |

Real aya `A` lives at internal index `A + 1`.

**Dart mapping:** `List<Aya?>` of length `ayaSlotCount`, sparse until the owning juz' shard is
merged. `null` == not loaded, and every call site must treat it as "not on this page / stop
walking" — mirroring the JS `undefined` guards.

---

## 4. Core logic — exact rules to port

These are literal ports. Where the JS has a subtlety, it is stated here so the implementation does
not have to re-derive it.

### 4.1 Word tokens

```dart
// Escapes, not literals — same reason the JS uses them: U+0621-U+064A (basic Arabic
// letters) and U+0671-U+06D3 (alef-wasla etc.).
final _arabicLetter = RegExp(r'[ء-يٱ-ۓ]');
bool isWordToken(String t) => _arabicLetter.hasMatch(t);
```

A whitespace-separated token counts as a selectable word **only if it contains an Arabic letter**.
Excluded by construction: aya-number ornaments (`﴿٢﴾`, `۝٢`), waqf marks (`ۖ ۗ ۘ ۙ ۚ ۛ ۜ`), and the
`۞` / `۩` ornaments. A non-word token inherits the show/hide/mark state of the word it *follows*
(the aya-end marker is appended to the aya's last word at build time).

### 4.2 Slot predicates

```dart
bool isBasmalaSlot(int sura0, int ayaIdx) => ayaIdx == 1 && sura0 != 0;
bool isCountableAya(int sura0, int ayaIdx) => ayaIdx >= (sura0 == 0 ? 2 : 1);
```

Titles never count as words. The basmala counts as **4** words (matching flat Tanzil indexing).

### 4.3 Range parsing

| Input | Result |
|---|---|
| `sura="2"` | `sura0 = 1` (0-based, both ends) |
| `aya="255"` | `[256, 256]` (+1 for decoration slots) |
| `aya="1-3"` | `[2, 4]` |
| `words="5"` | `[5, 5]` |
| `words="3-10"` / `"3:10"` | `[3, 10]` |
| malformed / `start < 1` / `start > end` | `null` |

- Malformed `words` → **fall back to the normal verse render**, log `Bad words parameter`.
- Malformed or out-of-bounds `highlight`/`error` → **drop that mark only**, log, keep rendering.
- `words` span is capped at **500 words** (`range[1] = range[0] + 499`).
- `words` with a `page` render → ignored + warning.
- `words` with an aya *range* → range end ignored + warning (only the start aya seeds the walk).

### 4.4 Basmala render mode

Given the running counter, the basmala's word count, the display range and the mark ranges:

```
fullyIn(r)     = r == null || (counter+1 >= r.start && counter+words <= r.end)
partiallyIn(r) = r != null && !fullyIn(r) && counter+words >= r.start && counter+1 <= r.end

if (!fullyIn(displayRange))                        -> individual tokens
if (partiallyIn(highlight) || partiallyIn(error))  -> individual tokens
else -> single ﷽ (U+FDFD) ligature, marked if a mark range fully covers it
```

Either way the counter advances by all 4 words. A full `page` render always shows the ligature
(blank slots stay blank).

### 4.5 Line-start detection & context spacers

```
partOnLine(aya, l)          -> the aya's part whose .l == l, else null
isLineStartPart(s, a, l)    -> true if ayas[a-1] is missing, on another page,
                               or has no part on line l   (a <= 0 -> true)
lineContext(s, page, l, a, dir)
    dir < 0: walk backwards from a, prepending parts on (page,l),
             stopping after the part that is itself a line start
    dir > 0: walk forwards, appending parts on (page,l)
    both: stop on a null aya or a page change
```

Context parts render as **transparent spans** — they hold layout, show nothing, and are excluded
from copy.

### 4.6 `collectWordParts` (the `words` walk)

Walks ayas in reading order from `(suraStart, ayaStart)`, grouping parts into visual lines keyed
by `"$page:$line"`, until the end word index is covered.

1. **Anchor rewind:** `ayaStart == 2 && suraStart > 0` → begin at slot 1 (that sura's own basmala).
   Al-Fatiha is exempt (its slot 1 is a *title*).
2. **Wrap-around:** past An-Nas the walk wraps to Al-Fatiha (`(suraStart + i) % 114`). The 500-word
   cap and the single-cycle bound keep it finite.
3. Skip parts with `t == ""` (blank decoration placeholders) — they must not become empty lines.
4. Stop collecting on a `null` aya (unloaded shard boundary).
5. **Trim:** annotate each group with the running countable-word index it *ends at* (`lastWord`),
   then:

   ```
   start = 0;  while (start < groups.length-1 && groups[start].lastWord < range.start) start++;
   end = start; while (end   < groups.length-1 && groups[end].lastWord   < range.end)   end++;
   keep groups[start .. end]
   counterStart = start > 0 ? groups[start-1].lastWord : 0
   ```

   Leading lines entirely before the selection and trailing lines entirely after it are dropped
   (trailing ones exist because collection grabs *whole* ayas, which may run onto further lines).
   `counterStart` carries the skipped leading words so word visibility downstream still lines up.
   The block therefore always begins and ends on a line that shows a selected word.

### 4.7 Juz' resolution

```
suraAyaToJuz(sura0, ayaIdx):
    pa = max(ayaIdx, 2)                     // decoration slots follow aya 1
    last k where juz[k].sura < sura0 || (juz[k].sura == sura0 && juz[k].aya <= pa)

neededJuz:
    verse + words -> [j, (j+1) % 30]        // words spill forward, wrapping at the end
    verse         -> [j(from) .. j(to)]
    page          -> from pages[page-1] bounds
```

### 4.8 Page-mode bounds

Sharded: `pages[page-1] -> [suraFrom, ayaFrom, suraTo, ayaTo]`.
Monolith fallback: the JS scan loop is ported verbatim.

### 4.9 Main render loop (page / verse mode)

```
lineFrom = suras[suraFrom].ayas[ayaFrom].r.first.l
lineTo   = suras[suraTo].ayas[ayaTo].r.last.l
multiline = page-mode ? true : false
if (lineTo != lineFrom) multiline = true
multiline = applyInlineOverride(inline, multiline)   // inline: "no" forces true
for l in lineFrom..lineTo:
    lookAhead = (suraFrom == suraTo) ? ayaTo : suras[suraCurrent].ayas.length-1
    for a in ayaCurrent .. min(ayaCurrent+5, lookAhead):
        skip if aya is null or aya.p != page
        take the part with .l == l
        ... emit ...
        ayaCurrent = a
        // sura jump: last aya of this sura, next sura's slot 0 on this page at line l+1
        if a >= lookAhead && next.suras[0] is on this page at line l+1:
            suraCurrent++; ayaCurrent = 0
```

The `+5` look-ahead window and the sura-jump peek can probe unloaded ayas — treat `null` as "not on
this page".

### 4.10 Stretch

```dart
enum MadinaStretchMode { stored, measured }   // default: stored
```

- **`stored`** — `scaleX = s * stretchScale` where `stretchScale` is 1 for anchor sizes.
- **`measured`** — `s == -1` still means centre; otherwise
  `scaleX = lineWidth / TextPainter(spans).width`, cached per line.

`s == -1` → `TextAlign.center`, no transform, in both modes.

### 4.11 Font-size interpolation (`stored` mode only)

Anchors are 16 and 24 px; the accepted range is 6–100 (out of range → warn, use 16).

```
S       = requested size
nearest = (S - 16 <= 24 - S) ? 16 : 24
lw(S)   = round(lw16 + (lw24 - lw16) * (S - 16) / (24 - 16))
stretchScale = lw(S) * nearest / (lw(nearest) * S)
```

Render data (text incl. build-inserted kashidas, stretch factors) comes from `nearest`'s DB.
Both anchor headers are fetched (manifest preferred, monolith fallback); if either is missing,
fall back to size 16. `measured` mode needs none of this — it derives scaleX from real widths.

---

## 5. CSS → Flutter mapping

| Web | Flutter |
|---|---|
| `transform: scaleX(s)`, `transform-origin: top right` | `Transform(alignment: Alignment.topRight, transform: Matrix4.diagonal3Values(s, 1, 1))` |
| `white-space: nowrap; direction: rtl; text-align: right` | `Text.rich(softWrap: false, maxLines: 1, overflow: visible, textDirection: rtl, textAlign: right)` |
| `s == -1` → `text-align: center` | `textAlign: TextAlign.center` |
| `visibility: hidden` (unselected word / spacer) | `TextStyle(color: Colors.transparent)` — advance width preserved |
| `.word-highlight` / `.word-error` background | `TextStyle(backgroundColor:)` — paints the advance box exactly, **no padding/border** |
| `color-mix(in srgb, X 20%, transparent)` | `X.withValues(alpha: 0.2)` |
| `line-height: 2 × size` (me_quran only) | `TextStyle(height: 2.0)` |
| `FontFace(family, url(font_url))` | `FontLoader(family)..addFont(sourceBytes)` then `.load()` |
| `hoverByType` — all fragments of an aya | `TextSpan.onEnter/onExit` + a shared `ValueNotifier<String?>` for the hovered aya key |
| `wireAyaClick` / `showAyaPopup` | `TextSpan.recognizer` (`TapGestureRecognizer`) + `OverlayEntry` |
| `mask-image` + `currentColor` frame | `flutter_svg` + `ColorFilter.mode(currentColor, srcIn)` painted **behind** the title line |
| `box-shadow: inset ±8px` gutter | thin `LinearGradient` strip on the side chosen by page parity (`page % 2 == 1` → right) |
| `width: line_width + 10` | `SizedBox(width: lineWidth + 10)` |
| `navigator.clipboard` + `alert(...)` | `Clipboard.setData` + `SnackBar` |
| `window.open(quran.com/...)` | `url_launcher.launchUrl` |
| inline quote marks (`::before` / `::after`) | leading/trailing `TextSpan`s with `”` / `“` at 50 % opacity |
| `sessionStorage` JSON cache + `content_hash` purge | in-memory `Map` + optional disk cache; hash mismatch clears both |
| in-flight request coalescing | `Map<String, Future<T>>` keyed by path |

### Central rendering decision

**One `Text.rich` per visual line; one `TextSpan` per token.** Not one widget per word.

Justification: tokenisation splits on whitespace, and Arabic never joins across a space, so no
shaping run is broken by the split — the same reason the web version can use one `<span>` per word.
A single paragraph also gives correct RTL bidi ordering for free and makes the `measured` mode a
single `TextPainter.layout()` call.

Per-aya rects for popup positioning come from
`RenderParagraph.getBoxesForSelection(TextSelection(...))` over the aya's character range within
the line, tracked while building the spans.

---

## 6. Public API

```dart
MadinaScope(                       // once, near the app root
  config: MadinaConfig(
    name: 'Madina05',              // data-name
    font: 'Hafs',                  // data-font
    fontSize: 16,                  // data-font-size (6..100)
    source: MadinaAssetSource(),   // or MadinaNetworkSource(...)
    stretchMode: MadinaStretchMode.stored,
  ),
  theme: MadinaTheme(...),         // background/header/highlight/error colours
  child: ...,
)

QuranMadinaView(page: 106, headless: true)
QuranMadinaView(sura: 2, aya: '8-10')
QuranMadinaView(sura: 1, aya: '7', words: '1-14', notitle: true)
QuranMadinaView(sura: 1, aya: '1', highlight: '2-3', error: '5')
QuranMadinaView(sura: 1, aya: '3', quotes: false, inline: MadinaInline.no)
```

`page` and `sura`/`aya` are mutually exclusive; `sura`+`aya` wins and `page` is ignored with a
warning (matching the JS `Ignoring page parameter!` path).

`inline`: `auto` (default) | `no` (force multiline). `yes` is accepted and logs
`inline="yes" is not implemented yet` then behaves as `auto` — same as the web.

### Theme

`MadinaTheme` carries the six CSS custom properties (`background`, `header`, `highlight`, `error`,
`highlightText`, `errorText`). The dark-pair swap is automatic: the web reads the *computed ambient
text colour* and picks a pair by WCAG relative luminance > 0.5; Flutter reads
`DefaultTextStyle.of(context).style.color` and applies the same rule.

### Copy format

```
“<visible text, whitespace collapsed>”

<sura name>
```

Header copy acts on the whole frame; the per-aya popup copy joins that aya's line fragments only.
Both exclude the header, transparent spacers, and unselected words — built from the span model, not
from rendered text.

---

## 7. Error handling

| Condition | Behaviour |
|---|---|
| Malformed `words` | log, fall back to normal verse render |
| Malformed / out-of-bounds `highlight`/`error` | log, drop that mark, keep rendering |
| Font size outside 6–100 | log, use 16 |
| Missing manifest | fall back to the monolithic `<stem>.json` |
| Missing monolith at a non-default size | fall back to size 16 |
| Missing anchor DB during interpolation | log, fall back to size 16 |
| Juz' shard fetch failure | log, mark loaded, render what is available (the JS behaviour) |
| Neither `page` nor `sura`+`aya` | log error, render nothing |

Nothing throws out of a render. Loading state renders a placeholder.

---

## 8. Testing

| Layer | What |
|---|---|
| **Pure Dart unit** | every rule in §4 — token counting, slot predicates, range parsing, basmala mode, `collectWordParts` trimming/wrap/anchor-rewind, juz' resolution, interpolation math. Table-driven, no Flutter. |
| **Fidelity check** | for all 604 pages of Hafs-16px: every justified line satisfies `stretch × measuredWidth ≈ lineWidth` within ±2 %. Reports the worst offenders. |
| **Golden** | page 1 and page 106, Hafs 16px, headless. |
| **Widget** | mark classes land on the right spans; hidden words stay transparent; copy output excludes header/spacers/hidden words. |

The **fidelity check is the decisive test**: it measures whether Flutter's HarfBuzz shaping matches
the Chrome measurements baked into the DB. If it fails, `measured` becomes the recommended default
and the finding is documented rather than papered over.

---

## 9. Milestones

1. `tool/convert_fonts.py` + committed `.ttf` files
2. `models` + `source` + `repository` + tests
3. `ranges` + `layout` + tests — the largest pure-logic surface
4. `line` + `widget`: `page` and `sura`/`aya` rendering
5. `words` selection + `highlight`/`error`
6. `chrome`: header, popup, copy, translate, sura frame, quotes, headless, notitle, inline
7. Arbitrary font sizes + remaining fonts
8. `example/` app, fidelity check, goldens, README

## 10. Known risk

**Amiri Quran Colored** is a COLR/CPAL colour font. Flutter's COLRv0 support is not uniform across
platforms and versions. It is scheduled last (milestone 7) and will be verified on a real device
before being advertised as supported; if it does not render in colour, that is documented as a
platform limitation rather than worked around.
