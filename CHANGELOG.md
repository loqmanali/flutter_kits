# Changelog

All notable changes to the `flutter_kits` monorepo are documented in this file.
Individual packages may keep their own `CHANGELOG.md` for package-specific
release notes.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
