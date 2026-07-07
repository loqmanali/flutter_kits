import 'package:equatable/equatable.dart';

/// Represents an image associated with a category.
///
/// Supports multiple image types (icon, thumbnail, banner, background)
/// and various sources (network, asset, placeholder).
///
/// ## Features
///
/// - Multiple image types for different use cases
/// - Support for responsive images with srcset
/// - Placeholder and fallback support
/// - Lazy loading configuration
/// - Alt text for accessibility
///
/// ## Usage
///
/// ```dart
/// // Network image
/// final image = CategoryImage.network(url: 'https://example.com/image.jpg');
///
/// // Asset image
/// final asset = CategoryImage.asset(path: 'assets/images/category.png');
///
/// // Banner with dimensions
/// final banner = CategoryImage.banner(
///   url: 'https://example.com/banner.jpg',
///   width: 1200,
///   height: 400,
/// );
///
/// // Icon
/// final icon = CategoryImage.icon(
///   name: 'restaurant',
///   color: '#FF5722',
/// );
/// ```
class CategoryImage extends Equatable {
  /// Unique identifier for this image.
  final String? id;

  /// The image URL (for network images).
  final String? url;

  /// The asset path (for local assets).
  final String? assetPath;

  /// The icon name (for icon fonts like Material Icons).
  final String? iconName;

  /// The icon code point (for custom icon fonts).
  final int? iconCodePoint;

  /// The icon font family.
  final String? iconFontFamily;

  /// The icon color (hex code).
  final String? iconColor;

  /// The image type.
  final CategoryImageType type;

  /// Alt text for accessibility.
  final String? alt;

  /// Image title/caption.
  final String? title;

  /// Image width in pixels.
  final int? width;

  /// Image height in pixels.
  final int? height;

  /// Responsive image sources (srcset).
  final Map<String, String>? srcSet;

  /// Placeholder URL while loading.
  final String? placeholder;

  /// Blur hash for placeholder.
  final String? blurHash;

  /// Background color while loading (hex code).
  final String? backgroundColor;

  /// Whether to lazy load this image.
  final bool lazyLoad;

  /// Image fit mode.
  final ImageFitMode fit;

  /// Sort order for multiple images.
  final int sortOrder;

  /// Whether this is the primary/default image.
  final bool isPrimary;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [CategoryImage] instance.
  const CategoryImage({
    this.id,
    this.url,
    this.assetPath,
    this.iconName,
    this.iconCodePoint,
    this.iconFontFamily,
    this.iconColor,
    this.type = CategoryImageType.image,
    this.alt,
    this.title,
    this.width,
    this.height,
    this.srcSet,
    this.placeholder,
    this.blurHash,
    this.backgroundColor,
    this.lazyLoad = true,
    this.fit = ImageFitMode.cover,
    this.sortOrder = 0,
    this.isPrimary = false,
    this.metadata,
  });

  /// Creates a network image.
  factory CategoryImage.network({
    required String url,
    String? id,
    String? alt,
    String? title,
    int? width,
    int? height,
    Map<String, String>? srcSet,
    String? placeholder,
    String? blurHash,
    bool isPrimary = false,
  }) {
    return CategoryImage(
      id: id,
      url: url,
      alt: alt,
      title: title,
      width: width,
      height: height,
      srcSet: srcSet,
      placeholder: placeholder,
      blurHash: blurHash,
      isPrimary: isPrimary,
    );
  }

  /// Creates an asset image.
  factory CategoryImage.asset({
    required String path,
    String? id,
    String? alt,
    int? width,
    int? height,
    bool isPrimary = false,
  }) {
    return CategoryImage(
      id: id,
      assetPath: path,
      type: CategoryImageType.asset,
      alt: alt,
      width: width,
      height: height,
      isPrimary: isPrimary,
      lazyLoad: false,
    );
  }

  /// Creates a banner image.
  factory CategoryImage.banner({
    required String url,
    String? id,
    String? alt,
    String? title,
    int? width,
    int? height,
    String? placeholder,
  }) {
    return CategoryImage(
      id: id,
      url: url,
      type: CategoryImageType.banner,
      alt: alt,
      title: title,
      width: width ?? 1200,
      height: height ?? 400,
      placeholder: placeholder,
    );
  }

  /// Creates a thumbnail image.
  factory CategoryImage.thumbnail({
    required String url,
    String? id,
    String? alt,
    int size = 150,
  }) {
    return CategoryImage(
      id: id,
      url: url,
      type: CategoryImageType.thumbnail,
      alt: alt,
      width: size,
      height: size,
    );
  }

  /// Creates an icon.
  factory CategoryImage.icon({
    required String name,
    String? id,
    String? color,
    String? fontFamily,
  }) {
    return CategoryImage(
      id: id,
      iconName: name,
      iconColor: color,
      iconFontFamily: fontFamily ?? 'MaterialIcons',
      type: CategoryImageType.icon,
      lazyLoad: false,
    );
  }

