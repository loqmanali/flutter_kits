// =============================================================================
// BOTTOM NAVIGATION SHELL
// =============================================================================
//
// This file provides a simple ShellRoute-based bottom navigation implementation.
// State is NOT preserved when switching tabs - each tab rebuilds when selected.
//
// USE THIS WHEN:
// - Tabs are independent and don't need state preservation
// - You want simpler implementation
// - Memory usage is a concern (only active tab is kept in memory)
//
// DON'T USE THIS WHEN:
// - You need to preserve scroll positions between tabs
// - You need to keep form data when switching tabs
// - Tabs have expensive initialization (use StatefulBottomNavShell instead)
//
// USAGE:
// ```dart
// final router = GoRouter(
//   routes: [
//     BottomNavShellBuilder.build(
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

/// Configuration for a bottom navigation destination
class BottomNavDestination {
  const BottomNavDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
  });

  /// Route path for this destination (e.g., '/home')
  final String path;

  /// Label text displayed below the icon
  final String label;

  /// Icon shown when not selected
  final IconData icon;

  /// Icon shown when selected (defaults to [icon] if null)
  final IconData? selectedIcon;

  /// Optional badge text (e.g., cart count)
  final String? badge;

  /// Get the appropriate icon based on selection state
  Widget buildIcon(bool isSelected) {
    final iconWidget = Icon(isSelected ? (selectedIcon ?? icon) : icon);

    if (badge != null && badge!.isNotEmpty) {
      return Badge(
        label: Text(badge!),
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  /// Build NavigationDestination for Material 3 NavigationBar
  NavigationDestination toNavigationDestination() {
    return NavigationDestination(
      icon: badge != null
          ? Badge(label: Text(badge!), child: Icon(icon))
          : Icon(icon),
      selectedIcon: badge != null
          ? Badge(label: Text(badge!), child: Icon(selectedIcon ?? icon))
          : Icon(selectedIcon ?? icon),
      label: label,
    );
  }

  /// Build BottomNavigationBarItem for classic BottomNavigationBar
  BottomNavigationBarItem toBottomNavItem() {
    return BottomNavigationBarItem(
      icon: badge != null
          ? Badge(label: Text(badge!), child: Icon(icon))
          : Icon(icon),
      activeIcon: badge != null
          ? Badge(label: Text(badge!), child: Icon(selectedIcon ?? icon))
          : Icon(selectedIcon ?? icon),
      label: label,
    );
  }
}

/// Builder for creating bottom navigation with simple ShellRoute
///
/// This creates a non-stateful shell where tabs don't preserve their state.
class BottomNavShellBuilder {
  BottomNavShellBuilder._();

  /// Build a ShellRoute with bottom navigation
  ///
  /// Parameters:
  /// - [destinations]: List of navigation destinations
  /// - [routes]: List of GoRoute for each destination (must match order)
  /// - [shellBuilder]: Optional custom shell widget builder
  /// - [navigatorKey]: Optional navigator key for the shell
  /// - [useMaterial3]: Whether to use Material 3 NavigationBar (default: true)
  ///
  /// Example:
  /// ```dart
  /// BottomNavShellBuilder.build(
  ///   destinations: [
  ///     BottomNavDestination(path: '/home', label: 'Home', icon: Icons.home),
  ///     BottomNavDestination(path: '/search', label: 'Search', icon: Icons.search),
  ///     BottomNavDestination(path: '/profile', label: 'Profile', icon: Icons.person),
  ///   ],
  ///   routes: [
  ///     GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
  ///     GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
  ///     GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ///   ],
  /// )
  /// ```
  static ShellRoute build({
    required List<BottomNavDestination> destinations,
    required List<RouteBase> routes,
    Widget Function(BuildContext, GoRouterState, Widget, List<BottomNavDestination>)? shellBuilder,
    GlobalKey<NavigatorState>? navigatorKey,
    bool useMaterial3 = true,
    List<NavigatorObserver>? observers,
    String? restorationScopeId,
  }) {
    return ShellRoute(
      navigatorKey: navigatorKey ?? NavigatorKeyRegistry.instance.shellKey,
      observers: observers,
      restorationScopeId: restorationScopeId,
      builder: (context, state, child) {
        if (shellBuilder != null) {
          return shellBuilder(context, state, child, destinations);
        }

        return _DefaultBottomNavShell(
          destinations: destinations,
          useMaterial3: useMaterial3,
          child: child,
        );
      },
      routes: routes,
    );
  }

  /// Build routes outside the shell (full-screen routes)
  ///
  /// These routes will not show the bottom navigation bar.
  ///
  /// Example:
  /// ```dart
  /// BottomNavShellBuilder.fullScreenRoute(
  ///   path: '/checkout',
  ///   builder: (context, state) => const CheckoutScreen(),
  /// )
  /// ```
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

/// Default bottom navigation shell widget
class _DefaultBottomNavShell extends StatelessWidget {
  const _DefaultBottomNavShell({
    required this.destinations,
    required this.child,
    this.useMaterial3 = true,
  });

  final List<BottomNavDestination> destinations;
  final Widget child;
  final bool useMaterial3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: useMaterial3
          ? _buildMaterial3Nav(context)
          : _buildClassicNav(context),
    );
  }

  Widget _buildMaterial3Nav(BuildContext context) {
    return NavigationBar(
      selectedIndex: _calculateSelectedIndex(context),
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: destinations.map((d) => d.toNavigationDestination()).toList(),
    );
  }

  Widget _buildClassicNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _calculateSelectedIndex(context),
      onTap: (index) => _onItemTapped(context, index),
      items: destinations.map((d) => d.toBottomNavItem()).toList(),
      type: BottomNavigationBarType.fixed,
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    for (var i = 0; i < destinations.length; i++) {
      if (location == destinations[i].path ||
          location.startsWith('${destinations[i].path}/')) {
        return i;
      }
    }

    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    // Use go() to clear the stack and navigate to the destination
    context.go(destinations[index].path);
  }
}

