// =============================================================================
// MIXED SHELL
// =============================================================================
//
// This file provides a combined navigation shell that supports multiple
// navigation patterns simultaneously (e.g., drawer + bottom nav).
//
// USE CASES:
// - Apps with both drawer navigation and bottom navigation
// - Responsive apps that show different navigation on different screen sizes
// - Complex apps with multiple navigation levels
//
// PATTERNS SUPPORTED:
// 1. Drawer + Bottom Navigation
// 2. Drawer + Tab Bar
// 3. Responsive (Bottom on mobile, Rail on tablet, Drawer on desktop)
//
// USAGE:
// ```dart
// MixedShellBuilder.buildDrawerWithBottomNav(
//   drawerDestinations: [...],
//   bottomNavDestinations: [...],
//   routes: [...],
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../adapters/navigator_key_registry.dart';
import 'bottom_nav_shell.dart';
import 'drawer_shell.dart';

/// Builder for creating mixed navigation shells
class MixedShellBuilder {
  MixedShellBuilder._();

  /// Build a shell with both drawer and bottom navigation
  ///
  /// The drawer contains secondary/settings navigation while
  /// the bottom nav contains the main app sections.
  ///
  /// Example:
  /// ```dart
  /// MixedShellBuilder.buildDrawerWithBottomNav(
  ///   drawerDestinations: [
  ///     DrawerDestination(path: '/settings', label: 'Settings', icon: Icons.settings),
  ///     DrawerDestination(path: '/about', label: 'About', icon: Icons.info),
  ///   ],
  ///   bottomNavDestinations: [
  ///     BottomNavDestination(path: '/home', label: 'Home', icon: Icons.home),
  ///     BottomNavDestination(path: '/search', label: 'Search', icon: Icons.search),
  ///   ],
  ///   routes: [
  ///     GoRoute(path: '/home', builder: ...),
  ///     GoRoute(path: '/search', builder: ...),
  ///   ],
  /// )
  /// ```
  static ShellRoute buildDrawerWithBottomNav({
    required List<DrawerDestination> drawerDestinations,
    required List<BottomNavDestination> bottomNavDestinations,
    required List<RouteBase> routes,
    Widget? drawerHeader,
    GlobalKey<NavigatorState>? navigatorKey,
    bool useMaterial3 = true,
  }) {
    return ShellRoute(
      navigatorKey: navigatorKey ?? NavigatorKeyRegistry.instance.shellKey,
      builder: (context, state, child) {
        return _DrawerBottomNavShell(
          drawerDestinations: drawerDestinations,
          bottomNavDestinations: bottomNavDestinations,
          drawerHeader: drawerHeader,
          useMaterial3: useMaterial3,
          child: child,
        );
      },
      routes: routes,
    );
  }

  /// Build a responsive navigation shell that adapts to screen size
  ///
  /// - Mobile: Bottom Navigation
  /// - Tablet: Navigation Rail
  /// - Desktop: Navigation Drawer (permanent)
  ///
  /// Example:
  /// ```dart
  /// MixedShellBuilder.buildResponsive(
  ///   destinations: [
  ///     ResponsiveNavDestination(
  ///       path: '/home',
  ///       label: 'Home',
  ///       icon: Icons.home,
  ///     ),
  ///     ResponsiveNavDestination(
  ///       path: '/search',
  ///       label: 'Search',
  ///       icon: Icons.search,
  ///     ),
  ///   ],
  ///   routes: [...],
  /// )
  /// ```
  static ShellRoute buildResponsive({
    required List<ResponsiveNavDestination> destinations,
    required List<RouteBase> routes,
    Widget? drawerHeader,
    GlobalKey<NavigatorState>? navigatorKey,
    double tabletBreakpoint = 600,
    double desktopBreakpoint = 1200,
    bool useMaterial3 = true,
  }) {
    return ShellRoute(
      navigatorKey: navigatorKey ?? NavigatorKeyRegistry.instance.shellKey,
      builder: (context, state, child) {
        return ResponsiveNavigationShell(
          destinations: destinations,
          drawerHeader: drawerHeader,
          tabletBreakpoint: tabletBreakpoint,
          desktopBreakpoint: desktopBreakpoint,
          useMaterial3: useMaterial3,
          child: child,
        );
      },
      routes: routes,
    );
  }

  /// Build a full-screen route outside any shell
  static GoRoute fullScreenRoute({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: NavigatorKeyRegistry.instance.rootKey,
      builder: builder,
      routes: routes,
    );
  }
}

/// Shell with drawer + bottom navigation
class _DrawerBottomNavShell extends StatelessWidget {
  const _DrawerBottomNavShell({
    required this.drawerDestinations,
    required this.bottomNavDestinations,
    required this.child,
    this.drawerHeader,
    this.useMaterial3 = true,
  });

