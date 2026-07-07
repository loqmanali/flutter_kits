// =============================================================================
// STATEFUL BOTTOM NAVIGATION SHELL
// =============================================================================
//
// This file provides a StatefulShellRoute-based bottom navigation implementation.
// State IS preserved when switching tabs - each tab maintains its state.
//
// USE THIS WHEN:
// - You need to preserve scroll positions between tabs
// - You need to keep form data when switching tabs
// - Tabs have expensive initialization that shouldn't be repeated
// - You want the best user experience for tab navigation
//
// DON'T USE THIS WHEN:
// - Memory usage is a critical concern
// - Tabs are truly independent and lightweight
//
// USAGE:
// ```dart
// final router = GoRouter(
//   routes: [
//     StatefulBottomNavShellBuilder.build(
//       branches: [...],
//       shellBuilder: (context, state, navigationShell) {
//         return MyCustomShell(navigationShell: navigationShell);
//       },
//     ),
//   ],
// );
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../adapters/navigator_key_registry.dart';

/// Configuration for a stateful navigation branch
class NavBranchConfig {
  const NavBranchConfig({
    required this.routes,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.navigatorKey,
    this.initialLocation,
    this.restorationScopeId,
  });

  /// Routes for this branch
  final List<RouteBase> routes;

  /// Label for the navigation item
  final String label;

  /// Icon when not selected
  final IconData icon;

  /// Icon when selected (defaults to [icon])
  final IconData? selectedIcon;

  /// Optional badge text
  final String? badge;

  /// Optional navigator key for this branch
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Initial location for this branch (defaults to first route)
  final String? initialLocation;

  /// Restoration scope ID for state restoration
  final String? restorationScopeId;

  /// Build a StatefulShellBranch from this config
  StatefulShellBranch toBranch() {
    return StatefulShellBranch(
      navigatorKey: navigatorKey,
      initialLocation: initialLocation,
      restorationScopeId: restorationScopeId,
      routes: routes,
    );
  }

  /// Build NavigationDestination for Material 3
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

  /// Build BottomNavigationBarItem for classic navigation
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

/// Builder for creating stateful bottom navigation
///
/// This creates a stateful shell where tabs preserve their state.
class StatefulBottomNavShellBuilder {
  StatefulBottomNavShellBuilder._();

  /// Build a StatefulShellRoute with bottom navigation using IndexedStack
  ///
  /// This is the recommended approach for most apps as it:
  /// - Preserves state when switching tabs
  /// - Keeps scroll positions
  /// - Doesn't rebuild tabs when switching
  ///
  /// Parameters:
  /// - [branches]: List of branch configurations
  /// - [shellBuilder]: Custom shell widget builder
  /// - [restorationScopeId]: ID for state restoration
  ///
  /// Example:
  /// ```dart
  /// StatefulBottomNavShellBuilder.build(
  ///   branches: [
  ///     NavBranchConfig(
  ///       label: 'Home',
  ///       icon: Icons.home_outlined,
  ///       selectedIcon: Icons.home,
  ///       routes: [
  ///         GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
  ///       ],
  ///     ),
  ///     NavBranchConfig(
  ///       label: 'Search',
  ///       icon: Icons.search,
  ///       routes: [
  ///         GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
  ///       ],
  ///     ),
  ///   ],
  /// )
  /// ```
  static StatefulShellRoute build({
    required List<NavBranchConfig> branches,
    Widget Function(BuildContext, GoRouterState, StatefulNavigationShell)? shellBuilder,
    String? restorationScopeId,
    bool useMaterial3 = true,
  }) {
    return StatefulShellRoute.indexedStack(
      restorationScopeId: restorationScopeId,
      builder: (context, state, navigationShell) {
        if (shellBuilder != null) {
          return shellBuilder(context, state, navigationShell);
        }

        return DefaultStatefulBottomNavShell(
          navigationShell: navigationShell,
          branches: branches,
          useMaterial3: useMaterial3,
        );
      },
      branches: branches.map((b) => b.toBranch()).toList(),
    );
  }

