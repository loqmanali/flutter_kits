// =============================================================================
// TRANSITION ROUTES
// =============================================================================
//
// This file provides custom Page implementations with different transitions.
// Use these to create smooth, engaging navigation experiences.
//
// AVAILABLE TRANSITIONS:
// - Fade
// - Slide (from any direction)
// - Scale
// - Rotation
// - Custom combinations
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom Page with fade transition
class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  FadeTransitionPage({
    required super.child,
    super.key,
    super.name,
    super.transitionDuration,
    super.reverseTransitionDuration,
    Curve curve = Curves.easeInOut,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
              child: child,
            );
          },
        );
}

/// Custom Page with slide transition
class SlideTransitionPage<T> extends CustomTransitionPage<T> {
  SlideTransitionPage({
    required super.child,
    super.key,
    super.name,
    super.transitionDuration,
    super.reverseTransitionDuration,
    SlideDirection direction = SlideDirection.rightToLeft,
    Curve curve = Curves.easeInOut,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: direction.beginOffset,
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          },
        );
}

/// Direction for slide transitions
enum SlideDirection {
  leftToRight(Offset(-1, 0)),
  rightToLeft(Offset(1, 0)),
  topToBottom(Offset(0, -1)),
  bottomToTop(Offset(0, 1));

  const SlideDirection(this.beginOffset);
  final Offset beginOffset;
}

/// Custom Page with scale transition
class ScaleTransitionPage<T> extends CustomTransitionPage<T> {
  ScaleTransitionPage({
    required super.child,
    super.key,
    super.name,
    super.transitionDuration,
    super.reverseTransitionDuration,
    double beginScale = 0.0,
    Curve curve = Curves.easeInOut,
    Alignment alignment = Alignment.center,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return ScaleTransition(
              scale: Tween<double>(
                begin: beginScale,
                end: 1.0,
              ).animate(curvedAnimation),
              alignment: alignment,
              child: child,
            );
          },
        );
}

/// Custom Page with rotation transition
class RotationTransitionPage<T> extends CustomTransitionPage<T> {
  RotationTransitionPage({
    required super.child,
    super.key,
    super.name,
    super.transitionDuration = const Duration(milliseconds: 400),
    super.reverseTransitionDuration = const Duration(milliseconds: 400),
    double beginTurns = 0.5,
    Curve curve = Curves.easeInOut,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return RotationTransition(
              turns: Tween<double>(
                begin: beginTurns,
                end: 0.0,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Custom Page with slide + fade transition
class SlideFadeTransitionPage<T> extends CustomTransitionPage<T> {
  SlideFadeTransitionPage({
    required super.child,
    super.key,
    super.name,
    super.transitionDuration,
    super.reverseTransitionDuration,
    SlideDirection direction = SlideDirection.rightToLeft,
    Curve curve = Curves.easeInOut,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: direction.beginOffset,
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Custom Page with scale + fade transition
class ScaleFadeTransitionPage<T> extends CustomTransitionPage<T> {
  ScaleFadeTransitionPage({
    required super.child,
    super.key,
    super.name,
    super.transitionDuration,
    super.reverseTransitionDuration,
    double beginScale = 0.8,
    Curve curve = Curves.easeInOut,
    Alignment alignment = Alignment.center,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return ScaleTransition(
              scale: Tween<double>(
                begin: beginScale,
                end: 1.0,
              ).animate(curvedAnimation),
              alignment: alignment,
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            );
          },
        );
}

/// No transition (instant navigation)
class NoTransitionPage<T> extends CustomTransitionPage<T> {
  NoTransitionPage({
    required super.child,
    super.key,
    super.name,
  }) : super(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
}

/// Shared axis transition (Material motion)
class SharedAxisTransitionPage<T> extends CustomTransitionPage<T> {
  SharedAxisTransitionPage({
    required super.child,
    super.key,
    super.name,
    super.transitionDuration,
    super.reverseTransitionDuration,
    SharedAxisDirection direction = SharedAxisDirection.horizontal,
    Curve curve = Curves.easeInOut,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            Offset beginOffset;
            switch (direction) {
              case SharedAxisDirection.horizontal:
                beginOffset = const Offset(30, 0);
                break;
              case SharedAxisDirection.vertical:
                beginOffset = const Offset(0, 30);
                break;
              case SharedAxisDirection.scaled:
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0)
                      .animate(curvedAnimation),
                  child: FadeTransition(
                    opacity: curvedAnimation,
                    child: child,
                  ),
                );
            }

            return Transform.translate(
              offset: Tween<Offset>(
                begin: beginOffset,
                end: Offset.zero,
              ).evaluate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Direction for shared axis transition
enum SharedAxisDirection {
  horizontal,
  vertical,
  scaled,
}

/// Builder helpers for transition routes
class TransitionRouteBuilder {
  TransitionRouteBuilder._();

  /// Build a route with fade transition
  static GoRoute fade({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) => FadeTransitionPage(
        key: state.pageKey,
        name: name,
        transitionDuration: duration,
        curve: curve,
        child: builder(context, state),
      ),
      routes: routes,
    );
  }

  /// Build a route with slide transition
  static GoRoute slide({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    Duration duration = const Duration(milliseconds: 300),
    SlideDirection direction = SlideDirection.rightToLeft,
    Curve curve = Curves.easeInOut,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) => SlideTransitionPage(
        key: state.pageKey,
        name: name,
        transitionDuration: duration,
        direction: direction,
        curve: curve,
        child: builder(context, state),
      ),
      routes: routes,
    );
  }

  /// Build a route with scale transition
  static GoRoute scale({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    Duration duration = const Duration(milliseconds: 300),
    double beginScale = 0.0,
    Curve curve = Curves.easeInOut,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) => ScaleTransitionPage(
        key: state.pageKey,
        name: name,
        transitionDuration: duration,
        beginScale: beginScale,
        curve: curve,
        child: builder(context, state),
      ),
      routes: routes,
    );
  }

  /// Build a route with no transition
  static GoRoute noTransition({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        name: name,
        child: builder(context, state),
      ),
      routes: routes,
    );
  }

  /// Build a route with shared axis transition (Material motion)
  static GoRoute sharedAxis({
    required String path,
    String? name,
    required Widget Function(BuildContext, GoRouterState) builder,
    Duration duration = const Duration(milliseconds: 300),
    SharedAxisDirection direction = SharedAxisDirection.horizontal,
    Curve curve = Curves.easeInOut,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) => SharedAxisTransitionPage(
        key: state.pageKey,
        name: name,
        transitionDuration: duration,
        direction: direction,
        curve: curve,
        child: builder(context, state),
      ),
      routes: routes,
    );
  }
}
