import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../controller/refresh_trigger_controller.dart';
import '../models/refresh_trigger_stage.dart';
import '../theme/refresh_trigger_theme.dart';
import 'indicators/default_refresh_indicator.dart';
import 'refresh_trigger_layout.dart';

/// Pull-to-refresh and pull-to-load-more around any scrollable.
///
/// ```dart
/// RefreshTrigger(
///   onRefresh: () async => fetchFirstPage(),
///   enableLoadMore: true,
///   onLoadMore: () async => fetchNextPage(),
///   child: ListView.builder(...),
/// )
/// ```
///
/// Values resolve widget → [RefreshTriggerTheme] → built-in default, so a theme
/// set once on the app can drive every trigger below it. See
/// [RefreshTriggerController] for firing either side programmatically.
class RefreshTrigger extends StatefulWidget {
  static Widget defaultIndicatorBuilder(
    BuildContext context,
    RefreshTriggerStage stage,
  ) {
    return DefaultRefreshIndicator(stage: stage, isHeader: stage.isHeader);
  }

  static Widget defaultHeaderBuilder(
    BuildContext context,
    RefreshTriggerStage stage,
  ) {
    return DefaultRefreshIndicator(stage: stage, isHeader: true);
  }

  static Widget defaultFooterBuilder(
    BuildContext context,
    RefreshTriggerStage stage,
  ) {
    return DefaultRefreshIndicator(stage: stage, isHeader: false);
  }

  /// Pull distance that arms the trigger. Defaults to `75`.
  final double? minExtent;

  /// Pull distance the indicator never travels past. Defaults to `150`.
  final double? maxExtent;

  final FutureVoidCallback? onRefresh;
  final LoadMoreCallback? onLoadMore;

  /// The scrollable to wrap.
  final Widget child;

  final Axis direction;

  /// Anchors the refresh indicator to the end of the scrollable instead of the
  /// start (and moves load-more to the start).
  final bool reverse;

  /// Legacy alias for [headerBuilder].
  final RefreshIndicatorBuilder? indicatorBuilder;
  final RefreshIndicatorBuilder? headerBuilder;
  final RefreshIndicatorBuilder? footerBuilder;

  final Curve? curve;

  /// How long the completed/failed state stays up. Defaults to `500ms`.
  final Duration? completeDuration;

  final RefreshTriggerController? controller;

  /// Defaults to [RefreshTriggerDisplayMode.overlay].
  final RefreshTriggerDisplayMode? displayMode;

  /// Defaults to `true`.
  final bool? enableRefresh;

  /// Defaults to `false`.
  final bool? enableLoadMore;

  /// Fires [onRefresh] once, right after the first frame.
  final bool refreshOnStart;

  /// Applied to [child] via [ScrollConfiguration] when non-null.
  final ScrollPhysics? physics;

  /// Defaults to `false`.
  final bool? enableSafeArea;

  const RefreshTrigger({
    super.key,
    this.minExtent,
    this.maxExtent,
    this.onRefresh,
    this.onLoadMore,
    this.direction = Axis.vertical,
    this.reverse = false,
    this.indicatorBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.curve,
    this.completeDuration,
    this.controller,
    this.displayMode,
    this.enableRefresh,
    this.enableLoadMore,
    this.refreshOnStart = false,
    this.physics,
    this.enableSafeArea,
    required this.child,
  });

  @override
  State<RefreshTrigger> createState() => RefreshTriggerState();
}

/// Interprets scroll notifications into pull state and runs the callbacks.
///
/// The layout lives in [RefreshTriggerLayout]; this class only decides *when*
/// each side fires and *what* stage it is in.
class RefreshTriggerState extends State<RefreshTrigger> {
  // Both extents are always positive; `widget.reverse` decides which edge each
  // one is anchored to.
  double _refreshExtent = 0;
  double _loadExtent = 0;
  TriggerStage _refreshStage = TriggerStage.idle;
  TriggerStage _loadStage = TriggerStage.idle;

