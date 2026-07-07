import 'package:dio/dio.dart';

/// Normalizes API results so repositories can read decoded payloads safely.
///
/// Supports both raw decoded JSON maps/lists and Dio [Response] objects.
class ApiResponseReader {
  final dynamic _source;

  const ApiResponseReader._(this._source);

  factory ApiResponseReader.from(dynamic response) {
    if (response is ApiResponseReader) {
      return response;
    }
    if (response is Response) {
      return ApiResponseReader._(response.data);
    }
    return ApiResponseReader._(response);
  }

  /// The full decoded response envelope.
  Map<String, dynamic> get envelope => _asMap(_source);

  /// Returns the `data` object when it is a map.
  ///
  /// When [fallbackToEnvelope] is true and `data` is missing or not a map,
  /// the whole envelope is returned instead.
  Map<String, dynamic> dataMap({bool fallbackToEnvelope = false}) {
    final value = envelope['data'];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return fallbackToEnvelope ? envelope : <String, dynamic>{};
  }

  /// Returns the `data` array when present, otherwise an empty list.
  ///
  /// When [fallbackToRootList] is true and the decoded response itself is a
  /// list, that root list is returned instead.
  List<dynamic> dataList({bool fallbackToRootList = false}) {
    final value = envelope['data'];
    if (value is List) {
      return List<dynamic>.from(value);
    }
    if (fallbackToRootList && _source is List) {
      return List<dynamic>.from(_source);
    }
    return const [];
  }

  /// Returns the `data` object when present, otherwise the full envelope.
  Map<String, dynamic> dataOrEnvelopeMap() {
    return dataMap(fallbackToEnvelope: true);
  }

  /// Reads an integer from the full response envelope.
  int intValue(String key, {int fallback = 0}) {
    return (envelope[key] as num?)?.toInt() ?? fallback;
  }

  /// Reads a string from the full response envelope.
  String? stringValue(String key) {
    return envelope[key] as String?;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw StateError(
      'Expected decoded response map but got ${value.runtimeType}.',
    );
  }
}