/// A customizable bottom navigation shell widget
///
/// Use this when you need more control over the shell's appearance.
class CustomBottomNavShell extends StatelessWidget {
  const CustomBottomNavShell({
    super.key,
    required this.destinations,
    required this.child,
    this.backgroundColor,
    this.elevation,
    this.indicatorColor,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.showLabels = true,
    this.useMaterial3 = true,
  });

  final List<BottomNavDestination> destinations;
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final Color? indicatorColor;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final Color? selectedLabelColor;
  final Color? unselectedLabelColor;
  final bool showLabels;
  final bool useMaterial3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: useMaterial3
          ? NavigationBar(
              selectedIndex: _calculateSelectedIndex(context),
              onDestinationSelected: (index) => _onItemTapped(context, index),
              backgroundColor: backgroundColor,
              elevation: elevation,
              indicatorColor: indicatorColor,
              destinations: destinations.map((d) => d.toNavigationDestination()).toList(),
            )
          : Theme(
              data: theme.copyWith(
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  backgroundColor: backgroundColor,
                  elevation: elevation,
                  selectedIconTheme: IconThemeData(color: selectedIconColor),
                  unselectedIconTheme: IconThemeData(color: unselectedIconColor),
                  selectedLabelStyle: TextStyle(color: selectedLabelColor),
                  unselectedLabelStyle: TextStyle(color: unselectedLabelColor),
                  showSelectedLabels: showLabels,
                  showUnselectedLabels: showLabels,
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _calculateSelectedIndex(context),
                onTap: (index) => _onItemTapped(context, index),
                items: destinations.map((d) => d.toBottomNavItem()).toList(),
                type: BottomNavigationBarType.fixed,
              ),
            ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    for (var i = 0; i < destinations.length; i++) {
      if (location == destinations[i].path ||
          location.startsWith('${destinations[i].path}/')) {
        return i;
      }
    }

    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    context.go(destinations[index].path);
  }
}
