// =============================================================================
// DRAWER SHELL
// =============================================================================
//
// This file provides a ShellRoute-based drawer navigation implementation.
// Use this for apps with many top-level destinations that don't fit in a
// bottom navigation bar.
//
// USE CASES:
// - Apps with 6+ main sections
// - Admin panels
// - Settings-heavy apps
// - Apps targeting larger screens (tablets)
//
// USAGE:
// ```dart
// final router = GoRouter(
//   routes: [
//     DrawerShellBuilder.build(
//       destinations: [...],
//       routes: [...],
//     ),
//   ],
// );
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../adapters/navigator_key_registry.dart';

/// Configuration for a drawer destination
class DrawerDestination {
  const DrawerDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.isDividerBefore = false,
    this.isHeader = false,
    this.headerTitle,
  });

  /// Route path for this destination
  final String path;

  /// Label text
  final String label;

  /// Icon when not selected
  final IconData icon;

  /// Icon when selected
  final IconData? selectedIcon;

  /// Optional badge
  final String? badge;

  /// Whether to show a divider before this item
  final bool isDividerBefore;

  /// Whether this is a header (non-clickable)
  final bool isHeader;

  /// Title for header (if isHeader is true)
  final String? headerTitle;

  /// Build a NavigationDrawerDestination
  NavigationDrawerDestination toDrawerDestination() {
    return NavigationDrawerDestination(
      icon: badge != null
          ? Badge(label: Text(badge!), child: Icon(icon))
          : Icon(icon),
      selectedIcon: badge != null
          ? Badge(label: Text(badge!), child: Icon(selectedIcon ?? icon))
          : Icon(selectedIcon ?? icon),
      label: Text(label),
    );
  }
}

/// Builder for creating drawer navigation
class DrawerShellBuilder {
  DrawerShellBuilder._();

  /// Build a ShellRoute with drawer navigation
  ///
  /// Parameters:
  /// - [destinations]: List of drawer destinations
  /// - [routes]: List of routes (must match non-header destinations order)
  /// - [drawerHeader]: Optional custom drawer header widget
  /// - [shellBuilder]: Optional custom shell builder
  ///
  /// Example:
  /// ```dart
  /// DrawerShellBuilder.build(
  ///   destinations: [
  ///     DrawerDestination(path: '/home', label: 'Home', icon: Icons.home),
  ///     DrawerDestination(path: '/settings', label: 'Settings', icon: Icons.settings, isDividerBefore: true),
  ///   ],
  ///   routes: [
  ///     GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
  ///     GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ///   ],
  /// )
  /// ```
  static ShellRoute build({
    required List<DrawerDestination> destinations,
    required List<RouteBase> routes,
    Widget? drawerHeader,
    Widget Function(BuildContext, GoRouterState, Widget, List<DrawerDestination>)? shellBuilder,
    GlobalKey<NavigatorState>? navigatorKey,
    String? restorationScopeId,
  }) {
    // Filter out headers for route matching
    final navigableDestinations = destinations.where((d) => !d.isHeader).toList();

    return ShellRoute(
      navigatorKey: navigatorKey ?? NavigatorKeyRegistry.instance.shellKey,
      restorationScopeId: restorationScopeId,
      builder: (context, state, child) {
        if (shellBuilder != null) {
          return shellBuilder(context, state, child, destinations);
        }

        return _DefaultDrawerShell(
          destinations: destinations,
          navigableDestinations: navigableDestinations,
          drawerHeader: drawerHeader,
          child: child,
        );
      },
      routes: routes,
    );
  }

