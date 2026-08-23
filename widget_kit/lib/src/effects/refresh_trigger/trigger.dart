part of '../refresh_trigger.dart';

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
                          _EdgePositioned(
                            direction: widget.direction,
                            reverse: widget.reverse,
                            child: FractionalTranslation(
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

/// Pins the indicator to the edge the pull comes from. A class, not a
/// wrapper method, so the Stack's parent data still resolves (a
/// StatelessWidget owns no RenderObject) while Flutter can skip rebuilding it.
class _EdgePositioned extends StatelessWidget {
  const _EdgePositioned({
    required this.direction,
    required this.reverse,
    required this.child,
  });

  final Axis direction;
  final bool reverse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.vertical) {
      return Positioned(
        top: !reverse ? 0 : null,
        bottom: !reverse ? null : 0,
        left: 0,
        right: 0,
        child: child,
      );
    }
    return Positioned(
      top: 0,
      bottom: 0,
      left: reverse ? null : 0,
      right: reverse ? 0 : null,
      child: child,
    );
  }
}
