import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../enums/animation_curve.dart';
import '../enums/animation_state.dart';
import '../enums/animation_type.dart';

/// Animation Configuration
///
/// Defines the configuration for an animation.
/// Used to specify animation properties like duration, curve, type, and repetition.
///
/// ## Examples
///
/// ```dart
/// // Basic fade animation configuration
/// final config = AnimationConfig(
///   type: AnimationType.fade,
///   duration: Duration(milliseconds: 300),
///   curve: AnimationCurve.easeInOut,
/// );
///
/// // Repeating pulse animation
/// final pulseConfig = AnimationConfig(
///   type: AnimationType.pulse,
///   duration: Duration(seconds: 1),
///   repeat: true,
///   repeatCount: 3,
/// );
///
/// // Using with widget
/// FadeTransitionWidget(
///   config: config,
///   child: YourWidget(),
/// )
/// ```
class AnimationConfig extends Equatable {
  /// The type of animation
  ///
  /// Determines which animation behavior to use.
  /// See [AnimationType] for available options.
  final AnimationType type;

  /// Duration of the animation
  ///
  /// How long the animation takes to complete.
  /// Default is 300 milliseconds.
  final Duration duration;

  /// Animation easing curve
  ///
  /// Controls the speed progression of the animation.
  /// See [AnimationCurve] for available options.
  /// Default is [AnimationCurve.easeInOut].
  final AnimationCurve curve;

  /// Whether animation should repeat
  ///
  /// If true, animation will repeat [repeatCount] times.
  /// Default is false.
  final bool repeat;

  /// Number of times to repeat
  ///
  /// Only used when [repeat] is true.
  /// Default is 1.
  final int repeatCount;

  /// Whether animation should auto-play
  ///
  /// If true, animation starts automatically when widget is built.
  /// Default is true.
  final bool autoPlay;

  /// Delay before animation starts
  ///
  /// Time to wait before starting the animation.
  /// Default is Duration.zero.
  final Duration delay;

  /// Callback when animation completes
  ///
  /// Called when animation reaches its end state.
  /// Default is null.
  final VoidCallback? onComplete;

  /// Callback when animation is dismissed
  ///
  /// Called when animation is stopped before completion.
  /// Default is null.
  final VoidCallback? onDismiss;

  /// Callback when animation status changes
  ///
  /// Called whenever animation state changes.
  /// Default is null.
  final Function(AnimationState)? onStatusChanged;

  /// Creates a default animation configuration
  ///
  /// Creates a config with sensible defaults:
  /// - type: [AnimationType.fade]
  /// - duration: 300ms
  /// - curve: [AnimationCurve.easeInOut]
  /// - repeat: false
  /// - autoPlay: true
  const AnimationConfig({
    this.type = AnimationType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.curve = AnimationCurve.easeInOut,
    this.repeat = false,
    this.repeatCount = 1,
    this.autoPlay = true,
    this.delay = Duration.zero,
    this.onComplete,
    this.onDismiss,
    this.onStatusChanged,
  });

  /// Creates a fade animation configuration
  ///
  /// Convenience constructor for fade animations.
  factory AnimationConfig.fade({
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
    bool autoPlay = true,
    Duration delay = Duration.zero,
    VoidCallback? onComplete,
    VoidCallback? onDismiss,
    Function(AnimationState)? onStatusChanged,
  }) {
    return AnimationConfig(
      duration: duration,
      curve: curve,
      autoPlay: autoPlay,
      delay: delay,
      onComplete: onComplete,
      onDismiss: onDismiss,
      onStatusChanged: onStatusChanged,
    );
  }

  /// Creates a slide animation configuration
  ///
  /// Convenience constructor for slide animations.
  factory AnimationConfig.slide({
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
    bool autoPlay = true,
    Duration delay = Duration.zero,
    VoidCallback? onComplete,
    VoidCallback? onDismiss,
    Function(AnimationState)? onStatusChanged,
  }) {
    return AnimationConfig(
      type: AnimationType.slide,
      duration: duration,
      curve: curve,
      autoPlay: autoPlay,
      delay: delay,
      onComplete: onComplete,
      onDismiss: onDismiss,
      onStatusChanged: onStatusChanged,
    );
  }

  /// Creates a scale animation configuration
  ///
  /// Convenience constructor for scale animations.
  factory AnimationConfig.scale({
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
    bool autoPlay = true,
    Duration delay = Duration.zero,
    VoidCallback? onComplete,
    VoidCallback? onDismiss,
    Function(AnimationState)? onStatusChanged,
  }) {
    return AnimationConfig(
      type: AnimationType.scale,
      duration: duration,
      curve: curve,
      autoPlay: autoPlay,
      delay: delay,
      onComplete: onComplete,
      onDismiss: onDismiss,
      onStatusChanged: onStatusChanged,
    );
  }

  /// Creates a rotation animation configuration
  ///
  /// Convenience constructor for rotation animations.
  factory AnimationConfig.rotation({
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
    bool autoPlay = true,
    Duration delay = Duration.zero,
    VoidCallback? onComplete,
    VoidCallback? onDismiss,
    Function(AnimationState)? onStatusChanged,
  }) {
    return AnimationConfig(
      type: AnimationType.rotation,
      duration: duration,
      curve: curve,
      autoPlay: autoPlay,
      delay: delay,
      onComplete: onComplete,
      onDismiss: onDismiss,
      onStatusChanged: onStatusChanged,
    );
  }

