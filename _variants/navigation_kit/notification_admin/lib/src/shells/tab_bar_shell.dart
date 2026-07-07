// =============================================================================
// TAB BAR SHELL
// =============================================================================
//
// This file provides a ShellRoute-based top tab bar navigation implementation.
// Use this for related content sections within a single screen context.
//
// USE CASES:
// - Product listings with category tabs
// - User profiles with sections (Posts, Photos, About)
// - Settings with grouped sections
// - Dashboard with different views
//
// USAGE:
// ```dart
// final router = GoRouter(
//   routes: [
//     TabBarShellBuilder.build(
//       tabs: [...],
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

/// Configuration for a tab bar tab
class TabConfig {
  const TabConfig({
    required this.path,
    required this.label,
    this.icon,
    this.badge,
  });

  /// Route path for this tab
  final String path;

  /// Label text for the tab
  final String label;

  /// Optional icon for the tab
  final IconData? icon;

  /// Optional badge text
  final String? badge;

  /// Build a Tab widget
  Tab toTab() {
    if (icon != null) {
      return Tab(
        icon: badge != null
            ? Badge(label: Text(badge!), child: Icon(icon))
            : Icon(icon),
        text: label,
      );
    }

    return Tab(
      child: badge != null
          ? Badge(
              label: Text(badge!),
              child: Text(label),
            )
          : Text(label),
    );
  }
}

/// Builder for creating tab bar navigation
class TabBarShellBuilder {
  TabBarShellBuilder._();

  /// Build a ShellRoute with tab bar navigation
  ///
  /// Parameters:
  /// - [tabs]: List of tab configurations
  /// - [routes]: List of routes (must match tabs order)
  /// - [title]: Title for the AppBar
  /// - [shellBuilder]: Optional custom shell builder
  /// - [tabBarOptions]: Optional tab bar customization
  ///
  /// Example:
  /// ```dart
  /// TabBarShellBuilder.build(
  ///   title: 'Products',
  ///   tabs: [
  ///     TabConfig(path: '/products/all', label: 'All'),
  ///     TabConfig(path: '/products/popular', label: 'Popular'),
  ///     TabConfig(path: '/products/new', label: 'New'),
  ///   ],
  ///   routes: [
  ///     GoRoute(path: '/products/all', builder: (_, __) => const AllProducts()),
  ///     GoRoute(path: '/products/popular', builder: (_, __) => const PopularProducts()),
  ///     GoRoute(path: '/products/new', builder: (_, __) => const NewProducts()),
  ///   ],
  /// )
  /// ```
  static ShellRoute build({
    required List<TabConfig> tabs,
    required List<RouteBase> routes,
    String? title,
    Widget Function(BuildContext, GoRouterState, Widget, List<TabConfig>)? shellBuilder,
    GlobalKey<NavigatorState>? navigatorKey,
    TabBarOptions? tabBarOptions,
    String? restorationScopeId,
  }) {
    return ShellRoute(
      navigatorKey: navigatorKey ?? NavigatorKeyRegistry.instance.shellKey,
      restorationScopeId: restorationScopeId,
      builder: (context, state, child) {
        if (shellBuilder != null) {
          return shellBuilder(context, state, child, tabs);
        }

        return _DefaultTabBarShell(
          tabs: tabs,
          title: title,
          options: tabBarOptions,
          child: child,
        );
      },
      routes: routes,
    );
  }

  /// Build a full-screen route outside the tab bar shell
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

/// Options for customizing the tab bar appearance
class TabBarOptions {
  const TabBarOptions({
    this.isScrollable = false,
    this.indicatorColor,
    this.indicatorWeight = 2.0,
    this.labelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.padding,
    this.indicatorPadding = EdgeInsets.zero,
    this.dividerColor,
  });

  final bool isScrollable;
  final Color? indicatorColor;
  final double indicatorWeight;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry indicatorPadding;
  final Color? dividerColor;
}

/// Default tab bar shell widget
class _DefaultTabBarShell extends StatefulWidget {
  const _DefaultTabBarShell({
    required this.tabs,
    required this.child,
    this.title,
    this.options,
  });

  final List<TabConfig> tabs;
  final Widget child;
  final String? title;
  final TabBarOptions? options;

  @override
  State<_DefaultTabBarShell> createState() => _DefaultTabBarShellState();
}

class _DefaultTabBarShellState extends State<_DefaultTabBarShell>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      context.go(widget.tabs[_tabController.index].path);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTabIndex();
  }

  void _syncTabIndex() {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final index = _findTabIndex(currentPath);
    if (index != _tabController.index) {
      _tabController.index = index;
    }
  }

  int _findTabIndex(String path) {
    for (var i = 0; i < widget.tabs.length; i++) {
      if (path == widget.tabs[i].path ||
          path.startsWith('${widget.tabs[i].path}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options ?? const TabBarOptions();

    return Scaffold(
      appBar: AppBar(
        title: widget.title != null ? Text(widget.title!) : null,
        bottom: TabBar(
          controller: _tabController,
          tabs: widget.tabs.map((t) => t.toTab()).toList(),
          isScrollable: options.isScrollable,
          indicatorColor: options.indicatorColor,
          indicatorWeight: options.indicatorWeight,
          labelColor: options.labelColor,
          unselectedLabelColor: options.unselectedLabelColor,
          labelStyle: options.labelStyle,
          unselectedLabelStyle: options.unselectedLabelStyle,
          padding: options.padding,
          indicatorPadding: options.indicatorPadding,
          dividerColor: options.dividerColor,
        ),
      ),
      body: widget.child,
    );
  }
}

/// Customizable tab bar shell for more control
class CustomTabBarShell extends StatefulWidget {
  const CustomTabBarShell({
    super.key,
    required this.tabs,
    required this.child,
    this.appBar,
    this.options,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final List<TabConfig> tabs;
  final Widget child;
  final PreferredSizeWidget? appBar;
  final TabBarOptions? options;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  State<CustomTabBarShell> createState() => _CustomTabBarShellState();
}

class _CustomTabBarShellState extends State<CustomTabBarShell>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      context.go(widget.tabs[_tabController.index].path);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTabIndex();
  }

  void _syncTabIndex() {
    final currentPath = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < widget.tabs.length; i++) {
      if (currentPath == widget.tabs[i].path ||
          currentPath.startsWith('${widget.tabs[i].path}/')) {
        if (i != _tabController.index) {
          _tabController.index = i;
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options ?? const TabBarOptions();

    return Scaffold(
      appBar: widget.appBar ??
          AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: widget.tabs.map((t) => t.toTab()).toList(),
              isScrollable: options.isScrollable,
              indicatorColor: options.indicatorColor,
              indicatorWeight: options.indicatorWeight,
              labelColor: options.labelColor,
              unselectedLabelColor: options.unselectedLabelColor,
            ),
          ),
      body: widget.child,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }

  /// Get the tab controller for external use
  TabController get tabController => _tabController;
}
