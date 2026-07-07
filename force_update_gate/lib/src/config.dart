import 'comparator.dart';
import 'labels.dart';
import 'policy.dart';

/// Controls how the dismissal ("Later") button behaves when
/// [ForceUpdateConfig.allowLater] is `true`.
enum ForceUpdateSkipMode {
  /// Dismissal lasts only for the current process — the gate appears
  /// again on the next cold start.
  session,

  /// Dismissal is persisted via `shared_preferences` for
  /// [ForceUpdateConfig.laterCooldown]. After the cooldown elapses, the
  /// gate appears again.
  cooldown,

  /// Dismissal is persisted *for the current store version*. When a
  /// newer version is published, the gate appears again. Use this for
  /// "Skip this version" UX.
  version,
}

/// Android in-app update flow.
///
/// See the Play Console docs for the difference between immediate and
/// flexible updates.
enum AndroidInAppUpdateMode {
  /// User sees a Play Store overlay that blocks the app until the update
  /// finishes. Closer in spirit to a "force update".
  immediate,

  /// Update downloads in the background; you complete it via
  /// [ForceUpdateActions.completeFlexibleUpdate].
  flexible,
}

/// Lifecycle callback invoked when the gate fires.
typedef ForceUpdateCallback = void Function(ForceUpdatePolicy policy);

/// Behavior + content configuration for the gate.
class ForceUpdateConfig {
  const ForceUpdateConfig({
    this.labels = const ForceUpdateLabels(),
    this.allowLater = false,
    this.skipMode = ForceUpdateSkipMode.session,
    this.laterCooldown = Duration.zero,
    this.recheckOnForeground = true,
    this.includeReleaseNotes = false,
    this.debugAlwaysShow = false,
    this.debugLogging = false,
    this.countryCode,
    this.minAppVersion,
    this.minOsVersion,
    this.fallbackStoreUrl,
    this.versionComparator,
    this.androidInAppUpdateMode,
    this.onUpdateRequired,
    this.onUpdateDismissed,
    this.onStoreOpened,
  });

  /// Strings rendered by the default screen / banner / dialog.
  final ForceUpdateLabels labels;

  /// When `true`, the gate renders a secondary dismissal button.
  final bool allowLater;

  /// How the dismissal ("Later" / "Skip") action behaves.
  final ForceUpdateSkipMode skipMode;

  /// Used when [skipMode] is [ForceUpdateSkipMode.cooldown]. Defaults to
  /// `Duration.zero`, which behaves like [ForceUpdateSkipMode.session].
  final Duration laterCooldown;

  /// Re-run the version check when the app returns to foreground (via
  /// `WidgetsBindingObserver`). Defaults to `true`.
  final bool recheckOnForeground;

  /// Surface store release notes via `ForceUpdatePolicy.releaseNotes`.
  /// The default screen renders them under a "What's new" heading.
  final bool includeReleaseNotes;

  /// Force the gate on for testing. **Strip before shipping.**
  final bool debugAlwaysShow;

  /// Verbose logs for store lookup debugging.
  final bool debugLogging;

  /// iTunes Search API country (iOS only).
  final String? countryCode;

  /// Hard floor pinned in code, e.g. `"1.2.0"`.
  final String? minAppVersion;

  /// Hard floor for the device OS version, e.g. `"13.0"` for iOS or
  /// `"10"` for Android. When the device falls below this floor, the
  /// gate fires regardless of app version.
  final String? minOsVersion;

  /// Used when the store listing URL can't be resolved.
  final String? fallbackStoreUrl;

  /// Override the version comparison logic. Useful for non-semver
  /// schemes or for projects that want pre-release tag ordering.
  final VersionComparator? versionComparator;

  /// Enable Google Play's native in-app update flow on Android. When
  /// non-null, the "Update" action triggers Play's overlay instead of
  /// launching the store URL.
  final AndroidInAppUpdateMode? androidInAppUpdateMode;

  /// Invoked once when the gate determines an update is required.
  final ForceUpdateCallback? onUpdateRequired;

  /// Invoked when the user dismisses the screen (only fires when
  /// [allowLater] is `true`).
  final ForceUpdateCallback? onUpdateDismissed;

  /// Invoked when the user taps the "Update" button (before launch).
  final ForceUpdateCallback? onStoreOpened;

  ForceUpdateConfig copyWith({
    ForceUpdateLabels? labels,
    bool? allowLater,
    ForceUpdateSkipMode? skipMode,
    Duration? laterCooldown,
    bool? recheckOnForeground,
    bool? includeReleaseNotes,
    bool? debugAlwaysShow,
    bool? debugLogging,
    String? countryCode,
    String? minAppVersion,
    String? minOsVersion,
    String? fallbackStoreUrl,
    VersionComparator? versionComparator,
    AndroidInAppUpdateMode? androidInAppUpdateMode,
    ForceUpdateCallback? onUpdateRequired,
    ForceUpdateCallback? onUpdateDismissed,
    ForceUpdateCallback? onStoreOpened,
  }) {
    return ForceUpdateConfig(
      labels: labels ?? this.labels,
      allowLater: allowLater ?? this.allowLater,
      skipMode: skipMode ?? this.skipMode,
      laterCooldown: laterCooldown ?? this.laterCooldown,
      recheckOnForeground: recheckOnForeground ?? this.recheckOnForeground,
      includeReleaseNotes: includeReleaseNotes ?? this.includeReleaseNotes,
      debugAlwaysShow: debugAlwaysShow ?? this.debugAlwaysShow,
      debugLogging: debugLogging ?? this.debugLogging,
      countryCode: countryCode ?? this.countryCode,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      minOsVersion: minOsVersion ?? this.minOsVersion,
      fallbackStoreUrl: fallbackStoreUrl ?? this.fallbackStoreUrl,
      versionComparator: versionComparator ?? this.versionComparator,
      androidInAppUpdateMode:
          androidInAppUpdateMode ?? this.androidInAppUpdateMode,
      onUpdateRequired: onUpdateRequired ?? this.onUpdateRequired,
      onUpdateDismissed: onUpdateDismissed ?? this.onUpdateDismissed,
      onStoreOpened: onStoreOpened ?? this.onStoreOpened,
    );
  }
}
