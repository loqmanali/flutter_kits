import 'package:flutter/widgets.dart';

import 'carousel_item.dart';

/// A carousel item that displays a custom widget.
///
/// Use this when you need full control over the carousel item content.
class WidgetCarouselItem extends CarouselItem {
  /// The widget to display in the carousel.
  final Widget child;

  /// Whether to apply border radius clipping.
  final bool applyBorderRadius;

  /// Optional unique identifier.
  @override
  final String? id;

  /// Optional metadata.
  @override
  final Map<String, dynamic>? metadata;

  /// Callback when this item is tapped.
  final VoidCallback? onItemTap;

  const WidgetCarouselItem({
    required this.child,
    this.applyBorderRadius = true,
    this.id,
    this.metadata,
    this.onItemTap,
  });

  @override
  Widget build(
    BuildContext context, {
    double borderRadius = 16.0,
    BoxFit fit = BoxFit.cover,
  }) {
    if (!applyBorderRadius) return child;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: child,
    );
  }

  @override
  void onTap() {
    onItemTap?.call();
  }

  /// Creates a copy with the given fields replaced.
  WidgetCarouselItem copyWith({
    Widget? child,
    bool? applyBorderRadius,
    String? id,
    Map<String, dynamic>? metadata,
    VoidCallback? onItemTap,
  }) {
    return WidgetCarouselItem(
      child: child ?? this.child,
      applyBorderRadius: applyBorderRadius ?? this.applyBorderRadius,
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
      onItemTap: onItemTap ?? this.onItemTap,
    );
  }
}
