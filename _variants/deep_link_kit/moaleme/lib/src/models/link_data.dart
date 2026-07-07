/// Common link types recognised out of the box.
///
/// The set covers the typical e-commerce / utility surfaces (category,
/// product, FAQ, profile, etc.). Apps that need additional types can use the
/// [LinkType.custom] case and inspect [LinkData.rawType] for the raw value
/// parsed from the URL.
enum LinkType {
  category,
  product,
  faq,
  form,
  profile,
  orders,
  notifications,
  search,

  /// The link's first path segment / host didn't map to one of the known
  /// types. Use [LinkData.rawType] to read the original string.
  custom,

  /// The link couldn't be parsed at all (invalid URI, empty path, etc.).
  unknown,
}

/// Structured representation of a parsed deep link.
class LinkData {
  LinkData({
    required this.type,
    this.rawType,
    this.id,
    this.parameters,
  });

  /// Recognised type. [LinkType.custom] means the kit didn't have a built-in
  /// mapping for [rawType]; the host app can still route on [rawType].
  final LinkType type;

  /// Raw type string parsed from the URL (always set when the URL is valid;
  /// `null` for [LinkType.unknown]).
  final String? rawType;

  /// Resource id (e.g. category id, product id) — `null` if absent.
  final String? id;

  /// Query parameters from the URL — `null` when there are none.
  final Map<String, dynamic>? parameters;

  factory LinkData.unknown() => LinkData(type: LinkType.unknown);

  @override
  String toString() =>
      'LinkData(type: $type, rawType: $rawType, id: $id, params: $parameters)';
}
