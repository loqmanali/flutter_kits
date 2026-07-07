import '../../core/models/animation_key.dart';

/// Animation Repository Interface
///
/// Abstract repository for animation operations.
/// Defines the contract for animation data access.
///
/// ## Examples
///
/// ```dart
/// // Implementing the repository
/// class AnimationRepositoryImpl implements AnimationRepository {
///   final AnimationLocalDatasource _datasource;
///
///   AnimationRepositoryImpl(this._datasource);
///
///   @override
///   Future<void> saveAnimationState(
///     AnimationKey key,
///     Map<String, dynamic> state,
///   ) async {
///     await _datasource.saveAnimationState(key, state);
///   }
/// }
///
/// // Using with use case
/// class PlayAnimationUseCase {
///   final AnimationRepository _repository;
///
///   PlayAnimationUseCase(this._repository);
///
///   Future<void> call(AnimationConfig config) async {
///     final key = AnimationKey.generate();
///     final state = {'config': config.toJson()};
///     await _repository.saveAnimationState(key, state);
///   }
/// }
/// ```
abstract class AnimationRepository {
  /// Saves animation state for a given key
  ///
  /// Persists animation state locally for later retrieval.
  /// Used to track animation progress across app restarts.
  ///
  /// [key] identifies which animation to save.
  /// [state] contains the animation data to save.
  ///
  /// Throws [AnimationException] if save fails.
  ///
  /// Example:
  /// ```dart
  /// final key = AnimationKey('my_animation');
  /// final state = {'isPlaying': true};
  /// await repository.saveAnimationState(key, state);
  /// ```
  Future<void> saveAnimationState(
    AnimationKey key,
    Map<String, dynamic> state,
  );

  /// Loads animation state for a given key
  ///
  /// Retrieves previously saved animation state.
  /// Returns null if no state exists for the key.
  ///
  /// [key] identifies which animation to load.
  ///
  /// Example:
  /// ```dart
  /// final key = AnimationKey('my_animation');
  /// final state = await repository.loadAnimationState(key);
  /// if (state != null) {
  ///   print('Found saved state: $state');
  /// }
  /// ```
  Future<Map<String, dynamic>?> loadAnimationState(
    AnimationKey key,
  );

  /// Clears all animation states
  ///
  /// Removes all saved animation states.
  /// Useful for cleanup or resetting animation tracking.
  ///
  /// Example:
  /// ```dart
  /// await repository.clearAllAnimationStates();
  /// ```
  Future<void> clearAllAnimationStates();

  /// Removes animation state for a given key
  ///
  /// Deletes the saved state for a specific animation.
  ///
  /// [key] identifies which animation to remove.
  ///
  /// Example:
  /// ```dart
  /// final key = AnimationKey('my_animation');
  /// await repository.removeAnimationState(key);
  /// ```
  Future<void> removeAnimationState(
    AnimationKey key,
  );

  /// Checks if animation state exists for a given key
  ///
  /// Returns true if a saved state exists for the key.
  ///
  /// [key] identifies which animation to check.
  ///
  /// Example:
  /// ```dart
  /// final key = AnimationKey('my_animation');
  /// final exists = await repository.hasAnimationState(key);
  /// if (exists) {
  ///   print('Animation state exists');
  /// }
  /// ```
  Future<bool> hasAnimationState(
    AnimationKey key,
  );

  /// Gets all animation keys
  ///
  /// Returns a list of all saved animation keys.
  /// Useful for debugging or cleanup.
  ///
  /// Example:
  /// ```dart
  /// final keys = await repository.getAllAnimationKeys();
  /// print('Found ${keys.length} animation states');
  /// ```
  Future<List<AnimationKey>> getAllAnimationKeys();

  /// Gets all animation states
  ///
  /// Returns a map of all saved animation states.
  /// Useful for debugging or state inspection.
  ///
  /// Example:
  /// ```dart
  /// final states = await repository.getAllAnimationStates();
  /// states.forEach((key, state) {
  ///   print('$key: $state');
  /// });
  /// ```
  Future<Map<AnimationKey, Map<String, dynamic>>> getAllAnimationStates();
}
