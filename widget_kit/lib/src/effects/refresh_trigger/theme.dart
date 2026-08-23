part of '../refresh_trigger.dart';

/// ===============================
/// THEME (Pure Flutter)
/// ===============================

class RefreshTriggerTheme {
  final double? minExtent;
  final double? maxExtent;
  final RefreshIndicatorBuilder? indicatorBuilder;
  final Curve? curve;
  final Duration? completeDuration;

  /// Copy shown by [AppPillRefreshIndicator] at each stage. Left null, the
  /// indicator falls back to its built-in Arabic strings — override these to
  /// localize without replacing [indicatorBuilder] wholesale.
  final String? pullText;
  final String? releaseText;
  final String? refreshingText;
  final String? completedText;

  const RefreshTriggerTheme({
    this.minExtent,
    this.maxExtent,
    this.indicatorBuilder,
    this.curve,
    this.completeDuration,
    this.pullText,
    this.releaseText,
    this.refreshingText,
    this.completedText,
  });

  RefreshTriggerTheme copyWith({
    ValueGetter<double?>? minExtent,
    ValueGetter<double?>? maxExtent,
    ValueGetter<RefreshIndicatorBuilder?>? indicatorBuilder,
    ValueGetter<Curve?>? curve,
    ValueGetter<Duration?>? completeDuration,
    ValueGetter<String?>? pullText,
    ValueGetter<String?>? releaseText,
    ValueGetter<String?>? refreshingText,
    ValueGetter<String?>? completedText,
  }) {
    return RefreshTriggerTheme(
      minExtent: minExtent == null ? this.minExtent : minExtent(),
      maxExtent: maxExtent == null ? this.maxExtent : maxExtent(),
      indicatorBuilder:
          indicatorBuilder == null ? this.indicatorBuilder : indicatorBuilder(),
      curve: curve == null ? this.curve : curve(),
      completeDuration:
          completeDuration == null ? this.completeDuration : completeDuration(),
      pullText: pullText == null ? this.pullText : pullText(),
      releaseText: releaseText == null ? this.releaseText : releaseText(),
      refreshingText:
          refreshingText == null ? this.refreshingText : refreshingText(),
      completedText:
          completedText == null ? this.completedText : completedText(),
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
        other.completeDuration == completeDuration &&
        other.pullText == pullText &&
        other.releaseText == releaseText &&
        other.refreshingText == refreshingText &&
        other.completedText == completedText;
  }

  @override
  int get hashCode => Object.hash(
        minExtent,
        maxExtent,
        indicatorBuilder,
        curve,
        completeDuration,
        pullText,
        releaseText,
        refreshingText,
        completedText,
      );

  @override
  String toString() {
    return 'RefreshTriggerTheme('
        'minExtent: $minExtent, '
        'maxExtent: $maxExtent, '
        'indicatorBuilder: $indicatorBuilder, '
        'curve: $curve, '
        'completeDuration: $completeDuration, '
        'pullText: $pullText, '
        'releaseText: $releaseText, '
        'refreshingText: $refreshingText, '
        'completedText: $completedText)';
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
