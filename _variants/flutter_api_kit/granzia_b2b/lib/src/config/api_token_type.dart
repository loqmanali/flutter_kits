/// Indicates which authentication scheme an endpoint requires.
///
/// Maps to factories on `DioApiClient`:
/// - [userToken]  → `DioApiClient.authenticated(...)`
/// - [none]       → `DioApiClient.public(...)`
enum ApiTokenType {
  /// Bearer token from `TokenStorage`.
  userToken,

  /// Public — no auth interceptor.
  none,
}

extension ApiTokenTypeX on ApiTokenType {
  String get description {
    switch (this) {
      case ApiTokenType.userToken:
        return 'User token (requires login)';
      case ApiTokenType.none:
        return 'Public (no auth)';
    }
  }
}
