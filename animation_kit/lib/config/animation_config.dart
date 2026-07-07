import '../core/enums/animation_curve.dart';

/// Global Animation Configuration
///
/// Global configuration for all animations in Animation Kit.
/// Provides default values and settings for animation behavior.
///
/// ## Examples
///
/// ```dart
/// // Getting animation configuration
/// final config = GlobalAnimationConfig.instance;
///
/// // Updating configuration
/// GlobalAnimationConfig.instance.update(
///   defaultDuration: Duration(milliseconds: 500),
///   defaultCurve: AnimationCurve.easeInOut,
/// );
///
/// // Using in widgets
/// FadeTransitionWidget(
///   config: GlobalAnimationConfig.instance,
///   child: YourWidget(),
/// )
/// ```
class GlobalAnimationConfig {
  /// Singleton instance of global animation configuration
  ///
  /// Provides global access to animation settings.
  static GlobalAnimationConfig? _instance;

  /// Default animation duration
  ///
  /// Default duration for all animations.
  /// Default is 300 milliseconds.
  static const Duration kDefaultDuration = Duration(milliseconds: 300);

  /// Default animation curve
  ///
  /// Default easing curve for all animations.
  /// Default is [AnimationCurve.easeInOut].
  static const AnimationCurve kDefaultCurve = AnimationCurve.easeInOut;

  /// Default auto-play setting
  ///
  /// Whether animations should auto-play by default.
  /// Default is true.
  static const bool kDefaultAutoPlay = true;

  /// Default repeat setting
  ///
  /// Whether animations repeat by default.
  /// Default is false.
  static const bool kDefaultRepeat = false;

  /// Default repeat count
  ///
  /// Number of repetitions for repeat animations.
  /// Default is 1.
  static const int kDefaultRepeatCount = 1;

  /// Default delay before animation starts
  ///
  /// Delay before animation begins.
  /// Default is Duration.zero.
  static const Duration kDefaultDelay = Duration.zero;

  /// Whether to stop animation on error
  ///
  /// Whether to stop animation if any step fails.
  /// Default is true.
  static const bool kDefaultStopOnError = true;

  /// Whether animations should be enabled globally
  ///
  /// Master switch to disable all animations.
  /// Default is true.
  static bool animationsEnabled = true;

  /// Current default animation duration
  ///
  /// Current default duration for animations.
  Duration _duration = kDefaultDuration;

  /// Current default animation curve
  ///
  /// Current default easing curve for animations.
  AnimationCurve _curve = kDefaultCurve;

  /// Current auto-play setting
  ///
  /// Current auto-play behavior for animations.
  bool _autoPlay = kDefaultAutoPlay;

  /// Creates a global animation configuration
  GlobalAnimationConfig._internal();

  /// Gets the singleton instance, creating it if needed
  static GlobalAnimationConfig get instance {
    _instance ??= GlobalAnimationConfig._internal();
    return _instance!;
  }

  /// Initializes global animation configuration
  static void initialize({
    Duration? defaultDuration,
    AnimationCurve? defaultCurve,
    bool? defaultAutoPlay,
    bool enabled = true,
  }) {
    _instance = GlobalAnimationConfig._internal();
    if (defaultDuration != null) _instance!._duration = defaultDuration;
    if (defaultCurve != null) _instance!._curve = defaultCurve;
    if (defaultAutoPlay != null) _instance!._autoPlay = defaultAutoPlay;
    animationsEnabled = enabled;
  }

  /// Updates default animation duration
  ///
  /// Sets new default for animation duration.
  ///
  /// Example:
  /// ```dart
  /// GlobalAnimationConfig.instance.updateDefaultDuration(Duration(milliseconds: 500));
  /// ```
  void updateDefaultDuration(Duration duration) {
    _duration = duration;
  }

  /// Updates default animation curve
  ///
  /// Sets new default for animation easing.
  ///
  /// Example:
  /// ```dart
  /// GlobalAnimationConfig.instance.updateDefaultCurve(AnimationCurve.bounceIn);
  /// ```
  void updateDefaultCurve(AnimationCurve curve) {
    _curve = curve;
  }

  /// Updates auto-play setting
  ///
  /// Enables or disables auto-play by default.
  ///
  /// Example:
  /// ```dart
  /// GlobalAnimationConfig.instance.updateAutoPlay(false);
  /// ```
  void updateAutoPlay(bool enabled) {
    _autoPlay = enabled;
  }

  /// Updates animations enabled state
  ///
  /// Enables or disables all animations globally.
  ///
  /// Example:
  /// ```dart
  /// GlobalAnimationConfig.instance.setAnimationsEnabled(false);
  /// ```
  void setAnimationsEnabled(bool enabled) {
    animationsEnabled = enabled;
  }

  /// Gets current default animation duration
  ///
  /// Returns the current default duration.
  ///
  /// Example:
  /// ```dart
  /// final duration = GlobalAnimationConfig.instance.defaultDuration;
  /// print('Default duration: ${duration.inMilliseconds}ms');
  /// ```
  Duration get defaultDuration {
    return _duration;
  }

  /// Gets current default animation curve
  ///
  /// Returns the current default easing curve.
  ///
  /// Example:
  /// ```dart
  /// final curve = GlobalAnimationConfig.instance.defaultCurve;
  /// print('Default curve: ${curve.displayName}');
  /// ```
  AnimationCurve get defaultCurve {
    return _curve;
  }

  /// Gets auto-play setting
  ///
  /// Returns whether animations auto-play by default.
  ///
  /// Example:
  /// ```dart
  /// final autoPlay = GlobalAnimationConfig.instance.autoPlay;
  /// print('Auto play: $autoPlay');
  /// ```
  bool get autoPlay {
    return _autoPlay;
  }

  /// Gets animations enabled state
  ///
  /// Returns whether animations are globally enabled.
  ///
  /// Example:
  /// ```dart
  /// final enabled = GlobalAnimationConfig.animationsEnabled;
  /// print('Animations enabled: $enabled');
  /// ```
  bool get isAnimationsEnabled {
    return animationsEnabled;
  }

  /// Creates a copy of this configuration values
  GlobalAnimationConfig copyWith({
    Duration? duration,
    AnimationCurve? curve,
    bool? autoPlay,
  }) {
    final copy = GlobalAnimationConfig._internal();
    copy._duration = duration ?? _duration;
    copy._curve = curve ?? _curve;
    copy._autoPlay = autoPlay ?? _autoPlay;
    return copy;
  }

  /// Returns a string representation of this configuration
  ///
  /// Useful for debugging and logging.
  String toDebugString() {
    final buffer = StringBuffer('GlobalAnimationConfig(');
    buffer.write('duration: ${_duration.inMilliseconds}ms');
    buffer.write(', curve: ${_curve.displayName}');
    buffer.write(', autoPlay: $_autoPlay');
    buffer.write(', animationsEnabled: $animationsEnabled');
    buffer.write(')');
    return buffer.toString();
  }

  @override
  String toString() =>
      'GlobalAnimationConfig(duration: ${_duration.inMilliseconds}ms, curve: ${_curve.displayName})';

  /// Resets configuration to defaults
  ///
  /// Resets all values to their defaults.
  ///
  /// Example:
  /// ```dart
  /// GlobalAnimationConfig.resetToDefaults();
  /// ```
  static void resetToDefaults() {
    if (_instance != null) {
      _instance!._duration = kDefaultDuration;
      _instance!._curve = kDefaultCurve;
      _instance!._autoPlay = kDefaultAutoPlay;
      animationsEnabled = true;
    }
  }
}
