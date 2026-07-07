/// Source of the current `Accept-Language` value.
///
/// Implement against your app's locale state. A bundled
/// `StaticLanguageProvider` is provided for the simple case.
abstract class LanguageProvider {
  String getLanguageCode();
}

/// Returns a fixed code regardless of state. Useful for tests or apps that
/// never change locale at runtime.
class StaticLanguageProvider implements LanguageProvider {
  final String code;
  const StaticLanguageProvider(this.code);

  @override
  String getLanguageCode() => code;
}
