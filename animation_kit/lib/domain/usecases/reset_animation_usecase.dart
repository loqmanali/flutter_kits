import '../../core/exceptions/animation_exception.dart';
import '../../core/models/animation_key.dart';
import '../repositories/animation_repository.dart';

/// Reset Animation Use Case
///
/// Business logic for resetting animations.
/// Handles animation reset with validation and error handling.
///
/// ## Examples
///
/// ```dart
/// // Creating use case
/// final useCase = ResetAnimationUseCase(
///   repository: animationRepository,
/// );
///
/// // Using with animation provider
/// ref.read(animationProvider.notifier).resetAnimation(key);
/// ```
class ResetAnimationUseCase {
  /// Animation repository for state management
  ///
  /// Used to reset animation states to initial values.
  final AnimationRepository repository;

  /// Creates a reset animation use case
  ///
  /// Initializes with required [repository].
  ResetAnimationUseCase({
    required this.repository,
  });

  /// Executes the reset animation operation
  ///
  /// Resets animation state for the given key.
  /// Clears isPlaying flag and resets progress to 0.
  ///
  /// Throws [AnimationException] if:
  /// - Animation not found for key
  /// - State update fails
  ///
  /// Example:
  /// ```dart
  /// final key = await useCase.call(animationKey('my_animation'));
  /// print('Animation reset with key: ${key.id}');
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

      if (!_canReset(currentState)) {
        throw AnimationException.animationNotFound(
          message: 'Animation cannot be reset for key: ${key.id}',
        );
      }

      // Reset state to initial values
      final newState = <String, dynamic>{
        'config': currentState!['config'],
        'isPlaying': false,
        'progress': 0.0,
        'resetAt': DateTime.now().toIso8601String(),
      };

      // Save reset state
      await repository.saveAnimationState(key, newState);
    } catch (e) {
      throw AnimationException.resetFailed(
        message: 'Failed to reset animation for key: ${key.id}',
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

  /// Validates that animation can be reset
  ///
  /// Checks if animation is in a state that allows reset.
  ///
  /// Returns true if animation exists and can be reset.
  bool _canReset(Map<String, dynamic>? state) {
    return state != null;
  }
}
