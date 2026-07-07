/// The result of a single force-update check.
///
/// Returned by `ForceUpdateService.resolvePolicy` and passed into
/// the screen builder so custom UIs can show version details.
class ForceUpdatePolicy {
  const ForceUpdatePolicy({
    required this.updateRequired,
    required this.currentVersion,
    required this.latestVersion,
    required this.storeUrl,
    this.releaseNotes,
    this.osBelowMinimum = false,
  });

  /// `true` when the gate should display the update screen.
  ///
  /// Triggered by any of:
  /// - installed version is older than the store version.
  /// - installed version is older than `minAppVersion` (if pinned).
  /// - the device OS is older than `minOsVersion` (if pinned).
  /// - `debugAlwaysShow` is set.
  final bool updateRequired;

  /// The semver version installed on this device, e.g. `"1.0.0"`.
  final String currentVersion;

  /// The latest version published on the store, e.g. `"1.0.1"`.
  /// `null` if the store lookup failed or the platform is unsupported.
  final String? latestVersion;

  /// Deep link to the store listing, used by the default "Update" action.
  final String storeUrl;

  /// Release notes string from the store listing.
  ///
  /// Populated only when `ForceUpdateConfig.includeReleaseNotes` is
  /// `true` and the underlying `upgrader` exposes them.
  final String? releaseNotes;

  /// `true` when the device's OS version is below
  /// `ForceUpdateConfig.minOsVersion`. Useful for displaying a different
  /// message ("upgrade your phone") when the cause isn't an outdated app.
  final bool osBelowMinimum;

  ForceUpdatePolicy copyWith({
    bool? updateRequired,
    String? currentVersion,
    String? latestVersion,
    String? storeUrl,
    String? releaseNotes,
    bool? osBelowMinimum,
  }) {
    return ForceUpdatePolicy(
      updateRequired: updateRequired ?? this.updateRequired,
      currentVersion: currentVersion ?? this.currentVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      storeUrl: storeUrl ?? this.storeUrl,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      osBelowMinimum: osBelowMinimum ?? this.osBelowMinimum,
    );
  }
}
