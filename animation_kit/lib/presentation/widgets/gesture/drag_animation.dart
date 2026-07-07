import 'package:flutter/material.dart';

/// Drag Animation Widget
///
/// Provides drag animation capabilities for a child widget.
class DragAnimation extends StatefulWidget {
  /// The child widget to animate
  final Widget child;

  /// Callback when drag starts
  final VoidCallback? onDragStart;

  /// Callback when drag ends
  final VoidCallback? onDragEnd;

  /// Callback when drag is cancelled
  final VoidCallback? onDragCancel;

  /// Whether to reset position after drag
  final bool resetOnEnd;

  /// Duration of reset animation
  final Duration resetDuration;

  const DragAnimation({
    super.key,
    required this.child,
    this.onDragStart,
    this.onDragEnd,
    this.onDragCancel,
    this.resetOnEnd = true,
    this.resetDuration = const Duration(milliseconds: 200),
  });

  @override
  State<DragAnimation> createState() => _DragAnimationState();
}

class _DragAnimationState extends State<DragAnimation>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.resetDuration,
    );
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    widget.onDragStart?.call();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    widget.onDragEnd?.call();
    if (widget.resetOnEnd) {
      _resetPosition();
    }
  }

  void _resetPosition() {
    _animation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _animation.addListener(() {
      setState(() {
        _offset = _animation.value;
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
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _offset,
        child: widget.child,
      ),
    );
  }
}
