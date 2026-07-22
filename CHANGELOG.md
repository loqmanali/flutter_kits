# Changelog

All notable changes to the `flutter_kits` monorepo are documented in this file.
Individual packages may keep their own `CHANGELOG.md` for package-specific
release notes.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.9] — 2026-07-22

Widens over-tight constraints so kits drop into more projects, and adds a
check that stops incompatible ranges from being merged in the first place.

### Added

- **tool/**: `dart run tool/bin/check_constraints.dart` fails when two kits
  declare version ranges for the same dependency that cannot both be
  satisfied. Independent pubspecs make such a pair invisible in either file on
  its own — it only surfaces as an unresolvable app, usually downstream. Only
  `dependencies` are treated as errors; `dev_dependencies` are not installed by
  consumers, so mismatches there are reported as harmless drift.

### Changed

- **notify_kit** (`0.1.1` → `0.1.2`): `timezone` `^0.9.2` →
  `>=0.9.2 <0.12.0`. With a `0.x` version the caret stops at `<0.10.0`, so the
  old range pinned every consuming app to `timezone` 0.9.x while 0.11 was
  current. Verified: analyze clean and 49 tests pass on both 0.9.2 and 0.11.1.
- **local_db_kit** (`1.2.0` → `1.2.1`): `flutter_secure_storage` `^10.0.0` →
  `>=9.0.0 <11.0.0`. The kit only uses `read`/`write`/`delete`, which are
  unchanged across 9.x and 10.x; requiring 10+ locked out any app still on 9.
  Verified: analyze clean and 83 tests pass on both 9.2.4 and 10.3.1.
- **animation_kit** (`0.1.0` → `0.1.1`): `flutter_lints` `^4.0.0` → `^6.0.0`,
  aligning with the rest of the repo, plus the `overridden_fields` and
  `use_super_parameters` fixes it surfaced in `CustomPageTransition` — the
  duration fields shadowed `PageRouteBuilder`'s own and were redundant.
- **force_update_gate**: `flutter_lints` `^4.0.0` → `^6.0.0`. Dev-only; no
  version bump because consumers are unaffected.

### Known issues

- **commerce_kit** is excluded from the constraint check (see `_excluded` in
  the script, which prints the reason on every run). It declares
  `flutter_riverpod ^2.4.9` against the repo's 3.x, and its sources sit outside
  `lib/` so it cannot be consumed as a package at all. Fixing it is a real
  migration, not a constraint bump.

## [1.1.8] — 2026-07-22

### Fixed

- **widget_kit**: Widened `flutter_hooks` from `^0.20.5` to `^0.21.0`
  (`1.0.1` → `1.0.2`). The old constraint excluded `0.21.x`, which made
  widget_kit unresolvable alongside any package depending on
  `hooks_riverpod ^3.3.2` — including this repo's own `otp_kit`, and
  inconsistent with `dropdown_menu_kit`, which was already on `^0.21.0`.
  widget_kit only uses core hooks (`HookWidget`, `useState`, `useEffect`,
  `useMemoized`, `useRef`, `useAnimationController`), all unchanged in 0.21;
  its 202 tests pass against the new constraint.

### Known issues

- **commerce_kit** still declares `flutter_riverpod ^2.4.9` while the rest of
  the repo is on 3.x. Its sources also sit outside `lib/`, so it is not
  consumable as a package — left untouched here; migrating it is its own task.

## [1.1.7] — 2026-07-22

### Changed

- **widget_kit**: Removed the embedded carousel implementation, its public
  exports, gallery demo, tests, and Riverpod dependencies. Use the standalone
  `carousel_kit` package for carousel functionality.

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
