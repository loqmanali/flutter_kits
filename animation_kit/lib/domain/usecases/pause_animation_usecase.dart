import '../../core/exceptions/animation_exception.dart';
import '../../core/models/animation_key.dart';
import '../repositories/animation_repository.dart';

/// Pause Animation Use Case
///
/// Business logic for pausing animations.
/// Handles animation pause and resume with validation and error handling.
///
/// ## Examples
///
/// ```dart
/// // Creating use case
/// final useCase = PauseAnimationUseCase(
///   repository: animationRepository,
/// );
///
/// // Using with animation provider
/// ref.read(animationProvider.notifier).pauseAnimation(key);
/// ```
class PauseAnimationUseCase {
  /// Animation repository for state management
  ///
  /// Used to update and load animation states.
  final AnimationRepository repository;

  /// Creates a pause animation use case
  ///
  /// Initializes with required [repository].
  PauseAnimationUseCase({
    required this.repository,
  });

  /// Executes the pause animation operation
  ///
  /// Pauses animation with given key.
  /// Updates state to indicate animation is paused.
  ///
  /// Throws [AnimationException] if:
  /// - Animation not found for key
  /// - Animation is not currently playing
  /// - State update fails
  ///
  /// Example:
  /// ```dart
  /// final key = await useCase.call(animationKey('my_animation'));
  /// print('Animation paused with key: ${key.id}');
  /// ```
  Future<AnimationKey> call(AnimationKey key) async {
    // Load current state
    final currentState = await repository.loadAnimationState(key);

    if (currentState == null) {
      throw AnimationException.animationNotFound(
        message: 'No animation found for key: ${key.id}',
      );
    }

    // Check if animation is currently playing
    if (!_isPlaying(currentState)) {
      throw AnimationException(
        message: 'Animation is not currently playing for key: ${key.id}',
        type: AnimationErrorType.controllerError,
      );
    }

    // Update state to paused
    final newState = Map<String, dynamic>.from(currentState);
    newState['isPlaying'] = false;
    newState['pausedAt'] = DateTime.now().toIso8601String();

    try {
      await repository.saveAnimationState(key, newState);
      return key;
    } catch (e) {
      throw AnimationException.pauseFailed(
        message: 'Failed to pause animation for key: ${key.id}',
        originalException: e,
      );
    }
  }

  /// Validates that animation is currently playing
  ///
  /// Checks if the animation state indicates it is playing.
  ///
  /// Returns true if animation is in playing state.
  bool _isPlaying(Map<String, dynamic>? state) {
    if (state == null) return false;
    return state['isPlaying'] == true;
  }
}
