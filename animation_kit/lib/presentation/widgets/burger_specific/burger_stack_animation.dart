import 'package:flutter/material.dart';

/// Burger Stack Animation
///
/// Animates burger ingredients stacking on top of each other.
class BurgerStackAnimation extends StatefulWidget {
  /// List of ingredient widgets to stack
  final List<Widget> ingredients;

  /// Duration of the stacking animation
  final Duration duration;

  /// Delay between each ingredient
  final Duration staggerDelay;

  /// Whether to auto-play the animation
  final bool autoPlay;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  const BurgerStackAnimation({
    super.key,
    required this.ingredients,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.autoPlay = true,
    this.onComplete,
  });

  @override
  State<BurgerStackAnimation> createState() => _BurgerStackAnimationState();
}

class _BurgerStackAnimationState extends State<BurgerStackAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (widget.autoPlay) {
      _playAnimation();
    }
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.ingredients.length,
      (index) => AnimationController(
        vsync: this,
        duration: widget.duration,
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.bounceOut,
      );
    }).toList();
  }

  Future<void> _playAnimation() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(widget.staggerDelay);
      _controllers[i].forward();
    }
    await Future.delayed(widget.duration);
    widget.onComplete?.call();
  }

  void play() => _playAnimation();

  void reset() {
    for (final controller in _controllers) {
      controller.reset();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(widget.ingredients.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -50 * (1 - _animations[index].value)),
              child: Opacity(
                opacity: _animations[index].value,
                child: widget.ingredients[index],
              ),
            );
          },
        );
      }),
    );
  }
}
