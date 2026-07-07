import 'package:flutter/material.dart';

import '../core/enums/animation_curve.dart';
import '../core/enums/transition_type.dart';

/// Transition Configuration
///
/// Configuration for slide and other transition animations.
/// Used with SlideTransitionWidget and similar widgets.
///
/// ## Examples
///
/// ```dart
/// // Creating a slide transition config
/// final config = TransitionConfig.slide(
///   type: TransitionType.slideRight,
///   duration: Duration(milliseconds: 300),
/// );
///
/// // Using in widgets
/// SlideTransitionWidget(
///   config: config,
///   child: YourWidget(),
/// )
/// ```
class TransitionConfig {
  /// Transition duration
  final Duration duration;

  /// Animation easing curve
  final AnimationCurve curve;

  /// Transition type
  final TransitionType type;

  /// Whether to auto-play the animation
  final bool autoPlay;

  /// Delay before animation starts
  final Duration delay;

  /// Begin offset for slide transitions
  final Offset beginOffset;

  /// End offset for slide transitions
  final Offset endOffset;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  /// Creates a transition configuration
  const TransitionConfig({
    this.duration = const Duration(milliseconds: 300),
    this.curve = AnimationCurve.easeInOut,
    this.type = TransitionType.fadeIn,
    this.autoPlay = true,
    this.delay = Duration.zero,
    this.beginOffset = const Offset(1.0, 0.0),
    this.endOffset = Offset.zero,
    this.onComplete,
  });

  /// Creates a slide transition configuration
  factory TransitionConfig.slide({
    TransitionType type = TransitionType.slideRight,
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
    bool autoPlay = true,
    Duration delay = Duration.zero,
    VoidCallback? onComplete,
  }) {
    Offset begin;
    switch (type) {
      case TransitionType.slideLeft:
        begin = const Offset(-1.0, 0.0);
        break;
      case TransitionType.slideRight:
        begin = const Offset(1.0, 0.0);
        break;
      case TransitionType.slideUp:
        begin = const Offset(0.0, -1.0);
        break;
      case TransitionType.slideDown:
        begin = const Offset(0.0, 1.0);
        break;
      default:
        begin = const Offset(1.0, 0.0);
    }

    return TransitionConfig(
      type: type,
      duration: duration,
      curve: curve,
      autoPlay: autoPlay,
      delay: delay,
      beginOffset: begin,
      onComplete: onComplete,
    );
  }

  /// Creates a copy with updated values
  TransitionConfig copyWith({
    Duration? duration,
    AnimationCurve? curve,
    TransitionType? type,
    bool? autoPlay,
    Duration? delay,
    Offset? beginOffset,
    Offset? endOffset,
    VoidCallback? onComplete,
  }) {
    return TransitionConfig(
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      type: type ?? this.type,
      autoPlay: autoPlay ?? this.autoPlay,
      delay: delay ?? this.delay,
      beginOffset: beginOffset ?? this.beginOffset,
      endOffset: endOffset ?? this.endOffset,
      onComplete: onComplete ?? this.onComplete,
    );
  }

  @override
  String toString() =>
      'TransitionConfig(type: $type, duration: ${duration.inMilliseconds}ms)';
}
