# force_update_gate

A drop-in Flutter widget that gates your app behind a force-update screen
when a newer version is published on the App Store / Play Store.

- **No Firebase, no backend** — version comparison happens directly
  against the public store listings via the
  [`upgrader`](https://pub.dev/packages/upgrader) package.
- **Doesn't block first paint** — your splash / home screen renders
  immediately, the gate only takes over once the version check resolves.
- **Multiple presentation modes** — full-screen takeover, top banner, or
  modal dialog.
- **Persistent dismissal** — session-only, time-based cooldown, or
  "skip this version" backed by `shared_preferences`.
- **Material + Cupertino** default screens, fully theme-aware.
- **Built-in localizations** for English, Arabic, French, Spanish,
  German, Turkish (and easy to add more).
- **Android in-app updates** — native Play Store update overlay via
  the `in_app_update` package.
- **Custom version comparator** for non-semver schemes.

---

## Installation

This package isn't on pub.dev. Add it as a path dependency in the
consumer project's `pubspec.yaml`:

```yaml
dependencies:
  force_update_gate:
    path: ../packages/force_update_gate
```

Then:

```sh
flutter pub get
```

---

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:force_update_gate/force_update_gate.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => ForceUpdateGate(child: child!),
      home: const MyHomePage(),
    );
  }
}
```

That's it. With zero configuration, the gate:

1. Reads the installed version via `package_info_plus`.
2. Looks up the latest version on Play Store / App Store via
   `upgrader`.
3. If the installed version is lower, replaces your app with the
   default Material screen — no dismiss button, the user must update.

---

## Presentation modes

| Mode | Widget / API | When to use |
|---|---|---|
| Full-screen takeover | `ForceUpdateGate` | Hard force-update; users must act before continuing. |
| Top banner | `ForceUpdateBanner` | Soft nudge; app stays usable. |
| Modal dialog | `showForceUpdateDialog()` | Point-in-time check (e.g. after login). |

---

## Configuration reference

```dart
ForceUpdateGate(
  config: ForceUpdateConfig(
    // ─── content ─────────────────────────────────────────
    labels: ForceUpdateLabels.ar(),

    // ─── behavior ────────────────────────────────────────
    allowLater: true,
    skipMode: ForceUpdateSkipMode.cooldown,    // session/cooldown/version
    laterCooldown: const Duration(hours: 24),
    recheckOnForeground: true,
    includeReleaseNotes: true,

    // ─── version-check tuning ────────────────────────────
    countryCode: 'sa',
    minAppVersion: '1.2.0',
    minOsVersion: '13.0',
    fallbackStoreUrl: 'https://apps.apple.com/app/id123456',
    versionComparator: myCustomComparator,

    // ─── platform integrations ───────────────────────────
    androidInAppUpdateMode: AndroidInAppUpdateMode.immediate,

    // ─── debug ───────────────────────────────────────────
    debugAlwaysShow: false,
    debugLogging: false,

    // ─── lifecycle hooks ─────────────────────────────────
    onUpdateRequired: (policy) => analytics.log('upgrade_shown'),
    onUpdateDismissed: (policy) => analytics.log('upgrade_dismissed'),
    onStoreOpened: (policy) => analytics.log('upgrade_store_opened'),
  ),
  child: child!,
)
```

### Field reference

| Field | Default | Purpose |
|---|---|---|
| `labels` | `ForceUpdateLabels()` (English) | Strings rendered by the default screens. Use `ForceUpdateLabels.ar()` etc. for built-in translations or pass your own. |
| `allowLater` | `false` | Show a secondary dismiss button. |
| `skipMode` | `session` | How dismissal behaves. See *Skip modes* below. |
| `laterCooldown` | `Duration.zero` | Cooldown when `skipMode == cooldown`. |
| `recheckOnForeground` | `true` | Re-run the check when the app resumes. |
| `includeReleaseNotes` | `false` | Surface `policy.releaseNotes` and render in default screens. |
| `debugAlwaysShow` | `false` | Force-display for testing. |
| `debugLogging` | `false` | Verbose logs from `upgrader` and `in_app_update`. |
| `countryCode` | `null` | iTunes Search API country override (iOS). |
| `minAppVersion` | `null` | Hard floor pinned in code. |
| `minOsVersion` | `null` | Hard floor for the device OS version. |
| `fallbackStoreUrl` | `null` | Used when the store listing URL can't be resolved. |
| `versionComparator` | `defaultVersionComparator` | Plug-in `int Function(installed, store)`. |
| `androidInAppUpdateMode` | `null` | `immediate` or `flexible` to use Play's native flow. |
| `onUpdateRequired` | `null` | Fires once when the gate decides to show. |
| `onUpdateDismissed` | `null` | Fires when the user taps Later/Skip. |
| `onStoreOpened` | `null` | Fires when the user taps Update (before launch). |

---

## Skip modes

Three modes control how the optional "Later" button persists across
launches:

| Mode | Behavior | Use case |
|---|---|---|
| `session` | Dismissal lasts only for the current process. The gate appears again on cold start. | Default. Hard force-update with a one-time escape. |
| `cooldown` | Dismissal persists for `laterCooldown` real-time. | "Don't nag me for 24 hours." |
| `version` | Dismissal persists *until the store version changes*. The gate appears again when a newer build ships. | "Skip this version" UX. |

The label on the dismiss button switches automatically to
`skipVersionButton` when `skipMode == version`.

---

## Custom UI

For total control over rendering, pass `screenBuilder`:

```dart
ForceUpdateGate(
  config: const ForceUpdateConfig(allowLater: true),
  screenBuilder: (context, policy, actions) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Installed: ${policy.currentVersion}'),
            if (policy.latestVersion != null)
              Text('Latest: ${policy.latestVersion}'),
            ElevatedButton(
              onPressed: () => actions.openStore(),
              child: const Text('Update'),
            ),
            if (actions.dismiss != null)
              TextButton(
                onPressed: actions.dismiss,
                child: const Text('Later'),
              ),
          ],
        ),
      ),
    );
  },
  child: child!,
)
```

`actions.dismiss` is `null` when `allowLater` is `false` — hide your
dismiss button accordingly.

---

## Cupertino screen

Drop in `CupertinoForceUpdateScreen` for an iOS look:

```dart
ForceUpdateGate(
  screenBuilder: (context, policy, actions) =>
      CupertinoForceUpdateScreen(
        policy: policy,
        actions: actions,
        labels: ForceUpdateLabels.en(),
        showReleaseNotes: true,
      ),
  child: child!,
)
```

---

## Banner mode

For a non-modal nudge that doesn't block the app:

```dart
ForceUpdateBanner(
  config: const ForceUpdateConfig(allowLater: true),
  child: child!,
)
```

The banner renders above the child, with Update / dismiss buttons
inline. Use this for soft-upgrade prompts where data freshness matters
but blocking the user is too aggressive.

---

## Dialog mode

For one-shot checks (e.g. on app entry, after login, on a manual
"Check for updates" button):

```dart
ElevatedButton(
  onPressed: () => showForceUpdateDialog(
    context: context,
    config: const ForceUpdateConfig(
      allowLater: true,
      includeReleaseNotes: true,
    ),
  ),
  child: const Text('Check for updates'),
)
```

The dialog is non-dismissible by default — pass `barrierDismissible:
true` plus `allowLater: true` if you want the user to be able to tap
outside.

---

## Localisation

Use the bundled factories or pass custom strings:

```dart
// Built-in: en, ar, fr, es, de, tr
ForceUpdateConfig(labels: ForceUpdateLabels.ar())

