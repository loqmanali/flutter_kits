import 'package:flutter/material.dart';

/// Animation State
///
/// Defines the current state of an animation.
/// Used to track and manage animation lifecycle.
///
/// ## Examples
///
/// ```dart
/// // Checking animation state
/// if (animationState == AnimationState.playing) {
///   print('Animation is currently playing');
/// }
///
/// // Using with animation provider
/// final state = ref.watch(animationProvider);
/// switch (state.status) {
///   case AnimationState.playing:
///     // Show loading indicator
///     break;
///   case AnimationState.completed:
///     // Show completion callback
///     break;
/// }
/// ```
///
/// ## State Transitions
///
/// ```
/// idle → playing → (paused → playing)* → completed
///                     ↓
///                   dismissed
/// ```
///
/// - **idle**: Animation is ready but not started
/// - **playing**: Animation is currently running
/// - **paused**: Animation is paused (can resume)
/// - **completed**: Animation finished successfully
/// - **dismissed**: Animation was dismissed/cancelled
enum AnimationState {
  /// Idle - animation is ready but not started
  ///
  /// The animation is initialized and ready to play.
  /// This is the initial state before [playAnimationUseCase] is called.
  ///
  /// Example:
  /// ```dart
  /// final controller = AnimationController(duration: Duration(seconds: 1));
  /// print(controller.status); // AnimationStatus.idle
  /// ```
  idle,

  /// Playing - animation is currently running
  ///
  /// The animation is actively running from start to finish.
  /// This is the active state during animation execution.
  ///
  /// Example:
  /// ```dart
  /// controller.forward();
  /// print(controller.status); // AnimationStatus.playing
  /// ```
  playing,

  /// Paused - animation is paused
  ///
  /// The animation was paused and can be resumed.
  /// Use [pauseAnimationUseCase] to pause and [playAnimationUseCase] to resume.
  ///
  /// Example:
  /// ```dart
  /// controller.stop();
  /// print(controller.status); // AnimationStatus.paused (or dismissed)
  /// ```
  paused,

  /// Completed - animation finished successfully
  ///
  /// The animation has reached its end state naturally.
  /// This triggers the [onComplete] callback if provided.
  ///
  /// Example:
  /// ```dart
  /// controller.addStatusListener((status) {
  ///   if (status == AnimationStatus.completed) {
  ///     print('Animation completed!');
  ///   }
  /// });
  /// ```
  completed,

  /// Dismissed - animation was cancelled
  ///
  /// The animation was stopped before completion.
  /// This can happen when [stopAnimationUseCase] is called.
  ///
  /// Example:
  /// ```dart
  /// controller.stop();
  /// print(controller.status); // AnimationStatus.dismissed
  /// ```
  dismissed,
}

/// Extension methods for [AnimationState]
extension AnimationStateExtension on AnimationState {
  /// Returns true if animation is actively running
  ///
  /// Returns true only for [AnimationState.playing].
  bool get isActive {
    return this == AnimationState.playing;
  }

  /// Returns true if animation can be started
  ///
  /// Returns true only for [AnimationState.idle] and [AnimationState.paused].
  bool get canStart {
    return this == AnimationState.idle || this == AnimationState.paused;
  }

  /// Returns true if animation can be paused
  ///
  /// Returns true only for [AnimationState.playing].
  bool get canPause {
    return this == AnimationState.playing;
  }

  /// Returns true if animation can be stopped
  ///
  /// Returns true for [AnimationState.playing] and [AnimationState.paused].
  bool get canStop {
    return this == AnimationState.playing || this == AnimationState.paused;
  }

  /// Returns true if animation has finished
  ///
  /// Returns true for [AnimationState.completed] and [AnimationState.dismissed].
  bool get isFinished {
    return this == AnimationState.completed || this == AnimationState.dismissed;
  }

  /// Returns true if animation completed successfully
  ///
  /// Returns true only for [AnimationState.completed].
  bool get isSuccess {
    return this == AnimationState.completed;
  }

  /// Returns true if animation was cancelled
  ///
  /// Returns true only for [AnimationState.dismissed].
  bool get isCancelled {
    return this == AnimationState.dismissed;
  }

  /// Returns a human-readable name for the animation state
  String get displayName {
    switch (this) {
      case AnimationState.idle:
        return 'Idle';
      case AnimationState.playing:
        return 'Playing';
      case AnimationState.paused:
        return 'Paused';
      case AnimationState.completed:
        return 'Completed';
      case AnimationState.dismissed:
        return 'Dismissed';
    }
  }

  /// Returns a description of the animation state
  String get description {
    switch (this) {
      case AnimationState.idle:
        return 'Animation is ready but not started';
      case AnimationState.playing:
        return 'Animation is currently running';
      case AnimationState.paused:
        return 'Animation is paused and can be resumed';
      case AnimationState.completed:
        return 'Animation finished successfully';
      case AnimationState.dismissed:
        return 'Animation was cancelled before completion';
    }
  }

  /// Converts to Flutter [AnimationStatus]
  ///
  /// Returns the corresponding Flutter [AnimationStatus] for use with
  /// Flutter's animation system.
  AnimationStatus toFlutterStatus() {
    switch (this) {
      case AnimationState.idle:
        return AnimationStatus.dismissed;
      case AnimationState.playing:
        return AnimationStatus.forward;
      case AnimationState.paused:
        return AnimationStatus.reverse;
      case AnimationState.completed:
        return AnimationStatus.completed;
      case AnimationState.dismissed:
        return AnimationStatus.dismissed;
    }
  }
}
