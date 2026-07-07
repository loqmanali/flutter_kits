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
}
