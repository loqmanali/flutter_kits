import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Types of navigation shell supported by the kit.
enum ShellType {
  /// No shell wrapper — routes are displayed directly.
  none,

  /// Simple bottom navigation bar. State is NOT preserved across tabs.
  bottomNav,

  /// Bottom navigation with `IndexedStack` state preservation (recommended).
  statefulBottomNav,

  /// Side drawer (hamburger menu).
  drawer,

  /// Top tab bar.
  tabBar,

  /// Mixed (e.g. drawer + bottom nav).
  mixed,
}

/// Configuration for guest-mode behavior.
class GuestModeConfig {
  const GuestModeConfig({
    this.enabled = false,
    this.allowedPaths = const [],
    this.restrictedPaths = const [],
    this.onRestrictedAccess,
    this.promptLoginOnRestricted = true,
  });

  final bool enabled;
  final List<String> allowedPaths;
  final List<String> restrictedPaths;
  final String? Function(String attemptedPath)? onRestrictedAccess;
  final bool promptLoginOnRestricted;

  bool isPathAllowed(String path) {
    if (allowedPaths.isNotEmpty) {
      return allowedPaths.any((allowed) => _matchPath(allowed, path));
    }
    if (restrictedPaths.isNotEmpty) {
      return !restrictedPaths.any((restricted) => _matchPath(restricted, path));
    }
    return true;
  }

  bool _matchPath(String pattern, String path) {
    final patternSegments = pattern.split('/');
    final pathSegments = path.split('/');
    if (patternSegments.length != pathSegments.length) {
      if (patternSegments.length < pathSegments.length) {
        for (var i = 0; i < patternSegments.length; i++) {
          if (!_segmentMatches(patternSegments[i], pathSegments[i])) {
            return false;
          }
        }
        return true;
      }
      return false;
    }
    for (var i = 0; i < patternSegments.length; i++) {
      if (!_segmentMatches(patternSegments[i], pathSegments[i])) {
        return false;
      }
    }
    return true;
  }

  bool _segmentMatches(String pattern, String segment) {
    if (pattern.startsWith(':')) return true;
    return pattern == segment;
  }
}

/// Main navigation configuration.
class NavigationConfig {
  NavigationConfig({
    required this.authStateProvider,
    this.currentUserProvider,
    this.initialLocation = '/',
    this.shellType = ShellType.statefulBottomNav,
    this.guestModeConfig = const GuestModeConfig(),
    this.publicPaths = const ['/login', '/register', '/forgot-password'],
    this.loginPath = '/login',
    this.homePath = '/home',
    this.onboardingPath = '/onboarding',
    this.errorPath = '/error',
    this.debugLogDiagnostics = false,
    this.redirectLimit = 5,
    this.refreshListenable,
    this.observers = const [],
    this.extraCodec,
  });

  // ----- authentication -----------------------------------------------------

  final bool Function() authStateProvider;
  final dynamic Function()? currentUserProvider;
  final Listenable? refreshListenable;

  // ----- paths --------------------------------------------------------------

  final String initialLocation;
  final List<String> publicPaths;
  final String loginPath;
  final String homePath;
  final String onboardingPath;
  final String errorPath;

  // ----- shell --------------------------------------------------------------

  final ShellType shellType;
  final GuestModeConfig guestModeConfig;

  // ----- router options -----------------------------------------------------

  final bool debugLogDiagnostics;
  final int redirectLimit;
  final List<NavigatorObserver> observers;
  final RouteInformationParser<Object>? extraCodec;

  // ----- helpers ------------------------------------------------------------

  bool isPublicPath(String path) {
    return publicPaths.any((publicPath) {
      if (publicPath == path) return true;
      if (path.startsWith('$publicPath/')) return true;
      return false;
    });
  }

  bool get isGuestModeEnabled => guestModeConfig.enabled;
  bool isGuestAllowedPath(String path) => guestModeConfig.isPathAllowed(path);
}

/// Configuration for an individual destination (bottom nav, drawer, etc.).
class NavigationDestinationConfig {
  const NavigationDestinationConfig({
    required this.path,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.requiresAuth = false,
    this.roles,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? badge;
  final bool requiresAuth;
  final List<String>? roles;

  IconData getIcon(bool isSelected) =>
      isSelected ? (selectedIcon ?? icon) : icon;
}

/// Branch configuration for `StatefulShellRoute.indexedStack`.
class BranchConfig {
  const BranchConfig({
    required this.routes,
    required this.destination,
    this.initialLocation,
    this.restorationScopeId,
    this.navigatorKey,
  });

  final List<RouteBase> routes;
  final NavigationDestinationConfig destination;
  final String? initialLocation;
  final String? restorationScopeId;
  final GlobalKey<NavigatorState>? navigatorKey;
}
