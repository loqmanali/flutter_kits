import 'package:flutter/widgets.dart';

/// Scroll physics type for the carousel.
enum CarouselScrollPhysics {
  /// Standard page snapping physics.
  page,

  /// Bouncing physics (iOS style).
  bouncing,

  /// Clamping physics (Android style).
  clamping,

  /// Never scrollable.
  neverScrollable,

  /// Always scrollable.
  alwaysScrollable,

  /// Custom physics (use with customPhysics parameter).
  custom,
}

/// Configuration for the layout and scrolling behavior of the carousel.
///
/// Use this class to customize how items are arranged and how
/// scrolling behaves.
class LayoutConfig {
  /// Whether to use PageView (true) or horizontal ListView (false).
  final bool usePageView;

  /// Spacing between carousel items.
  final double itemSpacing;

  /// Padding around the carousel items.
  final EdgeInsets itemPadding;

  /// Viewport fraction for PageView (how much of next/prev items to show).
  final double viewportFraction;

  /// Whether the carousel should loop infinitely.
  final bool infiniteScroll;

  /// Scroll direction.
  final Axis scrollDirection;

  /// Scroll physics type.
  final CarouselScrollPhysics physicsType;

  /// Custom scroll physics (used with CarouselScrollPhysics.custom).
  final ScrollPhysics? customPhysics;

  /// Whether to keep pages alive when scrolled out of view.
  final bool keepPage;

  /// Initial page index.
  final int initialPage;

  /// Whether to allow page snapping.
  final bool pageSnapping;

  /// Whether to pad ends of the carousel (only for horizontal ListView).
  final bool padEnds;

  /// Whether to reverse the scroll direction.
  final bool reverse;

  const LayoutConfig({
    this.usePageView = true,
    this.itemSpacing = 16.0,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.viewportFraction = 1.0,
    this.infiniteScroll = false,
    this.scrollDirection = Axis.horizontal,
    this.physicsType = CarouselScrollPhysics.page,
    this.customPhysics,
    this.keepPage = true,
    this.initialPage = 0,
    this.pageSnapping = true,
    this.padEnds = true,
    this.reverse = false,
  });

  /// Creates a copy with the given fields replaced.
  LayoutConfig copyWith({
    bool? usePageView,
    double? itemSpacing,
    EdgeInsets? itemPadding,
    double? viewportFraction,
    bool? infiniteScroll,
    Axis? scrollDirection,
    CarouselScrollPhysics? physicsType,
    ScrollPhysics? customPhysics,
    bool? keepPage,
    int? initialPage,
    bool? pageSnapping,
    bool? padEnds,
    bool? reverse,
  }) {
    return LayoutConfig(
      usePageView: usePageView ?? this.usePageView,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      itemPadding: itemPadding ?? this.itemPadding,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      infiniteScroll: infiniteScroll ?? this.infiniteScroll,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      physicsType: physicsType ?? this.physicsType,
      customPhysics: customPhysics ?? this.customPhysics,
      keepPage: keepPage ?? this.keepPage,
      initialPage: initialPage ?? this.initialPage,
      pageSnapping: pageSnapping ?? this.pageSnapping,
      padEnds: padEnds ?? this.padEnds,
      reverse: reverse ?? this.reverse,
    );
  }

  /// Get the appropriate ScrollPhysics based on physicsType.
  ScrollPhysics get scrollPhysics {
    switch (physicsType) {
      case CarouselScrollPhysics.page:
        return const PageScrollPhysics();
      case CarouselScrollPhysics.bouncing:
        return const BouncingScrollPhysics();
      case CarouselScrollPhysics.clamping:
        return const ClampingScrollPhysics();
      case CarouselScrollPhysics.neverScrollable:
        return const NeverScrollableScrollPhysics();
      case CarouselScrollPhysics.alwaysScrollable:
        return const AlwaysScrollableScrollPhysics();
      case CarouselScrollPhysics.custom:
        return customPhysics ?? const PageScrollPhysics();
    }
  }

  /// Preset: Standard page-based carousel.
  static const standard = LayoutConfig();

  /// Preset: Card carousel showing peek of adjacent items.
  static const cardPeek = LayoutConfig(
    viewportFraction: 0.85,
    itemSpacing: 12.0,
  );

  /// Preset: Full-bleed carousel (no padding).
  static const fullBleed = LayoutConfig(
    itemPadding: EdgeInsets.zero,
    itemSpacing: 0.0,
  );

  /// Preset: Horizontal scroll list (not page-based).
  static const horizontalList = LayoutConfig(
    usePageView: false,
    itemSpacing: 12.0,
  );

  /// Preset: Infinite scrolling carousel.
  static const infinite = LayoutConfig(
    infiniteScroll: true,
    viewportFraction: 0.9,
  );

  /// Preset: Vertical carousel.
  static const vertical = LayoutConfig(scrollDirection: Axis.vertical);
}