  /// Build a full-screen route outside the drawer shell
  static GoRoute fullScreenRoute({
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
}

/// Default drawer shell widget
class _DefaultDrawerShell extends StatelessWidget {
  const _DefaultDrawerShell({
    required this.destinations,
    required this.navigableDestinations,
    required this.child,
    this.drawerHeader,
  });

  final List<DrawerDestination> destinations;
  final List<DrawerDestination> navigableDestinations;
  final Widget child;
  final Widget? drawerHeader;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final currentDestination = _findCurrentDestination(currentPath);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentDestination?.label ?? ''),
      ),
      drawer: NavigationDrawer(
        selectedIndex: _calculateSelectedIndex(currentPath),
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
        children: _buildDrawerChildren(context),
      ),
      body: child,
    );
  }

  List<Widget> _buildDrawerChildren(BuildContext context) {
    final children = <Widget>[];

    // Add drawer header
    if (drawerHeader != null) {
      children.add(drawerHeader!);
    } else {
      children.add(
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Text(
            'Navigation',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      );
    }

    // Build destinations with dividers and headers
    for (final dest in destinations) {
      if (dest.isDividerBefore) {
        children.add(const Divider());
      }

      if (dest.isHeader) {
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
            child: Text(
              dest.headerTitle ?? dest.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        );
      } else {
        children.add(dest.toDrawerDestination());
      }
    }

    return children;
  }

  DrawerDestination? _findCurrentDestination(String path) {
    for (final dest in navigableDestinations) {
      if (path == dest.path || path.startsWith('${dest.path}/')) {
        return dest;
      }
    }
    return navigableDestinations.isNotEmpty ? navigableDestinations.first : null;
  }

  int _calculateSelectedIndex(String path) {
    for (var i = 0; i < navigableDestinations.length; i++) {
      if (path == navigableDestinations[i].path ||
          path.startsWith('${navigableDestinations[i].path}/')) {
        return i;
      }
    }
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    Navigator.pop(context); // Close drawer
    if (index < navigableDestinations.length) {
      context.go(navigableDestinations[index].path);
    }
  }
}

/// Customizable drawer shell widget
class CustomDrawerShell extends StatelessWidget {
  const CustomDrawerShell({
    super.key,
    required this.destinations,
    required this.child,
    this.drawerHeader,
    this.appBarTitle,
    this.appBarActions,
    this.drawerWidth,
    this.backgroundColor,
    this.elevation,
    this.showAppBar = true,
  });

  final List<DrawerDestination> destinations;
  final Widget child;
  final Widget? drawerHeader;
  final Widget? appBarTitle;
  final List<Widget>? appBarActions;
  final double? drawerWidth;
  final Color? backgroundColor;
  final double? elevation;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final navigableDestinations = destinations.where((d) => !d.isHeader).toList();
    final currentPath = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: appBarTitle ?? Text(_getCurrentTitle(currentPath, navigableDestinations)),
              actions: appBarActions,
              elevation: elevation,
            )
          : null,
      drawer: SizedBox(
        width: drawerWidth,
        child: NavigationDrawer(
          backgroundColor: backgroundColor,
          elevation: elevation,
          selectedIndex: _calculateSelectedIndex(currentPath, navigableDestinations),
          onDestinationSelected: (index) => _onDestinationSelected(context, index, navigableDestinations),
          children: _buildDrawerChildren(context),
        ),
      ),
      body: child,
    );
  }

  List<Widget> _buildDrawerChildren(BuildContext context) {
    final children = <Widget>[];

    if (drawerHeader != null) {
      children.add(drawerHeader!);
    }

    for (final dest in destinations) {
      if (dest.isDividerBefore) {
        children.add(const Divider());
      }

      if (dest.isHeader) {
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
            child: Text(
              dest.headerTitle ?? dest.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
      } else {
        children.add(dest.toDrawerDestination());
      }
    }

    return children;
  }

  String _getCurrentTitle(String path, List<DrawerDestination> navigable) {
    for (final dest in navigable) {
      if (path == dest.path || path.startsWith('${dest.path}/')) {
        return dest.label;
      }
    }
    return '';
  }

  int _calculateSelectedIndex(String path, List<DrawerDestination> navigable) {
    for (var i = 0; i < navigable.length; i++) {
      if (path == navigable[i].path || path.startsWith('${navigable[i].path}/')) {
        return i;
      }
    }
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index, List<DrawerDestination> navigable) {
    Navigator.pop(context);
    if (index < navigable.length) {
      context.go(navigable[index].path);
    }
  }
}
