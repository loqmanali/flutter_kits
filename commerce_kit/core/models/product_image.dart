import 'package:equatable/equatable.dart';

/// Represents an image associated with a product.
///
/// Supports multiple image sources (network, asset, memory) and
/// provides metadata like alt text, dimensions, and display order.
///
/// ## Usage
///
/// ```dart
/// // Network image
/// final image = ProductImage(
///   id: '1',
///   url: 'https://example.com/burger.jpg',
///   altText: 'Delicious Burger',
/// );
///
/// // Asset image
/// final assetImage = ProductImage.asset(
///   id: '2',
///   path: 'assets/images/burger.png',
///   altText: 'Burger',
/// );
///
/// // SVG image
/// final svgImage = ProductImage.svg(
///   id: '3',
///   path: 'assets/icons/burger.svg',
/// );
/// ```
class ProductImage extends Equatable {
  /// Unique identifier for this image.
  final String id;

  /// The image URL (for network images).
  final String? url;

  /// The asset path (for local asset images).
  final String? assetPath;

  /// Alternative text for accessibility.
  final String? altText;

  /// The image width in pixels.
  final int? width;

  /// The image height in pixels.
  final int? height;

  /// The display order (lower = displayed first).
  final int sortOrder;

  /// Whether this is the primary/main image.
  final bool isPrimary;

  /// The image type/source.
  final ImageSourceType sourceType;

  /// The image format.
  final ImageFormat format;

  /// Thumbnail URL for smaller displays.
  final String? thumbnailUrl;

  /// High-resolution URL for zoom/detail view.
  final String? highResUrl;

  /// Additional metadata for this image.
  final Map<String, dynamic>? metadata;

  /// Creates a [ProductImage] instance.
  const ProductImage({
    required this.id,
    this.url,
    this.assetPath,
    this.altText,
    this.width,
    this.height,
    this.sortOrder = 0,
    this.isPrimary = false,
    this.sourceType = ImageSourceType.network,
    this.format = ImageFormat.unknown,
    this.thumbnailUrl,
    this.highResUrl,
    this.metadata,
  });

  /// Creates a network image.
  factory ProductImage.network({
    required String id,
    required String url,
    String? altText,
    int? width,
    int? height,
    int sortOrder = 0,
    bool isPrimary = false,
    String? thumbnailUrl,
    String? highResUrl,
  }) {
    return ProductImage(
      id: id,
      url: url,
      altText: altText,
      width: width,
      height: height,
      sortOrder: sortOrder,
      isPrimary: isPrimary,
      format: _detectFormat(url),
      thumbnailUrl: thumbnailUrl,
      highResUrl: highResUrl,
    );
  }

  /// Creates an asset image.
  factory ProductImage.asset({
    required String id,
    required String path,
    String? altText,
    int? width,
    int? height,
    int sortOrder = 0,
    bool isPrimary = false,
  }) {
    return ProductImage(
      id: id,
      assetPath: path,
      altText: altText,
      width: width,
      height: height,
      sortOrder: sortOrder,
      isPrimary: isPrimary,
      sourceType: ImageSourceType.asset,
      format: _detectFormat(path),
    );
  }

  /// Creates an SVG image.
  factory ProductImage.svg({
    required String id,
    required String path,
    String? altText,
    int sortOrder = 0,
    bool isPrimary = false,
    bool isAsset = true,
  }) {
    return ProductImage(
      id: id,
      url: isAsset ? null : path,
      assetPath: isAsset ? path : null,
      altText: altText,
      sortOrder: sortOrder,
      isPrimary: isPrimary,
      sourceType: isAsset ? ImageSourceType.asset : ImageSourceType.network,
      format: ImageFormat.svg,
    );
  }

