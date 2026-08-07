import 'package:flutter/widgets.dart';

import '../models/refresh_trigger_stage.dart';

/// Shared defaults for every [RefreshTrigger] below a
/// [RefreshTriggerThemeProvider]. Every field is nullable: `null` means "fall
/// back to the widget value, then to the built-in default".
class RefreshTriggerTheme {
  final double? minExtent;
  final double? maxExtent;

  /// Legacy alias for [headerBuilder]. Kept so existing themes keep working.
  final RefreshIndicatorBuilder? indicatorBuilder;

  /// Builder for the pull-to-refresh indicator.
  final RefreshIndicatorBuilder? headerBuilder;

  /// Builder for the load-more indicator.
  final RefreshIndicatorBuilder? footerBuilder;

  final Curve? curve;
  final Duration? completeDuration;

  /// Copy shown by `AppPillRefreshIndicator` at each stage. Left null, the
  /// indicator falls back to its built-in Arabic strings — override these to
  /// localize without replacing [indicatorBuilder] wholesale.
  final String? pullText;
  final String? releaseText;
  final String? refreshingText;
  final String? completedText;
  final String? failedText;
  final String? noMoreDataText;

  final RefreshTriggerDisplayMode? displayMode;
  final bool? enableRefresh;
  final bool? enableLoadMore;

  /// Applied to the child through a [ScrollConfiguration] when non-null.
  final ScrollPhysics? physics;

  final bool? enableSafeArea;

  const RefreshTriggerTheme({
    this.minExtent,
    this.maxExtent,
    this.indicatorBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.curve,
    this.completeDuration,
    this.pullText,
    this.releaseText,
    this.refreshingText,
    this.completedText,
    this.failedText,
    this.noMoreDataText,
    this.displayMode,
    this.enableRefresh,
    this.enableLoadMore,
    this.physics,
    this.enableSafeArea,
  });

  /// Every parameter takes a getter so that passing `() => null` clears a field
  /// instead of being indistinguishable from "leave unchanged".
  RefreshTriggerTheme copyWith({
    ValueGetter<double?>? minExtent,
    ValueGetter<double?>? maxExtent,
    ValueGetter<RefreshIndicatorBuilder?>? indicatorBuilder,
    ValueGetter<RefreshIndicatorBuilder?>? headerBuilder,
    ValueGetter<RefreshIndicatorBuilder?>? footerBuilder,
    ValueGetter<Curve?>? curve,
    ValueGetter<Duration?>? completeDuration,
    ValueGetter<String?>? pullText,
    ValueGetter<String?>? releaseText,
    ValueGetter<String?>? refreshingText,
    ValueGetter<String?>? completedText,
    ValueGetter<String?>? failedText,
    ValueGetter<String?>? noMoreDataText,
    ValueGetter<RefreshTriggerDisplayMode?>? displayMode,
    ValueGetter<bool?>? enableRefresh,
    ValueGetter<bool?>? enableLoadMore,
    ValueGetter<ScrollPhysics?>? physics,
    ValueGetter<bool?>? enableSafeArea,
  }) {
    return RefreshTriggerTheme(
      minExtent: minExtent == null ? this.minExtent : minExtent(),
      maxExtent: maxExtent == null ? this.maxExtent : maxExtent(),
      indicatorBuilder:
          indicatorBuilder == null ? this.indicatorBuilder : indicatorBuilder(),
      headerBuilder:
          headerBuilder == null ? this.headerBuilder : headerBuilder(),
      footerBuilder:
          footerBuilder == null ? this.footerBuilder : footerBuilder(),
      curve: curve == null ? this.curve : curve(),
      completeDuration:
          completeDuration == null ? this.completeDuration : completeDuration(),
      pullText: pullText == null ? this.pullText : pullText(),
      releaseText: releaseText == null ? this.releaseText : releaseText(),
      refreshingText:
          refreshingText == null ? this.refreshingText : refreshingText(),
      completedText:
          completedText == null ? this.completedText : completedText(),
      failedText: failedText == null ? this.failedText : failedText(),
      noMoreDataText:
          noMoreDataText == null ? this.noMoreDataText : noMoreDataText(),
      displayMode: displayMode == null ? this.displayMode : displayMode(),
      enableRefresh:
          enableRefresh == null ? this.enableRefresh : enableRefresh(),
      enableLoadMore:
          enableLoadMore == null ? this.enableLoadMore : enableLoadMore(),
      physics: physics == null ? this.physics : physics(),
      enableSafeArea:
          enableSafeArea == null ? this.enableSafeArea : enableSafeArea(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RefreshTriggerTheme &&
        other.minExtent == minExtent &&
        other.maxExtent == maxExtent &&
        other.indicatorBuilder == indicatorBuilder &&
        other.headerBuilder == headerBuilder &&
        other.footerBuilder == footerBuilder &&
        other.curve == curve &&
        other.completeDuration == completeDuration &&
        other.pullText == pullText &&
        other.releaseText == releaseText &&
        other.refreshingText == refreshingText &&
        other.completedText == completedText &&
        other.failedText == failedText &&
        other.noMoreDataText == noMoreDataText &&
        other.displayMode == displayMode &&
        other.enableRefresh == enableRefresh &&
        other.enableLoadMore == enableLoadMore &&
        other.physics == physics &&
        other.enableSafeArea == enableSafeArea;
  }

  @override
  int get hashCode => Object.hash(
        minExtent,
        maxExtent,
        indicatorBuilder,
        headerBuilder,
        footerBuilder,
        curve,
        completeDuration,
        pullText,
        releaseText,
        refreshingText,
        completedText,
        failedText,
        noMoreDataText,
        displayMode,
        enableRefresh,
        enableLoadMore,
        physics,
        enableSafeArea,
      );

  @override
  String toString() {
    return 'RefreshTriggerTheme('
        'minExtent: $minExtent, '
        'maxExtent: $maxExtent, '
        'indicatorBuilder: $indicatorBuilder, '
        'headerBuilder: $headerBuilder, '
        'footerBuilder: $footerBuilder, '
        'curve: $curve, '
        'completeDuration: $completeDuration, '
        'pullText: $pullText, '
        'releaseText: $releaseText, '
        'refreshingText: $refreshingText, '
        'completedText: $completedText, '
        'failedText: $failedText, '
        'noMoreDataText: $noMoreDataText, '
        'displayMode: $displayMode, '
        'enableRefresh: $enableRefresh, '
        'enableLoadMore: $enableLoadMore, '
        'physics: $physics, '
        'enableSafeArea: $enableSafeArea)';
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

/// Helper to pick the first non-null value: widget over theme over default.
T styleValue<T>({required T defaultValue, T? widgetValue, T? themeValue}) {
  return widgetValue ?? themeValue ?? defaultValue;
}
