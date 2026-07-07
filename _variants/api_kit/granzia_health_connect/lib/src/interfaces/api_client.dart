/// Abstract API client that defines common HTTP operations.
abstract class ApiClient {
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,

    /// Optional override that replaces the `Authorization` header for this
    /// single request with `Bearer <bearerTokenOverride>`. Useful for one-off
    /// service-account calls.
    String? bearerTokenOverride,
  });

  Future<dynamic> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  /// Upload a single file (image or other) with optional extra fields.
  /// [filePath] is the local path of the file on device.
  /// [fieldName] is the form field name expected by backend.
  Future<dynamic> uploadFile(
    String endpoint, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  });

  /// Download a binary file to [savePath] on the device, reusing the same
  /// configured client (base URL, auth/token, language/version interceptors).
  ///
  /// [endpoint] may be a relative path (resolved against the base URL) or an
  /// absolute URL (e.g. a server-provided `download_url`) — Dio uses the
  /// absolute one as-is. Returns the [savePath] on success.
  Future<String> downloadToFile(
    String endpoint, {
    required String savePath,
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onProgress,
  });
}
