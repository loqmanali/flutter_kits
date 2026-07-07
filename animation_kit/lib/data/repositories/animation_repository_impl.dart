import '../../core/exceptions/animation_exception.dart';
import '../../core/models/animation_key.dart';
import '../../domain/repositories/animation_repository.dart';
import '../datasources/animation_local_datasource.dart';

/// Animation Repository Implementation
///
/// Concrete implementation of [AnimationRepository] using SharedPreferences.
/// Provides local persistence for animation states.
///
/// ## Examples
///
/// ```dart
/// // Creating repository
/// final repository = AnimationRepositoryImpl(
///   datasource: AnimationLocalDatasource(),
/// );
///
/// // Saving animation state
/// final key = AnimationKey('my_animation');
/// final state = {'isPlaying': true, 'progress': 0.5};
/// await repository.saveAnimationState(key, state);
///
/// // Loading animation state
/// final loadedState = await repository.loadAnimationState(key);
/// if (loadedState != null) {
///   print('Animation state: $loadedState');
/// }
/// ```
class AnimationRepositoryImpl implements AnimationRepository {
  /// Local datasource for persistence
  ///
  /// Handles all local storage operations.
  final AnimationLocalDatasource datasource;

  /// Creates an animation repository implementation
  ///
  /// Initializes with the given [datasource].
  AnimationRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<void> saveAnimationState(
    AnimationKey key,
    Map<String, dynamic> state,
  ) async {
    try {
      await datasource.save(key.id, state);
    } catch (e) {
      throw AnimationException(
        message: 'Failed to save animation state for key: ${key.id}',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> loadAnimationState(
    AnimationKey key,
  ) async {
    try {
      final state = await datasource.load(key.id);
      return state;
    } catch (e) {
      throw AnimationException(
        message: 'Failed to load animation state for key: ${key.id}',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearAllAnimationStates() async {
    try {
      await datasource.clearAll();
    } catch (e) {
      throw AnimationException(
        message: 'Failed to clear all animation states',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  @override
  Future<void> removeAnimationState(
    AnimationKey key,
  ) async {
    try {
      await datasource.remove(key.id);
    } catch (e) {
      throw AnimationException(
        message: 'Failed to remove animation state for key: ${key.id}',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  @override
  Future<bool> hasAnimationState(
    AnimationKey key,
  ) async {
    try {
      final state = await datasource.load(key.id);
      return state != null;
    } catch (e) {
      throw AnimationException(
        message: 'Failed to check animation state for key: ${key.id}',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  @override
  Future<List<AnimationKey>> getAllAnimationKeys() async {
    try {
      final keys = await datasource.getAllKeys();
      return keys.map((id) => AnimationKey(id: id)).toList();
    } catch (e) {
      throw AnimationException(
        message: 'Failed to get all animation keys',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  @override
  Future<Map<AnimationKey, Map<String, dynamic>>>
      getAllAnimationStates() async {
    try {
      final keys = await datasource.getAllKeys();
      final states = <AnimationKey, Map<String, dynamic>>{};

      for (final id in keys) {
        final state = await datasource.load(id);
        if (state != null) {
          states[AnimationKey(id: id)] = state;
        }
      }

      return states;
    } catch (e) {
      throw AnimationException(
        message: 'Failed to get all animation states',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }
}
