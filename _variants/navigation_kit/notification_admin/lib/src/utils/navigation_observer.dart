// =============================================================================
// NAVIGATION OBSERVER
// =============================================================================
//
// This file provides navigation observers for logging, analytics, and debugging.
// Use these observers to track navigation events throughout your app.
//
// USE CASES:
// - Analytics tracking (page views)
// - Debug logging
// - Screen time tracking
// - Navigation history recording
//
// =============================================================================

import 'package:flutter/material.dart';

import '../navigation_kit_runtime.dart';

/// A navigation observer that logs all navigation events
///
/// Useful for debugging and development.
///
/// Usage:
/// ```dart
/// GoRouter(
///   observers: [
///     LoggingNavigatorObserver(),
///   ],
///   routes: [...],
/// )
/// ```
class LoggingNavigatorObserver extends NavigatorObserver {
  LoggingNavigatorObserver({
    this.prefix = 'NAV',
    this.logPush = true,
    this.logPop = true,
    this.logReplace = true,
    this.logRemove = true,
    this.logger,
  });

  final String prefix;
  final bool logPush;
  final bool logPop;
  final bool logReplace;
  final bool logRemove;
  final void Function(String message)? logger;

  void _log(String message) {
    if (logger != null) {
      logger!(message);
    } else {
      NavigationKitRuntime.logger.debug('[$prefix] $message');
    }
  }

  /// Extracts a readable name from route settings
  String _getRouteName(Route<dynamic> route) {
    final settings = route.settings;

    // First priority: use the route name if available
    if (settings.name != null && settings.name!.isNotEmpty) {
      // Clean up the name - convert path to readable name
      String name = settings.name!;
      // If it's a path like /home or /burger/123, make it readable
      if (name.startsWith('/')) {
        name = name.substring(1); // Remove leading /
        if (name.isEmpty) name = 'root';
      }
      return name;
    }

    // Second priority: check route type for shell/base routes
    final routeType = route.runtimeType.toString();

    // Handle common GoRouter internal route types
    if (routeType.contains('PageBasedMaterialPageRoute') ||
        routeType.contains('ShellRoute') ||
        routeType.contains('StatefulShellRoute')) {
      return 'shell';
    }

    // Third priority: try to get the page/widget name
    final pageName = _extractPageName(route);
    if (pageName != null) {
      return pageName;
    }

    // Fallback: simplified route type
    return routeType.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('_', '');
  }

  /// Extracts the page or widget name from a route
  String? _extractPageName(Route<dynamic> route) {
    try {
      if (route is PageRoute) {
        // Try to access the page's child widget
        final dynamic pageRoute = route;
        // Check if it's a MaterialPage or similar with a child
        if (pageRoute.settings.arguments is Map) {
          final args = pageRoute.settings.arguments as Map;
          if (args.containsKey('screenName')) {
            return args['screenName'] as String;
          }
        }
      }
    } catch (_) {
      // Ignore errors
    }
    return null;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (logPush) {
      final routeName = _getRouteName(route);
      // Only show "from" if it's a meaningful route (not shell)
      if (previousRoute != null) {
        final fromName = _getRouteName(previousRoute);
        if (fromName != 'shell') {
          _log('PUSH: $routeName ← $fromName');
          return;
        }
      }
      _log('PUSH: $routeName');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (logPop) {
      final routeName = _getRouteName(route);
      // Only show "back to" if it's a meaningful route (not shell)
      if (previousRoute != null) {
        final backToName = _getRouteName(previousRoute);
        if (backToName != 'shell') {
          _log('POP: $routeName → $backToName');
          return;
        }
      }
      _log('POP: $routeName');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (logReplace) {
      _log('REPLACE: ${oldRoute != null ? _getRouteName(oldRoute) : 'none'} '
          '-> ${newRoute != null ? _getRouteName(newRoute) : 'none'}');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (logRemove) {
      _log('REMOVE: ${_getRouteName(route)}');
    }
  }
}

/// A navigation observer for analytics tracking
///
/// Override the callback methods to send events to your analytics provider.
///
/// Usage:
/// ```dart
/// GoRouter(
///   observers: [
///     AnalyticsNavigatorObserver(
///       onScreenView: (screenName, parameters) {
///         analytics.logScreenView(screenName, parameters);
///       },
///     ),
///   ],
///   routes: [...],
/// )
/// ```
class AnalyticsNavigatorObserver extends NavigatorObserver {
  AnalyticsNavigatorObserver({
    required this.onScreenView,
    this.extractScreenName,
    this.extractParameters,
    this.excludePaths = const [],
  });

  /// Callback when a new screen is viewed
  final void Function(String screenName, Map<String, dynamic> parameters)
      onScreenView;

  /// Custom function to extract screen name from route
  final String Function(Route<dynamic> route)? extractScreenName;

  /// Custom function to extract parameters from route
  final Map<String, dynamic> Function(Route<dynamic> route)? extractParameters;

  /// Paths to exclude from analytics
  final List<String> excludePaths;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackScreenView(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _trackScreenView(newRoute);
    }
  }

  void _trackScreenView(Route<dynamic> route) {
    final settings = route.settings;
    final name = settings.name;

    // Skip if no name or excluded
    if (name == null || excludePaths.contains(name)) {
      return;
    }

    // Extract screen name
    final screenName =
        extractScreenName?.call(route) ?? _defaultScreenName(route);

    // Extract parameters
    final parameters =
        extractParameters?.call(route) ?? _defaultParameters(route);

    onScreenView(screenName, parameters);
  }

  String _defaultScreenName(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null) return 'unknown';

    // Convert path to screen name (e.g., '/home/products' -> 'home_products')
    return name
        .replaceAll('/', '_')
        .replaceAll(RegExp(r'^_'), '')
        .replaceAll(RegExp(r'_$'), '');
  }

  Map<String, dynamic> _defaultParameters(Route<dynamic> route) {
    final args = route.settings.arguments;
    if (args is Map<String, dynamic>) {
      return args;
    }
    return {};
  }
}

/// A navigation observer that tracks screen time
///
/// Useful for analytics and understanding user behavior.
///
/// Usage:
/// ```dart
/// GoRouter(
///   observers: [
///     ScreenTimeObserver(
///       onScreenExit: (screenName, duration) {
///         analytics.logEvent('screen_time', {
///           'screen': screenName,
///           'duration_ms': duration.inMilliseconds,
///         });
///       },
///     ),
///   ],
///   routes: [...],
/// )
/// ```
class ScreenTimeObserver extends NavigatorObserver {
  ScreenTimeObserver({
    required this.onScreenExit,
    this.excludePaths = const [],
  });