  /// Creates a pulse animation configuration
  ///
  /// Convenience constructor for pulse animations.
  factory AnimationConfig.pulse({
    Duration duration = const Duration(seconds: 1),
    AnimationCurve curve = AnimationCurve.easeInOut,
    bool repeat = true,
    int repeatCount = -1, // infinite
    bool autoPlay = true,
    Duration delay = Duration.zero,
    VoidCallback? onComplete,
    VoidCallback? onDismiss,
    Function(AnimationState)? onStatusChanged,
  }) {
    return AnimationConfig(
      type: AnimationType.pulse,
      duration: duration,
      curve: curve,
      repeat: repeat,
      repeatCount: repeatCount,
      autoPlay: autoPlay,
      delay: delay,
      onComplete: onComplete,
      onDismiss: onDismiss,
      onStatusChanged: onStatusChanged,
    );
  }

  /// Creates a shake animation configuration
  ///
  /// Convenience constructor for shake animations.
  factory AnimationConfig.shake({
    Duration duration = const Duration(milliseconds: 500),
    AnimationCurve curve = AnimationCurve.easeInOut,
    bool autoPlay = false,
    Duration delay = Duration.zero,
    VoidCallback? onComplete,
    VoidCallback? onDismiss,
    Function(AnimationState)? onStatusChanged,
  }) {
    return AnimationConfig(
      type: AnimationType.shake,
      duration: duration,
      curve: curve,
      autoPlay: autoPlay,
      delay: delay,
      onComplete: onComplete,
      onDismiss: onDismiss,
      onStatusChanged: onStatusChanged,
    );
  }

  /// Creates a bounce animation configuration
  ///
  /// Convenience constructor for bounce animations.
  factory AnimationConfig.bounce({
    Duration duration = const Duration(milliseconds: 400),
    AnimationCurve curve = AnimationCurve.bounceOut,
    bool autoPlay = false,
    Duration delay = Duration.zero,
    VoidCallback? onComplete,
    VoidCallback? onDismiss,
    Function(AnimationState)? onStatusChanged,
  }) {
    return AnimationConfig(
      type: AnimationType.bounce,
      duration: duration,
      curve: curve,
      autoPlay: autoPlay,
      delay: delay,
      onComplete: onComplete,
      onDismiss: onDismiss,
      onStatusChanged: onStatusChanged,
    );
  }

  /// Creates a heartbeat animation configuration
  ///
  /// Convenience constructor for heartbeat animations.
  factory AnimationConfig.heartbeat({
    Duration duration = const Duration(milliseconds: 800),
    AnimationCurve curve = AnimationCurve.elasticOut,
    bool repeat = true,
    int repeatCount = -1, // infinite
    bool autoPlay = true,
    Duration delay = Duration.zero,
    VoidCallback? onComplete,
    VoidCallback? onDismiss,
    Function(AnimationState)? onStatusChanged,
  }) {
    return AnimationConfig(
      type: AnimationType.heartbeat,
      duration: duration,
      curve: curve,
      repeat: repeat,
      repeatCount: repeatCount,
      autoPlay: autoPlay,
      delay: delay,
      onComplete: onComplete,
      onDismiss: onDismiss,
      onStatusChanged: onStatusChanged,
    );
  }

  /// Creates a copy of this configuration with updated values
  ///
  /// Returns a new [AnimationConfig] with specified fields replaced.
  AnimationConfig copyWith({
    AnimationType? type,
    Duration? duration,
    AnimationCurve? curve,
    bool? repeat,
    int? repeatCount,
    bool? autoPlay,
    Duration? delay,
    VoidCallback? onComplete,
    VoidCallback? onDismiss,
    Function(AnimationState)? onStatusChanged,
  }) {
    return AnimationConfig(
      type: type ?? this.type,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      repeat: repeat ?? this.repeat,
      repeatCount: repeatCount ?? this.repeatCount,
      autoPlay: autoPlay ?? this.autoPlay,
      delay: delay ?? this.delay,
      onComplete: onComplete ?? this.onComplete,
      onDismiss: onDismiss ?? this.onDismiss,
      onStatusChanged: onStatusChanged ?? this.onStatusChanged,
    );
  }

  @override
  List<Object?> get props => [
        type,
        duration,
        curve,
        repeat,
        repeatCount,
        autoPlay,
        delay,
        onComplete,
        onDismiss,
        onStatusChanged,
      ];

  /// Returns total animation duration including repeats
  ///
  /// Calculates the total time the animation will take including
  /// all repetitions and delays.
  Duration get totalDuration {
    if (!repeat || repeatCount <= 0) {
      return duration + delay;
    }
    return (duration * repeatCount) + delay;
  }

  /// Returns true if animation should repeat infinitely
  ///
  /// Returns true if [repeat] is true and [repeatCount] is negative.
  bool get isInfinite {
    return repeat && repeatCount < 0;
  }
}
