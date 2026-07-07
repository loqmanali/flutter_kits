import 'package:flutter/material.dart';

/// Swipe Animation Widget
///
/// Provides swipe animation capabilities for a child widget.
class SwipeAnimation extends StatefulWidget {
  /// The child widget to animate
  final Widget child;

  /// Callback when swiped left
  final VoidCallback? onSwipeLeft;

  /// Callback when swiped right
  final VoidCallback? onSwipeRight;

  /// Callback when swiped up
  final VoidCallback? onSwipeUp;

  /// Callback when swiped down
  final VoidCallback? onSwipeDown;

  /// Minimum swipe distance to trigger callback
  final double threshold;

  /// Duration of the swipe animation
  final Duration duration;

  const SwipeAnimation({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.threshold = 50.0,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<SwipeAnimation> createState() => _SwipeAnimationState();
}

class _SwipeAnimationState extends State<SwipeAnimation>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_offset.dx.abs() > widget.threshold) {
      if (_offset.dx > 0) {
        widget.onSwipeRight?.call();
      } else {
        widget.onSwipeLeft?.call();
      }
    }

    if (_offset.dy.abs() > widget.threshold) {
      if (_offset.dy > 0) {
        widget.onSwipeDown?.call();
      } else {
        widget.onSwipeUp?.call();
      }
    }

    _resetPosition();
  }

  void _resetPosition() {
    final animation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    animation.addListener(() {
      setState(() {
        _offset = animation.value;
      });
    });

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _offset,
        child: widget.child,
      ),
    );
  }
}