  /// Creates a [ProductImage] from JSON.
  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id']?.toString() ?? '',
      url: json['url'] ?? json['src'] ?? json['image_url'],
      assetPath: json['asset_path'] ?? json['assetPath'],
      altText: json['alt_text'] ?? json['altText'] ?? json['alt'],
      width: json['width'],
      height: json['height'],
      sortOrder:
          json['sort_order'] ?? json['sortOrder'] ?? json['position'] ?? 0,
      isPrimary:
          json['is_primary'] ?? json['isPrimary'] ?? json['main'] ?? false,
      sourceType: _parseSourceType(json['source_type'] ?? json['sourceType']),
      format: _detectFormat(json['url'] ?? json['src'] ?? ''),
      thumbnailUrl:
          json['thumbnail_url'] ?? json['thumbnailUrl'] ?? json['thumbnail'],
      highResUrl: json['high_res_url'] ?? json['highResUrl'] ?? json['large'],
      metadata: json['metadata'],
    );
  }

  /// Converts this [ProductImage] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        if (url != null) 'url': url,
        if (assetPath != null) 'asset_path': assetPath,
        if (altText != null) 'alt_text': altText,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        'sort_order': sortOrder,
        'is_primary': isPrimary,
        'source_type': sourceType.name,
        'format': format.name,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (highResUrl != null) 'high_res_url': highResUrl,
        if (metadata != null) 'metadata': metadata,
      };

  /// Returns the effective image source (URL or asset path).
  String get source => url ?? assetPath ?? '';

  /// Returns `true` if this is an SVG image.
  bool get isSvg => format == ImageFormat.svg;

  /// Returns `true` if this is an asset image.
  bool get isAsset => sourceType == ImageSourceType.asset;

  /// Returns `true` if this is a network image.
  bool get isNetwork => sourceType == ImageSourceType.network;

  /// Returns the aspect ratio if dimensions are available.
  double? get aspectRatio {
    if (width != null && height != null && height! > 0) {
      return width! / height!;
    }
    return null;
  }

  /// Copies this [ProductImage] with optional new values.
  ProductImage copyWith({
    String? id,
    String? url,
    String? assetPath,
    String? altText,
    int? width,
    int? height,
    int? sortOrder,
    bool? isPrimary,
    ImageSourceType? sourceType,
    ImageFormat? format,
    String? thumbnailUrl,
    String? highResUrl,
    Map<String, dynamic>? metadata,
  }) {
    return ProductImage(
      id: id ?? this.id,
      url: url ?? this.url,
      assetPath: assetPath ?? this.assetPath,
      altText: altText ?? this.altText,
      width: width ?? this.width,
      height: height ?? this.height,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
      sourceType: sourceType ?? this.sourceType,
      format: format ?? this.format,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      highResUrl: highResUrl ?? this.highResUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  static ImageFormat _detectFormat(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.svg')) return ImageFormat.svg;
    if (lower.endsWith('.png')) return ImageFormat.png;
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return ImageFormat.jpeg;
    }
    if (lower.endsWith('.gif')) return ImageFormat.gif;
    if (lower.endsWith('.webp')) return ImageFormat.webp;
    return ImageFormat.unknown;
  }

  static ImageSourceType _parseSourceType(String? type) {
    switch (type) {
      case 'asset':
        return ImageSourceType.asset;
      case 'memory':
        return ImageSourceType.memory;
      case 'file':
        return ImageSourceType.file;
      default:
        return ImageSourceType.network;
    }
  }

  @override
  List<Object?> get props => [
        id,
        url,
        assetPath,
        altText,
        width,
        height,
        sortOrder,
        isPrimary,
        sourceType,
        format,
      ];
}

/// The source type of a product image.
enum ImageSourceType {
  /// Image from a network URL.
  network,

  /// Image from app assets.
  asset,

  /// Image from memory (bytes).
  memory,

  /// Image from local file system.
  file,
}

/// The format of a product image.
enum ImageFormat {
  /// JPEG/JPG format.
  jpeg,

  /// PNG format.
  png,

  /// SVG format.
  svg,

  /// GIF format.
  gif,

  /// WebP format.
  webp,

  /// Unknown format.
  unknown,
}
