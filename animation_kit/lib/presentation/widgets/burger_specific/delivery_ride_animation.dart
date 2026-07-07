import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Delivery Ride Animation
///
/// Animates a delivery vehicle moving across the screen.
class DeliveryRideAnimation extends StatefulWidget {
  /// The delivery vehicle widget
  final Widget vehicle;

  /// Duration of the ride animation
  final Duration duration;

  /// Whether to repeat the animation
  final bool repeat;

  /// Whether to auto-play the animation
  final bool autoPlay;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  const DeliveryRideAnimation({
    super.key,
    required this.vehicle,
    this.duration = const Duration(seconds: 2),
    this.repeat = false,
    this.autoPlay = true,
    this.onComplete,
  });

  @override
  State<DeliveryRideAnimation> createState() => _DeliveryRideAnimationState();
}

class _DeliveryRideAnimationState extends State<DeliveryRideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
        if (widget.repeat) {
          _controller.reset();
          _controller.forward();
        }
      }
    });

    if (widget.autoPlay) {
      _controller.forward();
    }
  }

  void play() => _controller.forward();
  void pause() => _controller.stop();
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
        final bounce = (math.sin(_bounceAnimation.value * 10).abs() * 5);
        return Transform.translate(
          offset: Offset(
            _slideAnimation.value * MediaQuery.of(context).size.width / 2,
            -bounce,
          ),
          child: widget.vehicle,
        );
      },
    );
  }
}