  final List<DrawerDestination> drawerDestinations;
  final List<BottomNavDestination> bottomNavDestinations;
  final Widget child;
  final Widget? drawerHeader;
  final bool useMaterial3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getCurrentTitle(context)),
      ),
      drawer: _buildDrawer(context),
      body: child,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final navigable = drawerDestinations.where((d) => !d.isHeader).toList();
    final currentPath = GoRouterState.of(context).matchedLocation;

    return NavigationDrawer(
      selectedIndex: _calculateDrawerIndex(currentPath, navigable),
      onDestinationSelected: (index) {
        Navigator.pop(context);
        if (index < navigable.length) {
          context.go(navigable[index].path);
        }
      },
      children: [
        if (drawerHeader != null)
          drawerHeader!
        else
          const DrawerHeader(child: Text('Menu')),
        ...drawerDestinations.map((d) {
          if (d.isHeader) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
              child: Text(
                d.headerTitle ?? d.label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            );
          }
          if (d.isDividerBefore) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                d.toDrawerDestination(),
              ],
            );
          }
          return d.toDrawerDestination();
        }),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    if (useMaterial3) {
      return NavigationBar(
        selectedIndex: _calculateBottomNavIndex(currentPath),
        onDestinationSelected: (index) {
          context.go(bottomNavDestinations[index].path);
        },
        destinations: bottomNavDestinations
            .map((d) => d.toNavigationDestination())
            .toList(),
      );
    }

    return BottomNavigationBar(
      currentIndex: _calculateBottomNavIndex(currentPath),
      onTap: (index) {
        context.go(bottomNavDestinations[index].path);
      },
      items: bottomNavDestinations.map((d) => d.toBottomNavItem()).toList(),
      type: BottomNavigationBarType.fixed,
    );
  }

  String _getCurrentTitle(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    // Check bottom nav destinations first (they're the main ones)
    for (final dest in bottomNavDestinations) {
      if (currentPath == dest.path || currentPath.startsWith('${dest.path}/')) {
        return dest.label;
      }
    }

    // Check drawer destinations
    for (final dest in drawerDestinations.where((d) => !d.isHeader)) {
      if (currentPath == dest.path || currentPath.startsWith('${dest.path}/')) {
        return dest.label;
      }
    }

    return '';
  }

  int _calculateBottomNavIndex(String path) {
    for (var i = 0; i < bottomNavDestinations.length; i++) {
      if (path == bottomNavDestinations[i].path ||
          path.startsWith('${bottomNavDestinations[i].path}/')) {
        return i;
      }
    }
    return 0;
  }

  int _calculateDrawerIndex(String path, List<DrawerDestination> navigable) {
    for (var i = 0; i < navigable.length; i++) {
      if (path == navigable[i].path || path.startsWith('${navigable[i].path}/')) {
        return i;
      }
    }
    return -1; // No selection in drawer
  }
}

/// Configuration for responsive navigation destination
class ResponsiveNavDestination {
  const ResponsiveNavDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? badge;

  NavigationDestination toNavigationDestination() {
    return NavigationDestination(
      icon: badge != null
          ? Badge(label: Text(badge!), child: Icon(icon))
          : Icon(icon),
      selectedIcon: Icon(selectedIcon ?? icon),
      label: label,
    );
  }

  NavigationRailDestination toRailDestination() {
    return NavigationRailDestination(
      icon: badge != null
          ? Badge(label: Text(badge!), child: Icon(icon))
          : Icon(icon),
      selectedIcon: Icon(selectedIcon ?? icon),
      label: Text(label),
    );
  }

  NavigationDrawerDestination toDrawerDestination() {
    return NavigationDrawerDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon ?? icon),
      label: Text(label),
    );
  }
}

/// Responsive navigation shell that adapts to screen size
class ResponsiveNavigationShell extends StatelessWidget {
  const ResponsiveNavigationShell({
    super.key,
    required this.destinations,
    required this.child,
    this.drawerHeader,
    this.tabletBreakpoint = 600,
    this.desktopBreakpoint = 1200,
    this.useMaterial3 = true,
  });

  final List<ResponsiveNavDestination> destinations;
  final Widget child;
  final Widget? drawerHeader;
  final double tabletBreakpoint;
  final double desktopBreakpoint;
  final bool useMaterial3;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= desktopBreakpoint) {
      return _buildDesktopLayout(context);
    } else if (width >= tabletBreakpoint) {
      return _buildTabletLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateIndex(currentPath),
        onDestinationSelected: (index) => _onNavigate(context, index),
        destinations: destinations.map((d) => d.toNavigationDestination()).toList(),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _calculateIndex(currentPath),
            onDestinationSelected: (index) => _onNavigate(context, index),
            labelType: NavigationRailLabelType.all,
            destinations: destinations.map((d) => d.toRailDestination()).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: _calculateIndex(currentPath),
            onDestinationSelected: (index) => _onNavigate(context, index),
            children: [
              if (drawerHeader != null)
                drawerHeader!
              else
                const SizedBox(height: 16),
              ...destinations.map((d) => d.toDrawerDestination()),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _calculateIndex(String path) {
    for (var i = 0; i < destinations.length; i++) {
      if (path == destinations[i].path ||
          path.startsWith('${destinations[i].path}/')) {
        return i;
      }
    }
    return 0;
  }

  void _onNavigate(BuildContext context, int index) {
    context.go(destinations[index].path);
  }
}