  /// Build a StatefulShellRoute with custom transition between branches
  ///
  /// Use this when you want custom animations between tabs.
  ///
  /// Example:
  /// ```dart
  /// StatefulBottomNavShellBuilder.buildWithTransition(
  ///   branches: [...],
  ///   transitionBuilder: (context, shell, children) {
  ///     return AnimatedSwitcher(
  ///       duration: Duration(milliseconds: 300),
  ///       child: children[shell.currentIndex],
  ///     );
  ///   },
  /// )
  /// ```
  static StatefulShellRoute buildWithTransition({
    required List<NavBranchConfig> branches,
    required Widget Function(BuildContext, StatefulNavigationShell, List<Widget>) transitionBuilder,
    Widget Function(BuildContext, GoRouterState, StatefulNavigationShell)? shellBuilder,
    String? restorationScopeId,
    bool useMaterial3 = true,
  }) {
    return StatefulShellRoute(
      restorationScopeId: restorationScopeId,
      navigatorContainerBuilder: (context, navigationShell, children) {
        return transitionBuilder(context, navigationShell, children);
      },
      builder: (context, state, navigationShell) {
        if (shellBuilder != null) {
          return shellBuilder(context, state, navigationShell);
        }

        return DefaultStatefulBottomNavShell(
          navigationShell: navigationShell,
          branches: branches,
          useMaterial3: useMaterial3,
        );
      },
      branches: branches.map((b) => b.toBranch()).toList(),
    );
  }

  /// Build a full-screen route that appears outside the shell
  ///
  /// Use this for routes that should not show the bottom navigation.
  static GoRoute fullScreenRoute({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<RouteBase> routes = const [],
    String? Function(BuildContext, GoRouterState)? redirect,
    Page<dynamic> Function(BuildContext, GoRouterState)? pageBuilder,
  }) {
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: NavigatorKeyRegistry.instance.rootKey,
      builder: pageBuilder == null ? builder : null,
      pageBuilder: pageBuilder,
      routes: routes,
      redirect: redirect,
    );
  }
}

/// Default stateful bottom navigation shell widget
class DefaultStatefulBottomNavShell extends StatelessWidget {
  const DefaultStatefulBottomNavShell({
    super.key,
    required this.navigationShell,
    required this.branches,
    this.useMaterial3 = true,
  });

  final StatefulNavigationShell navigationShell;
  final List<NavBranchConfig> branches;
  final bool useMaterial3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: useMaterial3
          ? NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: branches.map((b) => b.toNavigationDestination()).toList(),
            )
          : BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _onDestinationSelected,
              items: branches.map((b) => b.toBottomNavItem()).toList(),
              type: BottomNavigationBarType.fixed,
            ),
    );
  }

  void _onDestinationSelected(int index) {
    // goBranch navigates to the branch while preserving state
    // initialLocation: true returns to the branch's initial location
    // when tapping the already selected tab
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// Customizable stateful bottom navigation shell
class CustomStatefulBottomNavShell extends StatelessWidget {
  const CustomStatefulBottomNavShell({
    super.key,
    required this.navigationShell,
    required this.branches,
    this.backgroundColor,
    this.elevation,
    this.indicatorColor,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.showLabels = true,
    this.useMaterial3 = true,
    this.onDoubleTapTab,
  });

  final StatefulNavigationShell navigationShell;
  final List<NavBranchConfig> branches;
  final Color? backgroundColor;
  final double? elevation;
  final Color? indicatorColor;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final bool showLabels;
  final bool useMaterial3;

  /// Callback when user double-taps the current tab
  /// Useful for scrolling to top or refreshing
  final void Function(int index)? onDoubleTapTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: useMaterial3
          ? NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: backgroundColor,
              elevation: elevation,
              indicatorColor: indicatorColor,
              destinations: branches.map((b) => b.toNavigationDestination()).toList(),
            )
          : BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _onDestinationSelected,
              backgroundColor: backgroundColor,
              elevation: elevation,
              selectedIconTheme: IconThemeData(color: selectedIconColor),
              unselectedIconTheme: IconThemeData(color: unselectedIconColor),
              showSelectedLabels: showLabels,
              showUnselectedLabels: showLabels,
              items: branches.map((b) => b.toBottomNavItem()).toList(),
              type: BottomNavigationBarType.fixed,
            ),
    );
  }

  void _onDestinationSelected(int index) {
    if (index == navigationShell.currentIndex) {
      // Already on this tab - trigger double tap callback
      onDoubleTapTab?.call(index);
      // Go to initial location
      navigationShell.goBranch(index, initialLocation: true);
    } else {
      // Switch to new tab
      navigationShell.goBranch(index);
    }
  }
}

/// Helper widget for preserving scroll state in tabs
///
/// Wrap your scrollable content with this to preserve scroll position.
///
/// Example:
/// ```dart
/// class HomeScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return TabStatePreserver(
///       child: ListView.builder(
///         itemCount: 100,
///         itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
///       ),
///     );
///   }
/// }
/// ```
class TabStatePreserver extends StatefulWidget {
  const TabStatePreserver({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<TabStatePreserver> createState() => _TabStatePreserverState();
}

class _TabStatePreserverState extends State<TabStatePreserver>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
