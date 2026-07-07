// =============================================================================
// NAVIGATION EXTENSIONS
// =============================================================================
//
// This file provides extension methods for easier navigation operations.
// These extensions make common navigation patterns more concise and readable.
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension methods for BuildContext to simplify navigation
extension NavigationExtensions on BuildContext {
  // ============= BASIC NAVIGATION =============

  /// Navigate to a path, clearing the navigation stack
  ///
  /// Example:
  /// ```dart
  /// context.goTo('/home');
  /// ```
  void goTo(String path) => go(path);

  /// Navigate to a path, adding to the navigation stack
  ///
  /// Example:
  /// ```dart
  /// context.pushTo('/details/123');
  /// ```
  void pushTo(String path) => push(path);

  /// Navigate to a path and wait for a result
  ///
  /// Example:
  /// ```dart
  /// final result = await context.pushForResult<bool>('/confirm');
  /// if (result == true) {
  ///   // Handle confirmation
  /// }
  /// ```
  Future<T?> pushForResult<T>(String path, {Object? extra}) {
    return push<T>(path, extra: extra);
  }

  /// Go back to the previous route
  ///
  /// Example:
  /// ```dart
  /// context.goBack();
  /// ```
  void goBack() {
    if (canPop()) {
      pop();
    }
  }

  /// Go back with a result
  ///
  /// Example:
  /// ```dart
  /// context.goBackWith(true);
  /// ```
  void goBackWith<T>(T result) => pop(result);

  /// Check if can navigate back
  bool get canNavigateBack => canPop();

  // ============= NAMED NAVIGATION =============

  /// Navigate to a named route
  ///
  /// Example:
  /// ```dart
  /// context.goToNamed('product-detail', pathParameters: {'id': '123'});
  /// ```
  void goToNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Push a named route
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  // ============= CONVENIENCE METHODS =============

  /// Navigate to home
  ///
  /// Example:
  /// ```dart
  /// context.goHome();
  /// ```
  void goHome([String homePath = '/home']) => go(homePath);

  /// Navigate to login
  void goToLogin([String loginPath = '/login']) => go(loginPath);

  /// Navigate to login with redirect back
  ///
  /// Example:
  /// ```dart
  /// context.goToLoginWithRedirect('/protected-page');
  /// ```
  void goToLoginWithRedirect(String redirectPath, [String loginPath = '/login']) {
    go('$loginPath?redirect=${Uri.encodeComponent(redirectPath)}');
  }

  /// Push a detail page with ID
  ///
  /// Example:
  /// ```dart
  /// context.pushDetail('/products', '123');
  /// // Navigates to /products/123
  /// ```
  void pushDetail(String basePath, String id) {
    push('$basePath/$id');
  }

  /// Navigate with query parameters
  ///
  /// Example:
  /// ```dart
  /// context.goWithQuery('/search', {'q': 'flutter', 'category': 'tutorials'});
  /// // Navigates to /search?q=flutter&category=tutorials
  /// ```
  void goWithQuery(String path, Map<String, String> queryParams) {
    if (queryParams.isEmpty) {
      go(path);
      return;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    go('$path?$queryString');
  }

  /// Replace current route
  ///
  /// Example:
  /// ```dart
  /// context.replaceTo('/new-route');
  /// ```
  void replaceTo(String path) => pushReplacement(path);

  // ============= MODAL NAVIGATION =============

  /// Show a confirmation dialog route and wait for result
  ///
  /// Example:
  /// ```dart
  /// final confirmed = await context.showConfirmationRoute('/confirm-delete');
  /// if (confirmed) {
  ///   // Delete item
  /// }
  /// ```
  Future<bool> showConfirmationRoute(String path) async {
    final result = await push<bool>(path);
    return result ?? false;
  }

  // ============= STATE ACCESS =============

  /// Get the current route location
  ///
  /// Example:
  /// ```dart
  /// final currentPath = context.currentLocation;
  /// ```
  String get currentLocation {
    return GoRouterState.of(this).matchedLocation;
  }

  /// Get the full path including query parameters
  String get fullPath {
    final state = GoRouterState.of(this);
    return state.fullPath ?? state.matchedLocation;
  }

  /// Get the current route name
  String? get currentRouteName {
    return GoRouterState.of(this).name;
  }

  /// Get path parameters from current route
  Map<String, String> get pathParams {
    return GoRouterState.of(this).pathParameters;
  }

  /// Get query parameters from current route
  Map<String, String> get queryParams {
    return GoRouterState.of(this).queryParameters;
  }

  /// Get extra data passed to current route
  Object? get routeExtra {
    return GoRouterState.of(this).extra;
  }

  /// Get typed extra data
  ///
  /// Example:
  /// ```dart
  /// final product = context.getExtra<Product>();
  /// ```
  T? getExtra<T>() {
    final extra = GoRouterState.of(this).extra;
    if (extra is T) return extra;
    return null;
  }

  /// Get a path parameter by key
  ///
  /// Example:
  /// ```dart
  /// final productId = context.getPathParam('id');
  /// ```
  String? getPathParam(String key) {
    return GoRouterState.of(this).pathParameters[key];
  }

  /// Get a query parameter by key
  ///
  /// Example:
  /// ```dart
  /// final searchQuery = context.getQueryParam('q');
  /// ```
  String? getQueryParam(String key) {
    return GoRouterState.of(this).queryParameters[key];
  }
}

/// Extension methods for GoRouter
extension GoRouterExtensions on GoRouter {
  /// Navigate to a path if not already there
  ///
  /// Example:
  /// ```dart
  /// router.goIfNotCurrent('/home');
  /// ```
  void goIfNotCurrent(String path) {
    final currentPath = routerDelegate.currentConfiguration.fullPath;
    if (currentPath != path) {
      go(path);
    }
  }

  /// Get the current full path
  String get currentPath {
    return routerDelegate.currentConfiguration.fullPath;
  }

  /// Check if currently at a specific path
  bool isAt(String path) {
    return currentPath == path;
  }

  /// Check if current path starts with a given prefix
  bool isUnder(String pathPrefix) {
    return currentPath.startsWith(pathPrefix);
  }
}

/// Extension for easy navigation from widgets
extension NavigatorExtensions on NavigatorState {
  /// Pop until reaching a specific route
  ///
  /// Example:
  /// ```dart
  /// Navigator.of(context).popUntilNamed('/home');
  /// ```
  void popUntilNamed(String routeName) {
    popUntil((route) => route.settings.name == routeName);
  }

  /// Pop all routes and push a new one
  void popAllAndPush(String routeName) {
    popUntil((route) => false);
    pushNamed(routeName);
  }
}

/// Mixin for widgets that need navigation capabilities
///
/// Usage:
/// ```dart
/// class MyWidget extends StatefulWidget with NavigationMixin {
///   // ...
/// }
/// ```
mixin NavigationMixin<T extends StatefulWidget> on State<T> {
  /// Navigate to a path
  void navigateTo(String path) => context.go(path);

  /// Push a path
  void pushRoute(String path) => context.push(path);

  /// Go back
  void goBack() {
    if (context.canPop()) {
      context.pop();
    }
  }

  /// Get current location
  String get currentLocation => context.currentLocation;
}
