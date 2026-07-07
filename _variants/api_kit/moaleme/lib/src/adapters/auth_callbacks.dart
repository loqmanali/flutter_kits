/// Called by [AuthInterceptor] when a request returns 401.
///
/// Implementations should hit the refresh endpoint with [refreshToken] and
/// return the new access token (or `null` to signal "give up and log out").
typedef TokenRefreshCallback = Future<String?> Function(String refreshToken);

/// Called when a token refresh fails or no refresh token is available.
///
/// Implementations should perform host-app logout (e.g. clear user state,
/// navigate to the login screen).
typedef LogoutCallback = Future<void> Function();
