import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../enums/animation_curve.dart';
import '../enums/transition_type.dart';

/// Transition Configuration
///
/// Defines configuration for transition animations.
/// Used with slide, fade, scale, and rotation transitions.
///
/// ## Examples
///
/// ```dart
/// // Slide transition configuration
/// final config = TransitionConfig(
///   type: TransitionType.slideRight,
///   duration: Duration(milliseconds: 300),
///   curve: AnimationCurve.easeInOut,
/// );
///
/// // Using with widget
/// SlideTransitionWidget(
///   config: config,
///   child: YourWidget(),
/// )
/// ```
class TransitionConfig extends Equatable {
  /// The type of transition
  ///
  /// Determines which transition behavior to use.
  /// See [TransitionType] for available options.
  final TransitionType type;

  /// Duration of transition
  ///
  /// How long the transition takes to complete.
  /// Default is 300 milliseconds.
  final Duration duration;

  /// Animation easing curve
  ///
  /// Controls speed progression of transition.
  /// See [AnimationCurve] for available options.
  /// Default is [AnimationCurve.easeInOut].
  final AnimationCurve curve;

  /// Beginning offset for slide transitions
  ///
  /// Starting position offset for slide transitions.
  /// Default is determined by [type].
  final Offset? beginOffset;

  /// Ending offset for slide transitions
  ///
  /// Ending position offset for slide transitions.
  /// Default is Offset.zero.
  final Offset? endOffset;

  /// Beginning scale for scale transitions
  ///
  /// Starting scale for scale transitions.
  /// Default is determined by [type].
  final double? beginScale;

  /// Ending scale for scale transitions
  ///
  /// Ending scale for scale transitions.
  /// Default is 1.0.
  final double? endScale;

  /// Beginning opacity for fade transitions
  ///
  /// Starting opacity for fade transitions.
  /// Default is determined by [type].
  final double? beginOpacity;

  /// Ending opacity for fade transitions
  ///
  /// Ending opacity for fade transitions.
  /// Default is determined by [type].
  final double? endOpacity;

  /// Beginning angle for rotation transitions (in radians)
  ///
  /// Starting rotation angle in radians.
  /// Default is 0.0.
  final double? beginAngle;

  /// Ending angle for rotation transitions (in radians)
  ///
  /// Ending rotation angle in radians.
  /// Default is 2 * pi (360 degrees).
  final double? endAngle;

  /// Creates a default transition configuration
  ///
  /// Creates a config with sensible defaults:
  /// - type: [TransitionType.fadeIn]
  /// - duration: 300ms
  /// - curve: [AnimationCurve.easeInOut]
  const TransitionConfig({
    this.type = TransitionType.fadeIn,
    this.duration = const Duration(milliseconds: 300),
    this.curve = AnimationCurve.easeInOut,
    this.beginOffset,
    this.endOffset,
    this.beginScale,
    this.endScale,
    this.beginOpacity,
    this.endOpacity,
    this.beginAngle,
    this.endAngle,
  });

  /// Creates a slide transition configuration
  ///
  /// Convenience constructor for slide transitions.
  factory TransitionConfig.slide({
    required TransitionType type,
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
    Offset? beginOffset,
    Offset? endOffset,
  }) {
    assert(type.isSlide, 'Type must be a slide transition');
    return TransitionConfig(
      type: type,
      duration: duration,
      curve: curve,
      beginOffset: beginOffset ?? type.beginOffset,
      endOffset: endOffset ?? type.endOffset,
    );
  }

  /// Creates a fade transition configuration
  ///
  /// Convenience constructor for fade transitions.
  factory TransitionConfig.fade({
    required TransitionType type,
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
    double? beginOpacity,
    double? endOpacity,
  }) {
    assert(type.isFade, 'Type must be a fade transition');
    return TransitionConfig(
      type: type,
      duration: duration,
      curve: curve,
      beginOpacity: beginOpacity ?? type.beginOpacity,
      endOpacity: endOpacity ?? type.endOpacity,
    );
  }

  /// Creates a scale transition configuration
  ///
  /// Convenience constructor for scale transitions.
  factory TransitionConfig.scale({
    required TransitionType type,
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
    double? beginScale,
    double? endScale,
  }) {
    assert(type.isScale, 'Type must be a scale transition');
    return TransitionConfig(
      type: type,
      duration: duration,
      curve: curve,
      beginScale: beginScale ?? type.beginScale,
      endScale: endScale ?? type.endScale,
    );
  }

  /// Creates a rotation transition configuration
  ///
  /// Convenience constructor for rotation transitions.
  factory TransitionConfig.rotation({
    required TransitionType type,
    Duration duration = const Duration(milliseconds: 500),
    AnimationCurve curve = AnimationCurve.easeInOut,
    double? beginAngle,
    double? endAngle,
  }) {
    assert(type.isRotation, 'Type must be a rotation transition');
    return TransitionConfig(
      type: type,
      duration: duration,
      curve: curve,
      beginAngle: beginAngle ?? 0.0,
      endAngle: endAngle ?? (2 * 3.141592653589793),
    );
  }

  /// Creates a copy of this configuration with updated values
  ///
  /// Returns a new [TransitionConfig] with specified fields replaced.
  TransitionConfig copyWith({
    TransitionType? type,
    Duration? duration,
    AnimationCurve? curve,
    Offset? beginOffset,
    Offset? endOffset,
    double? beginScale,
    double? endScale,
    double? beginOpacity,
    double? endOpacity,
    double? beginAngle,
    double? endAngle,
  }) {
    return TransitionConfig(
      type: type ?? this.type,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      beginOffset: beginOffset ?? this.beginOffset,
      endOffset: endOffset ?? this.endOffset,
      beginScale: beginScale ?? this.beginScale,
      endScale: endScale ?? this.endScale,
      beginOpacity: beginOpacity ?? this.beginOpacity,
      endOpacity: endOpacity ?? this.endOpacity,
      beginAngle: beginAngle ?? this.beginAngle,
      endAngle: endAngle ?? this.endAngle,
    );
  }

  @override
  List<Object?> get props => [
        type,
        duration,
        curve,
        beginOffset,
        endOffset,
        beginScale,
        endScale,
        beginOpacity,
        endOpacity,
        beginAngle,
        endAngle,
      ];

  /// Returns effective beginning opacity
  ///
  /// Returns the actual beginning opacity to use.
  double get effectiveBeginOpacity {
    return beginOpacity ?? type.beginOpacity;
  }

  /// Returns effective ending opacity
  ///
  /// Returns the actual ending opacity to use.
  double get effectiveEndOpacity {
    return endOpacity ?? type.endOpacity;
  }

  /// Returns effective beginning scale
  ///
  /// Returns the actual beginning scale to use.
  double get effectiveBeginScale {
    return beginScale ?? type.beginScale;
  }

  /// Returns effective ending scale
  ///
  /// Returns the actual ending scale to use.
  double get effectiveEndScale {
    return endScale ?? type.endScale;
  }

  /// Returns effective beginning offset
  ///
  /// Returns the actual beginning offset to use.
  Offset get effectiveBeginOffset {
    return beginOffset ?? type.beginOffset;
  }

  /// Returns effective ending offset
  ///
  /// Returns the actual ending offset to use.
  Offset get effectiveEndOffset {
    return endOffset ?? type.endOffset;
  }
}
