import '../../core/exceptions/animation_exception.dart';
import '../../core/models/animation_config.dart';
import '../../core/models/animation_key.dart';
import '../repositories/animation_repository.dart';

/// Play Animation Use Case
///
/// Business logic for starting animations.
/// Handles animation playback with validation and error handling.
///
/// ## Examples
///
/// ```dart
/// // Creating use case
/// final useCase = PlayAnimationUseCase(
///   repository: animationRepository,
/// );
///
/// // Using with animation provider
/// ref.read(animationProvider.notifier).playAnimation(config);
/// ```
class PlayAnimationUseCase {
  /// Animation repository for state persistence
  ///
  /// Used to save and load animation states.
  final AnimationRepository repository;

  /// Creates a play animation use case
  ///
  /// Initializes with required [repository].
  PlayAnimationUseCase({
    required this.repository,
  });

  /// Executes the play animation operation
  ///
  /// Validates configuration and starts animation.
  /// Returns animation key for tracking.
  ///
  /// Throws [AnimationException] if:
  /// - Configuration is invalid
  /// - Animation fails to start
  ///
  /// Example:
  /// ```dart
  /// final key = await useCase.call(config);
  /// print('Animation started with key: ${key.id}');
  /// ```
  Future<AnimationKey> call(AnimationConfig config) async {
    // Validate configuration
    if (!_validateConfig(config)) {
      throw AnimationException.invalidConfig(
        message: 'Animation duration must be positive',
      );
    }

    // Create animation key
    final key = AnimationKey.generate();

    // Prepare state
    final state = <String, dynamic>{
      'config': _configToJson(config),
      'isPlaying': true,
      'progress': 0.0,
      'startedAt': DateTime.now().toIso8601String(),
    };

    try {
      // Save initial state
      await repository.saveAnimationState(key, state);

      return key;
    } catch (e) {
      throw AnimationException.startFailed(
        message: 'Failed to start animation: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Validates animation configuration
  ///
  /// Checks if configuration is valid for playback.
  ///
  /// Returns true if configuration is valid.
  bool _validateConfig(AnimationConfig config) {
    return config.duration.inMilliseconds > 0;
  }

  /// Converts configuration to JSON
  ///
  /// Returns a JSON representation of the config.
  Map<String, dynamic> _configToJson(AnimationConfig config) {
    return {
      'type': config.type.toString(),
      'duration': config.duration.inMilliseconds,
      'curve': config.curve.toString(),
      'repeat': config.repeat,
      'repeatCount': config.repeatCount,
      'autoPlay': config.autoPlay,
      'delay': config.delay.inMilliseconds,
    };
  }
}
