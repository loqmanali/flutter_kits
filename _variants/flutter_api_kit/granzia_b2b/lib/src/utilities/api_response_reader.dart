import 'package:dio/dio.dart';

/// Normalizes API results so repositories can read decoded payloads safely.
///
/// Supports both raw decoded JSON maps/lists and Dio [Response] objects.
class ApiResponseReader {
  final dynamic _source;

  const ApiResponseReader._(this._source);

  factory ApiResponseReader.from(dynamic response) {
    if (response is ApiResponseReader) return response;
    if (response is Response) return ApiResponseReader._(response.data);
    return ApiResponseReader._(response);
  }

  /// The full decoded response envelope.
  Map<String, dynamic> get envelope => _asMap(_source);

  Map<String, dynamic> dataMap({bool fallbackToEnvelope = false}) {
    final value = envelope['data'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return fallbackToEnvelope ? envelope : <String, dynamic>{};
  }

  List<dynamic> dataList({bool fallbackToRootList = false}) {
    final value = envelope['data'];
    if (value is List) return List<dynamic>.from(value);
    if (fallbackToRootList && _source is List) {
      return List<dynamic>.from(_source);
    }
    return const [];
  }

  Map<String, dynamic> dataOrEnvelopeMap() =>
      dataMap(fallbackToEnvelope: true);

  int intValue(String key, {int fallback = 0}) {
    return (envelope[key] as num?)?.toInt() ?? fallback;
  }

  String? stringValue(String key) => envelope[key] as String?;

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw StateError(
      'Expected decoded response map but got ${value.runtimeType}.',
    );
  }
}
