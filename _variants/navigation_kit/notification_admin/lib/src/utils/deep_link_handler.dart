// =============================================================================
// DEEP LINK HANDLER
// =============================================================================
//
// This file provides utilities for handling deep links in your app.
// Deep links allow users to navigate directly to specific content from
// outside the app (notifications, emails, social media, etc.).
//
// FEATURES:
// - URL parsing and validation
// - Parameter extraction
// - Route mapping from deep links
// - Deep link analytics
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Configuration for a deep link pattern
class DeepLinkPattern {
  const DeepLinkPattern({
    required this.pattern,
    required this.routePath,
    this.parameterMapping,
    this.queryParameterMapping,
    this.onMatch,
  });

  /// URL pattern to match (e.g., 'product/:id')
  /// Supports path parameters like :id, :slug
  final String pattern;

  /// App route path to navigate to
  final String routePath;

  /// Map deep link parameters to route parameters
  /// e.g., {'productId': 'id'} maps ?productId=123 to :id
  final Map<String, String>? parameterMapping;

  /// Map query parameters from deep link to route
  final Map<String, String>? queryParameterMapping;

  /// Callback when this pattern is matched
  final void Function(Map<String, String> parameters)? onMatch;
}

/// Handler for processing deep links
class DeepLinkHandler {
  DeepLinkHandler({
    required this.patterns,
    this.defaultPath = '/',
    this.onUnknownLink,
    this.onDeepLinkReceived,
    this.hosts = const [],
  });

  /// List of supported deep link patterns
  final List<DeepLinkPattern> patterns;

  /// Default path when no pattern matches
  final String defaultPath;

  /// Callback for unknown deep links
  final String? Function(Uri uri)? onUnknownLink;

  /// Callback when any deep link is received (for analytics)
  final void Function(Uri uri, String? matchedRoute)? onDeepLinkReceived;

  /// Allowed hosts for deep links (empty = all hosts allowed)
  final List<String> hosts;

  /// Process a deep link URI and return the app route
  ///
  /// Returns the route path to navigate to, or null if invalid.
  ///
  /// Example:
  /// ```dart
  /// final handler = DeepLinkHandler(patterns: [...]);
  /// final route = handler.processDeepLink(Uri.parse('myapp://product/123'));
  /// if (route != null) {
  ///   context.go(route);
  /// }
  /// ```
  String? processDeepLink(Uri uri) {
    // Validate host if hosts are specified
    if (hosts.isNotEmpty && !hosts.contains(uri.host)) {
      onDeepLinkReceived?.call(uri, null);
      return onUnknownLink?.call(uri) ?? defaultPath;
    }

    final path = uri.path;
    final queryParams = uri.queryParameters;

    // Try to match patterns
    for (final pattern in patterns) {
      final match = _matchPattern(pattern.pattern, path);
      if (match != null) {
        // Build route path with parameters
        final route = _buildRoute(
          pattern,
          match,
          queryParams,
        );

        // Notify callbacks
        pattern.onMatch?.call(match);
        onDeepLinkReceived?.call(uri, route);

        return route;
      }
    }

    // No pattern matched
    onDeepLinkReceived?.call(uri, null);
    return onUnknownLink?.call(uri) ?? defaultPath;
  }

  /// Match a path against a pattern and extract parameters
  Map<String, String>? _matchPattern(String pattern, String path) {
    final patternSegments = pattern.split('/').where((s) => s.isNotEmpty).toList();
    final pathSegments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (patternSegments.length != pathSegments.length) {
      return null;
    }

    final parameters = <String, String>{};

    for (var i = 0; i < patternSegments.length; i++) {
      final patternSegment = patternSegments[i];
      final pathSegment = pathSegments[i];

      if (patternSegment.startsWith(':')) {
        // This is a parameter
        final paramName = patternSegment.substring(1);
        parameters[paramName] = pathSegment;
      } else if (patternSegment != pathSegment) {
        // Segments don't match
        return null;
      }
    }

    return parameters;
  }

