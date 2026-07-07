/// Framework-agnostic HTTP client interface.
///
/// Concrete implementations live in `lib/src/implementations`. The
/// recommended one is `DioApiClient`, but consumers can swap in their own
/// (e.g. backed by `http`, `chopper`, or a mock).
abstract class ApiClient {
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  });

  /// GET that returns raw bytes — for binary downloads (CSV/PDF/etc.).
  /// Goes through the same interceptors as [get].
  Future<List<int>> getBytes(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  });

  /// [receiveTimeout] overrides the client-default receive timeout for this
  /// single call — useful for long-running endpoints.
  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Duration? receiveTimeout,
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

  /// Upload a single file via multipart with optional extra form fields.
  Future<dynamic> uploadFile(
    String endpoint, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  });
}
