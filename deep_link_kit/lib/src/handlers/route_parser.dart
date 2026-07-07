import '../adapters/deep_link_kit_runtime.dart';
import '../models/link_data.dart';

/// Parses raw deep-link strings into [LinkData].
///
/// Supports two formats:
/// - **Custom scheme**: `<scheme>://<type>/<id>?...` — e.g. `myapp://category/1`
/// - **Universal link**: `https://<host>/<type>/<id>?...` — e.g.
///   `https://example.com/product/42`
///
/// The set of recognised types ([LinkType.category], [LinkType.product], …)
/// is built in; anything else falls through to [LinkType.custom] with the
/// raw type string preserved on [LinkData.rawType].
class RouteParser {
  RouteParser._();

  /// Parse [link] into [LinkData]. Returns [LinkData.unknown] when the URL
  /// is malformed.
  static LinkData parseLink(String link) {
    try {
      final uri = Uri.parse(link);

      String type;
      String? id;

      if (_isCustomScheme(uri)) {
        // Custom scheme: host is the type, first path segment is the id.
        type = uri.host;
        id = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      } else {
        // HTTP/HTTPS: first path segment is type, second is id.
        final pathSegments = uri.pathSegments;
        if (pathSegments.isEmpty) {
          return LinkData.unknown();
        }
        type = pathSegments[0];
        id = pathSegments.length > 1 ? pathSegments[1] : null;
      }

      final params = uri.queryParameters;
      final paramMap = params.isNotEmpty ? params : null;
      final linkType = _resolveLinkType(type);

      // Preserve historic behaviour for the `search` type: when `?query=…`
      // is present, expose it as the id.
      if (linkType == LinkType.search) {
        return LinkData(
          type: LinkType.search,
          rawType: type,
          id: params['query'] ?? id,
          parameters: paramMap,
        );
      }

      return LinkData(
        type: linkType,
        rawType: type,
        id: id,
        parameters: paramMap,
      );
    } catch (_) {
      return LinkData.unknown();
    }
  }

  /// True if [link] matches one of the configured custom schemes or
  /// universal-link hosts on [DeepLinkKitRuntime].
  static bool isAppLink(String link) {
    if (DeepLinkKitRuntime.isEmpty) return false;
    try {
      final uri = Uri.parse(link);
      return _isCustomScheme(uri) || _isUniversalHost(uri);
    } catch (_) {
      return false;
    }
  }

  static bool _isCustomScheme(Uri uri) {
    return DeepLinkKitRuntime.customSchemes.contains(uri.scheme);
  }

  static bool _isUniversalHost(Uri uri) {
    final host = uri.host;
    if (host.isEmpty) return false;
    return DeepLinkKitRuntime.universalLinkHosts.contains(host);
  }

  static LinkType _resolveLinkType(String type) {
    switch (type) {
      case 'category':
        return LinkType.category;
      case 'product':
        return LinkType.product;
      case 'faq':
        return LinkType.faq;
      case 'form':
        return LinkType.form;
      case 'profile':
        return LinkType.profile;
      case 'orders':
        return LinkType.orders;
      case 'notifications':
        return LinkType.notifications;
      case 'search':
        return LinkType.search;
      default:
        return LinkType.custom;
    }
  }
}
