/// Animation Exception
///
/// Base exception class for all animation-related errors.
/// Used throughout Animation Kit for consistent error handling.
///
/// ## Examples
///
/// ```dart
/// // Throwing an animation exception
/// throw AnimationException.startFailed(
///   message: 'Animation failed to start',
/// );
///
/// // Catching and handling animation exceptions
/// try {
///   await animationProvider.playAnimation(config);
/// } on AnimationException catch (e) {
///   print('Animation error: ${e.message}');
///   // Handle error appropriately
/// }
/// ```
///
/// ## Error Types
///
/// - **startFailed**: Animation failed to start
/// - **stopFailed**: Animation failed to stop
/// - **pauseFailed**: Animation failed to pause
/// - **resetFailed**: Animation failed to reset
/// - **invalidConfig**: Invalid animation configuration
/// - **animationNotFound**: Animation not found
/// - **controllerError**: Animation controller error
class AnimationException implements Exception {
  /// Human-readable error message
  ///
  /// Describes what went wrong.
  final String message;

  /// Type of animation error
  ///
  /// Categorizes the error for better handling.
  final AnimationErrorType type;

  /// Original exception that caused this error
  ///
  /// Optional underlying exception.
  final dynamic originalException;

  /// Stack trace for debugging
  ///
  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;

  /// Creates an animation exception
  ///
  /// Creates an exception with [message] and [type].
  const AnimationException({
    required this.message,
    required this.type,
    this.originalException,
    this.stackTrace,
  });

  /// Creates an animation exception with original exception
  ///
  /// Creates an exception wrapping another exception.
  factory AnimationException.withOriginalException({
    required String message,
    required AnimationErrorType type,
    dynamic originalException,
    StackTrace? stackTrace,
  }) {
    return AnimationException(
      message: message,
      type: type,
      originalException: originalException,
      stackTrace: stackTrace,
    );
  }

  /// Creates a start failed exception
  ///
  /// Convenience constructor for start failures.
  factory AnimationException.startFailed({
    String? message,
    dynamic originalException,
  }) {
    return AnimationException(
      message: message ?? 'Animation failed to start',
      type: AnimationErrorType.startFailed,
      originalException: originalException,
    );
  }

  /// Creates a stop failed exception
  ///
  /// Convenience constructor for stop failures.
  factory AnimationException.stopFailed({
    String? message,
    dynamic originalException,
  }) {
    return AnimationException(
      message: message ?? 'Animation failed to stop',
      type: AnimationErrorType.stopFailed,
      originalException: originalException,
    );
  }

  /// Creates a pause failed exception
  ///
  /// Convenience constructor for pause failures.
  factory AnimationException.pauseFailed({
    String? message,
    dynamic originalException,
  }) {
    return AnimationException(
      message: message ?? 'Animation failed to pause',
      type: AnimationErrorType.pauseFailed,
      originalException: originalException,
    );
  }

  /// Creates a reset failed exception
  ///
  /// Convenience constructor for reset failures.
  factory AnimationException.resetFailed({
    String? message,
    dynamic originalException,
  }) {
    return AnimationException(
      message: message ?? 'Animation failed to reset',
      type: AnimationErrorType.resetFailed,
      originalException: originalException,
    );
  }

  /// Creates an invalid config exception
  ///
  /// Convenience constructor for invalid configurations.
  factory AnimationException.invalidConfig({
    required String message,
    dynamic originalException,
  }) {
    return AnimationException(
      message: message,
      type: AnimationErrorType.invalidConfig,
      originalException: originalException,
    );
  }

  /// Creates an animation not found exception
  ///
  /// Convenience constructor for missing animations.
  factory AnimationException.animationNotFound({
    String? message,
    String? animationKey,
    dynamic originalException,
  }) {
    final msg = message ??
        (animationKey != null
            ? 'Animation not found: $animationKey'
            : 'Animation not found');
    return AnimationException(
      message: msg,
      type: AnimationErrorType.animationNotFound,
      originalException: originalException,
    );
  }

  /// Creates a controller error exception
  ///
  /// Convenience constructor for controller errors.
  factory AnimationException.controllerError({
    required String message,
    dynamic originalException,
  }) {
    return AnimationException(
      message: message,
      type: AnimationErrorType.controllerError,
      originalException: originalException,
    );
  }

  @override
  String toString() => 'AnimationException: $message (type: $type)';

  /// Returns true if this is a start failure
  ///
  /// Returns true for [AnimationErrorType.startFailed].
  bool get isStartFailure {
    return type == AnimationErrorType.startFailed;
  }

  /// Returns true if this is a stop failure
  ///
  /// Returns true for [AnimationErrorType.stopFailed].
  bool get isStopFailure {
    return type == AnimationErrorType.stopFailed;
  }

  /// Returns true if this is a pause failure
  ///
  /// Returns true for [AnimationErrorType.pauseFailed].
  bool get isPauseFailure {
    return type == AnimationErrorType.pauseFailed;
  }

  /// Returns true if this is a reset failure
  ///
  /// Returns true for [AnimationErrorType.resetFailed].
  bool get isResetFailure {
    return type == AnimationErrorType.resetFailed;
  }

  /// Returns true if this is an invalid config error
  ///
  /// Returns true for [AnimationErrorType.invalidConfig].
  bool get isInvalidConfig {
    return type == AnimationErrorType.invalidConfig;
  }

  /// Returns true if this is an animation not found error
  ///
  /// Returns true for [AnimationErrorType.animationNotFound].
  bool get isAnimationNotFound {
    return type == AnimationErrorType.animationNotFound;
  }

  /// Returns true if this is a controller error
  ///
  /// Returns true for [AnimationErrorType.controllerError].
  bool get isControllerError {
    return type == AnimationErrorType.controllerError;
  }

  /// Returns true if this error is recoverable
  ///
  /// Some errors can be recovered from (like pause failures).
  bool get isRecoverable {
    switch (type) {
      case AnimationErrorType.pauseFailed:
      case AnimationErrorType.resetFailed:
        return true;
      case AnimationErrorType.startFailed:
      case AnimationErrorType.stopFailed:
      case AnimationErrorType.invalidConfig:
      case AnimationErrorType.animationNotFound:
      case AnimationErrorType.controllerError:
        return false;
    }
  }
}

/// Animation Error Type
///
/// Categorizes different types of animation errors.
enum AnimationErrorType {
  /// Animation failed to start
  ///
  /// Animation could not be started due to an error.
  startFailed,

  /// Animation failed to stop
  ///
  /// Animation could not be stopped due to an error.
  stopFailed,

  /// Animation failed to pause
  ///
  /// Animation could not be paused due to an error.
  pauseFailed,

  /// Animation failed to reset
  ///
  /// Animation could not be reset due to an error.
  resetFailed,

  /// Invalid animation configuration
  ///
  /// Provided animation configuration is invalid.
  invalidConfig,

  /// Animation not found
  ///
  /// Requested animation does not exist.
  animationNotFound,

  /// Animation controller error
  ///
  /// Error with animation controller.
  controllerError,
}
