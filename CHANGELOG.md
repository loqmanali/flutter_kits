# Changelog

All notable changes to the `flutter_kits` monorepo are documented in this file.
Individual packages may keep their own `CHANGELOG.md` for package-specific
release notes.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.3] — 2026-07-19

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
