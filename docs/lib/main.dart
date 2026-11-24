import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/catalog.dart';
import 'router.dart';
import 'shell/docs_router.dart';
import 'shell/docs_scaffold.dart';
import 'shell/theme_controller.dart';
import 'theme/docs_theme.dart';

void main() {
  runApp(const ProviderScope(child: DocsApp()));
}

class DocsApp extends StatelessWidget {
  const DocsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeModeController(
      child: Builder(
        builder: (context) {
          final mode = ThemeModeController.of(context);
          return MaterialApp.router(
            title: 'flutter_kits docs',
            debugShowCheckedModeBanner: false,
            theme: DocsTheme.light(),
            darkTheme: DocsTheme.dark(),
            themeMode: mode,
            routerDelegate: _delegate,
            routeInformationParser: const DocsRouteParser(),
          );
        },
      ),
    );
  }
}

/// One delegate for the app's lifetime: it owns the current route and is what
/// the sidebar, home cards, and search dialog all navigate through.
final _delegate = DocsRouterDelegate(_buildShell);

Widget _buildShell(String path) {
  final resolution = resolveRoute(path);

  return DocsNavigator(
    delegate: _delegate,
    child: Builder(
      builder: (context) {
        void navigate(String route) => _delegate.go(route);

        final child = switch (resolution.kind) {
          RouteKind.home => buildHomePage(navigate),
          RouteKind.notFound => buildNotFoundPage(resolution.path, navigate),
          _ => resolution.child!,
        };

        return DocsScaffold(
          catalog: catalog,
          currentPath: path,
          currentTitle: resolution.title,
          onNavigate: navigate,
          child: child,
        );
      },
    ),
  );
}
