## confirm_kit 1.0.0

New kit, generalized from `lekbox`'s `ActionConfirmationDialog` (a hard-coded
SVG + two buttons + a `isDestructive` bool) into something reusable.

- `ConfirmDialog<T>`: intent-driven accent/icon/label, 1..N `ConfirmAction<T>`s
  in four button styles, optional `content` widget, centered or start-aligned.
- Async actions render an in-button spinner, disable the siblings, and block
  barrier/drag/back until the work settles — the original dialog could be
  dismissed mid-request.
- Three surfaces from one widget: dialog, bottom sheet (keyboard-aware), or
  bare content embedded in a page. `.show()` returns the typed result,
  `.ask()` the yes/no bool.
- `ConfirmKitTheme` (`ThemeExtension`) + `ConfirmStrings` replace the hard-coded
  colors, radii and English labels; unset colors resolve from `ColorScheme`, so
  dark mode works without configuration.
- Long content scrolls instead of overflowing on short screens.

## quran_madina_kit 0.1.0

- New kit: renders Quran pages visually identical to the printed Madina Mushaf without images,
  driven byte-for-byte by the `quran-madina-html` JSON databases.
- Full behavioural parity with the web runtime: `page` / `sura`+`aya` / `words` render modes,
  `highlight`/`error` word marking in every mode, `headless`, `quotes`, `inline`, `notitle`,
  copy-to-clipboard, quran.com translate links, the per-aya popup, the decorative sura frame, and
  arbitrary font sizes 6–100 via anchor interpolation.
- Bundles all five fonts at both anchor sizes (Hafs, Uthman, Amiri Quran, Amiri Quran Colored,
  me_quran) — ~19 MB of JSON, fully offline. Amiri Quran Colored's COLRv0 tajweed colouring is
  verified to render, not assumed.
- Links never leave the app: the translate action opens quran.com on a full-screen page inside the
  app (`webview_flutter`), and `MadinaConfig.onTranslate` hands it to the host app's own browser or
  router instead.
