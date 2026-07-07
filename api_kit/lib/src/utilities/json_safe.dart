/// Safe JSON parsing helpers.
///
/// Use these instead of raw `as` casts in `fromJson` methods. They never
/// throw a type-cast error regardless of what the API returns.
abstract final class JsonSafe {
  static List<dynamic> asList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value;
    if (value is Map) {
      return value.entries
          .map((e) => <String, dynamic>{'key': e.key, 'value': e.value})
          .toList();
    }
    return const [];
  }

  static List<Map<String, dynamic>> asListMapped(
    dynamic value,
    Map<String, dynamic> Function(dynamic key, dynamic value) mapper,
  ) {
    if (value == null) return const [];
    if (value is List) return value.cast<Map<String, dynamic>>();
    if (value is Map) {
      return value.entries.map((e) => mapper(e.key, e.value)).toList();
    }
    return const [];
  }

  static String asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  static int asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static double asDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static bool asBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value == 'true' || value == '1';
    return fallback;
  }

  static Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return const {};
  }

  static DateTime? asDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
