import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/carousel_item.dart';
import '../models/carousel_state.dart';

/// A simple state notifier for carousel state management.
///
/// This is a lighter alternative to [CarouselController] when you don't
/// need full controller functionality (like auto-scroll).
class CarouselStateNotifier extends Notifier<CarouselState> {
  @override
  CarouselState build() {
    return const CarouselState();
  }

  /// Updates the items in the carousel.
  void setItems(List<CarouselItem> items) {
    state = state.copyWith(items: items).clampIndex();
  }

  /// Adds an item to the carousel.
  void addItem(CarouselItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  /// Removes an item at the specified index.
  void removeItemAt(int index) {
    if (index < 0 || index >= state.itemCount) return;
    final newItems = [...state.items]..removeAt(index);
    state = state.copyWith(items: newItems).clampIndex();
  }

  /// Sets the current index.
  void setCurrentIndex(int index) {
    if (index < 0 || index >= state.itemCount) return;
    state = state.copyWith(currentIndex: index);
  }

  /// Moves to the next item.
  void next({bool loop = false}) {
    state = state.next(loop: loop);
  }

  /// Moves to the previous item.
  void previous({bool loop = false}) {
    state = state.previous(loop: loop);
  }

  /// Goes to a specific index.
  void goTo(int index) {
    state = state.goTo(index);
  }

  /// Sets the animating state.
  void setAnimating(bool animating) {
    state = state.copyWith(isAnimating: animating);
  }

  /// Sets the paused state.
  void setPaused(bool paused) {
    state = state.copyWith(isPaused: paused);
  }

  /// Sets the dragging state.
  void setDragging(bool dragging) {
    state = state.copyWith(isDragging: dragging);
  }

  /// Clears all items.
  void clear() {
    state = const CarouselState();
  }
}

/// Provider for carousel state.
///
/// Usage:
/// ```dart
/// final state = ref.watch(carouselStateProvider);
/// final notifier = ref.read(carouselStateProvider.notifier);
/// notifier.next();
/// ```
final carouselStateProvider =
    NotifierProvider.autoDispose<CarouselStateNotifier, CarouselState>(
  CarouselStateNotifier.new,
);

/// Provider for a simple current index state.
///
/// Useful when you only need to track the current index
/// without full carousel state management.
///
/// Usage:
/// ```dart
/// final currentIndex = ref.watch(carouselIndexProvider);
/// ref.read(carouselIndexProvider.notifier).setIndex(2);
/// ```
final carouselIndexProvider = NotifierProvider.autoDispose<_CarouselIndex, int>(
  _CarouselIndex.new,
);

class _CarouselIndex extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }

  void increment(int max) {
    if (state < max - 1) state++;
  }

  void decrement() {
    if (state > 0) state--;
  }
}
