import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';

import '../config/auto_scroll_config.dart';
import '../config/layout_config.dart';
import '../config/visual_config.dart';
import '../models/carousel_item.dart';
import '../models/carousel_state.dart';

/// A controller for managing carousel state and behavior.
///
/// This controller handles:
/// - Page navigation (next, previous, goTo)
/// - Auto-scroll functionality
/// - User interaction pausing
/// - State management
class CarouselController extends ChangeNotifier {
  CarouselController({
    List<CarouselItem> items = const [],
    int initialIndex = 0,
    AutoScrollConfig autoScrollConfig = const AutoScrollConfig(),
    VisualConfig visualConfig = const VisualConfig(),
    LayoutConfig layoutConfig = const LayoutConfig(),
    this.onPageChanged,
  })  : _autoScrollConfig = autoScrollConfig,
        _visualConfig = visualConfig,
        _layoutConfig = layoutConfig,
        _state = CarouselState(
          items: items,
          currentIndex: initialIndex.clamp(
            0,
            items.isEmpty ? 0 : items.length - 1,
          ),
        ) {
    _initPageController();
    _initAutoScroll();
  }

  CarouselState _state;
  AutoScrollConfig _autoScrollConfig;
  VisualConfig _visualConfig;
  LayoutConfig _layoutConfig;

  PageController? _pageController;
  Timer? _autoScrollTimer;

  /// Callback when page changes.
  final ValueChanged<int>? onPageChanged;

  /// Current carousel state.
  CarouselState get state => _state;

  /// Current page index.
  int get currentIndex => _state.currentIndex;

  /// Total item count.
  int get itemCount => _state.itemCount;

  /// Whether auto-scroll is paused.
  bool get isPaused => _state.isPaused;

  /// The internal page controller.
  PageController? get pageController => _pageController;

  /// Current auto-scroll configuration.
  AutoScrollConfig get autoScrollConfig => _autoScrollConfig;

  /// Current visual configuration.
  VisualConfig get visualConfig => _visualConfig;

  /// Current layout configuration.
  LayoutConfig get layoutConfig => _layoutConfig;

  void _initPageController() {
    _pageController = PageController(
      initialPage: _state.currentIndex,
      viewportFraction: _layoutConfig.viewportFraction,
      keepPage: _layoutConfig.keepPage,
    );
  }

