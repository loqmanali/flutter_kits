// =============================================================================
// AUTH GUARD
// =============================================================================
//
// This file provides authentication-related route guards.
// Guards are redirect functions that protect routes based on auth state.
//
// HOW IT WORKS:
// When a user tries to navigate to a route, the guard checks if they're
// authenticated. If not, it redirects them to the login page while
// preserving the original destination for redirect after login.
//
// USAGE:
// ```dart
// GoRouter(
//   redirect: AuthGuard.globalRedirect(
//     isAuthenticated: () => authService.isLoggedIn,
//     publicPaths: ['/login', '/register'],
//     loginPath: '/login',
//   ),
//   routes: [...],
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Typedef for authentication state provider
typedef AuthStateProvider = bool Function();

/// Typedef for redirect function
typedef RedirectFunction = String? Function(BuildContext context, GoRouterState state);

/// Authentication guard for protecting routes
///
/// This class provides static methods that return redirect functions
/// for use with GoRouter's redirect parameter.
class AuthGuard {
  AuthGuard._();

  // ============= GLOBAL REDIRECT =============

  /// Creates a global redirect function for authentication
  ///
  /// This redirect runs on EVERY navigation and handles:
  /// - Redirecting unauthenticated users away from protected routes
  /// - Redirecting authenticated users away from auth pages (login, register)
  /// - Preserving the intended destination for redirect after login
  ///
  /// Parameters:
  /// - [isAuthenticated]: Function that returns current auth state
  /// - [publicPaths]: List of paths that don't require authentication
  /// - [loginPath]: Path to the login screen
  /// - [homePath]: Path to redirect to after successful login (if no redirect param)
  /// - [preserveRedirectParam]: Whether to save the original path for redirect
  ///
  /// Example:
  /// ```dart
  /// GoRouter(
  ///   redirect: AuthGuard.globalRedirect(
  ///     isAuthenticated: () => authService.isLoggedIn,
  ///     publicPaths: ['/login', '/register', '/forgot-password'],
  ///     loginPath: '/login',
  ///     homePath: '/home',
  ///   ),
  ///   routes: [...],
  /// )
  /// ```
  static RedirectFunction globalRedirect({
    required AuthStateProvider isAuthenticated,
    required List<String> publicPaths,
    required String loginPath,
    String homePath = '/',
    bool preserveRedirectParam = true,
  }) {
    return (BuildContext context, GoRouterState state) {
      final isLoggedIn = isAuthenticated();
      final currentPath = state.matchedLocation;
      final fullPath = state.fullPath ?? state.matchedLocation;

      // Check if current path is public
      final isPublicPath = _isPublicPath(currentPath, publicPaths);

      // Check if user is on an auth page (login, register, etc.)
      final isOnAuthPage = _isAuthPage(currentPath, publicPaths);

      // Case 1: Not authenticated and trying to access protected route
      if (!isLoggedIn && !isPublicPath) {
        if (preserveRedirectParam) {
          // Encode the full path for redirect
          return '$loginPath?redirect=${Uri.encodeComponent(fullPath)}';
        }
        return loginPath;
      }

      // Case 2: Authenticated and trying to access auth page
      if (isLoggedIn && isOnAuthPage) {
        // Check if there's a redirect parameter
        final redirectParam = state.queryParameters['redirect'];
        if (redirectParam != null && redirectParam.isNotEmpty) {
          return Uri.decodeComponent(redirectParam);
        }
        return homePath;
      }

      // No redirect needed
      return null;
    };
  }

  // ============= ROUTE-LEVEL REDIRECT =============

  /// Creates a redirect function for a specific protected route
  ///
  /// Use this for route-level protection when you need different
  /// behavior than the global redirect.
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/admin',
  ///   redirect: AuthGuard.protectedRoute(
  ///     isAuthenticated: () => authService.isLoggedIn,
  ///     loginPath: '/login',
  ///   ),
  ///   builder: (context, state) => const AdminScreen(),
  /// )
  /// ```
  static RedirectFunction protectedRoute({
    required AuthStateProvider isAuthenticated,
    required String loginPath,
    bool preserveRedirectParam = true,
  }) {
    return (BuildContext context, GoRouterState state) {
      if (!isAuthenticated()) {
        if (preserveRedirectParam) {
          final fullPath = state.fullPath ?? state.matchedLocation;
          return '$loginPath?redirect=${Uri.encodeComponent(fullPath)}';
        }
        return loginPath;
      }
      return null;
    };
  }

  // ============= GUEST ONLY REDIRECT =============

