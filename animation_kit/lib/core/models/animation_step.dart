import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../enums/animation_curve.dart';
import '../enums/animation_type.dart';
import 'animation_config.dart';

/// Animation Step
///
/// Defines a single step in an animation sequence.
/// Each step represents one animation to be executed.
///
/// ## Examples
///
/// ```dart
/// // Creating an animation step
/// final step = AnimationStep(
///   config: AnimationConfig.fade(duration: Duration(milliseconds: 300)),
///   stepIndex: 0,
/// );
///
/// // Creating a step with callback
/// final stepWithCallback = AnimationStep(
///   config: AnimationConfig.fade(duration: Duration(milliseconds: 300)),
///   stepIndex: 0,
///   onComplete: () {
///     print('Step 0 completed');
///   },
/// );
/// ```
class AnimationStep extends Equatable {
  /// Configuration for this animation step
  ///
  /// Defines how the animation should behave.
  final AnimationConfig config;

  /// Index of this step in the sequence
  ///
  /// Used to identify the step order.
  final int stepIndex;

  /// Optional label for this step
  ///
  /// Can be used for debugging or UI display.
  final String? label;

  /// Callback when this step completes
  ///
  /// Called when the animation for this step finishes.
  final VoidCallback? onComplete;

  /// Callback when this step starts
  ///
  /// Called when the animation for this step begins.
  final VoidCallback? onStart;

  /// Callback when this step fails
  ///
  /// Called if the animation encounters an error.
  final Function(dynamic)? onError;

  /// Creates an animation step
  ///
  /// Creates a step with the given [config] and [stepIndex].
  const AnimationStep({
    required this.config,
    required this.stepIndex,
    this.label,
    this.onComplete,
    this.onStart,
    this.onError,
  });

  /// Creates a fade animation step
  ///
  /// Convenience constructor for fade animation steps.
  factory AnimationStep.fade({
    required int stepIndex,
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
    String? label,
    VoidCallback? onComplete,
    VoidCallback? onStart,
    Function(dynamic)? onError,
  }) {
    return AnimationStep(
      config: AnimationConfig.fade(
        duration: duration,
        curve: curve,
        onComplete: onComplete,
      ),
      stepIndex: stepIndex,
      label: label,
      onComplete: onComplete,
      onStart: onStart,
      onError: onError,
    );
  }

  /// Creates a slide animation step
  ///
  /// Convenience constructor for slide animation steps.
  factory AnimationStep.slide({
    required int stepIndex,
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
    String? label,
    VoidCallback? onComplete,
    VoidCallback? onStart,
    Function(dynamic)? onError,
  }) {
    return AnimationStep(
      config: AnimationConfig.slide(
        duration: duration,
        curve: curve,
        onComplete: onComplete,
      ),
      stepIndex: stepIndex,
      label: label,
      onComplete: onComplete,
      onStart: onStart,
      onError: onError,
    );
  }

  /// Creates a scale animation step
  ///
  /// Convenience constructor for scale animation steps.
  factory AnimationStep.scale({
    required int stepIndex,
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
    String? label,
    VoidCallback? onComplete,
    VoidCallback? onStart,
    Function(dynamic)? onError,
  }) {
    return AnimationStep(
      config: AnimationConfig.scale(
        duration: duration,
        curve: curve,
        onComplete: onComplete,
      ),
      stepIndex: stepIndex,
      label: label,
      onComplete: onComplete,
      onStart: onStart,
      onError: onError,
    );
  }

  /// Creates a rotation animation step
  ///
  /// Convenience constructor for rotation animation steps.
  factory AnimationStep.rotation({
    required int stepIndex,
    Duration duration = const Duration(milliseconds: 500),
    AnimationCurve curve = AnimationCurve.easeInOut,
    String? label,
    VoidCallback? onComplete,
    VoidCallback? onStart,
    Function(dynamic)? onError,
  }) {
    return AnimationStep(
      config: AnimationConfig.rotation(
        duration: duration,
        curve: curve,
        onComplete: onComplete,
      ),
      stepIndex: stepIndex,
      label: label,
      onComplete: onComplete,
      onStart: onStart,
      onError: onError,
    );
  }

  /// Creates a custom animation step
  ///
  /// Convenience constructor for custom animation steps.
  factory AnimationStep.custom({
    required int stepIndex,
    required Duration duration,
    AnimationCurve curve = AnimationCurve.easeInOut,
    String? label,
    VoidCallback? onComplete,
    VoidCallback? onStart,
    Function(dynamic)? onError,
  }) {
    return AnimationStep(
      config: AnimationConfig(
        type: AnimationType.custom,
        duration: duration,
        curve: curve,
        onComplete: onComplete,
      ),
      stepIndex: stepIndex,
      label: label,
      onComplete: onComplete,
      onStart: onStart,
      onError: onError,
    );
  }

  /// Creates a copy of this step with updated values
  ///
  /// Returns a new [AnimationStep] with specified fields replaced.
  AnimationStep copyWith({
    AnimationConfig? config,
    int? stepIndex,
    String? label,
    VoidCallback? onComplete,
    VoidCallback? onStart,
    Function(dynamic)? onError,
  }) {
    return AnimationStep(
      config: config ?? this.config,
      stepIndex: stepIndex ?? this.stepIndex,
      label: label ?? this.label,
      onComplete: onComplete ?? this.onComplete,
      onStart: onStart ?? this.onStart,
      onError: onError ?? this.onError,
    );
  }

  @override
  List<Object?> get props => [
        config,
        stepIndex,
        label,
        onComplete,
        onStart,
        onError,
      ];

  /// Returns the duration of this step
  ///
  /// Returns the [config.duration] for convenience.
  Duration get duration => config.duration;

  /// Returns the type of animation for this step
  ///
  /// Returns the [config.type] for convenience.
  AnimationType get type => config.type;

  /// Returns a string representation of this step
  ///
  /// Useful for debugging and logging.
  String toDebugString() {
    final buffer = StringBuffer('AnimationStep(');
    buffer.write('index: $stepIndex');
    buffer.write(', type: ${type.displayName}');
    buffer.write(', duration: ${duration.inMilliseconds}ms');
    if (label != null) {
      buffer.write(', label: $label');
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  String toString() =>
      'AnimationStep(index: $stepIndex, type: ${type.displayName})';

  /// Returns true if this is the first step
  ///
  /// Returns true if [stepIndex] is 0.
  bool get isFirstStep {
    return stepIndex == 0;
  }

  /// Returns true if this is the last step
  ///
  /// This is context-dependent and requires the total step count.
  bool isLastStep(int totalSteps) {
    return stepIndex == totalSteps - 1;
  }
}
