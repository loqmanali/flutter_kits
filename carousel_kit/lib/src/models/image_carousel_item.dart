import 'package:flutter/material.dart';

import 'carousel_item.dart';
import 'carousel_overlay.dart';

/// A carousel item that displays an image.
///
/// Supports both asset images and network images.
/// Can include an overlay with title, subtitle, and custom widgets.
class ImageCarouselItem extends CarouselItem {
  /// Path to the image (asset path or network URL).
  final String imagePath;

  /// Whether the image is an asset (true) or network image (false).
  final bool isAsset;

  /// Optional overlay configuration.
  final CarouselOverlay? overlay;

  /// Optional custom overlay widget (takes precedence over [overlay]).
  final Widget? customOverlay;

  /// Optional placeholder widget while loading network images.
  final Widget? placeholder;

  /// Optional error widget when image fails to load.
  final Widget? errorWidget;

  /// Optional unique identifier.
  @override
  final String? id;

  /// Optional metadata.
  @override
  final Map<String, dynamic>? metadata;

  /// Callback when this item is tapped.
  final VoidCallback? onItemTap;

  const ImageCarouselItem({
    required this.imagePath,
    this.isAsset = true,
    this.overlay,
    this.customOverlay,
    this.placeholder,
    this.errorWidget,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _CarouselImage(
            imagePath: imagePath,
            isAsset: isAsset,
            fit: fit,
            placeholder: placeholder,
            errorWidget: errorWidget,
          ),
          if (overlay != null) _CarouselOverlay(overlay: overlay!),
          if (customOverlay != null) customOverlay!,
        ],
      ),
    );
  }

  @override
  void onTap() {
    onItemTap?.call();
  }

  /// Creates a copy with the given fields replaced.
  ImageCarouselItem copyWith({
    String? imagePath,
    bool? isAsset,
    CarouselOverlay? overlay,
    Widget? customOverlay,
    Widget? placeholder,
    Widget? errorWidget,
    String? id,
    Map<String, dynamic>? metadata,
    VoidCallback? onItemTap,
  }) {
    return ImageCarouselItem(
      imagePath: imagePath ?? this.imagePath,
      isAsset: isAsset ?? this.isAsset,
      overlay: overlay ?? this.overlay,
      customOverlay: customOverlay ?? this.customOverlay,
      placeholder: placeholder ?? this.placeholder,
      errorWidget: errorWidget ?? this.errorWidget,
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
      onItemTap: onItemTap ?? this.onItemTap,
    );
  }
}

/// The photo itself: asset or network, with its placeholder and error states.
class _CarouselImage extends StatelessWidget {
  const _CarouselImage({
    required this.imagePath,
    required this.isAsset,
    required this.fit,
    required this.placeholder,
    required this.errorWidget,
  });

  final String imagePath;
  final bool isAsset;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (isAsset || imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: fit,
        height: double.infinity,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 48,
                  ),
                ),
              );
        },
      );
    }

    return Image.network(
      imagePath,
      fit: fit,
      height: double.infinity,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 48,
                ),
              ),
            );
      },
    );
  }
}

/// Gradient scrim plus caption, drawn over the photo.
class _CarouselOverlay extends StatelessWidget {
  const _CarouselOverlay({required this.overlay});

  final CarouselOverlay overlay;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: overlay.gradient ??
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  // Scrim + caption sit on the photo: black/white is what
                  // keeps them legible over arbitrary imagery.
                  Colors.black.withValues(alpha: overlay.gradientOpacity),
                ],
              ),
        ),
        child: Padding(
          padding: overlay.padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: overlay.crossAxisAlignment,
            children: [
              if (overlay.title != null)
                Text(
                  overlay.title!,
                  style: overlay.titleStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: overlay.titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              if (overlay.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  overlay.subtitle!,
                  style: overlay.subtitleStyle ??
                      const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                  maxLines: overlay.subtitleMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (overlay.trailing != null) ...[
                const SizedBox(height: 8),
                overlay.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