// From your own AppLocalizations:
ForceUpdateConfig(
  labels: ForceUpdateLabels(
    title: AppLocalizations.of(context)!.updateAvailable,
    message: AppLocalizations.of(context)!.newVersionAvailableForce,
    updateButton: AppLocalizations.of(context)!.update,
    laterButton: AppLocalizations.of(context)!.later,
  ),
)
```

The default screen respects the ambient `Directionality`, so RTL
languages render correctly when `MaterialApp.locale` is set.

---

## Android in-app updates

Use Google's native update overlay instead of bouncing to the Play
Store listing:

```dart
ForceUpdateConfig(
  androidInAppUpdateMode: AndroidInAppUpdateMode.immediate,
)
```

Two modes:

- **`immediate`** — Play takes over the screen until the update
  finishes. Closer in spirit to a force update.
- **`flexible`** — Update downloads in the background. Call
  `actions.completeFlexibleUpdate()` from your custom screen to
  install once the download completes.

The package falls back to launching the store URL on iOS or when Play
rejects the request (e.g. the build wasn't installed via Play, or the
update isn't available yet).

---

## Custom version comparator

If your versions don't follow vanilla semver:

```dart
ForceUpdateConfig(
  versionComparator: (installed, store) {
    // return negative when installed < store
    // return 0 when equal
    // return positive when installed > store
    return MyVersion.parse(installed).compareTo(MyVersion.parse(store));
  },
)
```

The default comparator strips `+build` metadata and `-prerelease`
tags, splits on `.`, and compares numeric components.

---

## Imperative API

For state-management-driven apps:

```dart
final policy = await const ForceUpdateService(
  config: ForceUpdateConfig(minAppVersion: '1.2.0'),
).resolvePolicy();