  void _initAutoScroll() {
    if (_autoScrollConfig.enabled && _state.itemCount > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(_autoScrollConfig.interval, (_) {
      if (!_state.isPaused && !_state.isDragging) {
        _autoAdvance();
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _autoAdvance() {
    if (_state.isEmpty) return;

    int nextIndex;
    if (_autoScrollConfig.reverse) {
      nextIndex = _autoScrollConfig.loop
          ? (_state.currentIndex - 1 + _state.itemCount) % _state.itemCount
          : (_state.currentIndex - 1).clamp(0, _state.itemCount - 1);
    } else {
      nextIndex = _autoScrollConfig.loop
          ? (_state.currentIndex + 1) % _state.itemCount
          : (_state.currentIndex + 1).clamp(0, _state.itemCount - 1);
    }

    if (nextIndex != _state.currentIndex) {
      animateToPage(nextIndex);
    }
  }

  /// Updates the items in the carousel.
  void updateItems(List<CarouselItem> items) {
    _state = _state.copyWith(items: items).clampIndex();
    notifyListeners();

    if (_autoScrollConfig.enabled && items.length > 1) {
      _startAutoScroll();
    } else {
      _stopAutoScroll();
    }
  }

  /// Updates the auto-scroll configuration.
  void updateAutoScrollConfig(AutoScrollConfig config) {
    _autoScrollConfig = config;
    _stopAutoScroll();
    if (config.enabled && _state.itemCount > 1) {
      _startAutoScroll();
    }
    notifyListeners();
  }

  /// Updates the visual configuration.
  void updateVisualConfig(VisualConfig config) {
    _visualConfig = config;
    notifyListeners();
  }

  /// Updates the layout configuration.
  void updateLayoutConfig(LayoutConfig config) {
    final needsNewController =
        _layoutConfig.viewportFraction != config.viewportFraction ||
            _layoutConfig.keepPage != config.keepPage;

    _layoutConfig = config;

    if (needsNewController) {
      _pageController?.dispose();
      _initPageController();
    }

    notifyListeners();
  }

  /// Navigates to the next page.
  void next({bool animate = true}) {
    if (_state.isEmpty) return;

    final nextIndex = _autoScrollConfig.loop
        ? (_state.currentIndex + 1) % _state.itemCount
        : (_state.currentIndex + 1).clamp(0, _state.itemCount - 1);

    if (animate) {
      animateToPage(nextIndex);
    } else {
      jumpToPage(nextIndex);
    }
  }

  /// Navigates to the previous page.
  void previous({bool animate = true}) {
    if (_state.isEmpty) return;

    final prevIndex = _autoScrollConfig.loop
        ? (_state.currentIndex - 1 + _state.itemCount) % _state.itemCount
        : (_state.currentIndex - 1).clamp(0, _state.itemCount - 1);

    if (animate) {
      animateToPage(prevIndex);
    } else {
      jumpToPage(prevIndex);
    }
  }

  /// Animates to a specific page.
  void animateToPage(int index) {
    if (_state.isEmpty || index < 0 || index >= _state.itemCount) return;
    if (_pageController?.hasClients != true) return;

    _state = _state.copyWith(isAnimating: true);
    notifyListeners();

    _pageController!
        .animateToPage(
      index,
      duration: _visualConfig.animationDuration,
      curve: _visualConfig.animationCurve,
    )
        .then((_) {
      _state = _state.copyWith(
        currentIndex: index,
        isAnimating: false,
      );
      onPageChanged?.call(index);
      notifyListeners();
    });
  }

  /// Jumps to a specific page without animation.
  void jumpToPage(int index) {
    if (_state.isEmpty || index < 0 || index >= _state.itemCount) return;
    if (_pageController?.hasClients != true) return;

    _pageController!.jumpToPage(index);
    _state = _state.copyWith(currentIndex: index);
    onPageChanged?.call(index);
    notifyListeners();
  }

  /// Called when page changes (from PageView callback).
  void onPageChangedInternal(int index) {
    _state = _state.copyWith(currentIndex: index);
    onPageChanged?.call(index);
    notifyListeners();
  }

  /// Pauses auto-scroll.
  void pause() {
    _state = _state.copyWith(isPaused: true);
    notifyListeners();
  }

  /// Resumes auto-scroll.
  void resume() {
    _state = _state.copyWith(isPaused: false);
    notifyListeners();
  }

  /// Pauses auto-scroll temporarily (for user interaction).
  void pauseTemporarily() {
    if (!_autoScrollConfig.pauseOnInteraction) return;

    pause();
    Future.delayed(_autoScrollConfig.pauseDuration, () {
      if (_state.isPaused) {
        resume();
      }
    });
  }

  /// Called when user starts dragging.
  void onDragStart() {
    _state = _state.copyWith(isDragging: true);
    notifyListeners();
  }

  /// Called when user stops dragging.
  void onDragEnd() {
    _state = _state.copyWith(isDragging: false);
    if (_autoScrollConfig.pauseOnInteraction) {
      pauseTemporarily();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController?.dispose();
    super.dispose();
  }
}

/// Provider for carousel controller with autoDispose.
///
/// Usage:
/// ```dart
/// final controller = ref.watch(carouselControllerProvider(items));
/// // Or access notifier
/// ref.read(carouselControllerProvider(items).notifier).next();
/// ```
///
/// For more control, use [carouselControllerProviderWithConfig].
final carouselControllerProvider =
    Provider.autoDispose.family<CarouselController, List<CarouselItem>>(
  (ref, items) => CarouselController(items: items),
);

/// Provider for carousel controller with full configuration options.
///
/// Usage:
/// ```dart
/// final controller = ref.watch(carouselControllerProviderWithConfig(
///   CarouselControllerConfig(
///     items: myItems,
///     autoScrollConfig: AutoScrollConfig.normal,
///   ),
/// ));
/// ```
final carouselControllerProviderWithConfig =
    Provider.autoDispose.family<CarouselController, CarouselControllerConfig>(
  (ref, config) => CarouselController(
    items: config.items,
    initialIndex: config.initialIndex,
    autoScrollConfig: config.autoScrollConfig,
    visualConfig: config.visualConfig,
    layoutConfig: config.layoutConfig,
    onPageChanged: config.onPageChanged,
  ),
);

/// Configuration for creating a carousel controller via provider.
class CarouselControllerConfig {
  final List<CarouselItem> items;
  final int initialIndex;
  final AutoScrollConfig autoScrollConfig;
  final VisualConfig visualConfig;
  final LayoutConfig layoutConfig;
  final ValueChanged<int>? onPageChanged;

  const CarouselControllerConfig({
    required this.items,
    this.initialIndex = 0,
    this.autoScrollConfig = const AutoScrollConfig(),
    this.visualConfig = const VisualConfig(),
    this.layoutConfig = const LayoutConfig(),
    this.onPageChanged,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarouselControllerConfig &&
          runtimeType == other.runtimeType &&
          items.length == other.items.length &&
          initialIndex == other.initialIndex;

  @override
  int get hashCode => items.length.hashCode ^ initialIndex.hashCode;
}
