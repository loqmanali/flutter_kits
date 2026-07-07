/// Process-wide configuration for deep_link_kit.
///
/// Tells the kit which links belong to your app:
/// - Which custom URL schemes to accept (e.g. `'lekbox'`, `'myapp'`).
/// - Which universal-link hosts to accept (e.g. `'example.com'`,
///   `'www.example.com'`).
///
/// Configure once near the top of `main()` before calling
/// `DeepLinkService.init()`.
///
/// ```dart
/// DeepLinkKitRuntime.use(
///   customSchemes: const ['myapp'],
///   universalLinkHosts: const ['example.com', 'www.example.com'],
/// );
/// ```
class DeepLinkKitRuntime {
  DeepLinkKitRuntime._();

  static List<String> _customSchemes = const [];
  static List<String> _universalLinkHosts = const [];

  /// Override the configuration. Pass only the values you want to change.
  static void use({
    List<String>? customSchemes,
    List<String>? universalLinkHosts,
  }) {
    if (customSchemes != null) _customSchemes = customSchemes;
    if (universalLinkHosts != null) _universalLinkHosts = universalLinkHosts;
  }

  /// Custom URL schemes belonging to the app (e.g. `myapp`).
  static List<String> get customSchemes => _customSchemes;

  /// Universal-link hosts belonging to the app (e.g. `example.com`).
  static List<String> get universalLinkHosts => _universalLinkHosts;

  /// True when no schemes/hosts are configured — in that case the kit treats
  /// every link as foreign and forwards nothing.
  static bool get isEmpty =>
      _customSchemes.isEmpty && _universalLinkHosts.isEmpty;
}
