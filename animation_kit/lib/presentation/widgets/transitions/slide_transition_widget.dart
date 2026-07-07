import 'package:flutter/material.dart';

import '../../../config/transition_config.dart';
import '../../../core/enums/animation_curve.dart';

/// Slide Transition Widget
///
/// Provides slide animation for a child widget.
class SlideTransitionWidget extends StatefulWidget {
  /// The child widget to animate
  final Widget child;

  /// Transition configuration
  final TransitionConfig config;

  const SlideTransitionWidget({
    super.key,
    required this.child,
    required this.config,
  });

  @override
  State<SlideTransitionWidget> createState() => _SlideTransitionWidgetState();
}

class _SlideTransitionWidgetState extends State<SlideTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.config.duration,
    );

    _animation = Tween<Offset>(
      begin: widget.config.beginOffset,
      end: widget.config.endOffset,
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
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}
