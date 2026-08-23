import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/widget_kit_theme.dart';

/// A reusable image widget that can render:
/// - Network images (http/https URLs)
/// - Base64-encoded images
/// - Local asset images
///
/// It automatically falls back to [fallbackAsset] when the provided [image]
/// is null, empty, or invalid.
///
/// You can use either [image] for raw data (base64, asset path) or [imageURL]
/// for direct network URLs. If both are provided, [imageURL] takes priority
/// when it's a valid URL.
class AppMediaImage extends StatelessWidget {
  const AppMediaImage({
    super.key,
    this.image,
    this.imageURL,
    this.fit = BoxFit.contain,
    required this.fallbackAsset,
    this.width,
    this.height,
    this.semanticLabel,
    this.colorFilter,
    this.placeholderColor,
  });

  /// Raw image value from backend or local (URL, base64, or asset path).
  final String? image;

  /// Direct network URL for the image. Takes priority over [image] if valid.
  final String? imageURL;

  /// How the image should be inscribed into the space allocated.
  final BoxFit fit;

  /// Asset used when [image] cannot be rendered.
  final String fallbackAsset;

  /// Width of the image widget.
  final double? width;

  /// Height of the image widget.
  final double? height;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Color filter to apply to the image.
  final ColorFilter? colorFilter;

  /// Background color shown behind the loading spinner. Falls back to
  /// [WidgetKitTheme.mediaPlaceholderColor], then a neutral grey.
  final Color? placeholderColor;

  /// Returns the effective image source to use
  String get _effectiveImage {
    // If imageURL is provided and valid, use it
    if (imageURL != null && imageURL!.isNotEmpty) {
      return imageURL!;
    }
    // Otherwise use image
    return image ?? '';
  }

  bool get _isNetworkUrl =>
      _effectiveImage.startsWith('http://') ||
      _effectiveImage.startsWith('https://');

  bool get _looksLikeBase64 =>
      _effectiveImage.isNotEmpty &&
      !_isNetworkUrl &&
      !_effectiveImage.startsWith('assets/');

  Future<Uint8List?> _tryDecodeBase64Async() async {
    return compute(_decodeBase64Isolate, _effectiveImage);
  }

