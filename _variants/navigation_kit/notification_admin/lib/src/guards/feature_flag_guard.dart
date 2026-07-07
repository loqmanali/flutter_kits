// =============================================================================
// FEATURE FLAG GUARD
// =============================================================================
//
// This file provides feature flag-based route guards.
// Use this to control access to features based on feature flags,
// A/B tests, or gradual rollouts.
//
// USE CASES:
// - Feature toggles: Enable/disable features without deployment
// - A/B testing: Show different features to different users
// - Gradual rollout: Roll out features to a percentage of users
// - Beta features: Show features only to beta testers
// - Maintenance mode: Temporarily disable certain features
//
// USAGE:
// ```dart
// GoRoute(
//   path: '/new-feature',
//   redirect: FeatureFlagGuard.requireFeature(
//     isFeatureEnabled: () => featureFlagService.isEnabled('new_feature'),
//     fallbackPath: '/home',
//   ),
//   builder: (context, state) => const NewFeatureScreen(),
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Feature flag guard for controlling access based on feature flags
class FeatureFlagGuard {
  FeatureFlagGuard._();

  // ============= SINGLE FEATURE CHECK =============

  /// Creates a redirect that requires a specific feature to be enabled
  ///
  /// Parameters:
  /// - [isFeatureEnabled]: Function that checks if feature is enabled
  /// - [fallbackPath]: Path to redirect if feature is disabled
  /// - [showComingSoon]: If true, redirect to a "coming soon" page
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/chat',
  ///   redirect: FeatureFlagGuard.requireFeature(
  ///     isFeatureEnabled: () => featureFlags.isEnabled('chat_feature'),
  ///     fallbackPath: '/home',
  ///   ),
  ///   builder: (context, state) => const ChatScreen(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) requireFeature({
    required bool Function() isFeatureEnabled,
    required String fallbackPath,
    String? comingSoonPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      if (!isFeatureEnabled()) {
        if (comingSoonPath != null) {
          return '$comingSoonPath?feature=${Uri.encodeComponent(state.matchedLocation)}';
        }
        return fallbackPath;
      }
      return null;
    };
  }

  // ============= NAMED FEATURE CHECK =============

  /// Creates a redirect that requires a named feature flag
  ///
  /// This version takes the feature flag service and flag name,
  /// making it more reusable.
  ///
  /// Parameters:
  /// - [getFeatureFlag]: Function to get a feature flag by name
  /// - [featureName]: Name of the feature flag to check
  /// - [fallbackPath]: Path to redirect if feature is disabled
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/ar-preview',
  ///   redirect: FeatureFlagGuard.requireNamedFeature(
  ///     getFeatureFlag: (name) => featureFlags.isEnabled(name),
  ///     featureName: 'ar_preview',
  ///     fallbackPath: '/products',
  ///   ),
  ///   builder: (context, state) => const ARPreviewScreen(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) requireNamedFeature({
    required bool Function(String featureName) getFeatureFlag,
    required String featureName,
    required String fallbackPath,
    String? comingSoonPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      if (!getFeatureFlag(featureName)) {
        if (comingSoonPath != null) {
          return '$comingSoonPath?feature=$featureName';
        }
        return fallbackPath;
      }
      return null;
    };
  }

  // ============= MULTIPLE FEATURES CHECK =============

  /// Creates a redirect that requires multiple features to be enabled
  ///
  /// Parameters:
  /// - [getFeatureFlag]: Function to get a feature flag by name
  /// - [requiredFeatures]: List of feature names that must ALL be enabled
  /// - [fallbackPath]: Path to redirect if any feature is disabled
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/video-call',
  ///   redirect: FeatureFlagGuard.requireAllFeatures(
  ///     getFeatureFlag: (name) => featureFlags.isEnabled(name),
  ///     requiredFeatures: ['video_call', 'real_time_messaging'],
  ///     fallbackPath: '/chat',
  ///   ),
  ///   builder: (context, state) => const VideoCallScreen(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) requireAllFeatures({
    required bool Function(String featureName) getFeatureFlag,
    required List<String> requiredFeatures,
    required String fallbackPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      final allEnabled = requiredFeatures.every((feature) => getFeatureFlag(feature));
      if (!allEnabled) {
        return fallbackPath;
      }
      return null;
    };
  }

  /// Creates a redirect that requires at least one feature to be enabled
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/payment',
  ///   redirect: FeatureFlagGuard.requireAnyFeature(
  ///     getFeatureFlag: (name) => featureFlags.isEnabled(name),
  ///     features: ['stripe_payment', 'paypal_payment', 'apple_pay'],
  ///     fallbackPath: '/checkout-unavailable',
  ///   ),
  ///   builder: (context, state) => const PaymentScreen(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) requireAnyFeature({
    required bool Function(String featureName) getFeatureFlag,
    required List<String> features,
    required String fallbackPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      final anyEnabled = features.any((feature) => getFeatureFlag(feature));
      if (!anyEnabled) {
        return fallbackPath;
      }
      return null;
    };
  }

  // ============= BETA/EXPERIMENTAL CHECK =============

  /// Creates a redirect for beta/experimental features
  ///
  /// Requires user to be in beta program AND feature to be enabled.
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/experimental-ui',
  ///   redirect: FeatureFlagGuard.requireBetaFeature(
  ///     isFeatureEnabled: () => featureFlags.isEnabled('experimental_ui'),
  ///     isUserInBeta: () => userService.currentUser?.isBetaTester ?? false,
  ///     fallbackPath: '/home',
  ///     notInBetaPath: '/join-beta',
  ///   ),
  ///   builder: (context, state) => const ExperimentalUIScreen(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) requireBetaFeature({
    required bool Function() isFeatureEnabled,
    required bool Function() isUserInBeta,
    required String fallbackPath,
    String? notInBetaPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      // Check if feature is enabled at all
      if (!isFeatureEnabled()) {
        return fallbackPath;
      }

      // Check if user is in beta program
      if (!isUserInBeta()) {
        return notInBetaPath ?? fallbackPath;
      }

      return null;
    };
  }

  // ============= MAINTENANCE MODE CHECK =============

  /// Creates a redirect for maintenance mode
  ///
  /// Blocks access to routes when the app/feature is under maintenance.
  /// Optionally allows admin access during maintenance.
  ///
  /// Example:
  /// ```dart
  /// // Apply to specific routes
  /// GoRoute(
  ///   path: '/checkout',
  ///   redirect: FeatureFlagGuard.maintenanceMode(
  ///     isUnderMaintenance: () => appConfig.isCheckoutMaintenance,
  ///     maintenancePath: '/maintenance',
  ///   ),
  ///   builder: (context, state) => const CheckoutScreen(),
  /// )
  ///
  /// // Or apply globally
  /// GoRouter(
  ///   redirect: FeatureFlagGuard.maintenanceMode(
  ///     isUnderMaintenance: () => appConfig.isGlobalMaintenance,
  ///     maintenancePath: '/maintenance',
  ///     allowAdminBypass: true,
  ///     isAdmin: () => authService.currentUser?.isAdmin ?? false,
  ///   ),
  ///   routes: [...],
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) maintenanceMode({
    required bool Function() isUnderMaintenance,
    required String maintenancePath,
    bool allowAdminBypass = false,
    bool Function()? isAdmin,
    List<String> bypassPaths = const [],
  }) {
    return (BuildContext context, GoRouterState state) {
      final currentPath = state.matchedLocation;

      // Don't redirect if already on maintenance page
      if (currentPath == maintenancePath) {
        return null;
      }

      // Check bypass paths
      if (bypassPaths.any((path) => currentPath == path || currentPath.startsWith('$path/'))) {
        return null;
      }

      // Check maintenance status
      if (!isUnderMaintenance()) {
        return null;
      }

      // Check admin bypass
      if (allowAdminBypass && isAdmin != null && isAdmin()) {
        return null;
      }

      return maintenancePath;
    };
  }

  // ============= A/B TEST REDIRECT =============

  /// Creates a redirect based on A/B test variant
  ///
  /// Redirects users to different paths based on their test variant.
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/checkout',
  ///   redirect: FeatureFlagGuard.abTestRedirect(
  ///     getVariant: () => abTestService.getVariant('checkout_flow'),
  ///     variantPaths: {
  ///       'control': '/checkout/standard',
  ///       'variant_a': '/checkout/simplified',
  ///       'variant_b': '/checkout/one-page',
  ///     },
  ///     defaultPath: '/checkout/standard',
  ///   ),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) abTestRedirect({
    required String? Function() getVariant,
    required Map<String, String> variantPaths,
    required String defaultPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      final variant = getVariant();

      if (variant != null && variantPaths.containsKey(variant)) {
        return variantPaths[variant];
      }

      return defaultPath;
    };
  }

  // ============= GRADUAL ROLLOUT CHECK =============

  /// Creates a redirect for gradual feature rollout
  ///
  /// Uses user ID to deterministically include/exclude users.
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/new-home',
  ///   redirect: FeatureFlagGuard.gradualRollout(
  ///     getUserId: () => authService.currentUser?.id,
  ///     rolloutPercentage: 25, // 25% of users
  ///     featurePath: '/new-home',
  ///     fallbackPath: '/home',
  ///   ),
  ///   builder: (context, state) => const NewHomeScreen(),
  /// )
  /// ```
  static String? Function(BuildContext, GoRouterState) gradualRollout({
    required String? Function() getUserId,
    required int rolloutPercentage,
    required String featurePath,
    required String fallbackPath,
  }) {
    return (BuildContext context, GoRouterState state) {
      final userId = getUserId();

      if (userId == null) {
        return fallbackPath;
      }

      // Deterministic check based on user ID hash
      final hash = userId.hashCode.abs();
      final userPercentile = hash % 100;

      if (userPercentile < rolloutPercentage) {
        return null; // User is in rollout group
      }

      return fallbackPath;
    };
  }
}

/// Common feature flag names
///
/// Use these for consistency across your app
abstract class CommonFeatureFlags {
  CommonFeatureFlags._();

  // Core features
  static const String darkMode = 'dark_mode';
  static const String pushNotifications = 'push_notifications';
  static const String analytics = 'analytics';
  static const String crashReporting = 'crash_reporting';

  // E-commerce
  static const String checkout = 'checkout';
  static const String guestCheckout = 'guest_checkout';
  static const String applePay = 'apple_pay';
  static const String googlePay = 'google_pay';
  static const String wishlist = 'wishlist';
  static const String productReviews = 'product_reviews';

  // Social
  static const String chat = 'chat';
  static const String videoCall = 'video_call';
  static const String stories = 'stories';
  static const String liveStreaming = 'live_streaming';

  // Experimental
  static const String newUI = 'new_ui';
  static const String arPreview = 'ar_preview';
  static const String aiRecommendations = 'ai_recommendations';

  // System
  static const String maintenance = 'maintenance';
  static const String forceUpdate = 'force_update';
}
