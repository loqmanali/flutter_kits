import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/carousel_config.dart';
import '../config/indicator_config.dart';
import '../models/carousel_item.dart';
import '../providers/carousel_controller_provider.dart';
import 'carousel_indicator.dart';

/// A fully-featured carousel widget with Riverpod state management.
///
/// This widget provides a complete carousel solution with:
/// - Auto-scroll functionality
/// - Multiple indicator styles and effects
/// - Configurable layout and visual options
/// - Riverpod state management
/// - Gesture detection for pause/resume
///
/// Example usage:
/// ```dart
/// final items = [
///   ImageCarouselItem.asset('assets/banner1.png'),
///   ImageCarouselItem.asset('assets/banner2.png'),
/// ];
///
/// Carousel(
///   items: items,
///   config: CarouselConfig.banner,
/// )
/// ```
class Carousel extends ConsumerStatefulWidget {
  /// List of carousel items to display.
  final List<CarouselItem> items;

  /// Carousel configuration.
  final CarouselConfig config;

  /// Optional controller for external control.
  final CarouselController? controller;

  /// Callback when page changes.
  final ValueChanged<int>? onPageChanged;

  const Carousel({
    super.key,
    required this.items,
    this.config = const CarouselConfig(),
    this.controller,
    this.onPageChanged,
  });

  @override
  ConsumerState<Carousel> createState() => _CarouselState();
}