  /// Creates an icon from code point.
  factory CategoryImage.iconCodePoint({
    required int codePoint,
    String? id,
    String? color,
    String fontFamily = 'MaterialIcons',
  }) {
    return CategoryImage(
      id: id,
      iconCodePoint: codePoint,
      iconColor: color,
      iconFontFamily: fontFamily,
      type: CategoryImageType.icon,
      lazyLoad: false,
    );
  }

  /// Creates a background image.
  factory CategoryImage.background({
    required String url,
    String? id,
    String? blurHash,
    String? backgroundColor,
  }) {
    return CategoryImage(
      id: id,
      url: url,
      type: CategoryImageType.background,
      blurHash: blurHash,
      backgroundColor: backgroundColor,
    );
  }

  /// Creates a placeholder image.
  factory CategoryImage.placeholder({
    String? backgroundColor,
    String? iconName,
    String? iconColor,
  }) {
    return CategoryImage(
      type: CategoryImageType.placeholder,
      backgroundColor: backgroundColor ?? '#E0E0E0',
      iconName: iconName ?? 'image',
      iconColor: iconColor ?? '#9E9E9E',
      lazyLoad: false,
    );
  }

  /// Creates a [CategoryImage] from JSON.
  factory CategoryImage.fromJson(Map<String, dynamic> json) {
    return CategoryImage(
      id: json['id']?.toString(),
      url: json['url'] ?? json['src'] ?? json['source'],
      assetPath: json['asset'] ?? json['asset_path'] ?? json['local'],
      iconName: json['icon'] ?? json['icon_name'],
      iconCodePoint: json['icon_code'] ?? json['code_point'],
      iconFontFamily: json['icon_font'] ?? json['font_family'],
      iconColor: json['icon_color'],
      type: _parseType(json['type']),
      alt: json['alt'] ?? json['alt_text'],
      title: json['title'] ?? json['caption'],
      width: json['width'],
      height: json['height'],
      srcSet: json['srcset'] != null
          ? Map<String, String>.from(json['srcset'] as Map)
          : null,
      placeholder: json['placeholder'],
      blurHash: json['blur_hash'] ?? json['blurhash'],
      backgroundColor: json['background_color'] ?? json['bg_color'],
      lazyLoad: json['lazy_load'] ?? json['lazy'] ?? true,
      fit: _parseFit(json['fit'] ?? json['object_fit']),
      sortOrder: json['sort_order'] ?? json['position'] ?? json['order'] ?? 0,
      isPrimary:
          json['is_primary'] ?? json['primary'] ?? json['default'] ?? false,
      metadata: json['metadata'] ?? json['meta'],
    );
  }

