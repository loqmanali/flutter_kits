import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef RefreshIndicatorBuilder = Widget Function(
  BuildContext context,
  RefreshTriggerStage stage,
);

typedef FutureVoidCallback = Future<void> Function();

/// ===============================
/// THEME (Pure Flutter)
/// ===============================

class RefreshTriggerTheme {
  final double? minExtent;
  final double? maxExtent;
  final RefreshIndicatorBuilder? indicatorBuilder;
  final Curve? curve;
  final Duration? completeDuration;

  const RefreshTriggerTheme({
    this.minExtent,
    this.maxExtent,
    this.indicatorBuilder,
    this.curve,
    this.completeDuration,
  });

  RefreshTriggerTheme copyWith({
    ValueGetter<double?>? minExtent,
    ValueGetter<double?>? maxExtent,
    ValueGetter<RefreshIndicatorBuilder?>? indicatorBuilder,
    ValueGetter<Curve?>? curve,
    ValueGetter<Duration?>? completeDuration,
  }) {
    return RefreshTriggerTheme(
      minExtent: minExtent == null ? this.minExtent : minExtent(),
      maxExtent: maxExtent == null ? this.maxExtent : maxExtent(),
      indicatorBuilder:
          indicatorBuilder == null ? this.indicatorBuilder : indicatorBuilder(),
      curve: curve == null ? this.curve : curve(),
      completeDuration:
          completeDuration == null ? this.completeDuration : completeDuration(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RefreshTriggerTheme &&
        other.minExtent == minExtent &&
        other.maxExtent == maxExtent &&
        other.indicatorBuilder == indicatorBuilder &&
        other.curve == curve &&
        other.completeDuration == completeDuration;
  }

  @override
  int get hashCode => Object.hash(
        minExtent,
        maxExtent,
        indicatorBuilder,
        curve,
        completeDuration,
      );

  @override
  String toString() {
    return 'RefreshTriggerTheme('
        'minExtent: $minExtent, '
        'maxExtent: $maxExtent, '
        'indicatorBuilder: $indicatorBuilder, '
        'curve: $curve, '
        'completeDuration: $completeDuration)';
  }
}

/// Inherited provider for the theme (optional).
class RefreshTriggerThemeProvider extends InheritedWidget {
  final RefreshTriggerTheme data;

  const RefreshTriggerThemeProvider({
    super.key,
    required this.data,
    required super.child,
  });

  static RefreshTriggerTheme? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<RefreshTriggerThemeProvider>()
        ?.data;
  }

  @override
  bool updateShouldNotify(RefreshTriggerThemeProvider oldWidget) =>
      oldWidget.data != data;
}

/// Helper to pick the first non-null value.
T styleValue<T>({required T defaultValue, T? widgetValue, T? themeValue}) {
  return widgetValue ?? themeValue ?? defaultValue;
}

/// ===============================
/// PUBLIC API
/// ===============================

enum TriggerStage { idle, pulling, refreshing, completed }

class RefreshTriggerStage {
  final TriggerStage stage;
  final Animation<double> extent;
  final Axis direction;
  final bool reverse;

  const RefreshTriggerStage(
    this.stage,
    this.extent,
    this.direction,
    this.reverse,
  );

  double get extentValue => extent.value;
}

class RefreshTrigger extends StatefulWidget {
  static Widget defaultIndicatorBuilder(
    BuildContext context,
    RefreshTriggerStage stage,
  ) {
    return DefaultRefreshIndicator(stage: stage);
  }

  final double? minExtent;
  final double? maxExtent;
  final FutureVoidCallback? onRefresh;
  final Widget child;
  final Axis direction;
  final bool reverse;
  final RefreshIndicatorBuilder? indicatorBuilder;
  final Curve? curve;
  final Duration? completeDuration;

  const RefreshTrigger({
    super.key,
    this.minExtent,
    this.maxExtent,
    this.onRefresh,
    this.direction = Axis.vertical,
    this.reverse = false,
    this.indicatorBuilder,
    this.curve,
    this.completeDuration,
    required this.child,
  });

  @override
  State<RefreshTrigger> createState() => RefreshTriggerState();
}

/// ===============================
/// DEFAULT INDICATOR (Pure Flutter)
/// ===============================

class DefaultRefreshIndicator extends StatefulWidget {
  final RefreshTriggerStage stage;

  const DefaultRefreshIndicator({super.key, required this.stage});

