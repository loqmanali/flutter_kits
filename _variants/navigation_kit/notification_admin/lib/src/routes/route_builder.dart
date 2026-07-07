// =============================================================================
// ROUTE BUILDER
// =============================================================================
//
// This file provides helper functions for building common route patterns.
// Use these builders to create consistent, well-structured routes.
//
// FEATURES:
// - Quick route creation with sensible defaults
// - Sub-route helpers for nested navigation
// - Protected route wrappers
// - Common route patterns (detail, list, form, etc.)
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../adapters/navigator_key_registry.dart';
import '../guards/auth_guard.dart';

/// Helper class for building routes with common patterns
class RouteBuilder {
  RouteBuilder._();

  // ============= BASIC ROUTES =============

  /// Build a simple route
  ///
  /// Example:
  /// ```dart
  /// RouteBuilder.simple(
  ///   path: '/home',
  ///   name: 'home',
  ///   builder: (context, state) => const HomeScreen(),
  /// )
  /// ```
  static GoRoute simple({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      builder: builder,
      routes: routes,
    );
  }

  /// Build a full-screen route (outside any shell)
  ///
  /// Use for modals, checkout flows, or any screen that should
  /// hide the bottom navigation.
  ///
  /// Example:
  /// ```dart
  /// RouteBuilder.fullScreen(
  ///   path: '/checkout',
  ///   name: 'checkout',
  ///   builder: (context, state) => const CheckoutScreen(),
  /// )
  /// ```
  static GoRoute fullScreen({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<RouteBase> routes = const [],
    String? Function(BuildContext, GoRouterState)? redirect,
  }) {
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: NavigatorKeyRegistry.instance.rootKey,
      builder: builder,
      routes: routes,
      redirect: redirect,
    );
  }

  /// Build a protected route that requires authentication
  ///
  /// Example:
  /// ```dart
  /// RouteBuilder.protected(
  ///   path: '/profile',
  ///   builder: (context, state) => const ProfileScreen(),
  ///   isAuthenticated: () => authService.isLoggedIn,
  ///   loginPath: '/login',
  /// )
  /// ```
  static GoRoute protected({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    required bool Function() isAuthenticated,
    required String loginPath,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      redirect: AuthGuard.protectedRoute(
        isAuthenticated: isAuthenticated,
        loginPath: loginPath,
      ),
      builder: builder,
      routes: routes,
    );
  }

  // ============= DETAIL ROUTES =============

  /// Build a detail route with ID parameter
  ///
  /// Common pattern for viewing item details.
  ///
  /// Example:
  /// ```dart
  /// RouteBuilder.detail(
  ///   path: 'product/:id',  // Results in /products/product/:id
  ///   name: 'product-detail',
  ///   builder: (context, state) {
  ///     final id = state.pathParameters['id']!;
  ///     return ProductDetailScreen(id: id);
  ///   },
  /// )
  /// ```
  static GoRoute detail({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<RouteBase> routes = const [],
    bool fullScreen = false,
  }) {
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: fullScreen ? NavigatorKeyRegistry.instance.rootKey : null,
      builder: builder,
      routes: routes,
    );
  }

  /// Build a detail route that extracts ID and passes it to builder
  ///
  /// Convenience method that extracts the ID parameter automatically.
  ///
  /// Example:
  /// ```dart
  /// RouteBuilder.detailWithId(
  ///   basePath: '/products',
  ///   name: 'product-detail',
  ///   builder: (context, id) => ProductDetailScreen(id: id),
  /// )
  /// ```
  static GoRoute detailWithId({
    required String basePath,
    String idParam = 'id',
    String? name,
    required Widget Function(BuildContext, String id) builder,
    bool fullScreen = false,
  }) {
    return GoRoute(
      path: '$basePath/:$idParam',
      name: name,
      parentNavigatorKey: fullScreen ? NavigatorKeyRegistry.instance.rootKey : null,
      builder: (context, state) {
        final id = state.pathParameters[idParam] ?? '';
        return builder(context, id);
      },
    );
  }

  // ============= LIST-DETAIL PATTERN =============

  /// Build a list route with a nested detail route
  ///
  /// Common pattern for master-detail navigation.
  ///
  /// Example:
  /// ```dart
  /// RouteBuilder.listWithDetail(
  ///   listPath: '/products',
  ///   listBuilder: (context, state) => const ProductListScreen(),
  ///   detailPath: ':id',
  ///   detailBuilder: (context, state) {
  ///     final id = state.pathParameters['id']!;
  ///     return ProductDetailScreen(id: id);
  ///   },
  /// )
  /// ```
  static GoRoute listWithDetail({
    required String listPath,
    String? listName,
    required Widget Function(BuildContext, GoRouterState) listBuilder,
    required String detailPath,
    String? detailName,
    required Widget Function(BuildContext, GoRouterState) detailBuilder,
    bool detailFullScreen = false,
    List<RouteBase> additionalRoutes = const [],
  }) {
    return GoRoute(
      path: listPath,
      name: listName,
      builder: listBuilder,
      routes: [
        GoRoute(
          path: detailPath,
          name: detailName,
          parentNavigatorKey: detailFullScreen ? NavigatorKeyRegistry.instance.rootKey : null,
          builder: detailBuilder,
        ),
        ...additionalRoutes,
      ],
    );
  }

  // ============= REDIRECT ROUTES =============

  /// Build a redirect route
  ///
  /// Useful for legacy URLs or shortcuts.
  ///
  /// Example:
  /// ```dart
  /// RouteBuilder.redirect(
  ///   from: '/old-products',
  ///   to: '/products',
  /// )
  /// ```
  static GoRoute redirect({
    required String from,
    required String to,
    String? name,
  }) {
    return GoRoute(
      path: from,
      name: name,
      redirect: (_, __) => to,
    );
  }

  /// Build a conditional redirect route
  ///
  /// Example:
  /// ```dart
  /// RouteBuilder.conditionalRedirect(
  ///   path: '/',
  ///   condition: () => authService.isLoggedIn,
  ///   trueRedirect: '/home',
  ///   falseRedirect: '/login',
  /// )
  /// ```
  static GoRoute conditionalRedirect({
    required String path,
    String? name,
    required bool Function() condition,
    required String trueRedirect,
    required String falseRedirect,
  }) {
    return GoRoute(
      path: path,
      name: name,
      redirect: (_, __) => condition() ? trueRedirect : falseRedirect,
    );
  }

  // ============= WIZARD/FLOW ROUTES =============

  /// Build a multi-step flow (wizard) route
  ///
  /// Creates a parent route with sequential child steps.
  ///
  /// Example:
  /// ```dart
  /// RouteBuilder.flow(
  ///   basePath: '/checkout',
  ///   initialRedirect: '/checkout/cart',
  ///   steps: [
  ///     FlowStep(path: 'cart', builder: (_, __) => const CartStep()),
  ///     FlowStep(path: 'shipping', builder: (_, __) => const ShippingStep()),
  ///     FlowStep(path: 'payment', builder: (_, __) => const PaymentStep()),
  ///     FlowStep(path: 'confirm', builder: (_, __) => const ConfirmStep()),
  ///   ],
  /// )
  /// ```
  static GoRoute flow({
    required String basePath,
    String? name,
    required String initialRedirect,
    required List<FlowStep> steps,
    bool fullScreen = true,
  }) {
    return GoRoute(
      path: basePath,
      name: name,
      parentNavigatorKey: fullScreen ? NavigatorKeyRegistry.instance.rootKey : null,
      redirect: (context, state) {
        // If at base path, redirect to first step
        if (state.matchedLocation == basePath) {
          return initialRedirect;
        }
        return null;
      },
      routes: steps
          .map(
            (step) => GoRoute(
              path: step.path,
              name: step.name,
              builder: step.builder,
            ),
          )
          .toList(),
    );
  }

  // ============= TAB ROUTES =============

  /// Build routes for a tabbed section
  ///
  /// Example:
  /// ```dart
  /// RouteBuilder.tabbed(
  ///   basePath: '/profile',
  ///   tabs: [
  ///     TabRoute(path: 'posts', builder: (_, __) => const PostsTab()),
  ///     TabRoute(path: 'photos', builder: (_, __) => const PhotosTab()),
  ///     TabRoute(path: 'about', builder: (_, __) => const AboutTab()),
  ///   ],
  /// )
  /// ```
  static List<GoRoute> tabbed({
    required String basePath,
    required List<TabRoute> tabs,
  }) {
    return tabs
        .map(
          (tab) => GoRoute(
            path: '$basePath/${tab.path}',
            name: tab.name,
            builder: tab.builder,
            routes: tab.routes,
          ),
        )
        .toList();
  }
}

