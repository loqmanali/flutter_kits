import 'package:flutter/material.dart';

/// Custom Page Transition
///
/// Provides custom page route transitions.
class CustomPageTransition<T> extends PageRouteBuilder<T> {
  /// The page to transition to
  final Widget page;

  /// Duration of the transition
  @override
  final Duration transitionDuration;

  /// Reverse duration of the transition
  @override
  final Duration reverseTransitionDuration;

  /// Creates a custom page transition
  CustomPageTransition({
    required this.page,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                ),
                child: child,
              ),
            );
          },
        );

  /// Creates a fade transition
  factory CustomPageTransition.fade({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomPageTransition(
      page: page,
      transitionDuration: duration,
    );
  }

  /// Creates a slide transition from right
  factory CustomPageTransition.slideRight({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomPageTransition(
      page: page,
      transitionDuration: duration,
    );
  }
}