if (policy.updateRequired) {
  // dispatch an event, navigate manually, etc.
}
```

`ForceUpdatePolicy` exposes:

- `updateRequired` — whether the gate should show.
- `currentVersion` — installed semver.
- `latestVersion` — store semver (or `null`).
- `storeUrl` — direct link to the listing.
- `releaseNotes` — when `includeReleaseNotes: true`.
- `osBelowMinimum` — when `minOsVersion` is set and exceeded.

---

## Lifecycle callbacks

Useful for analytics:

```dart
ForceUpdateConfig(
  onUpdateRequired: (policy) {
    analytics.log('force_update_shown', {
      'installed': policy.currentVersion,
      'latest': policy.latestVersion,
    });
  },
  onUpdateDismissed: (policy) =>
      analytics.log('force_update_dismissed'),
  onStoreOpened: (policy) =>
      analytics.log('force_update_store_opened'),
)
```

`onUpdateRequired` fires at most once per gate instance.
`onUpdateDismissed` fires every time the user taps the dismiss
button. `onStoreOpened` fires immediately before the store launch
(or in-app update flow).

---

## Testing locally

Force the screen without publishing a new version:

- **Recommended:** set `debugAlwaysShow: true` on the config.
- Or temporarily lower `pubspec.yaml`'s semver below the published
  store version (e.g. `0.9.0+1` against a store at `1.0.0`).

Build numbers (the part after `+`) are **ignored** — only the semver
matters.

For unit / widget tests in your own app, inject mocks via
`ForceUpdateGate.service` and `ForceUpdateGate.inAppUpdateHelper`.
The `gate_test.dart` in this package shows the pattern.

---

## How the version check works

1. **Installed version** — from `package_info_plus`. Matches the semver
   in your `pubspec.yaml` at build time.
2. **Store version** — `upgrader` queries the iTunes Search API on iOS
   and scrapes Play Store metadata on Android.
3. **Comparison** — the gate fires when:
   - `installed < latest_store_version`, or
   - `installed < minAppVersion` (if configured), or
   - `osBelowMinimum` (if `minOsVersion` is set), or
   - `debugAlwaysShow == true`.

**Direction matters.** If your installed version is *equal to* or
*ahead of* the store, no update screen appears.

---

## Caveats

- **iOS country code.** Apps published outside the US default need
  `countryCode` set, otherwise the iTunes lookup may not find the
  listing.
- **Store propagation.** After publishing, store metadata can take
  minutes to hours to propagate.
- **No remote kill switch.** You can't disable a specific build for
  some users — the only signal is "is your installed version below
  what's published / pinned".
- **First launch needs internet.** Without connectivity the gate
  silently allows the app to proceed.
- **In-app updates are Android-only and Play-installed-only.** The
  `in_app_update` package fails on iOS and on sideloaded Android
  builds; the package transparently falls back to launching the
  store URL.

---

## Public API

Exported from `package:force_update_gate/force_update_gate.dart`:

- Widgets: `ForceUpdateGate`, `ForceUpdateBanner`,
  `DefaultForceUpdateScreen`, `CupertinoForceUpdateScreen`.
- Imperative: `ForceUpdateService`, `showForceUpdateDialog`.
- Data: `ForceUpdateConfig`, `ForceUpdateLabels`, `ForceUpdatePolicy`,
  `ForceUpdateActions`.
- Enums: `ForceUpdateSkipMode`, `AndroidInAppUpdateMode`,
  `InAppUpdateResult`.
- Typedefs: `ForceUpdateScreenBuilder`, `VersionComparator`,
  `ForceUpdateCallback`.
- Helpers: `defaultVersionComparator`, `DismissalStore`,
  `InAppUpdateHelper`.

---

## License

MIT.
