## 0.2.0

### Added

- **Persistent dismissal** via `shared_preferences`. New
  `ForceUpdateSkipMode` enum: `session` (default), `cooldown`, `version`
  ("skip this version").
- **Foreground re-check** through `WidgetsBindingObserver`. Toggle with
  `ForceUpdateConfig.recheckOnForeground` (defaults to `true`).
- **Lifecycle callbacks**: `onUpdateRequired`, `onUpdateDismissed`,
  `onStoreOpened` for analytics.
- **Custom version comparator** via `VersionComparator` typedef and the
  `versionComparator` config field. `defaultVersionComparator` is
  exposed for reuse.
- **`CupertinoForceUpdateScreen`** — iOS-styled default screen.
- **`ForceUpdateBanner`** — non-modal banner alternative for soft-upgrade
  flows.
- **`showForceUpdateDialog`** — imperative `AlertDialog` API for
  point-in-time gating (e.g. after login).
- **Release notes** support: set `includeReleaseNotes: true` to expose
  store release notes via `ForceUpdatePolicy.releaseNotes` and render
  them in the default screens.
- **Bundled localizations**: `ForceUpdateLabels.en/ar/fr/es/de/tr()`
  factory constructors.
- **Android in-app update**: `androidInAppUpdateMode: immediate` or
  `flexible` to use Google's native flow instead of bouncing to the
  store URL.
- **Minimum OS version gate** via `minOsVersion`. Surfaces in the policy
  as `osBelowMinimum`.

### Changed

- `ForceUpdateActions` now also exposes `completeFlexibleUpdate` for
  finishing flexible Android downloads.
- `ForceUpdateConfig.copyWith()` covers all new fields.

### Tests

- Unit tests for the version comparator (semver, build metadata,
  pre-release tags, non-numeric coercion).
- Unit tests for `DismissalStore` covering all three skip modes.
- Widget tests for the gate covering: child-while-loading, default
  screen render, Later button visibility / behavior, custom
  `screenBuilder`, and lifecycle callbacks.
- API surface smoke test that fails if a public export disappears.

### Example

- Restructured `example/` into a runnable Flutter app with its own
  `pubspec.yaml`. Demonstrates the gate, banner, dialog, Cupertino
  screen, and lifecycle callbacks.

## 0.1.0

- Initial release.
- `ForceUpdateGate` widget that wraps any subtree and switches to an
  update screen when a newer version is detected on the store.
- `ForceUpdateService` for advanced/imperative integrations.
- Default Material screen with primary "Update" action and optional
  "Later" dismissal.
- Custom UI via `screenBuilder` callback.
- Configurable labels, behavior, debug flags, country code, and pinned
  `minAppVersion`.
