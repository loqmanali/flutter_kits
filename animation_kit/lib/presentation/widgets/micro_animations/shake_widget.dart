import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/animation_config.dart';

/// Shake Widget
///
/// Provides a shaking animation effect for a child widget.
class ShakeWidget extends StatefulWidget {
  /// The child widget to animate
  final Widget child;

  /// Animation configuration
  final AnimationConfig config;

  /// Shake intensity (pixels)
  final double shakeIntensity;

  /// Number of shakes
  final int shakeCount;

  const ShakeWidget({
    super.key,
    required this.child,
    this.config = const AnimationConfig(),
    this.shakeIntensity = 10.0,
    this.shakeCount = 4,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.config.duration,
    );

    if (widget.config.autoPlay) {
      _controller.forward();
    }
  }

  void play() => _controller.forward(from: 0);
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
        final sineValue = math.sin(_controller.value * widget.shakeCount * math.pi);
        return Transform.translate(
          offset: Offset(sineValue * widget.shakeIntensity, 0),
          child: widget.child,
        );
      },
    );
  }
}
