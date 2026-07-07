// =============================================================================
// GUEST GUARD
// =============================================================================
//
// This file provides guest mode route guards.
// Guest mode allows users to browse the app without logging in,
// while restricting access to certain features.
//
// USE CASES:
// - E-commerce apps: Let users browse products without login
// - Content apps: Let users read articles but restrict commenting
// - Social apps: Let users view public profiles but restrict messaging
//
// USAGE:
// ```dart
// GoRouter(
//   redirect: GuestGuard.redirect(
//     isAuthenticated: () => authService.isLoggedIn,
//     isGuest: () => guestService.isGuestMode,
//     guestAllowedPaths: ['/home', '/products', '/categories'],
//     loginPath: '/login',
//   ),
//   routes: [...],
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Typedef for guest state provider
typedef GuestStateProvider = bool Function();

/// Guest mode guard for controlling guest access to routes
///
/// Guest mode is different from unauthenticated:
/// - Unauthenticated: User hasn't logged in at all
/// - Guest mode: User explicitly chose to browse without logging in
class GuestGuard {
  GuestGuard._();

  // ============= MAIN REDIRECT =============

  /// Creates a redirect function for guest mode
  ///
  /// This handles three states:
  /// 1. Authenticated user: Full access
  /// 2. Guest user: Limited access based on allowedPaths
  /// 3. Unauthenticated (not guest): Redirect to login
  ///
  /// Parameters:
  /// - [isAuthenticated]: Function that returns if user is logged in
  /// - [isGuest]: Function that returns if user is in guest mode
  /// - [guestAllowedPaths]: Paths guests can access
  /// - [loginPath]: Path to login screen
  /// - [guestPromptPath]: Path to show when guest tries restricted content
  /// - [onRestrictedAccess]: Custom handler for restricted access
  ///
  /// Example:
  /// ```dart
  /// GoRouter(
  ///   redirect: GuestGuard.redirect(
  ///     isAuthenticated: () => authService.isLoggedIn,
  ///     isGuest: () => authService.isGuestMode,
  ///     guestAllowedPaths: [
  ///       '/home',
  ///       '/products',
  ///       '/categories',
  ///       '/search',
  ///     ],
  ///     loginPath: '/login',
  ///   ),
  ///   routes: [...],
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) redirect({
    required bool Function() isAuthenticated,
    required bool Function() isGuest,
    required List<String> guestAllowedPaths,
    required String loginPath,
    String? guestPromptPath,
    String? Function(String attemptedPath)? onRestrictedAccess,
  }) {
    return (BuildContext context, GoRouterState state) {
      final currentPath = state.matchedLocation;

      // Authenticated users have full access
      if (isAuthenticated()) {
        return null;
      }

      // Guest mode: check if path is allowed
      if (isGuest()) {
        final isAllowed = _isPathAllowed(currentPath, guestAllowedPaths);

        if (!isAllowed) {
          // Custom handler for restricted access
          if (onRestrictedAccess != null) {
            return onRestrictedAccess(currentPath);
          }

          // Default: show guest prompt or redirect to login
          if (guestPromptPath != null) {
            return '$guestPromptPath?from=${Uri.encodeComponent(currentPath)}';
          }
          return '$loginPath?redirect=${Uri.encodeComponent(currentPath)}';
        }

        return null; // Path is allowed for guest
      }

      // Not authenticated and not guest: redirect to login
      // (This case is typically handled by AuthGuard, but included for completeness)
      return '$loginPath?redirect=${Uri.encodeComponent(currentPath)}';
    };
  }

  // ============= ROUTE-LEVEL GUARD =============

  /// Creates a redirect for a specific route that's restricted for guests
  ///
  /// Use this for individual routes that need guest restriction.
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/checkout',
  ///   redirect: GuestGuard.restrictedForGuest(
  ///     isGuest: () => authService.isGuestMode,
  ///     redirectPath: '/guest-prompt',
  ///   ),
  ///   builder: (context, state) => const CheckoutScreen(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) restrictedForGuest({
    required bool Function() isGuest,
    required String redirectPath,
    bool includeFromParam = true,
  }) {
    return (BuildContext context, GoRouterState state) {
      if (isGuest()) {
        if (includeFromParam) {
          final fullPath = state.fullPath ?? state.matchedLocation;
          return '$redirectPath?from=${Uri.encodeComponent(fullPath)}';
        }
        return redirectPath;
      }
      return null;
    };
  }

  // ============= COMBINED AUTH + GUEST GUARD =============

  /// Creates a combined guard for both auth and guest mode
  ///
  /// This is the recommended approach for apps with guest mode.
  /// It handles all three states in one redirect function.
  ///
  /// Parameters:
  /// - [isAuthenticated]: Returns true if user is logged in
  /// - [isGuest]: Returns true if user is in guest mode
  /// - [publicPaths]: Paths accessible without any auth (login, register)
  /// - [guestAllowedPaths]: Paths guests can access
  /// - [loginPath]: Login screen path
  /// - [homePath]: Home screen path
  /// - [guestPromptPath]: Optional path to show guest upgrade prompt
  ///
  /// Example:
  /// ```dart
  /// GoRouter(
  ///   redirect: GuestGuard.combinedAuthAndGuestRedirect(
  ///     isAuthenticated: () => authService.isLoggedIn,
  ///     isGuest: () => authService.isGuestMode,
  ///     publicPaths: ['/login', '/register', '/onboarding'],
  ///     guestAllowedPaths: ['/home', '/products', '/categories'],
  ///     loginPath: '/login',
  ///     homePath: '/home',
  ///   ),
  ///   routes: [...],
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) combinedAuthAndGuestRedirect({
    required bool Function() isAuthenticated,
    required bool Function() isGuest,
    required List<String> publicPaths,
    required List<String> guestAllowedPaths,
    required String loginPath,
    required String homePath,
    String? guestPromptPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      final currentPath = state.matchedLocation;
      final fullPath = state.fullPath ?? state.matchedLocation;
      final isLoggedIn = isAuthenticated();
      final isGuestMode = isGuest();

      // Check if path is public
      final isPublicPath = _isPathAllowed(currentPath, publicPaths);

      // Case 1: Authenticated user
      if (isLoggedIn) {
        // Redirect away from auth pages
        if (_isAuthPage(currentPath)) {
          final redirect = state.queryParameters['redirect'];
          if (redirect != null && redirect.isNotEmpty) {
            return Uri.decodeComponent(redirect);
          }
          return homePath;
        }
        return null; // Full access
      }

      // Case 2: Guest mode
      if (isGuestMode) {
        // Allow access to public paths
        if (isPublicPath) return null;

        // Check guest-specific allowed paths
        final isGuestAllowed = _isPathAllowed(currentPath, guestAllowedPaths);
        if (isGuestAllowed) return null;

        // Restricted path for guest
        if (guestPromptPath != null) {
          return '$guestPromptPath?from=${Uri.encodeComponent(currentPath)}';
        }
        return '$loginPath?redirect=${Uri.encodeComponent(currentPath)}';
      }

      // Case 3: Not authenticated, not guest
      if (!isPublicPath) {
        return '$loginPath?redirect=${Uri.encodeComponent(fullPath)}';
      }

      return null;
    };
  }

  // ============= HELPER METHODS =============

  /// Check if a path matches any in the allowed list
  static bool _isPathAllowed(String path, List<String> allowedPaths) {
    return allowedPaths.any((allowed) {
      // Exact match
      if (path == allowed) return true;

      // Prefix match (e.g., '/products' allows '/products/123')
      if (path.startsWith('$allowed/')) return true;

      // Pattern match with parameters
      if (allowed.contains(':')) {
        return _matchPathWithParams(allowed, path);
      }

      return false;
    });
  }

  /// Match path with parameter patterns
  static bool _matchPathWithParams(String pattern, String path) {
    final patternSegments = pattern.split('/');
    final pathSegments = path.split('/');

    if (patternSegments.length > pathSegments.length) return false;

    for (var i = 0; i < patternSegments.length; i++) {
      final patternSegment = patternSegments[i];
      final pathSegment = pathSegments[i];

      // Parameter segment matches anything
      if (patternSegment.startsWith(':')) continue;

      // Must match exactly
      if (patternSegment != pathSegment) return false;
    }

    return true;
  }

  /// Check if path is an auth page
  static bool _isAuthPage(String path) {
    const authPaths = ['/login', '/register', '/forgot-password', '/reset-password'];
    return authPaths.any((authPath) => path == authPath || path.startsWith('$authPath/'));
  }
}

