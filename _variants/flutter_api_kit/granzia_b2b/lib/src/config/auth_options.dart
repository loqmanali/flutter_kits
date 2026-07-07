/// Per-project toggles for auth behavior.
///
/// Construct once and pass into `AuthInterceptor` / `DioApiClient` to enable
/// or disable cross-cutting auth features without touching their code.
class AuthOptions {
  /// When `true`, an unauthorized response transitions the user to guest mode
  /// via the `LogoutCallback`. When `false`, the callback is invoked as a
  /// full logout.
  ///
  /// The package itself does not distinguish between the two — it merely
  /// invokes the callback you provide. This flag is here so the same
  /// callback can branch on app-level behavior.
  final bool enableGuestMode;

  /// Whether the refresh-token flow is active. When `false`, 401 responses
  /// fall straight through to the logout callback.
  final bool enableRefreshTokenFlow;

  const AuthOptions({
    this.enableGuestMode = false,
    this.enableRefreshTokenFlow = false,
  });

  static const defaults = AuthOptions();
}
