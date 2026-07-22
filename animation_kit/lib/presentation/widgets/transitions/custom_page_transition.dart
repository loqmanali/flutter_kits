import 'package:flutter/material.dart';

/// Custom Page Transition
///
/// Provides custom page route transitions.
class CustomPageTransition<T> extends PageRouteBuilder<T> {
  /// The page to transition to
  final Widget page;

  /// Creates a custom page transition.
  ///
  /// [transitionDuration] and [reverseTransitionDuration] are forwarded to
  /// [PageRouteBuilder], which already stores and exposes them — redeclaring
  /// them here as fields shadowed the inherited ones (`overridden_fields`).
  CustomPageTransition({
    required this.page,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
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
