import 'package:flutter/material.dart';

import '../../../core/enums/animation_curve.dart';
import '../../../core/models/animation_config.dart';

/// Scale Transition Widget
///
/// Provides scale animation for a child widget.
class ScaleTransitionWidget extends StatefulWidget {
  /// The child widget to animate
  final Widget child;

  /// Animation configuration
  final AnimationConfig config;

  /// Begin scale
  final double beginScale;

  /// End scale
  final double endScale;

  const ScaleTransitionWidget({
    super.key,
    required this.child,
    this.config = const AnimationConfig(),
    this.beginScale = 0.0,
    this.endScale = 1.0,
  });

  @override
  State<ScaleTransitionWidget> createState() => _ScaleTransitionWidgetState();
}

class _ScaleTransitionWidgetState extends State<ScaleTransitionWidget>
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

    _animation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(
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
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