  /// Callback when a screen is exited with the time spent
  final void Function(String screenName, Duration duration) onScreenExit;

  /// Paths to exclude from tracking
  final List<String> excludePaths;

  final Map<String, DateTime> _screenEntryTimes = {};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Record exit time for previous route
    if (previousRoute != null) {
      _recordScreenExit(previousRoute);
    }

    // Record entry time for new route
    _recordScreenEntry(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Record exit time for popped route
    _recordScreenExit(route);

    // Re-record entry for the route we're going back to
    if (previousRoute != null) {
      _recordScreenEntry(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      _recordScreenExit(oldRoute);
    }
    if (newRoute != null) {
      _recordScreenEntry(newRoute);
    }
  }

  void _recordScreenEntry(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && !excludePaths.contains(name)) {
      _screenEntryTimes[name] = DateTime.now();
    }
  }

  void _recordScreenExit(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || excludePaths.contains(name)) return;

    final entryTime = _screenEntryTimes.remove(name);
    if (entryTime != null) {
      final duration = DateTime.now().difference(entryTime);
      onScreenExit(name, duration);
    }
  }
}

/// A navigation observer that maintains a history stack
///
/// Useful for implementing custom back navigation or breadcrumbs.
///
/// Usage:
/// ```dart
/// final historyObserver = NavigationHistoryObserver();
///
/// GoRouter(
///   observers: [historyObserver],
///   routes: [...],
/// )
///
/// // Later, access history:
/// print(historyObserver.history);
/// print(historyObserver.currentRoute);
/// ```
class NavigationHistoryObserver extends NavigatorObserver {
  NavigationHistoryObserver({
    this.maxHistoryLength = 50,
  });

  final int maxHistoryLength;
  final List<String> _history = [];

  /// Get the navigation history (oldest first)
  List<String> get history => List.unmodifiable(_history);

  /// Get the current route name
  String? get currentRoute => _history.isNotEmpty ? _history.last : null;

  /// Get the previous route name
  String? get previousRoute =>
      _history.length > 1 ? _history[_history.length - 2] : null;

  /// Check if can go back in history
  bool get canGoBack => _history.length > 1;

  /// Clear the history
  void clearHistory() {
    _history.clear();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) {
      _history.add(name);
      _trimHistory();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_history.isNotEmpty) {
      _history.removeLast();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (_history.isNotEmpty && oldRoute?.settings.name == _history.last) {
      _history.removeLast();
    }
    final name = newRoute?.settings.name;
    if (name != null) {
      _history.add(name);
      _trimHistory();
    }
  }

  void _trimHistory() {
    while (_history.length > maxHistoryLength) {
      _history.removeAt(0);
    }
  }
}

/// Combines multiple navigation observers
///
/// Usage:
/// ```dart
/// GoRouter(
///   observers: [
///     CompositeNavigatorObserver([
///       LoggingNavigatorObserver(),
///       AnalyticsNavigatorObserver(...),
///       ScreenTimeObserver(...),
///     ]),
///   ],
///   routes: [...],
/// )
/// ```
class CompositeNavigatorObserver extends NavigatorObserver {
  CompositeNavigatorObserver(this.observers);

  final List<NavigatorObserver> observers;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in observers) {
      observer.didPush(route, previousRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in observers) {
      observer.didPop(route, previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    for (final observer in observers) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in observers) {
      observer.didRemove(route, previousRoute);
    }
  }
}
