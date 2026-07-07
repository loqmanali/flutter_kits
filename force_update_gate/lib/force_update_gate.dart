/// `force_update_gate` — drop-in force update for Flutter apps.
///
/// See `README.md` for full usage. Public exports:
///
/// - [ForceUpdateGate]                  — wrap your app with this widget.
/// - [ForceUpdateBanner]                — non-modal banner alternative.
/// - [showForceUpdateDialog]            — imperative dialog API.
/// - [ForceUpdateConfig]                — behavior + content configuration.
/// - [ForceUpdateLabels]                — localisable strings (with
///                                        built-in factories `.en()`,
///                                        `.ar()`, `.fr()`, `.es()`,
///                                        `.de()`, `.tr()`).
/// - [ForceUpdatePolicy]                — resolved version-check result.
/// - [ForceUpdateActions]               — callbacks passed to custom UIs.
/// - [ForceUpdateService]               — imperative API.
/// - [ForceUpdateScreenBuilder]         — typedef for custom screens.
/// - [DefaultForceUpdateScreen]         — Material default UI.
/// - [CupertinoForceUpdateScreen]       — iOS-style alternative.
/// - [ForceUpdateSkipMode]              — session / cooldown / version.
/// - [AndroidInAppUpdateMode]           — immediate / flexible.
/// - [VersionComparator]                — typedef for custom comparators.
/// - [defaultVersionComparator]         — the package's semver default.
library;

export 'src/actions.dart';
export 'src/banner.dart';
export 'src/comparator.dart';
export 'src/config.dart';
export 'src/cupertino_screen.dart';
export 'src/default_screen.dart';
export 'src/dialog.dart';
export 'src/dismissal_store.dart';
export 'src/gate.dart';
export 'src/in_app_update_helper.dart';
export 'src/labels.dart';
export 'src/policy.dart';
export 'src/service.dart';
