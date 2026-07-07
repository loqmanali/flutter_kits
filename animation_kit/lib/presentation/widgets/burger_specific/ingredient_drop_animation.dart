import 'package:flutter/material.dart';

/// Ingredient Drop Animation
///
/// Animates an ingredient dropping from above with bounce effect.
class IngredientDropAnimation extends StatefulWidget {
  /// The ingredient widget to animate
  final Widget child;

  /// Duration of the drop animation
  final Duration duration;

  /// Drop height
  final double dropHeight;

  /// Whether to auto-play the animation
  final bool autoPlay;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  const IngredientDropAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.dropHeight = 100.0,
    this.autoPlay = true,
    this.onComplete,
  });

  @override
  State<IngredientDropAnimation> createState() =>
      _IngredientDropAnimationState();
}

class _IngredientDropAnimationState extends State<IngredientDropAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dropAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _dropAnimation = Tween<double>(begin: -widget.dropHeight, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.autoPlay) {
      _controller.forward();
    }
  }

  void play() => _controller.forward();
  void reset() => _controller.reset();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _dropAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