  /// Build the route path with parameters
  String _buildRoute(
    DeepLinkPattern pattern,
    Map<String, String> pathParams,
    Map<String, String> queryParams,
  ) {
    var route = pattern.routePath;

    // Replace path parameters
    pathParams.forEach((key, value) {
      route = route.replaceAll(':$key', value);
    });

    // Apply parameter mapping if specified
    if (pattern.parameterMapping != null) {
      pattern.parameterMapping!.forEach((deepLinkParam, routeParam) {
        if (queryParams.containsKey(deepLinkParam)) {
          route = route.replaceAll(':$routeParam', queryParams[deepLinkParam]!);
        }
      });
    }

    // Build query string if needed
    final routeQueryParams = <String, String>{};

    if (pattern.queryParameterMapping != null) {
      pattern.queryParameterMapping!.forEach((deepLinkParam, routeParam) {
        if (queryParams.containsKey(deepLinkParam)) {
          routeQueryParams[routeParam] = queryParams[deepLinkParam]!;
        }
      });
    }

    if (routeQueryParams.isNotEmpty) {
      final queryString = routeQueryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      route = '$route?$queryString';
    }

    return route;
  }
}

/// A widget that handles deep links on app start
///
/// Wrap your MaterialApp.router with this to handle initial deep links.
///
/// Usage:
/// ```dart
/// DeepLinkWrapper(
///   handler: deepLinkHandler,
///   child: MaterialApp.router(
///     routerConfig: router,
///   ),
/// )
/// ```
class DeepLinkWrapper extends StatefulWidget {
  const DeepLinkWrapper({
    super.key,
    required this.handler,
    required this.child,
    this.onDeepLinkError,
  });

  final DeepLinkHandler handler;
  final Widget child;
  final void Function(Object error, StackTrace stackTrace)? onDeepLinkError;

  @override
  State<DeepLinkWrapper> createState() => _DeepLinkWrapperState();
}

class _DeepLinkWrapperState extends State<DeepLinkWrapper> {
  @override
  void initState() {
    super.initState();
    _handleInitialDeepLink();
  }

  Future<void> _handleInitialDeepLink() async {
    // Note: In a real app, you would use app_links or uni_links package
    // to get the initial deep link. This is just a placeholder.
    // Example with app_links:
    // final appLinks = AppLinks();
    // final initialLink = await appLinks.getInitialAppLink();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension for easy deep link handling with GoRouter
extension DeepLinkExtension on BuildContext {
  /// Navigate to a deep link
  void handleDeepLink(Uri uri, DeepLinkHandler handler) {
    final route = handler.processDeepLink(uri);
    if (route != null) {
      go(route);
    }
  }
}

/// Common deep link patterns for reference
class CommonDeepLinkPatterns {
  CommonDeepLinkPatterns._();

  /// Product detail pattern
  /// Matches: /product/123, /product/abc-slug
  static DeepLinkPattern product({
    String routePath = '/products/:id',
    void Function(Map<String, String>)? onMatch,
  }) {
    return DeepLinkPattern(
      pattern: 'product/:id',
      routePath: routePath,
      onMatch: onMatch,
    );
  }

  /// Category pattern
  /// Matches: /category/electronics, /category/123
  static DeepLinkPattern category({
    String routePath = '/categories/:id',
    void Function(Map<String, String>)? onMatch,
  }) {
    return DeepLinkPattern(
      pattern: 'category/:id',
      routePath: routePath,
      onMatch: onMatch,
    );
  }

  /// User profile pattern
  /// Matches: /user/johndoe, /profile/123
  static DeepLinkPattern profile({
    String pattern = 'user/:id',
    String routePath = '/profile/:id',
    void Function(Map<String, String>)? onMatch,
  }) {
    return DeepLinkPattern(
      pattern: pattern,
      routePath: routePath,
      onMatch: onMatch,
    );
  }

  /// Search pattern
  /// Matches: /search?q=keyword
  static DeepLinkPattern search({
    String routePath = '/search',
    void Function(Map<String, String>)? onMatch,
  }) {
    return DeepLinkPattern(
      pattern: 'search',
      routePath: routePath,
      queryParameterMapping: {'q': 'q', 'query': 'q'},
      onMatch: onMatch,
    );
  }

  /// Order detail pattern
  /// Matches: /order/ORD-12345
  static DeepLinkPattern order({
    String routePath = '/orders/:id',
    void Function(Map<String, String>)? onMatch,
  }) {
    return DeepLinkPattern(
      pattern: 'order/:id',
      routePath: routePath,
      onMatch: onMatch,
    );
  }

  /// Promo/referral pattern
  /// Matches: /promo/SAVE20, /referral/ABC123
  static DeepLinkPattern promo({
    String pattern = 'promo/:code',
    String routePath = '/',
    void Function(Map<String, String>)? onMatch,
  }) {
    return DeepLinkPattern(
      pattern: pattern,
      routePath: routePath,
      onMatch: onMatch,
    );
  }
}
