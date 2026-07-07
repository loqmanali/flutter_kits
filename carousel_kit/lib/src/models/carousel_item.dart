import 'package:flutter/widgets.dart';

/// Base abstract class for carousel items.
///
/// Extend this class to create custom carousel item types.
/// The [build] method must be implemented to return the widget
/// that will be displayed in the carousel.
abstract class CarouselItem {
  const CarouselItem();

  /// Builds the widget representation of this carousel item.
  ///
  /// [context] - The build context
  /// [borderRadius] - Border radius to apply to the item
  /// [fit] - BoxFit for images within the item
  Widget build(
    BuildContext context, {
    double borderRadius = 16.0,
    BoxFit fit = BoxFit.cover,
  });

  /// Optional callback when item is tapped.
  /// Override this in subclasses to handle tap events.
  void onTap() {}

  /// Optional unique identifier for the item.
  String? get id => null;

  /// Optional metadata associated with the item.
  Map<String, dynamic>? get metadata => null;
}

/// A carousel item that displays an image.
///
/// Supports both asset and network images with optional
/// error and loading builders.
class ImageCarouselItem extends CarouselItem {
  /// Creates an image item from an asset path.
  const ImageCarouselItem.asset(
    this.assetPath, {
    this.id,
    this.metadata,
    this.errorBuilder,
    this.onTapCallback,
  })  : networkUrl = null,
        _isAsset = true;

  /// Creates an image item from a network URL.
  const ImageCarouselItem.network(
    this.networkUrl, {
    this.id,
    this.metadata,
    this.errorBuilder,
    this.onTapCallback,
  })  : assetPath = null,
        _isAsset = false;

  /// The asset path (for asset images).
  final String? assetPath;

  /// The network URL (for network images).
  final String? networkUrl;

  /// Whether this is an asset image.
  final bool _isAsset;

  /// Unique identifier for this item.
  @override
  final String? id;

  /// Optional metadata.
  @override
  final Map<String, dynamic>? metadata;

  /// Builder for error state.
  final ImageErrorWidgetBuilder? errorBuilder;

  /// Callback when tapped.
  final VoidCallback? onTapCallback;

  @override
  void onTap() {
    onTapCallback?.call();
  }

  @override
  Widget build(
    BuildContext context, {
    double borderRadius = 16.0,
    BoxFit fit = BoxFit.cover,
  }) {
    final image = _isAsset
        ? Image.asset(
            assetPath!,
            fit: fit,
            errorBuilder: errorBuilder,
          )
        : Image.network(
            networkUrl!,
            fit: fit,
            errorBuilder: errorBuilder,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }
}

/// A carousel item that displays a custom widget.
///
/// Use this when you need to display non-image content
/// or custom layouts in the carousel.
class WidgetCarouselItem extends CarouselItem {
  /// Creates a widget item with a custom builder.
  const WidgetCarouselItem({
    required this.builder,
    this.id,
    this.metadata,
    this.onTapCallback,
  });

  /// Builder function that creates the widget.
  final Widget Function(BuildContext context) builder;

  /// Unique identifier for this item.
  @override
  final String? id;

  /// Optional metadata.
  @override
  final Map<String, dynamic>? metadata;

  /// Callback when tapped.
  final VoidCallback? onTapCallback;

  @override
  void onTap() {
    onTapCallback?.call();
  }

  @override
  Widget build(
    BuildContext context, {
    double borderRadius = 16.0,
    BoxFit fit = BoxFit.cover,
  }) {
    return builder(context);
  }
}
