import 'package:flutter/material.dart';

import '../../../core/enums/animation_curve.dart';
import '../../../core/models/animation_config.dart';

/// Rotation Transition Widget
///
/// Provides rotation animation for a child widget.
class RotationTransitionWidget extends StatefulWidget {
  /// The child widget to animate
  final Widget child;

  /// Animation configuration
  final AnimationConfig config;

  /// Number of rotations
  final double turns;

  const RotationTransitionWidget({
    super.key,
    required this.child,
    this.config = const AnimationConfig(),
    this.turns = 1.0,
  });

  @override
  State<RotationTransitionWidget> createState() =>
      _RotationTransitionWidgetState();
}

class _RotationTransitionWidgetState extends State<RotationTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.config.duration,
    );

    _animation = Tween<double>(begin: 0.0, end: widget.turns).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.config.curve.toFlutterCurve(),
      ),
    );

    if (widget.config.autoPlay) {
      Future.delayed(widget.config.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.config.onComplete?.call();
      }
    });
  }

  void play() => _controller.forward();
  void reverse() => _controller.reverse();
  void reset() => _controller.reset();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: widget.child,
    );
  }
}