/// Configuration for a flow step
class FlowStep {
  const FlowStep({
    required this.path,
    this.name,
    required this.builder,
  });

  final String path;
  final String? name;
  final Widget Function(BuildContext, GoRouterState) builder;
}

/// Configuration for a tab route
class TabRoute {
  const TabRoute({
    required this.path,
    this.name,
    required this.builder,
    this.routes = const [],
  });

  final String path;
  final String? name;
  final Widget Function(BuildContext, GoRouterState) builder;
  final List<RouteBase> routes;
}

/// Extension for easy route chaining
extension GoRouteExtensions on GoRoute {
  /// Add sub-routes to this route
  GoRoute withRoutes(List<RouteBase> additionalRoutes) {
    return GoRoute(
      path: path,
      name: name,
      builder: builder,
      pageBuilder: pageBuilder,
      redirect: redirect,
      routes: [...routes, ...additionalRoutes],
    );
  }

  /// Add a redirect to this route
  GoRoute withRedirect(
      String? Function(BuildContext, GoRouterState) redirectFn,) {
    return GoRoute(
      path: path,
      name: name,
      builder: builder,
      pageBuilder: pageBuilder,
      redirect: redirectFn,
      routes: routes,
    );
  }

  /// Make this route full-screen (outside shell)
  GoRoute asFullScreen() {
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: NavigatorKeyRegistry.instance.rootKey,
      builder: builder,
      pageBuilder: pageBuilder,
      redirect: redirect,
      routes: routes,
    );
  }
}
