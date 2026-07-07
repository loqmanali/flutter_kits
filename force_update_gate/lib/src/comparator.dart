/// Compares two version strings.
///
/// Returns a negative number when [installed] is older than [store],
/// `0` when equal, positive when [installed] is newer.
typedef VersionComparator = int Function(String installed, String store);

/// Default semver-style comparator used by [ForceUpdateService] when
/// [ForceUpdateConfig.versionComparator] is null.
///
/// Strips anything after `+` (build metadata) and `-` (pre-release tags
/// like `1.0.0-beta.1`), splits on `.`, and compares each numeric
/// component. Non-numeric parts are coerced to `0`.
///
/// For projects that need pre-release ordering (`1.0.0-alpha < 1.0.0-beta
/// < 1.0.0`), provide a custom [VersionComparator].
int defaultVersionComparator(String installed, String store) {
  final left = _parseVersion(installed);
  final right = _parseVersion(store);
  final length = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < length; i++) {
    final a = i < left.length ? left[i] : 0;
    final b = i < right.length ? right[i] : 0;
    if (a < b) return -1;
    if (a > b) return 1;
  }
  return 0;
}

List<int> _parseVersion(String value) {
  final stripped = value.split('+').first.split('-').first;
  return stripped
      .split('.')
      .map(
        (part) =>
            int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      )
      .toList();
}
