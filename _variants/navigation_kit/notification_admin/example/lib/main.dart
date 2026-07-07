// Minimal example: wire navigation_kit into a GoRouter app.
//
// Documentation snippet — drop into a real project for a runnable demo.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation_kit/navigation_kit.dart';

void main() {
  NavigationKitRuntime.use();

  final router = GoRouter(
    navigatorKey: NavigationKitRuntime.rootKey,
    initialLocation: '/home',
    observers: [LoggingNavigatorObserver()],
    routes: [
      GoRoute(path: '/home', builder: (_, __) => const _HomeScreen()),
      RouteBuilder.fullScreen(
        path: '/details/:id',
        builder: (_, state) => _DetailsScreen(id: state.pathParameters['id']!),
      ),
    ],
  );

  runApp(MaterialApp.router(routerConfig: router));
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.pushTo('/details/42'),
          child: const Text('Open details'),
        ),
      ),
    );
  }
}

class _DetailsScreen extends StatelessWidget {
  const _DetailsScreen({required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details #$id')),
      body: Center(
        child: ElevatedButton(
          onPressed: context.goBack,
          child: const Text('Back'),
        ),
      ),
    );
  }
}