  @override
  State<DefaultRefreshIndicator> createState() =>
      _DefaultRefreshIndicatorState();
}

class _DefaultRefreshIndicatorState extends State<DefaultRefreshIndicator> {
  static const _kPadH = EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  static const _kPadSmall = EdgeInsets.all(6);
  static const _kAnimDuration = Duration(milliseconds: 250);

  Widget _spacerW(double w) => SizedBox(width: w);

  Widget _buildRefreshing(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text('Refreshing...')),
        SizedBox(width: 8),
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }

  Widget _buildCompleted(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Flexible(child: Text('Completed')),
        _spacerW(8),
        SizedBox(
          width: 24,
          height: 16,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return CustomPaint(
                painter: AnimatedCheckPainter(
                  progress: value,
                  color: color,
                  strokeWidth: 1.8,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPulling(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.stage.extent,
      builder: (context, child) {
        final v = widget.stage.extentValue.clamp(0.0, 1.0);
        double angle;
        if (widget.stage.direction == Axis.vertical) {
          // 0 -> 1 (0 -> 180)
          angle = -math.pi * v;
        } else {
          // 0 -> 1 (90 -> 270)
          angle = -math.pi / 2 + -math.pi * v;
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: angle,
              child: const Icon(Icons.arrow_downward, size: 18),
            ),
            _spacerW(8),
            Flexible(
              child: Text(v < 1 ? 'Pull to refresh' : 'Release to refresh'),
            ),
            _spacerW(8),
            Transform.rotate(
              angle: angle,
              child: const Icon(Icons.arrow_downward, size: 18),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIdle(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [Flexible(child: Text('Pull to refresh'))],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (widget.stage.stage) {
      case TriggerStage.refreshing:
        child = _buildRefreshing(context);
        break;
      case TriggerStage.completed:
        child = _buildCompleted(context);
        break;
      case TriggerStage.pulling:
        child = _buildPulling(context);
        break;
      case TriggerStage.idle:
        child = _buildIdle(context);
        break;
    }

    final card = Container(
      padding: widget.stage.stage == TriggerStage.pulling ? _kPadSmall : _kPadH,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: AnimatedSwitcher(
        duration: _kAnimDuration,
        child: KeyedSubtree(key: ValueKey(widget.stage.stage), child: child),
      ),
    );

    return Center(child: card);
  }
}

/// A compact pill-style refresh indicator — flat (no shadow), localised
/// strings, rotating arrow on pull, spinner on refresh, checkmark on done.
///
/// Use as: `RefreshTrigger(indicatorBuilder: AppPillRefreshIndicator.builder, ...)`
class AppPillRefreshIndicator {
  const AppPillRefreshIndicator._();

  /// Plug straight into `RefreshTrigger.indicatorBuilder`.
  static Widget builder(BuildContext context, RefreshTriggerStage stage) {
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;
    final onSurface = scheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.6);

    String label;
    Widget? trailing;
    switch (stage.stage) {
      case TriggerStage.idle:
        label = 'اسحب للأسفل للتحديث';
        break;
      case TriggerStage.pulling:
        label = stage.extentValue >= 1 ? 'اترك للتحديث' : 'اسحب للأسفل للتحديث';
        trailing = AnimatedBuilder(
          animation: stage.extent,
          builder: (_, __) => Transform.rotate(
            angle: -3.14159 * stage.extentValue.clamp(0.0, 1.0),
            child: Icon(Icons.arrow_downward, size: 14, color: muted),
          ),
        );
        break;
      case TriggerStage.refreshing:
        label = 'جاري التحديث…';
        trailing = SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 1.8, color: primary),
        );
        break;
      case TriggerStage.completed:
        label = 'تم التحديث';
        trailing = Icon(Icons.check, size: 16, color: primary);
        break;
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: muted),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}

/// Draws a checkmark that animates with [progress] 0..1
class AnimatedCheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  AnimatedCheckPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = color;

    // Define a simple check ✔ path based on size.
    final start = Offset(size.width * 0.05, size.height * 0.55);
    final mid = Offset(size.width * 0.40, size.height * 0.90);
    final end = Offset(size.width * 0.95, size.height * 0.10);

    // Animate two segments: start->mid then mid->end
    const total = 1.0;
    const firstSegWeight = 0.5; // first half draws first segment
    if (progress <= firstSegWeight) {
      final t = (progress / firstSegWeight).clamp(0.0, 1.0);
      final p = Offset.lerp(start, mid, t)!;
      canvas.drawLine(start, p, paint);
    } else {
      // draw full first segment
      canvas.drawLine(start, mid, paint);
      // draw partial second segment
      final t = ((progress - firstSegWeight) / (total - firstSegWeight)).clamp(
        0.0,
        1.0,
      );
      final p = Offset.lerp(mid, end, t)!;
      canvas.drawLine(mid, p, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedCheckPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// ===============================
/// CORE LOGIC
/// ===============================

const kDefaultDuration = Duration(milliseconds: 250);

class _RefreshTriggerTween extends Animatable<double> {
  final double minExtent;
  const _RefreshTriggerTween(this.minExtent);
  @override
  double transform(double t) => t / minExtent;
}

class RefreshTriggerState extends State<RefreshTrigger>
    with SingleTickerProviderStateMixin {
  double _currentExtent = 0;
  bool _scrolling = false;
  ScrollDirection _userScrollDirection = ScrollDirection.idle;
  TriggerStage _stage = TriggerStage.idle;
  Future<void>? _currentFuture;
  int _currentFutureCount = 0;

  // Computed theme values
  late double _minExtent;
  late double _maxExtent;
  late RefreshIndicatorBuilder _indicatorBuilder;
  late Curve _curve;
  late Duration _completeDuration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateThemeValues();
  }

  @override
  void didUpdateWidget(covariant RefreshTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateThemeValues();
  }

  void _updateThemeValues() {
    final themeData = RefreshTriggerThemeProvider.of(context);

    _minExtent = styleValue<double>(
      widgetValue: widget.minExtent,
      themeValue: themeData?.minExtent,
      defaultValue: 75.0,
    );

    _maxExtent = styleValue<double>(
      widgetValue: widget.maxExtent,
      themeValue: themeData?.maxExtent,
      defaultValue: 150.0,
    );

    _indicatorBuilder = widget.indicatorBuilder ??
        themeData?.indicatorBuilder ??
        RefreshTrigger.defaultIndicatorBuilder;

    _curve = widget.curve ?? themeData?.curve ?? Curves.easeOutSine;

    _completeDuration = widget.completeDuration ??
        themeData?.completeDuration ??
        const Duration(milliseconds: 500);
  }

  double _calculateSafeExtent(double extent) {
    final e = widget.reverse ? -extent : extent;
    if (e > _minExtent) {
      final relativeExtent = e - _minExtent;
      final maxExtent = _maxExtent;
      final diff = (maxExtent - _minExtent) - relativeExtent;
      final diffNormalized = diff / (maxExtent - _minExtent);
      final decel = Curves.decelerate.transform(diffNormalized.clamp(0, 1));
      return maxExtent - decel * diff;
    }
    return e;
  }

  Widget _wrapPositioned(Widget child) {
    if (widget.direction == Axis.vertical) {
      return Positioned(
        top: !widget.reverse ? 0 : null,
        bottom: !widget.reverse ? null : 0,
        left: 0,
        right: 0,
        child: child,
      );
    } else {
      return Positioned(
        top: 0,
        bottom: 0,
        left: widget.reverse ? null : 0,
        right: widget.reverse ? 0 : null,
        child: child,
      );
    }
  }

  Offset get _offset {
    if (widget.direction == Axis.vertical) {
      return Offset(0, widget.reverse ? 1 : -1);
    } else {
      return Offset(widget.reverse ? 1 : -1, 0);
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is ScrollEndNotification && _scrolling) {
      setState(() {
        final normalizedExtent =
            widget.reverse ? -_currentExtent : _currentExtent;
        if (normalizedExtent >= _minExtent) {
          _scrolling = false;
          refresh();
        } else {
          _stage = TriggerStage.idle;
          _currentExtent = 0;
        }
      });
    } else if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta;
      if (delta != null) {
        final axisDirection = notification.metrics.axisDirection;
        final normalizedDelta = (axisDirection == AxisDirection.down ||
                axisDirection == AxisDirection.right)
            ? -delta
            : delta;

        if (_stage == TriggerStage.pulling) {
          final forward = normalizedDelta > 0;
          if ((forward && _userScrollDirection == ScrollDirection.forward) ||
              (!forward && _userScrollDirection == ScrollDirection.reverse)) {
            setState(() {
              _currentExtent +=
                  widget.reverse ? -normalizedDelta : normalizedDelta;
            });
          } else {
            if (_currentExtent >= _minExtent) {
              _scrolling = false;
              refresh();
            } else {
              setState(() {
                _currentExtent +=
                    widget.reverse ? -normalizedDelta : normalizedDelta;
              });
            }
          }
        } else if (_stage == TriggerStage.idle &&
            (widget.reverse
                ? notification.metrics.extentAfter == 0
                : notification.metrics.extentBefore == 0) &&
            (widget.reverse ? -normalizedDelta : normalizedDelta) > 0) {
          setState(() {
            _currentExtent = 0;
            _scrolling = true;
            _stage = TriggerStage.pulling;
          });
        }
      }
    } else if (notification is UserScrollNotification) {
      _userScrollDirection = notification.direction;
    } else if (notification is OverscrollNotification) {
      final axisDirection = notification.metrics.axisDirection;
      final overscroll = (axisDirection == AxisDirection.down ||
              axisDirection == AxisDirection.right)
          ? -notification.overscroll
          : notification.overscroll;
      if (overscroll > 0) {
        if (_stage == TriggerStage.idle) {
          setState(() {
            _currentExtent = 0;
            _scrolling = true;
            _stage = TriggerStage.pulling;
          });
        } else {
          setState(() {
            _currentExtent += overscroll;
          });
        }
      }
    }
    return false;
  }

  Future<void> refresh([FutureVoidCallback? refreshCallback]) async {
    _scrolling = false;
    final count = ++_currentFutureCount;
    if (_currentFuture != null) {
      await _currentFuture;
    }
    setState(() {
      _currentFuture = _refresh(refreshCallback);
    });
    return _currentFuture!.whenComplete(() {
      if (!mounted || count != _currentFutureCount) return;
      setState(() {
        _currentFuture = null;
        _stage = TriggerStage.completed;
        Timer(_completeDuration, () {
          if (!mounted) return;
          setState(() {
            _stage = TriggerStage.idle;
            _currentExtent = 0;
          });
        });
      });
    });
  }

  Future<void> _refresh([FutureVoidCallback? refresh]) {
    if (_stage != TriggerStage.refreshing) {
      setState(() {
        _stage = TriggerStage.refreshing;
      });
    }
    refresh ??= widget.onRefresh;
    return refresh?.call() ?? Future.value();
  }

  @override
  Widget build(BuildContext context) {
    final tween = _RefreshTriggerTween(_minExtent);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: _AnimatedValueBuilder(
        // When refreshing/completed, hold at minExtent to keep indicator visible.
        value: (_stage == TriggerStage.refreshing ||
                _stage == TriggerStage.completed)
            ? _minExtent
            : _currentExtent,
        duration: _scrolling ? Duration.zero : kDefaultDuration,
        curve: _curve,
        builder: (context, animation) {
          return Stack(
            fit: StackFit.passthrough,
            children: [
              widget.child,
              AnimatedBuilder(
                animation: animation,
                child: _indicatorBuilder(
                  context,
                  RefreshTriggerStage(
                    _stage,
                    tween.animate(animation),
                    widget.direction,
                    widget.reverse,
                  ),
                ),
                builder: (context, child) {
                  return Positioned.fill(
                    child: ClipRect(
                      child: Stack(
                        children: [
                          _wrapPositioned(
                            FractionalTranslation(
                              translation: _offset,
                              child: Transform.translate(
                                offset: widget.direction == Axis.vertical
                                    ? Offset(
                                        0,
                                        _calculateSafeExtent(animation.value),
                                      )
                                    : Offset(
                                        _calculateSafeExtent(animation.value),
                                        0,
                                      ),
                                child: child,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

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

class RefreshTriggerPhysics extends ScrollPhysics {
  const RefreshTriggerPhysics({super.parent});

  @override
  RefreshTriggerPhysics applyTo(ScrollPhysics? ancestor) {
    return RefreshTriggerPhysics(parent: buildParent(ancestor));
  }
}

/// ===============================
/// USAGE EXAMPLE
/// ===============================
///
/// RefreshTriggerThemeProvider(
///   data: const RefreshTriggerTheme(
///     minExtent: 80,
///     maxExtent: 150,
///     curve: Curves.easeOutSine,
///   ),
///   child: RefreshTrigger(
///     onRefresh: () async {
///       await Future.delayed(const Duration(seconds: 2));
///     },
///     child: ListView.builder(
///       physics: const BouncingScrollPhysics(),
///       itemCount: 30,
///       itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
///     ),
///   ),
/// )
