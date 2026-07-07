import 'package:flutter/material.dart';

/// Animation Mixin
///
/// Provides common animation functionality for StatefulWidgets.
/// Use this mixin to easily add animation capabilities to your widgets.
///
/// ## Examples
///
/// ```dart
/// class MyAnimatedWidget extends StatefulWidget {
///   @override
///   State<MyAnimatedWidget> createState() => _MyAnimatedWidgetState();
/// }
///
/// class _MyAnimatedWidgetState extends State<MyAnimatedWidget>
///     with SingleTickerProviderStateMixin, AnimationMixin {
///   @override
///   void initState() {
///     super.initState();
///     initAnimation(duration: Duration(milliseconds: 300));
///   }
/// }
/// ```
mixin AnimationMixin<T extends StatefulWidget> on State<T>, TickerProvider {
  /// Animation controller for managing animations
  late AnimationController animationController;

  /// Whether the animation has been initialized
  bool _isInitialized = false;

  /// Initializes the animation controller
  ///
  /// Call this in [initState] to set up the animation.
  void initAnimation({
    Duration duration = const Duration(milliseconds: 300),
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
  }) {
    animationController = AnimationController(
      vsync: this,
      duration: duration,
      lowerBound: lowerBound,
      upperBound: upperBound,
      animationBehavior: animationBehavior,
    );
    _isInitialized = true;
  }

  /// Plays the animation forward
  void playAnimation() {
    if (_isInitialized) {
      animationController.forward();
    }
  }

  /// Plays the animation in reverse
  void reverseAnimation() {
    if (_isInitialized) {
      animationController.reverse();
    }
  }

  /// Resets the animation to the beginning
  void resetAnimation() {
    if (_isInitialized) {
      animationController.reset();
    }
  }

  /// Stops the animation
  void stopAnimation() {
    if (_isInitialized) {
      animationController.stop();
    }
  }

  /// Repeats the animation
  void repeatAnimation({bool reverse = false}) {
    if (_isInitialized) {
      animationController.repeat(reverse: reverse);
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      animationController.dispose();
    }
    super.dispose();
  }
}