  /// Converts this [CategoryImage] to JSON.
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (url != null) 'url': url,
        if (assetPath != null) 'asset_path': assetPath,
        if (iconName != null) 'icon_name': iconName,
        if (iconCodePoint != null) 'icon_code': iconCodePoint,
        if (iconFontFamily != null) 'icon_font': iconFontFamily,
        if (iconColor != null) 'icon_color': iconColor,
        'type': type.name,
        if (alt != null) 'alt': alt,
        if (title != null) 'title': title,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (srcSet != null) 'srcset': srcSet,
        if (placeholder != null) 'placeholder': placeholder,
        if (blurHash != null) 'blur_hash': blurHash,
        if (backgroundColor != null) 'background_color': backgroundColor,
        'lazy_load': lazyLoad,
        'fit': fit.name,
        'sort_order': sortOrder,
        'is_primary': isPrimary,
        if (metadata != null) 'metadata': metadata,
      };

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns `true` if this is a network image.
  bool get isNetwork => url != null && url!.isNotEmpty;

  /// Returns `true` if this is an asset image.
  bool get isAsset => assetPath != null && assetPath!.isNotEmpty;

  /// Returns `true` if this is an icon.
  bool get isIcon => iconName != null || iconCodePoint != null;

  /// Returns `true` if this is a placeholder.
  bool get isPlaceholder => type == CategoryImageType.placeholder;

  /// Returns `true` if this image has dimensions.
  bool get hasDimensions => width != null && height != null;

  /// Returns the aspect ratio if dimensions are available.
  double? get aspectRatio {
    if (!hasDimensions || height == 0) return null;
    return width! / height!;
  }

  /// Returns the effective source (URL or asset path).
  String? get source => url ?? assetPath;

  /// Returns `true` if this image has a valid source.
  bool get hasSource => isNetwork || isAsset || isIcon;

  /// Returns `true` if this image has a placeholder.
  bool get hasPlaceholder =>
      placeholder != null || blurHash != null || backgroundColor != null;

  // ─────────────────────────────────────────────────────────────────────────
  // Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Gets the URL for a specific size from srcSet.
  String? getUrlForSize(String size) {
    return srcSet?[size] ?? url;
  }

  /// Gets the best URL for the given width.
  String? getBestUrl(int targetWidth) {
    if (srcSet == null || srcSet!.isEmpty) return url;

    // Parse srcSet and find best match
    final sizes = srcSet!.entries.toList();
    sizes.sort((a, b) {
      final aWidth = int.tryParse(a.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final bWidth = int.tryParse(b.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return aWidth.compareTo(bWidth);
    });

    for (final entry in sizes) {
      final width =
          int.tryParse(entry.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (width >= targetWidth) return entry.value;
    }

    return sizes.last.value;
  }

  /// Copies this [CategoryImage] with optional new values.
  CategoryImage copyWith({
    String? id,
    String? url,
    String? assetPath,
    String? iconName,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconColor,
    CategoryImageType? type,
    String? alt,
    String? title,
    int? width,
    int? height,
    Map<String, String>? srcSet,
    String? placeholder,
    String? blurHash,
    String? backgroundColor,
    bool? lazyLoad,
    ImageFitMode? fit,
    int? sortOrder,
    bool? isPrimary,
    Map<String, dynamic>? metadata,
  }) {
    return CategoryImage(
      id: id ?? this.id,
      url: url ?? this.url,
      assetPath: assetPath ?? this.assetPath,
      iconName: iconName ?? this.iconName,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      iconColor: iconColor ?? this.iconColor,
      type: type ?? this.type,
      alt: alt ?? this.alt,
      title: title ?? this.title,
      width: width ?? this.width,
      height: height ?? this.height,
      srcSet: srcSet ?? this.srcSet,
      placeholder: placeholder ?? this.placeholder,
      blurHash: blurHash ?? this.blurHash,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      lazyLoad: lazyLoad ?? this.lazyLoad,
      fit: fit ?? this.fit,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
      metadata: metadata ?? this.metadata,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────────────────

  static CategoryImageType _parseType(dynamic value) {
    if (value == null) return CategoryImageType.image;
    switch (value.toString().toLowerCase()) {
      case 'image':
      case 'photo':
        return CategoryImageType.image;
      case 'thumbnail':
      case 'thumb':
        return CategoryImageType.thumbnail;
      case 'icon':
        return CategoryImageType.icon;
      case 'banner':
      case 'hero':
        return CategoryImageType.banner;
      case 'background':
      case 'bg':
        return CategoryImageType.background;
      case 'asset':
      case 'local':
        return CategoryImageType.asset;
      case 'placeholder':
        return CategoryImageType.placeholder;
      default:
        return CategoryImageType.image;
    }
  }

  static ImageFitMode _parseFit(dynamic value) {
    if (value == null) return ImageFitMode.cover;
    switch (value.toString().toLowerCase()) {
      case 'contain':
        return ImageFitMode.contain;
      case 'cover':
        return ImageFitMode.cover;
      case 'fill':
        return ImageFitMode.fill;
      case 'fit_width':
      case 'fitwidth':
      case 'width':
        return ImageFitMode.fitWidth;
      case 'fit_height':
      case 'fitheight':
      case 'height':
        return ImageFitMode.fitHeight;
      case 'none':
      case 'scale_down':
        return ImageFitMode.none;
      default:
        return ImageFitMode.cover;
    }
  }

  @override
  List<Object?> get props => [
        id,
        url,
        assetPath,
        iconName,
        iconCodePoint,
        type,
        isPrimary,
      ];
}

/// Types of category images.
enum CategoryImageType {
  /// Standard image.
  image,

  /// Thumbnail/small preview.
  thumbnail,

  /// Icon (from icon font).
  icon,

  /// Banner/hero image.
  banner,

  /// Background image.
  background,

  /// Local asset.
  asset,

  /// Placeholder.
  placeholder,
}

/// Image fit modes.
enum ImageFitMode {
  /// Scale to fill, may crop.
  cover,

  /// Scale to fit, may have letterboxing.
  contain,

  /// Stretch to fill exactly.
  fill,

  /// Scale to fit width.
  fitWidth,

  /// Scale to fit height.
  fitHeight,

  /// No scaling.
  none,
}

/// Extension methods for [CategoryImageType].
extension CategoryImageTypeExtension on CategoryImageType {
  /// Returns a human-readable label.
  String get label {
    switch (this) {
      case CategoryImageType.image:
        return 'Image';
      case CategoryImageType.thumbnail:
        return 'Thumbnail';
      case CategoryImageType.icon:
        return 'Icon';
      case CategoryImageType.banner:
        return 'Banner';
      case CategoryImageType.background:
        return 'Background';
      case CategoryImageType.asset:
        return 'Asset';
      case CategoryImageType.placeholder:
        return 'Placeholder';
    }
  }
}

/// Extension methods for [ImageFitMode].
extension ImageFitModeExtension on ImageFitMode {
  /// Returns a human-readable label.
  String get label {
    switch (this) {
      case ImageFitMode.cover:
        return 'Cover';
      case ImageFitMode.contain:
        return 'Contain';
      case ImageFitMode.fill:
        return 'Fill';
      case ImageFitMode.fitWidth:
        return 'Fit Width';
      case ImageFitMode.fitHeight:
        return 'Fit Height';
      case ImageFitMode.none:
        return 'None';
    }
  }
}