  bool _scrolling = false;
  bool _noMoreData = false;
  ScrollDirection _userScrollDirection = ScrollDirection.idle;

  Future<void>? _currentRefresh;
  Future<void>? _currentLoadMore;
  Timer? _refreshResetTimer;
  Timer? _loadResetTimer;

  // Resolved from widget + theme + defaults on every dependency change.
  late double _minExtent;
  late double _maxExtent;
  late RefreshIndicatorBuilder _headerBuilder;
  late RefreshIndicatorBuilder _footerBuilder;
  late Curve _curve;
  late Duration _completeDuration;
  late RefreshTriggerDisplayMode _displayMode;
  late bool _enableRefresh;
  late bool _enableLoadMore;
  late bool _enableSafeArea;
  ScrollPhysics? _physics;

  /// Stage of the pull-to-refresh side.
  TriggerStage get refreshStage => _refreshStage;

  /// Stage of the load-more side.
  TriggerStage get loadMoreStage => _loadStage;

  /// Whether the list was told there is nothing left to load.
  bool get noMoreData => _noMoreData;

  @override
  void initState() {
    super.initState();
    widget.controller?.attach(this);
    if (widget.refreshOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.onRefresh != null) refresh();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateThemeValues();
  }

  @override
  void didUpdateWidget(covariant RefreshTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach(this);
      widget.controller?.attach(this);
    }
    _updateThemeValues();
  }

  @override
  void dispose() {
    _refreshResetTimer?.cancel();
    _loadResetTimer?.cancel();
    widget.controller?.detach(this);
    super.dispose();
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

    _headerBuilder = widget.headerBuilder ??
        widget.indicatorBuilder ??
        themeData?.headerBuilder ??
        themeData?.indicatorBuilder ??
        RefreshTrigger.defaultHeaderBuilder;

    _footerBuilder = widget.footerBuilder ??
        themeData?.footerBuilder ??
        RefreshTrigger.defaultFooterBuilder;

    _curve = widget.curve ?? themeData?.curve ?? Curves.easeOutSine;

    _completeDuration = widget.completeDuration ??
        themeData?.completeDuration ??
        const Duration(milliseconds: 500);

    _displayMode = styleValue<RefreshTriggerDisplayMode>(
      widgetValue: widget.displayMode,
      themeValue: themeData?.displayMode,
      defaultValue: RefreshTriggerDisplayMode.overlay,
    );

    _enableRefresh = styleValue<bool>(
      widgetValue: widget.enableRefresh,
      themeValue: themeData?.enableRefresh,
      defaultValue: true,
    );

    _enableLoadMore = styleValue<bool>(
      widgetValue: widget.enableLoadMore,
      themeValue: themeData?.enableLoadMore,
      defaultValue: false,
    );

    _enableSafeArea = styleValue<bool>(
      widgetValue: widget.enableSafeArea,
      themeValue: themeData?.enableSafeArea,
      defaultValue: false,
    );

    _physics = widget.physics ?? themeData?.physics;
  }

  /// Extent mutations are deferred to the end of the frame: in
  /// [RefreshTriggerDisplayMode.inset] the indicator resizes the viewport, and
  /// resizing during a scroll notification would `setState` mid-layout.
  void _schedule(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) action();
    });
  }

  void _scheduleSetState(VoidCallback action) =>
      _schedule(() => setState(action));

  /// A pull may only *start* while the finger is down: a programmatic
  /// `jumpTo`/`animateTo` or a fling settling at the edge must not trigger.
  bool get _userIsDragging => _userScrollDirection != ScrollDirection.idle;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is UserScrollNotification) {
      _userScrollDirection = notification.direction;
      return false;
    }

    if (notification is ScrollEndNotification) {
      if (_scrolling) _schedule(_settle);
      return false;
    }

    final metrics = notification.metrics;
    final towardsStart = metrics.axisDirection == AxisDirection.down ||
        metrics.axisDirection == AxisDirection.right;

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta;
      if (delta == null) return false;

      // > 0 means the content is being pulled towards the scrollable's start.
      final normalized = towardsStart ? -delta : delta;
      // Positive grows the refresh indicator, negative grows the load-more one.
      final refreshDelta = widget.reverse ? -normalized : normalized;

      final atRefreshEdge =
          widget.reverse ? metrics.extentAfter == 0 : metrics.extentBefore == 0;
      final atLoadEdge =
          widget.reverse ? metrics.extentBefore == 0 : metrics.extentAfter == 0;

      // The delta only counts as a pull while it matches the user's drag; once
      // it stops matching, the finger let go and we either fire or fall back.
      final userAgrees = (normalized > 0 &&
              _userScrollDirection == ScrollDirection.forward) ||
          (normalized < 0 && _userScrollDirection == ScrollDirection.reverse);

      if (_refreshStage == TriggerStage.pulling) {
        if (!userAgrees && _refreshExtent >= _minExtent) {
          _schedule(() {
            _scrolling = false;
            refresh();
          });
        } else {
          _scheduleSetState(
            () => _refreshExtent = math.max(0, _refreshExtent + refreshDelta),
          );
        }
      } else if (_loadStage == TriggerStage.pulling) {
        if (!userAgrees && _loadExtent >= _minExtent) {
          _schedule(() {
            _scrolling = false;
            loadMore();
          });
        } else {
          _scheduleSetState(
            () => _loadExtent = math.max(0, _loadExtent - refreshDelta),
          );
        }
      } else if (_refreshStage == TriggerStage.idle &&
          _enableRefresh &&
          _userIsDragging &&
          atRefreshEdge &&
          refreshDelta > 0) {
        // `_scrolling` is set now, not in the deferred callback: the settle
        // check reads it while the notification is still being dispatched.
        _scrolling = true;
        _scheduleSetState(() {
          _refreshExtent = refreshDelta;
          _refreshStage = TriggerStage.pulling;
        });
      } else if (_loadStage == TriggerStage.idle &&
          _enableLoadMore &&
          !_noMoreData &&
          _userIsDragging &&
          atLoadEdge &&
          refreshDelta < 0) {
        _scrolling = true;
        _scheduleSetState(() {
          _loadExtent = -refreshDelta;
          _loadStage = TriggerStage.pulling;
        });
      }
      return false;
    }

    if (notification is OverscrollNotification) {
      final normalized =
          towardsStart ? -notification.overscroll : notification.overscroll;
      final refreshOver = widget.reverse ? -normalized : normalized;

      if (refreshOver > 0 && _enableRefresh) {
        if (_refreshStage == TriggerStage.idle && _userIsDragging) {
          _scrolling = true;
          _scheduleSetState(() {
            _refreshExtent = refreshOver;
            _refreshStage = TriggerStage.pulling;
          });
        } else if (_refreshStage == TriggerStage.pulling) {
          _scheduleSetState(() => _refreshExtent += refreshOver);
        }
      } else if (refreshOver < 0 && _enableLoadMore && !_noMoreData) {
        if (_loadStage == TriggerStage.idle && _userIsDragging) {
          _scrolling = true;
          _scheduleSetState(() {
            _loadExtent = -refreshOver;
            _loadStage = TriggerStage.pulling;
          });
        } else if (_loadStage == TriggerStage.pulling) {
          _scheduleSetState(() => _loadExtent += -refreshOver);
        }
      }
    }
    return false;
  }

  /// Called once the scroll settles: fire whichever side passed the threshold.
  void _settle() {
    if (_refreshExtent >= _minExtent && _enableRefresh) {
      _scrolling = false;
      refresh();
    } else if (_loadExtent >= _minExtent && _enableLoadMore && !_noMoreData) {
      _scrolling = false;
      loadMore();
    } else {
      setState(() {
        if (_refreshStage == TriggerStage.pulling) {
          _refreshStage = TriggerStage.idle;
          _refreshExtent = 0;
        }
        if (_loadStage == TriggerStage.pulling) {
          _loadStage = TriggerStage.idle;
          _loadExtent = 0;
        }
      });
    }
  }

  /// Runs [refreshCallback] (or `widget.onRefresh`) and drives the indicator.
  Future<void> refresh([FutureVoidCallback? refreshCallback]) {
    if (_refreshStage == TriggerStage.refreshing) {
      return _currentRefresh ?? Future.value();
    }

    _scrolling = false;
    _refreshResetTimer?.cancel();
    setState(() => _refreshStage = TriggerStage.refreshing);
    widget.controller?.notifyStageChanged();

    // Future.sync, not a bare call: a non-async callback that throws would
    // otherwise escape before we get a future, leaving the stage stuck on
    // `refreshing` forever.
    final future = Future<void>.sync(
      () => (refreshCallback ?? widget.onRefresh)?.call(),
    );
    _currentRefresh = future;

    return future.then(
      (_) => finishRefresh(true, resetNoMoreData: true),
      onError: (_) => finishRefresh(false),
    );
  }

  /// Runs [loadMoreCallback] (or `widget.onLoadMore`) and drives the footer.
  Future<void> loadMore([LoadMoreCallback? loadMoreCallback]) {
    if (_loadStage == TriggerStage.refreshing || _noMoreData) {
      return _currentLoadMore ?? Future.value();
    }

    _scrolling = false;
    _loadResetTimer?.cancel();
    setState(() => _loadStage = TriggerStage.refreshing);
    widget.controller?.notifyStageChanged();

    final future = Future<void>.sync(
      () => (loadMoreCallback ?? widget.onLoadMore)?.call(),
    );
    _currentLoadMore = future;

    return future.then(
      (_) => finishLoadMore(true, _noMoreData),
      onError: (_) => finishLoadMore(false, _noMoreData),
    );
  }

  /// Ends the running refresh. Prefer [RefreshTriggerController.finishRefresh].
  void finishRefresh(bool success, {bool resetNoMoreData = false}) {
    if (!mounted || _refreshStage != TriggerStage.refreshing) return;

    setState(() {
      _currentRefresh = null;
      // Fresh data means the list can grow again.
      if (resetNoMoreData) _noMoreData = false;
      _refreshStage = success ? TriggerStage.completed : TriggerStage.failed;
    });
    widget.controller?.notifyStageChanged();

    _refreshResetTimer?.cancel();
    _refreshResetTimer = Timer(_completeDuration, () {
      if (!mounted) return;
      setState(() {
        _refreshStage = TriggerStage.idle;
        _refreshExtent = 0;
      });
      widget.controller?.notifyStageChanged();
    });
  }

  /// Ends the running load-more. Prefer
  /// [RefreshTriggerController.finishLoadMore].
  void finishLoadMore(bool success, bool noMoreData) {
    if (!mounted || _loadStage != TriggerStage.refreshing) return;

    setState(() {
      _currentLoadMore = null;
      _noMoreData = noMoreData;
      _loadStage = success ? TriggerStage.completed : TriggerStage.failed;
    });
    widget.controller?.notifyStageChanged();

    _loadResetTimer?.cancel();
    _loadResetTimer = Timer(_completeDuration, () {
      if (!mounted) return;
      setState(() {
        _loadStage = TriggerStage.idle;
        _loadExtent = 0;
      });
      widget.controller?.notifyStageChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;

    if (_physics != null) {
      content = ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(physics: _physics),
        child: content,
      );
    }
    if (_enableSafeArea) content = SafeArea(child: content);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RefreshTriggerLayout(
        displayMode: _displayMode,
        direction: widget.direction,
        reverse: widget.reverse,
        curve: _curve,
        animate: !_scrolling,
        minExtent: _minExtent,
        maxExtent: _maxExtent,
        enableRefresh: _enableRefresh,
        enableLoadMore: _enableLoadMore,
        headerBuilder: _headerBuilder,
        footerBuilder: _footerBuilder,
        refreshStage: _refreshStage,
        loadMoreStage: _loadStage,
        refreshExtent: _refreshExtent,
        loadMoreExtent: _loadExtent,
        noMoreData: _noMoreData,
        child: content,
      ),
    );
  }
}
