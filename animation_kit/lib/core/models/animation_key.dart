import 'package:equatable/equatable.dart';

/// Animation Key
///
/// Unique identifier for an animation instance.
/// Used to track and manage multiple animations simultaneously.
///
/// ## Examples
///
/// ```dart
/// // Creating an animation key
/// final key = AnimationKey('fade_in');
///
/// // Using with animation provider
/// final state = ref.watch(animationProvider(key: key));
///
/// // Creating unique key for list items
/// final keys = List.generate(
///   items.length,
///   (index) => AnimationKey('item_$index'),
/// );
/// ```
class AnimationKey extends Equatable {
  /// Unique identifier for the animation
  ///
  /// Used to distinguish between different animation instances.
  final String id;

  /// Optional category for grouping animations
  ///
  /// Can be used to group related animations together.
  final String? category;

  /// Optional timestamp for tracking
  ///
  /// Records when this key was created.
  final DateTime? createdAt;

  /// Creates an animation key with an ID
  ///
  /// The [id] should be unique within the scope
  /// where the animation is used.
  const AnimationKey({
    required this.id,
    this.category,
    this.createdAt,
  });

  /// Creates an animation key with a generated ID
  ///
  /// Generates a unique ID using a prefix and timestamp.
  factory AnimationKey.generate({
    String prefix = 'animation',
    String? category,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final id = '${prefix}_$timestamp';
    return AnimationKey(
      id: id,
      category: category,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a copy of this key with updated values
  ///
  /// Returns a new [AnimationKey] with specified fields replaced.
  AnimationKey copyWith({
    String? id,
    String? category,
    DateTime? createdAt,
  }) {
    return AnimationKey(
      id: id ?? this.id,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, category, createdAt];

  /// Returns true if this key belongs to the given category
  ///
  /// Checks if the [category] matches the provided [category].
  bool isInCategory(String? category) {
    if (category == null) {
      return this.category == null;
    }
    return this.category == category;
  }

  /// Returns true if this key is newer than the given key
  ///
  /// Compares [createdAt] timestamps.
  bool isNewerThan(AnimationKey other) {
    if (createdAt == null || other.createdAt == null) {
      return false;
    }
    return createdAt!.isAfter(other.createdAt!);
  }

  /// Returns true if this key is older than the given key
  ///
  /// Compares [createdAt] timestamps.
  bool isOlderThan(AnimationKey other) {
    if (createdAt == null || other.createdAt == null) {
      return false;
    }
    return createdAt!.isBefore(other.createdAt!);
  }

  /// Returns a string representation of this key
  ///
  /// Useful for debugging and logging.
  String toDebugString() {
    final buffer = StringBuffer('AnimationKey(');
    buffer.write('id: $id');
    if (category != null) {
      buffer.write(', category: $category');
    }
    if (createdAt != null) {
      buffer.write(', createdAt: $createdAt');
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  String toString() =>
      'AnimationKey(id: $id${category != null ? ', category: $category' : ''})';

  /// Creates a new key with the given category
  ///
  /// Returns a new [AnimationKey] with the same [id] but different [category].
  AnimationKey withCategory(String category) {
    return copyWith(category: category);
  }

  /// Creates a new key with the given ID
  ///
  /// Returns a new [AnimationKey] with the same [category] but different [id].
  AnimationKey withId(String id) {
    return copyWith(id: id);
  }

  /// Returns true if this is a valid key
  ///
  /// A key is valid if [id] is not empty.
  bool get isValid {
    return id.isNotEmpty;
  }

  /// Returns the hash code for this key
  ///
  /// Used for equality comparisons and hashing.
  @override
  int get hashCode => id.hashCode;

  /// Checks if this key equals another object
  ///
  /// Two keys are equal if their [id] values match.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimationKey && other.id == id;
  }
}
