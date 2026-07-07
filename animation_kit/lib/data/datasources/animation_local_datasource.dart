import 'package:shared_preferences/shared_preferences.dart';

import '../../core/exceptions/animation_exception.dart';

/// Animation Local Datasource
///
/// Handles local storage of animation states using SharedPreferences.
/// Provides persistence for animation progress tracking.
///
/// ## Examples
///
/// ```dart
/// // Creating datasource
/// final datasource = AnimationLocalDatasource();
///
/// // Saving animation state
/// final key = AnimationKey('my_animation');
/// final state = {'isPlaying': true, 'progress': 0.5};
/// await datasource.save(key.id, state);
///
/// // Loading animation state
/// final loadedState = await datasource.load(key.id);
/// if (loadedState != null) {
///   print('Animation state: $loadedState');
/// }
/// ```
class AnimationLocalDatasource {
  /// SharedPreferences instance
  ///
  /// Used for all local storage operations.
  final SharedPreferences _prefs;

  /// Key prefix for animation storage
  ///
  /// All animation keys are prefixed with this value.
  static const String _keyPrefix = 'animation_';

  /// Creates an animation local datasource
  ///
  /// Requires a SharedPreferences instance.
  AnimationLocalDatasource(this._prefs);

  /// Creates an animation local datasource asynchronously
  static Future<AnimationLocalDatasource> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AnimationLocalDatasource(prefs);
  }

  /// Saves animation state for a given key
  ///
  /// Persists animation state to local storage.
  ///
  /// [key] identifies which animation to save.
  /// [state] contains animation data to save.
  ///
  /// Throws [AnimationException] if save fails.
  ///
  /// Example:
  /// ```dart
  /// final key = AnimationKey('my_animation');
  /// final state = {'isPlaying': true};
  /// await datasource.save(key.id, state);
  /// ```
  Future<void> save(
    String key,
    Map<String, dynamic> state,
  ) async {
    try {
      await _prefs.setString('$_keyPrefix$key', _encodeState(state));
    } catch (e) {
      throw AnimationException(
        message: 'Failed to save animation state for key: $key',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  /// Loads animation state for a given key
  ///
  /// Retrieves previously saved animation state.
  /// Returns null if no state exists for key.
  ///
  /// [key] identifies which animation to load.
  ///
  /// Example:
  /// ```dart
  /// final key = AnimationKey('my_animation');
  /// final state = await datasource.load(key.id);
  /// if (state != null) {
  ///   print('Loaded state: $state');
  /// }
  /// ```
  Future<Map<String, dynamic>?> load(
    String key,
  ) async {
    try {
      final encoded = _prefs.getString('$_keyPrefix$key');
      if (encoded == null || encoded.isEmpty) {
        return null;
      }
      return _decodeState(encoded);
    } catch (e) {
      throw AnimationException(
        message: 'Failed to load animation state for key: $key',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  /// Removes animation state for a given key
  ///
  /// Deletes saved state for a specific animation.
  ///
  /// [key] identifies which animation to remove.
  ///
  /// Example:
  /// ```dart
  /// final key = AnimationKey('my_animation');
  /// await datasource.remove(key.id);
  /// ```
  Future<void> remove(
    String key,
  ) async {
    try {
      await _prefs.remove('$_keyPrefix$key');
    } catch (e) {
      throw AnimationException(
        message: 'Failed to remove animation state for key: $key',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  /// Clears all animation states
  ///
  /// Removes all saved animation states.
  /// Useful for cleanup or resetting animation tracking.
  ///
  /// Example:
  /// ```dart
  /// await datasource.clearAll();
  /// ```
  Future<void> clearAll() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      throw AnimationException(
        message: 'Failed to clear all animation states',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  /// Gets all animation keys
  ///
  /// Returns a list of all saved animation keys.
  /// Useful for debugging or cleanup.
  ///
  /// Example:
  /// ```dart
  /// final keys = await datasource.getAllKeys();
  /// print('Found ${keys.length} animation states');
  /// ```
  Future<List<String>> getAllKeys() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      return keys.map((key) => key.substring(_keyPrefix.length)).toList();
    } catch (e) {
      throw AnimationException(
        message: 'Failed to get all animation keys',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  /// Checks if animation state exists for a given key
  ///
  /// Returns true if a saved state exists for the key.
  ///
  /// [key] identifies which animation to check.
  ///
  /// Example:
  /// ```dart
  /// final key = AnimationKey('my_animation');
  /// final exists = await datasource.has(key.id);
  /// if (exists) {
  ///   print('Animation state exists');
  /// }
  /// ```
  Future<bool> has(
    String key,
  ) async {
    try {
      return _prefs.containsKey('$_keyPrefix$key');
    } catch (e) {
      throw AnimationException(
        message: 'Failed to check animation state for key: $key',
        type: AnimationErrorType.controllerError,
        originalException: e,
      );
    }
  }

  /// Encodes state map to JSON string
  ///
  /// Converts state map to JSON for storage.
  String _encodeState(Map<String, dynamic> state) {
    return state.entries.map((entry) {
      return '${entry.key}:${entry.value}';
    }).join('|');
  }

  /// Decodes JSON string to state map
  ///
  /// Converts JSON string back to state map.
  Map<String, dynamic> _decodeState(String encoded) {
    final entries = encoded.split('|');
    final Map<String, dynamic> state = {};

    for (final entry in entries) {
      final parts = entry.split(':');
      if (parts.length >= 2) {
        final key = parts[0];
        final value = parts.sublist(1).join(':');
        state[key] = value;
      }
    }

    return state;
  }

  /// Gets all animation states
  ///
  /// Returns a map of all saved animation states.
  /// Useful for debugging or state inspection.
  ///
  /// Example:
  /// ```dart
  /// final states = await datasource.getAllStates();
  /// states.forEach((key, state) {
  ///   print('$key: $state');
  /// });
  /// ```
  Future<Map<String, Map<String, dynamic>>> getAllStates() async {
    try {
      final keys = await getAllKeys();
      final Map<String, Map<String, dynamic>> states = {};

      for (final key in keys) {
        final state = await load(key);
        if (state != null) {
          states[key] = state;
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