/// Configuration class for guest mode
///
/// Use this to configure guest mode behavior in your app.
class GuestModeConfiguration {
  const GuestModeConfiguration({
    required this.allowedPaths,
    this.restrictedPaths = const [],
    this.guestPromptPath,
    this.showUpgradePromptOnRestricted = true,
    this.allowedActions = const [],
  });

  /// Paths that guests can freely access
  final List<String> allowedPaths;

  /// Paths that are explicitly restricted (optional)
  /// If empty, all paths not in [allowedPaths] are restricted
  final List<String> restrictedPaths;

  /// Path to show upgrade/login prompt
  final String? guestPromptPath;

  /// Whether to show upgrade prompt when accessing restricted content
  final bool showUpgradePromptOnRestricted;

  /// Actions that guests can perform (e.g., 'view_product', 'add_to_cart')
  final List<String> allowedActions;

  /// Check if an action is allowed for guests
  bool isActionAllowed(String action) {
    if (allowedActions.isEmpty) return false;
    return allowedActions.contains(action);
  }

  /// Check if a path is allowed for guests
  bool isPathAllowed(String path) {
    // If explicitly restricted, return false
    if (restrictedPaths.isNotEmpty) {
      if (GuestGuard._isPathAllowed(path, restrictedPaths)) {
        return false;
      }
    }

    // Check allowed paths
    return GuestGuard._isPathAllowed(path, allowedPaths);
  }
}