  static Uint8List? _decodeBase64Isolate(String data) {
    try {
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _isSvgBytesAsync(Uint8List bytes) async {
    return compute(_checkSvgBytesIsolate, bytes);
  }

  static bool _checkSvgBytesIsolate(Uint8List bytes) {
    try {
      final header = utf8.decode(bytes, allowMalformed: true);
      return header.trimLeft().startsWith('<svg');
    } catch (_) {
      return false;
    }
  }

  Future<String> _sanitizeSvgDimensionsAsync(String svg) async {
    try {
      return compute(_sanitizeSvgDimensionsIsolate, svg);
    } catch (_) {
      return svg; // Return original if sanitization fails
    }
  }

  static String _sanitizeSvgDimensionsIsolate(String svg) {
    return svg.replaceAllMapped(
      RegExp(r'(width|height)="(\d+)%"'),
      (m) => '${m.group(1)}="100"',
    );
  }

  Future<String?> _processSvgAsync(Uint8List bytes) async {
    try {
      final rawSvg = utf8.decode(bytes, allowMalformed: true);
      return await _sanitizeSvgDimensionsAsync(rawSvg);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveImg = _effectiveImage;

    if (effectiveImg.isEmpty) {
      return _AssetImage(
        assetPath: fallbackAsset,
        fallbackAsset: fallbackAsset,
        fit: fit,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
      );
    }

    if (_isNetworkUrl) {
      return CachedNetworkImage(
        imageUrl: effectiveImg,
        fit: fit,
        width: width,
        height: height,
        errorWidget: (_, __, ___) => _AssetImage(
          assetPath: fallbackAsset,
          fallbackAsset: fallbackAsset,
          fit: fit,
          width: width,
          height: height,
          semanticLabel: semanticLabel,
        ),
        placeholder: (_, __) => _MediaPlaceholder(
          width: width,
          height: height,
          placeholderColor: placeholderColor,
        ),
      );
    }

    if (_looksLikeBase64) {
      return FutureBuilder<ImageDataResult>(
        future: _processBase64Image(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _MediaPlaceholder(
              width: width,
              height: height,
              placeholderColor: placeholderColor,
            );
          }

          final result = snapshot.data;
          if (result?.success == true) {
            return _DecodedImage(
              result: result!,
              fallbackAsset: fallbackAsset,
              fit: fit,
              width: width,
              height: height,
              semanticLabel: semanticLabel,
            );
          }

          return _AssetImage(
            assetPath: fallbackAsset,
            fallbackAsset: fallbackAsset,
            fit: fit,
            width: width,
            height: height,
            semanticLabel: semanticLabel,
          );
        },
      );
    }

    return _AssetImage(
      assetPath: effectiveImg,
      fallbackAsset: fallbackAsset,
      fit: fit,
      width: width,
      height: height,
      semanticLabel: semanticLabel,
    );
  }

  Future<ImageDataResult> _processBase64Image() async {
    try {
      final bytes = await _tryDecodeBase64Async();
      if (bytes == null) {
        return const ImageDataResult.failure();
      }

      final isSvg = await _isSvgBytesAsync(bytes);
      if (isSvg) {
        final processedSvg = await _processSvgAsync(bytes);
        if (processedSvg != null) {
          return ImageDataResult.svg(processedSvg);
        }
      }

      return ImageDataResult.image(bytes);
    } catch (_) {
      return const ImageDataResult.failure();
    }
  }
}

class ImageDataResult {
  const ImageDataResult.image(this.bytes)
      : svgContent = null,
        isSvg = false,
        success = true;

  const ImageDataResult.svg(this.svgContent)
      : bytes = null,
        isSvg = true,
        success = true;

  const ImageDataResult.failure()
      : bytes = null,
        svgContent = null,
        isSvg = false,
        success = false;

  final Uint8List? bytes;
  final String? svgContent;
  final bool isSvg;
  final bool success;
}

/// A bundled asset, falling back to [fallbackAsset] when it fails to decode.
class _AssetImage extends StatelessWidget {
  const _AssetImage({
    required this.assetPath,
    required this.fallbackAsset,
    required this.fit,
    required this.width,
    required this.height,
    required this.semanticLabel,
  });

  final String assetPath;
  final String fallbackAsset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: fit,
      width: width,
      height: height,
      semanticLabel: semanticLabel,
      // One hop only: if the fallback itself fails, show the broken-image
      // glyph rather than recursing.
      errorBuilder: (_, __, ___) => assetPath == fallbackAsset
          ? const Icon(Icons.broken_image_outlined)
          : _AssetImage(
              assetPath: fallbackAsset,
              fallbackAsset: fallbackAsset,
              fit: fit,
              width: width,
              height: height,
              semanticLabel: semanticLabel,
            ),
    );
  }
}

/// Neutral box shown while a remote or base64 image resolves.
class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder({
    required this.width,
    required this.height,
    required this.placeholderColor,
  });

  final double? width;
  final double? height;
  final Color? placeholderColor;

  @override
  Widget build(BuildContext context) {
    final kit = WidgetKitTheme.of(context);
    final effectiveColor = placeholderColor ??
        kit.mediaPlaceholderColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      width: width,
      height: height,
      color: effectiveColor,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

/// Renders a decoded base64 payload — SVG string or raw bytes.
class _DecodedImage extends StatelessWidget {
  const _DecodedImage({
    required this.result,
    required this.fallbackAsset,
    required this.fit,
    required this.width,
    required this.height,
    required this.semanticLabel,
  });

  final ImageDataResult result;
  final String fallbackAsset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (result.isSvg) {
      return SvgPicture.string(
        result.svgContent!,
        fit: fit,
        width: width,
        height: height,
      );
    }

    return Image.memory(
      result.bytes!,
      fit: fit,
      width: width,
      height: height,
      semanticLabel: semanticLabel,
      errorBuilder: (_, __, ___) => _AssetImage(
        assetPath: fallbackAsset,
        fallbackAsset: fallbackAsset,
        fit: fit,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
