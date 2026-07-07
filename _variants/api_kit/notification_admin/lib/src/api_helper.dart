import 'api_token_type.dart';
import 'interfaces/api_client.dart';

/// Resolver function that returns the right [ApiClient] for a given
/// [ApiTokenType].
///
/// The host app supplies this once (typically wired through its DI
/// container) and passes it to [ApiHelper]. Keeping resolution behind a
/// callback means api_kit doesn't depend on any specific DI framework.
typedef ApiClientResolver = ApiClient Function(ApiTokenType tokenType);

/// Thin helper that selects the right [ApiClient] for a request and runs it.
///
/// ```dart
/// final helper = ApiHelper((type) => switch (type) {
///   ApiTokenType.userToken   => userClient,
///   ApiTokenType.staticToken => publicClient,
///   ApiTokenType.both        => fullClient,
/// });
///
/// final user = await helper.executeApiCall(
///   tokenType: ApiTokenType.userToken,
///   apiCall: (client) => client.get('/me'),
/// );
/// ```
class ApiHelper {
  ApiHelper(this._resolver);

  final ApiClientResolver _resolver;

  /// Returns the API client appropriate for [tokenType].
  ApiClient getClient(ApiTokenType tokenType) => _resolver(tokenType);

  /// Resolves the client for [tokenType] and runs [apiCall] against it.
  Future<T> executeApiCall<T>({
    required ApiTokenType tokenType,
    required Future<T> Function(ApiClient client) apiCall,
  }) async {
    final client = getClient(tokenType);
    return apiCall(client);
  }
}
