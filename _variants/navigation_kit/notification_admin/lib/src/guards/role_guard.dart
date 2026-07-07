// =============================================================================
// ROLE GUARD
// =============================================================================
//
// This file provides role-based access control (RBAC) for routes.
// Use this when different user types have access to different parts of the app.
//
// USE CASES:
// - Admin panels: Only admins can access
// - Premium features: Only premium users can access
// - Staff sections: Only staff members can access
// - Verified users: Only verified users can access certain features
//
// USAGE:
// ```dart
// GoRoute(
//   path: '/admin',
//   redirect: RoleGuard.requireRole(
//     getCurrentUserRole: () => authService.currentUser?.role,
//     allowedRoles: ['admin', 'super_admin'],
//     unauthorizedPath: '/unauthorized',
//   ),
//   builder: (context, state) => const AdminScreen(),
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// User model interface for role-based access
///
/// Your user model should implement or extend this
abstract class RoleBasedUser {
  String? get role;
  List<String> get permissions;
  bool get isVerified;
  bool get isPremium;
}

/// Role guard for role-based access control
class RoleGuard {
  RoleGuard._();

  // ============= ROLE-BASED REDIRECT =============

  /// Creates a redirect that requires specific role(s)
  ///
  /// Parameters:
  /// - [getCurrentUserRole]: Function to get current user's role
  /// - [allowedRoles]: List of roles that can access the route
  /// - [unauthorizedPath]: Path to redirect if role not allowed
  /// - [loginPath]: Path to redirect if not authenticated
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/admin/dashboard',
  ///   redirect: RoleGuard.requireRole(
  ///     getCurrentUserRole: () => authService.currentUser?.role,
  ///     allowedRoles: ['admin', 'moderator'],
  ///     unauthorizedPath: '/unauthorized',
  ///   ),
  ///   builder: (context, state) => const AdminDashboard(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) requireRole({
    required String? Function() getCurrentUserRole,
    required List<String> allowedRoles,
    required String unauthorizedPath,
    String? loginPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      final userRole = getCurrentUserRole();
      final fullPath = state.fullPath ?? state.matchedLocation;

      // Not authenticated
      if (userRole == null) {
        if (loginPath != null) {
          return '$loginPath?redirect=${Uri.encodeComponent(fullPath)}';
        }
        return unauthorizedPath;
      }

      // Check if user has required role
      if (!allowedRoles.contains(userRole)) {
        return unauthorizedPath;
      }