- Sharded lazy DB loading (manifest + 30 juz' shards) with request coalescing, content-hash cache
  invalidation and a monolithic fallback. Asset and network sources are swappable.
- Justification verified per font across all ~8800 justified lines of the Mushaf. `stored` mode
  replays the DB's Chrome-measured factors and keeps half of all lines within 1%, but its tail is
  font-dependent (Hafs p95 0.77%, Uthman p95 3.09% / max 8.62%). `MadinaStretchMode.measured` is
  therefore the default: it fills every justified line exactly (0.0000% max drift, all five fonts),
  memoised so only the first layout of a line costs anything.

# Changelog

All notable changes to the `flutter_kits` monorepo are documented in this file.
Individual packages may keep their own `CHANGELOG.md` for package-specific
release notes.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## showcase_kit 1.0.0

New kit, ported from a coach-marks widget that had been sitting unused in two
app repos (`cardfiy`, `hayakum_app_v2`) as a near-duplicate copy.

- `useShowcaseTour(steps)` returns a `ShowcaseController` (`start` / `stop` /
  `isRunning`); the tour is owned by the calling widget and disposed with it.
- `ShowcaseTarget` attaches the step's `GlobalKey` and nothing else, so it can
  wrap any widget without touching layout.
- Fixed while porting: the `OverlayEntry` and auto-play timer leaked when the
  host widget was unmounted mid-tour; `Prev` on the first step silently ended
  the tour; the bubble was pushed off the top edge for a target low on screen;
  taps fell through the backdrop to the app behind it; a target key that never
  mounted spun a post-frame loop forever.
- Button copy comes from `TourLabels` (the original hard-coded English), and
  the bubble follows the ambient `ColorScheme` instead of the default canvas
  colour and `Colors.grey`.
- 7 widget tests cover navigation, skip, auto-play, the modal backdrop and
  disposal on unmount.

## [1.1.6] — 2026-07-19

Upstreams a set of `widget_kit` fixes and features that had been made
downstream in a consuming app and were never folded back in.

### Fixed

- **widget_kit**: `ShimmerShape` hardcoded `Colors.white` as its background,
  so every skeleton rendered as a bright white block in dark mode.
  `backgroundColor` is now nullable and falls back to
  `Theme.of(context).colorScheme.surfaceContainerHighest`. Callers that pass
  an explicit colour are unaffected.
- **widget_kit**: `ShimmerLayouts.card` applied its `height` as a fixed
  `Container` height, so content taller than that value overflowed the inner
  `Column`. `height` is now a floor (`BoxConstraints(minHeight:)`) with
  `MainAxisSize.min`, letting the card grow instead of clip.

- **widget_kit**: `Accordion` clipped its children at the panel corners
  because the rounded `Container` had no `clipBehavior`, and the content
  `SizeTransition` used `Alignment.topCenter`, which does not flip under
  RTL. Panels now use `Clip.antiAlias` and `AlignmentDirectional(0, -1)`.
- **widget_kit**: `Accordion` headers were bare `GestureDetector`s, so taps
  produced no ink response. They are now `Material` + `InkWell`.

### Added

- **widget_kit**: `ShimmerLayouts.cardList({count, cardHeight, padding})` —
  a non-scrolling column of card skeletons, as a drop-in replacement for a
  centered `CircularProgressIndicator` on list screens during first load.
- **widget_kit**: `Accordion` gained per-instance and per-item styling
  overrides — `headerBackgroundColor`, `contentBackgroundColor`,
  `headerForegroundColor`, `headerPadding`, `contentPadding`, `panelMargin`,
  and `trailingIcon`, with `AccordionItemData.headerBackgroundColor`,
  `headerForegroundColor`, and `trailing` taking precedence per item.
  Foreground colour is applied via `IconTheme`/`DefaultTextStyle` so
  consumers don't thread it through every descendant. All defaults match the
  previously hardcoded values, so existing call sites are unaffected.
- **widget_kit**: `RefreshTriggerTheme` gained `pullText`, `releaseText`,
  `refreshingText`, and `completedText`. `AppPillRefreshIndicator` hardcoded
  Arabic copy, which a project-agnostic package should not do; the strings
  are now overridable per app and the Arabic values remain as fallbacks.

### Changed

- **widget_kit**: `AppButton.enableHapticFeedback` now defaults to `true`
  (was `false`). Tactile confirmation on tap is the expected default; pass
  `enableHapticFeedback: false` to opt out.

## [1.1.5] — 2026-07-19

### Fixed

- **notify_kit**: `init()` latched its `_initialized` flag before awaiting
  the fallible local/FCM init calls, so a failure on first init silently
  wedged every retry (including the one `registerDevice()` tells callers to
  make after login) into a permanent no-op. The flag now only latches on
  genuine success; a concurrent second `init()` call while one is in flight
  now awaits the same attempt instead of double-running it.
- **storage_kit**: `saveAuthTokens`/`saveAccessToken` updated the in-memory
  access-token cache before the write was attempted and never rolled it
  back on failure, so `getAccessTokenSync()` could report a token that was
  never actually persisted (silent sign-out after restart). The cache now
  follows the write's actual result and rolls back to the previous,
  still-persisted value on failure.
- **api_kit**: Added `ApiKitRuntime.resetForTesting()` so tests can restore
  the process-wide runtime config to its defaults between runs; previously
  there was no way to reset it and `use()`'s "only overwrite non-null
  fields" semantics meant state leaked across tests. Added the package's
  first `test/` suite.

## [1.1.2] — 2026-07-11

### Added

- **widget_kit**: New `picker_sheet` module — a generic, reusable
  "pick one item from a list" bottom-sheet toolkit. Ships composable
  building blocks (`PickerSheetScaffold`, `PickerSheetSearchField`,
  `PickerSheetTitleBar`, `PickerSheetSectionLabel`, `PickerSheetList`,
  `PickerSheetOptionTile`) plus a ready-made `TypeaheadPickerSheet<T>`
  for server-side debounced search-and-pick flows. All public APIs are
  exported from the package barrel.

## [1.1.1] — 2026-07-07

### Changed

- **animation_kit**: Replaced the deprecated `Color.withOpacity()` API with
  `Color.withValues(alpha:)` in the `OrderConfetti` confetti painter to keep
  the package compatible with recent Flutter SDKs (avoids the
  `withOpacity` deprecation warning).
- **force_update_gate**: Bumped the `package_info_plus` constraint from
  `^8.0.0` to `^9.0.0`.

## [1.1.0]

- Shared Flutter packages monorepo release.

## [1.0.0]

- Initial monorepo release.
