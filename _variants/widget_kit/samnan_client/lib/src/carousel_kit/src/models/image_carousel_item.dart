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
          _buildImage(fit),
          if (overlay != null) _buildDefaultOverlay(),
          ?customOverlay,
        ],
      ),
    );
  }

  Widget _buildImage(BoxFit fit) {
    if (isAsset || imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: fit,
        height: double.infinity,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                color: const Color(0xFF1E1E1E),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white54,
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
              color: const Color(0xFF2A2A2A),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white54,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              color: const Color(0xFF1E1E1E),
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            );
      },
    );
  }

  Widget _buildDefaultOverlay() {
    if (overlay == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient:
              overlay!.gradient ??
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: overlay!.gradientOpacity),
                ],
              ),
        ),
        child: Padding(
          padding: overlay!.padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: overlay!.crossAxisAlignment,
            children: [
              if (overlay!.title != null)
                Text(
                  overlay!.title!,
                  style:
                      overlay!.titleStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: overlay!.titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              if (overlay!.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  overlay!.subtitle!,
                  style:
                      overlay!.subtitleStyle ??
                      const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: overlay!.subtitleMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (overlay!.trailing != null) ...[
                const SizedBox(height: 8),
                overlay!.trailing!,
              ],
            ],
          ),
        ),
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