      return null; // Access granted
    };
  }

  // ============= PERMISSION-BASED REDIRECT =============

  /// Creates a redirect that requires specific permission(s)
  ///
  /// This is more granular than role-based access.
  /// A user can have multiple permissions regardless of their role.
  ///
  /// Parameters:
  /// - [getCurrentUserPermissions]: Function to get user's permissions
  /// - [requiredPermissions]: Permissions needed (ALL must be present)
  /// - [anyPermission]: If true, ANY permission is sufficient
  /// - [unauthorizedPath]: Path to redirect if permission denied
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/admin/users',
  ///   redirect: RoleGuard.requirePermission(
  ///     getCurrentUserPermissions: () => authService.currentUser?.permissions ?? [],
  ///     requiredPermissions: ['manage_users'],
  ///     unauthorizedPath: '/admin',
  ///   ),
  ///   builder: (context, state) => const ManageUsersScreen(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) requirePermission({
    required List<String> Function() getCurrentUserPermissions,
    required List<String> requiredPermissions,
    bool anyPermission = false,
    required String unauthorizedPath,
    String? loginPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      final userPermissions = getCurrentUserPermissions();
      final fullPath = state.fullPath ?? state.matchedLocation;

      // No permissions = not authenticated or no roles assigned
      if (userPermissions.isEmpty && requiredPermissions.isNotEmpty) {
        if (loginPath != null) {
          return '$loginPath?redirect=${Uri.encodeComponent(fullPath)}';
        }
        return unauthorizedPath;
      }

      // Check permissions
      bool hasPermission;
      if (anyPermission) {
        // User needs ANY of the required permissions
        hasPermission = requiredPermissions.any(
          (perm) => userPermissions.contains(perm),
        );
      } else {
        // User needs ALL required permissions
        hasPermission = requiredPermissions.every(
          (perm) => userPermissions.contains(perm),
        );
      }

      if (!hasPermission) {
        return unauthorizedPath;
      }

      return null; // Access granted
    };
  }

  // ============= VERIFIED USER REDIRECT =============

  /// Creates a redirect that requires user to be verified
  ///
  /// Use this for features that require email/phone verification.
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/send-message',
  ///   redirect: RoleGuard.requireVerified(
  ///     isUserVerified: () => authService.currentUser?.isVerified ?? false,
  ///     verificationPath: '/verify-email',
  ///   ),
  ///   builder: (context, state) => const SendMessageScreen(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) requireVerified({
    required bool Function() isUserVerified,
    required String verificationPath,
    String? loginPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      final fullPath = state.fullPath ?? state.matchedLocation;
      try {
        final isVerified = isUserVerified();
        if (!isVerified) {
          return '$verificationPath?redirect=${Uri.encodeComponent(fullPath)}';
        }
        return null;
      } catch (_) {
        // User might not be logged in
        if (loginPath != null) {
          return '$loginPath?redirect=${Uri.encodeComponent(fullPath)}';
        }
        return verificationPath;
      }
    };
  }

  // ============= PREMIUM USER REDIRECT =============

  /// Creates a redirect that requires premium/paid subscription
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/premium-content',
  ///   redirect: RoleGuard.requirePremium(
  ///     isUserPremium: () => subscriptionService.isPremium,
  ///     upgradePath: '/upgrade',
  ///   ),
  ///   builder: (context, state) => const PremiumContentScreen(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) requirePremium({
    required bool Function() isUserPremium,
    required String upgradePath,
    String? loginPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      final fullPath = state.fullPath ?? state.matchedLocation;
      try {
        final isPremium = isUserPremium();
        if (!isPremium) {
          return '$upgradePath?from=${Uri.encodeComponent(fullPath)}';
        }
        return null;
      } catch (_) {
        if (loginPath != null) {
          return '$loginPath?redirect=${Uri.encodeComponent(fullPath)}';
        }
        return upgradePath;
      }
    };
  }

  // ============= COMBINED GUARDS =============

  /// Combines role and permission checks
  ///
  /// User must have the required role AND permissions.
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/admin/settings',
  ///   redirect: RoleGuard.requireRoleAndPermission(
  ///     getCurrentUserRole: () => authService.currentUser?.role,
  ///     getCurrentUserPermissions: () => authService.currentUser?.permissions ?? [],
  ///     allowedRoles: ['admin'],
  ///     requiredPermissions: ['edit_settings'],
  ///     unauthorizedPath: '/admin',
  ///   ),
  ///   builder: (context, state) => const AdminSettingsScreen(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) requireRoleAndPermission({
    required String? Function() getCurrentUserRole,
    required List<String> Function() getCurrentUserPermissions,
    required List<String> allowedRoles,
    required List<String> requiredPermissions,
    required String unauthorizedPath,
    String? loginPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      final userRole = getCurrentUserRole();
      final userPermissions = getCurrentUserPermissions();
      final fullPath = state.fullPath ?? state.matchedLocation;

      // Not authenticated
      if (userRole == null) {
        if (loginPath != null) {
          return '$loginPath?redirect=${Uri.encodeComponent(fullPath)}';
        }
        return unauthorizedPath;
      }

      // Check role
      if (!allowedRoles.contains(userRole)) {
        return unauthorizedPath;
      }

      // Check permissions
      final hasAllPermissions = requiredPermissions.every(
        (perm) => userPermissions.contains(perm),
      );
      if (!hasAllPermissions) {
        return unauthorizedPath;
      }

      return null; // Access granted
    };
  }

  // ============= HIERARCHY-BASED REDIRECT =============

  /// Creates a redirect based on role hierarchy
  ///
  /// Higher roles automatically have access to lower role routes.
  /// Define hierarchy as: ['user', 'moderator', 'admin', 'super_admin']
  /// An admin can access moderator routes, but not vice versa.
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/moderator-panel',
  ///   redirect: RoleGuard.requireMinimumRole(
  ///     getCurrentUserRole: () => authService.currentUser?.role,
  ///     minimumRole: 'moderator',
  ///     roleHierarchy: ['user', 'moderator', 'admin', 'super_admin'],
  ///     unauthorizedPath: '/unauthorized',
  ///   ),
  ///   builder: (context, state) => const ModeratorPanel(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) requireMinimumRole({
    required String? Function() getCurrentUserRole,
    required String minimumRole,
    required List<String> roleHierarchy,
    required String unauthorizedPath,
    String? loginPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      final userRole = getCurrentUserRole();
      final fullPath = state.fullPath ?? state.matchedLocation;

      // Not authenticated
      if (userRole == null) {
        if (loginPath != null) {
          return '$loginPath?redirect=${Uri.encodeComponent(fullPath)}';
        }
        return unauthorizedPath;
      }

      final userRoleIndex = roleHierarchy.indexOf(userRole);
      final requiredRoleIndex = roleHierarchy.indexOf(minimumRole);

      // Unknown role
      if (userRoleIndex == -1) {
        return unauthorizedPath;
      }

      // User role is lower than required
      if (userRoleIndex < requiredRoleIndex) {
        return unauthorizedPath;
      }

      return null; // Access granted
    };
  }
}

/// Common role constants
///
/// Use these for consistency across your app
abstract class CommonRoles {
  CommonRoles._();

  static const String guest = 'guest';
  static const String user = 'user';
  static const String premium = 'premium';
  static const String moderator = 'moderator';
  static const String admin = 'admin';
  static const String superAdmin = 'super_admin';

  /// Default role hierarchy (lowest to highest)
  static const List<String> defaultHierarchy = [
    guest,
    user,
    premium,
    moderator,
    admin,
    superAdmin,
  ];
}

/// Common permission constants
abstract class CommonPermissions {
  CommonPermissions._();

  // User management
  static const String viewUsers = 'view_users';
  static const String createUsers = 'create_users';
  static const String editUsers = 'edit_users';
  static const String deleteUsers = 'delete_users';

  // Content management
  static const String viewContent = 'view_content';
  static const String createContent = 'create_content';
  static const String editContent = 'edit_content';
  static const String deleteContent = 'delete_content';

  // System
  static const String viewSettings = 'view_settings';
  static const String editSettings = 'edit_settings';
  static const String viewAnalytics = 'view_analytics';
  static const String manageRoles = 'manage_roles';
}
