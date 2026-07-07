import 'package:flutter/foundation.dart';

import 'carousel_item.dart';

/// Represents the current state of a carousel.
///
/// This immutable class holds all the state information needed
/// to manage and display a carousel.
@immutable
class CarouselState {
  /// List of carousel items.
  final List<CarouselItem> items;

  /// Current page index.
  final int currentIndex;

  /// Whether the carousel is currently animating.
  final bool isAnimating;

  /// Whether auto-scroll is currently paused.
  final bool isPaused;

  /// Whether the user is currently dragging.
  final bool isDragging;

  /// Total number of items.
  int get itemCount => items.length;

  /// Whether there is a next item.
  bool get hasNext => currentIndex < itemCount - 1;

  /// Whether there is a previous item.
  bool get hasPrevious => currentIndex > 0;

  /// Whether the carousel is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the carousel is not empty.
  bool get isNotEmpty => items.isNotEmpty;

  /// The current item, or null if empty.
  CarouselItem? get currentItem =>
      isEmpty ? null : items[currentIndex.clamp(0, itemCount - 1)];

  const CarouselState({
    this.items = const [],
    this.currentIndex = 0,
    this.isAnimating = false,
    this.isPaused = false,
    this.isDragging = false,
  });

  /// Creates a copy with the given fields replaced.
  CarouselState copyWith({
    List<CarouselItem>? items,
    int? currentIndex,
    bool? isAnimating,
    bool? isPaused,
    bool? isDragging,
  }) {
    return CarouselState(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      isAnimating: isAnimating ?? this.isAnimating,
      isPaused: isPaused ?? this.isPaused,
      isDragging: isDragging ?? this.isDragging,
    );
  }

  /// Creates a new state with the current index clamped to valid bounds.
  CarouselState clampIndex() {
    if (isEmpty) return copyWith(currentIndex: 0);
    return copyWith(currentIndex: currentIndex.clamp(0, itemCount - 1));
  }

  /// Creates a new state with the next index.
  CarouselState next({bool loop = false}) {
    if (isEmpty) return this;
    final nextIndex = loop
        ? (currentIndex + 1) % itemCount
        : (currentIndex + 1).clamp(0, itemCount - 1);
    return copyWith(currentIndex: nextIndex);
  }

  /// Creates a new state with the previous index.
  CarouselState previous({bool loop = false}) {
    if (isEmpty) return this;
    final prevIndex = loop
        ? (currentIndex - 1 + itemCount) % itemCount
        : (currentIndex - 1).clamp(0, itemCount - 1);
    return copyWith(currentIndex: prevIndex);
  }

  /// Creates a new state with a specific index.
  CarouselState goTo(int index) {
    if (isEmpty) return this;
    return copyWith(currentIndex: index.clamp(0, itemCount - 1));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarouselState &&
          runtimeType == other.runtimeType &&
          listEquals(items, other.items) &&
          currentIndex == other.currentIndex &&
          isAnimating == other.isAnimating &&
          isPaused == other.isPaused &&
          isDragging == other.isDragging;

  @override
  int get hashCode =>
      items.hashCode ^
      currentIndex.hashCode ^
      isAnimating.hashCode ^
      isPaused.hashCode ^
      isDragging.hashCode;

  @override
  String toString() {
    return 'CarouselState(itemCount: $itemCount, currentIndex: $currentIndex, '
        'isAnimating: $isAnimating, isPaused: $isPaused, isDragging: $isDragging)';
  }
}
