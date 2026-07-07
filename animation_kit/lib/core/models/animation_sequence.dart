import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'animation_config.dart';
import 'animation_step.dart';

/// Animation Sequence
///
/// Defines a sequence of animations to play in order.
/// Used for complex multi-step animations.
///
/// ## Examples
///
/// ```dart
/// // Creating an animation sequence
/// final sequence = AnimationSequence(
///   steps: [
///     AnimationStep.fade(duration: Duration(milliseconds: 300)),
///     AnimationStep.scale(duration: Duration(milliseconds: 200)),
///     AnimationStep.fadeOut(duration: Duration(milliseconds: 300)),
///   ],
///   repeat: false,
/// );
///
/// // Using with animation provider
/// ref.read(animationSequenceProvider.notifier).playSequence(sequence);
/// ```
class AnimationSequence extends Equatable {
  /// List of animation steps in the sequence
  ///
  /// Steps are executed in order from first to last.
  final List<AnimationStep> steps;

  /// Whether the sequence should repeat
  ///
  /// If true, the sequence will loop continuously.
  final bool repeat;

  /// Number of times to repeat the sequence
  ///
  /// Only used when [repeat] is true.
  /// -1 means infinite repetition.
  final int repeatCount;

  /// Delay between sequence repetitions
  ///
  /// Time to wait between completing the sequence
  /// and starting the next repetition.
  final Duration delayBetweenRepeats;

  /// Whether to stop the sequence on error
  ///
  /// If true, the sequence will stop if any step fails.
  final bool stopOnError;

  /// Callback when the sequence completes
  ///
  /// Called when all steps have been executed.
  final VoidCallback? onComplete;

  /// Callback when the sequence is stopped
  ///
  /// Called when the sequence is stopped before completion.
  final VoidCallback? onStop;

  /// Callback when a step completes
  ///
  /// Called after each step in the sequence completes.
  final Function(int stepIndex)? onStepComplete;

  /// Creates an animation sequence
  ///
  /// Creates a sequence with the given [steps].
  const AnimationSequence({
    required this.steps,
    this.repeat = false,
    this.repeatCount = 1,
    this.delayBetweenRepeats = Duration.zero,
    this.stopOnError = true,
    this.onComplete,
    this.onStop,
    this.onStepComplete,
  });

  /// Creates an animation sequence from configs
  ///
  /// Convenience constructor to create steps from configs.
  factory AnimationSequence.fromConfigs({
    required List<AnimationConfig> configs,
    bool repeat = false,
    int repeatCount = 1,
    Duration delayBetweenRepeats = Duration.zero,
    bool stopOnError = true,
    VoidCallback? onComplete,
    VoidCallback? onStop,
    Function(int stepIndex)? onStepComplete,
  }) {
    final steps = configs
        .asMap()
        .entries
        .map(
          (entry) => AnimationStep(
            config: entry.value,
            stepIndex: entry.key,
          ),
        )
        .toList();
    return AnimationSequence(
      steps: steps,
      repeat: repeat,
      repeatCount: repeatCount,
      delayBetweenRepeats: delayBetweenRepeats,
      stopOnError: stopOnError,
      onComplete: onComplete,
      onStop: onStop,
      onStepComplete: onStepComplete,
    );
  }

  /// Creates a copy of this sequence with updated values
  ///
  /// Returns a new [AnimationSequence] with specified fields replaced.
  AnimationSequence copyWith({
    List<AnimationStep>? steps,
    bool? repeat,
    int? repeatCount,
    Duration? delayBetweenRepeats,
    bool? stopOnError,
    VoidCallback? onComplete,
    VoidCallback? onStop,
    Function(int stepIndex)? onStepComplete,
  }) {
    return AnimationSequence(
      steps: steps ?? this.steps,
      repeat: repeat ?? this.repeat,
      repeatCount: repeatCount ?? this.repeatCount,
      delayBetweenRepeats: delayBetweenRepeats ?? this.delayBetweenRepeats,
      stopOnError: stopOnError ?? this.stopOnError,
      onComplete: onComplete ?? this.onComplete,
      onStop: onStop ?? this.onStop,
      onStepComplete: onStepComplete ?? this.onStepComplete,
    );
  }

  @override
  List<Object?> get props => [
        steps,
        repeat,
        repeatCount,
        delayBetweenRepeats,
        stopOnError,
        onComplete,
        onStop,
        onStepComplete,
      ];

  /// Returns total duration of the sequence
  ///
  /// Calculates the total time for all steps to complete.
  Duration get totalDuration {
    if (steps.isEmpty) {
      return Duration.zero;
    }
    final stepsDuration = steps.fold<Duration>(
      Duration.zero,
      (sum, step) => sum + step.config.duration,
    );
    if (!repeat || repeatCount <= 0) {
      return stepsDuration;
    }
    return (stepsDuration * repeatCount) +
        (delayBetweenRepeats * (repeatCount - 1));
  }

  /// Returns true if the sequence repeats infinitely
  ///
  /// Returns true if [repeat] is true and [repeatCount] is negative.
  bool get isInfinite {
    return repeat && repeatCount < 0;
  }

  /// Returns true if the sequence is valid
  ///
  /// A sequence is valid if it has at least one step.
  bool get isValid {
    return steps.isNotEmpty;
  }

  /// Returns the number of steps in the sequence
  ///
  /// Returns the count of [steps].
  int get stepCount {
    return steps.length;
  }

  /// Returns the first step in the sequence
  ///
  /// Returns the first step, or null if sequence is empty.
  AnimationStep? get firstStep {
    return steps.isEmpty ? null : steps.first;
  }

  /// Returns the last step in the sequence
  ///
  /// Returns the last step, or null if sequence is empty.
  AnimationStep? get lastStep {
    return steps.isEmpty ? null : steps.last;
  }

  /// Returns the step at the given index
  ///
  /// Returns the step at [index], or null if index is out of range.
  AnimationStep? stepAtIndex(int index) {
    if (index < 0 || index >= steps.length) {
      return null;
    }
    return steps[index];
  }

  /// Returns a string representation of this sequence
  ///
  /// Useful for debugging and logging.
  String toDebugString() {
    final buffer = StringBuffer('AnimationSequence(');
    buffer.write('steps: ${steps.length}');
    buffer.write(', repeat: $repeat');
    buffer.write(', repeatCount: $repeatCount');
    buffer.write(', totalDuration: ${totalDuration.inMilliseconds}ms');
    buffer.write(')');
    return buffer.toString();
  }

  @override
  String toString() =>
      'AnimationSequence(steps: ${steps.length}, repeat: $repeat)';
}