  /// Creates a redirect for routes that should only be accessible to guests
  ///
  /// Use this for login/register pages to redirect authenticated users away.
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/login',
  ///   redirect: AuthGuard.guestOnly(
  ///     isAuthenticated: () => authService.isLoggedIn,
  ///     homePath: '/home',
  ///   ),
  ///   builder: (context, state) => const LoginScreen(),
  /// )
  /// ```
  static RedirectFunction guestOnly({
    required AuthStateProvider isAuthenticated,
    required String homePath,
  }) {
    return (BuildContext context, GoRouterState state) {
      if (isAuthenticated()) {
        // Check for redirect parameter
        final redirectParam = state.queryParameters['redirect'];
        if (redirectParam != null && redirectParam.isNotEmpty) {
          return Uri.decodeComponent(redirectParam);
        }
        return homePath;
      }
      return null;
    };
  }

  // ============= COMBINED REDIRECT =============

  /// Combines multiple redirect functions into one
  ///
  /// Executes redirects in order until one returns a non-null value.
  ///
  /// Example:
  /// ```dart
  /// GoRouter(
  ///   redirect: AuthGuard.combine([
  ///     AuthGuard.globalRedirect(...),
  ///     FeatureFlagGuard.redirect(...),
  ///     MaintenanceGuard.redirect(...),
  ///   ]),
  ///   routes: [...],
  /// )
  /// ```
  static RedirectFunction combine(List<RedirectFunction> redirects) {
    return (BuildContext context, GoRouterState state) {
      for (final redirect in redirects) {
        final result = redirect(context, state);
        if (result != null) return result;
      }
      return null;
    };
  }

  // ============= ASYNC REDIRECT =============

  /// Creates an async redirect for authentication checks that require async operations
  ///
  /// Note: GoRouter supports async redirects natively since v7.0.0
  ///
  /// Example:
  /// ```dart
  /// GoRouter(
  ///   redirect: AuthGuard.asyncGlobalRedirect(
  ///     isAuthenticated: () async => await authService.checkAuthStatus(),
  ///     publicPaths: ['/login'],
  ///     loginPath: '/login',
  ///   ),
  ///   routes: [...],
  /// )
  /// ```
  static Future<String?> Function(BuildContext, GoRouterState) asyncGlobalRedirect({
    required Future<bool> Function() isAuthenticated,
    required List<String> publicPaths,
    required String loginPath,
    String homePath = '/',
    bool preserveRedirectParam = true,
  }) {
    return (BuildContext context, GoRouterState state) async {
      final isLoggedIn = await isAuthenticated();
      final currentPath = state.matchedLocation;
      final fullPath = state.fullPath ?? state.matchedLocation;

      final isPublicPath = _isPublicPath(currentPath, publicPaths);
      final isOnAuthPage = _isAuthPage(currentPath, publicPaths);

      if (!isLoggedIn && !isPublicPath) {
        if (preserveRedirectParam) {
          return '$loginPath?redirect=${Uri.encodeComponent(fullPath)}';
        }
        return loginPath;
      }

      if (isLoggedIn && isOnAuthPage) {
        final redirectParam = state.queryParameters['redirect'];
        if (redirectParam != null && redirectParam.isNotEmpty) {
          return Uri.decodeComponent(redirectParam);
        }
        return homePath;
      }

      return null;
    };
  }

  // ============= HELPER METHODS =============

  /// Check if a path is in the public paths list
  static bool _isPublicPath(String path, List<String> publicPaths) {
    return publicPaths.any((publicPath) {
      if (path == publicPath) return true;
      // Check prefix match for sub-routes
      if (path.startsWith('$publicPath/')) return true;
      return false;
    });
  }

  /// Check if a path is an authentication page
  static bool _isAuthPage(String path, List<String> publicPaths) {
    // Auth pages are typically in the public paths
    // Common auth pages
    const authPaths = ['/login', '/register', '/forgot-password', '/reset-password'];
    return authPaths.any((authPath) => path == authPath || path.startsWith('$authPath/'));
  }
}

/// Extension to make it easier to use auth guards with GoRoute
extension AuthGuardExtension on GoRoute {
  /// Wrap this route with authentication protection
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/profile',
  ///   builder: (context, state) => const ProfileScreen(),
  /// ).protected(
  ///   isAuthenticated: () => authService.isLoggedIn,
  ///   loginPath: '/login',
  /// )
  /// ```
  GoRoute protected({
    required AuthStateProvider isAuthenticated,
    required String loginPath,
  }) {
    return GoRoute(
      path: path,
      name: name,
      redirect: AuthGuard.protectedRoute(
        isAuthenticated: isAuthenticated,
        loginPath: loginPath,
      ),
      builder: builder,
      pageBuilder: pageBuilder,
      routes: routes,
    );
  }
}
