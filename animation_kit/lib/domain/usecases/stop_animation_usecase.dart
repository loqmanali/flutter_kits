import '../../core/exceptions/animation_exception.dart';
import '../../core/models/animation_key.dart';
import '../repositories/animation_repository.dart';

/// Stop Animation Use Case
///
/// Business logic for stopping animations.
/// Handles animation termination with validation and error handling.
///
/// ## Examples
///
/// ```dart
/// // Creating use case
/// final useCase = StopAnimationUseCase(
///   repository: animationRepository,
/// );
///
/// // Using with animation provider
/// ref.read(animationProvider.notifier).stopAnimation(key);
/// ```
class StopAnimationUseCase {
  /// Animation repository for state management
  ///
  /// Used to update and clear animation states.
  final AnimationRepository repository;

  /// Creates a stop animation use case
  ///
  /// Initializes with required [repository].
  StopAnimationUseCase({
    required this.repository,
  });

  /// Executes the stop animation operation
  ///
  /// Stops the animation with the given key.
  /// Updates state to indicate animation is stopped.
  ///
  /// Throws [AnimationException] if:
  /// - Animation not found for key
  /// - State update fails
  ///
  /// Example:
  /// ```dart
  /// final key = AnimationKey('my_animation');
  /// await useCase.call(key);
  /// print('Animation stopped with key: ${key.id}');
  /// ```
  Future<void> call(AnimationKey key) async {
    try {
      // Load current state
      final currentState = await repository.loadAnimationState(key);

      if (!_animationExists(currentState)) {
        throw AnimationException.animationNotFound(
          message: 'No animation found for key: ${key.id}',
        );
      }

      if (!_isPlaying(currentState)) {
        throw AnimationException.animationNotFound(
          message: 'Animation is not currently playing for key: ${key.id}',
        );
      }

      // Update state to stopped
      final newState = Map<String, dynamic>.from(currentState!);
      newState['isPlaying'] = false;
      newState['stoppedAt'] = DateTime.now().toIso8601String();

      // Save updated state
      await repository.saveAnimationState(key, newState);
    } catch (e) {
      throw AnimationException.stopFailed(
        message: 'Failed to stop animation for key: ${key.id}',
        originalException: e,
      );
    }
  }

  /// Validates that animation exists for the given key
  ///
  /// Checks if an animation state exists for the key.
  ///
  /// Returns true if state exists.
  bool _animationExists(Map<String, dynamic>? state) {
    return state != null && state.containsKey('isPlaying');
  }

  /// Validates that animation is currently playing
  ///
  /// Checks if animation is in playing state.
  ///
  /// Returns true if animation is playing.
  bool _isPlaying(Map<String, dynamic>? state) {
    return state != null && state['isPlaying'] == true;
  }
}
