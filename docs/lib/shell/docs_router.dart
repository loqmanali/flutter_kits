import 'package:flutter/material.dart';

/// Browser-URL wiring for the docs.
///
/// Routes are the same flat strings the catalog already uses (`/widget_kit`,
/// `/widget_kit/app-button`), so nothing else has to change: the delegate just
/// keeps that string in sync with the address bar. Deep links, browser
/// back/forward, and "copy this link" all fall out of that.
///
/// The default (hash) URL strategy is kept deliberately — `/#/widget_kit` needs
/// no server-side rewrite rule, so the built site drops onto GitHub Pages or any
/// static host untouched.
class DocsRouteParser extends RouteInformationParser<String> {
  const DocsRouteParser();

  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) async {
    final path = routeInformation.uri.path;
    return path.isEmpty ? '/' : path;
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) =>
      RouteInformation(uri: Uri.parse(configuration));
}

/// Holds the current route string and rebuilds the shell when it changes.
class DocsRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  DocsRouterDelegate(this.pageBuilder);

  /// Builds the full shell for a route string.
  final Widget Function(String path) pageBuilder;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _path = '/';
  String get path => _path;

  @override
  String? get currentConfiguration => _path;

  /// Navigate, pushing a browser history entry.
  void go(String path) {
    if (_path == path) return;
    _path = path;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    _path = configuration;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        // One page: the shell swaps its body itself, so there is no in-app
        // navigation stack to maintain — history lives in the browser.
        pages: [
          MaterialPage<void>(key: const ValueKey('docs-shell'), child: pageBuilder(_path)),
        ],
        onDidRemovePage: (_) {},
      );
}

/// Lets any descendant navigate without threading a callback down the tree.
class DocsNavigator extends InheritedWidget {
  const DocsNavigator({
    super.key,
    required this.delegate,
    required super.child,
  });

  final DocsRouterDelegate delegate;

  static void go(BuildContext context, String path) {
    context.dependOnInheritedWidgetOfExactType<DocsNavigator>()!.delegate.go(path);
  }

  @override
  bool updateShouldNotify(DocsNavigator oldWidget) => delegate != oldWidget.delegate;
}