class _CarouselState extends ConsumerState<Carousel> {
  late final CarouselController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        CarouselController(
          items: widget.items,
          autoScrollConfig: widget.config.autoScroll,
          visualConfig: widget.config.visual,
          layoutConfig: widget.config.layout,
          onPageChanged: _handlePageChanged,
        );
    _currentIndex = _controller.currentIndex;
  }

  @override
  void didUpdateWidget(Carousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _controller.updateItems(widget.items);
    }
  }

  void _handlePageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onPageChanged?.call(index);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.config.visual.height,
        child: _buildEmptyState(),
      );
    }

    return _buildCarousel();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        height: widget.config.visual.height,
        decoration: BoxDecoration(
          color: widget.config.visual.backgroundColor,
          borderRadius:
              BorderRadius.circular(widget.config.visual.borderRadius),
        ),
        child: const Icon(Icons.image_not_supported_outlined),
      ),
    );
  }

  Widget _buildCarousel() {
    final indicator = widget.config.indicator;

    if (indicator.position == IndicatorPosition.overlay) {
      return _buildOverlayCarousel();
    }

    if (indicator.position == IndicatorPosition.above) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CarouselIndicator(
            currentPage: _currentIndex,
            pageCount: widget.items.length,
            config: indicator,
          ),
          _buildPageView(),
        ],
      );
    }

    // Default: below
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPageView(),
        if (indicator.show)
          CarouselIndicator(
            currentPage: _currentIndex,
            pageCount: widget.items.length,
            config: indicator,
          ),
      ],
    );
  }

  Widget _buildOverlayCarousel() {
    return SizedBox(
      height: widget.config.visual.height,
      child: Stack(
        children: [
          _buildPageView(),
          if (widget.config.indicator.show)
            Positioned(
              left: 0,
              right: 0,
              bottom: widget.config.indicator.margin,
              child: CarouselIndicator(
                currentPage: _currentIndex,
                pageCount: widget.items.length,
                config: widget.config.indicator,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    final visual = widget.config.visual;
    final layout = widget.config.layout;

    return GestureDetector(
      onPanDown: (_) => _controller.onDragStart(),
      onPanEnd: (_) => _controller.onDragEnd(),
      child: Container(
        height: visual.height,
        decoration: BoxDecoration(
          color: visual.backgroundColor,
          borderRadius: BorderRadius.circular(visual.borderRadius),
          border: visual.borderColor != null
              ? Border.all(
                  color: visual.borderColor!,
                  width: visual.borderWidth,
                )
              : null,
          boxShadow: visual.boxShadow,
        ),
        clipBehavior: visual.clipBehavior,
        child: PageView.builder(
          controller: _controller.pageController,
          onPageChanged: _controller.onPageChangedInternal,
          itemCount: widget.items.length,
          padEnds: layout.padEnds,
          itemBuilder: (context, index) {
            return _buildItem(index);
          },
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = widget.items[index];
    final visual = widget.config.visual;

    return Padding(
      padding: visual.padding,
      child: item.build(
        context,
        borderRadius: visual.borderRadius,
        fit: visual.imageFit,
      ),
    );
  }
}

/// A simplified carousel widget without Riverpod dependency.
///
/// Use this when you want direct control without providers.
class ControlledCarousel extends StatefulWidget {
  /// List of carousel items to display.
  final List<CarouselItem> items;

  /// Carousel configuration.
  final CarouselConfig config;

  /// Optional controller for external control.
  final CarouselController? controller;

  /// Callback when page changes.
  final ValueChanged<int>? onPageChanged;

  const ControlledCarousel({
    super.key,
    required this.items,
    this.config = const CarouselConfig(),
    this.controller,
    this.onPageChanged,
  });

  @override
  State<ControlledCarousel> createState() => _ControlledCarouselState();
}

class _ControlledCarouselState extends State<ControlledCarousel> {
  late final CarouselController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        CarouselController(
          items: widget.items,
          autoScrollConfig: widget.config.autoScroll,
          visualConfig: widget.config.visual,
          layoutConfig: widget.config.layout,
          onPageChanged: _handlePageChanged,
        );
    _currentIndex = _controller.currentIndex;
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(ControlledCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _controller.updateItems(widget.items);
    }
  }

  void _handlePageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onPageChanged?.call(index);
  }

  void _onControllerUpdate() {
    if (mounted && _currentIndex != _controller.currentIndex) {
      setState(() {
        _currentIndex = _controller.currentIndex;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.config.visual.height,
        child: _buildEmptyState(),
      );
    }

    return _buildCarousel();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        height: widget.config.visual.height,
        decoration: BoxDecoration(
          color: widget.config.visual.backgroundColor,
          borderRadius:
              BorderRadius.circular(widget.config.visual.borderRadius),
        ),
        child: const Icon(Icons.image_not_supported_outlined),
      ),
    );
  }

  Widget _buildCarousel() {
    final indicator = widget.config.indicator;

    if (indicator.position == IndicatorPosition.overlay) {
      return _buildOverlayCarousel();
    }

    if (indicator.position == IndicatorPosition.above) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CarouselIndicator(
            currentPage: _currentIndex,
            pageCount: widget.items.length,
            config: indicator,
          ),
          _buildPageView(),
        ],
      );
    }

    // Default: below
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPageView(),
        if (indicator.show)
          CarouselIndicator(
            currentPage: _currentIndex,
            pageCount: widget.items.length,
            config: indicator,
          ),
      ],
    );
  }

  Widget _buildOverlayCarousel() {
    return SizedBox(
      height: widget.config.visual.height,
      child: Stack(
        children: [
          _buildPageView(),
          if (widget.config.indicator.show)
            Positioned(
              left: 0,
              right: 0,
              bottom: widget.config.indicator.margin,
              child: CarouselIndicator(
                currentPage: _currentIndex,
                pageCount: widget.items.length,
                config: widget.config.indicator,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    final visual = widget.config.visual;
    final layout = widget.config.layout;

    return GestureDetector(
      onPanDown: (_) => _controller.onDragStart(),
      onPanEnd: (_) => _controller.onDragEnd(),
      child: Container(
        height: visual.height,
        decoration: BoxDecoration(
          color: visual.backgroundColor,
          borderRadius: BorderRadius.circular(visual.borderRadius),
          border: visual.borderColor != null
              ? Border.all(
                  color: visual.borderColor!,
                  width: visual.borderWidth,
                )
              : null,
          boxShadow: visual.boxShadow,
        ),
        clipBehavior: visual.clipBehavior,
        child: PageView.builder(
          controller: _controller.pageController,
          onPageChanged: _controller.onPageChangedInternal,
          itemCount: widget.items.length,
          padEnds: layout.padEnds,
          itemBuilder: (context, index) {
            return _buildItem(index);
          },
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = widget.items[index];
    final visual = widget.config.visual;

    return Padding(
      padding: visual.padding,
      child: item.build(
        context,
        borderRadius: visual.borderRadius,
        fit: visual.imageFit,
      ),
    );
  }
}
