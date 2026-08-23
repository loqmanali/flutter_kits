part of '../refresh_trigger.dart';

/// A tiny helper similar to "AnimatedValueBuilder.animation" that exposes an `Animation<double>`.
class _AnimatedValueBuilder extends StatefulWidget {
  final double value;
  final Duration duration;
  final Curve curve;
  final Widget Function(BuildContext, Animation<double>) builder;

  const _AnimatedValueBuilder({
    required this.value,
    required this.duration,
    required this.curve,
    required this.builder,
  });

  @override
  State<_AnimatedValueBuilder> createState() => _AnimatedValueBuilderState();
}

class _AnimatedValueBuilderState extends State<_AnimatedValueBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _current = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.value;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didUpdateWidget(covariant _AnimatedValueBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _current ||
        widget.duration != oldWidget.duration ||
        widget.curve != oldWidget.curve) {
      // Restart the controller with new duration/curve
      _controller.duration = widget.duration;
      _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

      // Animate from _current to widget.value
      _controller.reset();
      _controller.forward();
      _current = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The exposed animation's value will be _current * _animation.value,
  // but we actually need the lerp from previous to current.
  // Simpler: manually map in builder below.
  @override
  Widget build(BuildContext context) {
    final begin = _animation.isDismissed
        ? _current
        : _current; // placeholder (we'll compute in AnimatedBuilder)
    final target = _current;

    // We need the previous value to lerp from; store it outside:
    // We'll keep it in a local closure variable using StatefulBuilder-like approach.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: target),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, value, _) {
        // Wrap primitive value in an Animation-like adapter
        final anim = _ValueAnimation(value);
        return widget.builder(context, anim);
      },
    );
  }
}

class _ValueAnimation extends Animation<double> {
  final double _value;
  const _ValueAnimation(this._value);

  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
  @override
  void addStatusListener(AnimationStatusListener listener) {}
  @override
  void removeStatusListener(AnimationStatusListener listener) {}

  @override
  AnimationStatus get status => AnimationStatus.completed;

  @override
  double get value => _value;
}
