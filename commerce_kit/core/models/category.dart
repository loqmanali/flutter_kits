import 'package:equatable/equatable.dart';

import '../enums/category_type.dart';
import 'category_image.dart';

/// Represents a category in the e-commerce system.
///
/// Categories are used to organize products into logical groups for
/// easier navigation and discovery. This model supports:
///
/// - Hierarchical categories (parent/child relationships)
/// - Multiple category types (standard, featured, sale, etc.)
/// - Rich media (images, icons, banners)
/// - SEO metadata
/// - Display customization
/// - Scheduling (active date ranges)
/// - Nested subcategories of any depth
///
/// ## Features
///
/// - **Hierarchical Structure**: Categories can have unlimited depth
/// - **Multiple Images**: Support for icon, thumbnail, banner, and background
/// - **Type System**: Different category types for different purposes
/// - **Scheduling**: Categories can be scheduled to appear/disappear
/// - **Customization**: Colors, display modes, custom metadata
/// - **SEO Ready**: Title, description, and keywords for search engines
///
/// ## Usage
///
/// ```dart
/// // Simple category
/// final burgers = Category(
///   id: 'cat-1',
///   name: 'Burgers',
///   slug: 'burgers',
/// );
///
/// // Category with subcategories
/// final food = Category(
///   id: 'cat-food',
///   name: 'Food',
///   slug: 'food',
///   children: [
///     Category(id: 'cat-burgers', name: 'Burgers', slug: 'burgers'),
///     Category(id: 'cat-pizza', name: 'Pizza', slug: 'pizza'),
///   ],
/// );
///
/// // Featured category with image
/// final featured = Category(
///   id: 'cat-featured',
///   name: 'Featured Items',
///   slug: 'featured',
///   type: CategoryType.featured,
///   image: CategoryImage.banner(url: 'https://...'),
///   description: 'Our most popular items',
/// );
/// ```
class Category extends Equatable {
  /// Unique identifier for this category.
  final String id;

  /// The category name.
  final String name;

  /// URL-friendly slug for this category.
  final String? slug;

  /// The category type.
  final CategoryType type;

  /// Short description for listings.
  final String? shortDescription;

  /// Full category description.
  final String? description;

  /// Parent category ID (null for root categories).
  final String? parentId;

  /// Child categories (subcategories).
  final List<Category> children;

  /// The depth level in the hierarchy (0 for root).
  final int level;

  /// The path from root to this category (list of ancestor IDs).
  final List<String> path;

  /// Primary category image.
  final CategoryImage? image;

  /// Thumbnail image for listings.
  final CategoryImage? thumbnail;

  /// Icon image or icon name.
  final CategoryImage? icon;

  /// Banner image for category headers.
  final CategoryImage? banner;

  /// Background image for category pages.
  final CategoryImage? backgroundImage;

  /// Primary color for this category (hex code).
  final String? color;

  /// Secondary/accent color (hex code).
  final String? accentColor;

  /// Background color (hex code).
  final String? backgroundColor;

  /// Text color (hex code).
  final String? textColor;

  /// Number of products in this category.
  final int productCount;

  /// Number of products including subcategories.
  final int totalProductCount;

  /// Sort order for display.
  final int sortOrder;

  /// Whether this category is active/enabled.
  final bool isActive;

  /// Whether this category is visible to customers.
  final bool isVisible;

  /// Whether this category is featured.
  final bool isFeatured;

  /// Whether this category is included in navigation menus.
  final bool includeInMenu;

  /// Whether this category is included in search.
  final bool includeInSearch;

  /// Whether this category allows products.
  final bool allowProducts;

  /// The display mode for this category.
  final CategoryDisplayMode displayMode;

  /// Number of columns for grid display.
  final int? gridColumns;

  /// Default sort option for products.
  final ProductSortOption? defaultSort;

  /// Date when this category becomes active.
  final DateTime? activeFrom;

  /// Date when this category becomes inactive.
  final DateTime? activeUntil;

  /// SEO title.
  final String? seoTitle;

  /// SEO description.
  final String? seoDescription;

  /// SEO keywords.
  final List<String> seoKeywords;

  /// Canonical URL.
  final String? canonicalUrl;

  /// Open Graph image URL.
  final String? ogImageUrl;

  /// Custom URL (for external or special links).
  final String? customUrl;

  /// Whether to open custom URL in new tab.
  final bool openInNewTab;

  /// Badge text to display (e.g., "New", "Sale").
  final String? badge;

  /// Badge color (hex code).
  final String? badgeColor;

  /// The date this category was created.
  final DateTime? createdAt;

  /// The date this category was last updated.
  final DateTime? updatedAt;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [Category] instance.
  const Category({
    required this.id,
    required this.name,
    this.slug,
    this.type = CategoryType.standard,
    this.shortDescription,
    this.description,
    this.parentId,
    this.children = const [],
    this.level = 0,
    this.path = const [],
    this.image,
    this.thumbnail,
    this.icon,
    this.banner,
    this.backgroundImage,
    this.color,
    this.accentColor,
    this.backgroundColor,
    this.textColor,
    this.productCount = 0,
    this.totalProductCount = 0,
    this.sortOrder = 0,
    this.isActive = true,
    this.isVisible = true,
    this.isFeatured = false,
    this.includeInMenu = true,
    this.includeInSearch = true,
    this.allowProducts = true,
    this.displayMode = CategoryDisplayMode.grid,
    this.gridColumns,
    this.defaultSort,
    this.activeFrom,
    this.activeUntil,
    this.seoTitle,
    this.seoDescription,
    this.seoKeywords = const [],
    this.canonicalUrl,
    this.ogImageUrl,
    this.customUrl,
    this.openInNewTab = false,
    this.badge,
    this.badgeColor,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Creates a root category.
  factory Category.root({
    required String id,
    required String name,
    String? slug,
    String? description,
    CategoryImage? image,
    List<Category> children = const [],
  }) {
    return Category(
      id: id,
      name: name,
      slug: slug ?? _generateSlug(name),
      description: description,
      image: image,
      children: children,
    );
  }

  /// Creates a subcategory.
  factory Category.child({
    required String id,
    required String name,
    required String parentId,
    required int level,
    required List<String> path,
    String? slug,
    String? description,
    CategoryImage? image,
    List<Category> children = const [],
  }) {
    return Category(
      id: id,
      name: name,
      slug: slug ?? _generateSlug(name),
      parentId: parentId,
      level: level,
      path: path,
      description: description,
      image: image,
      children: children,
    );
  }

  /// Creates a featured category.
  factory Category.featured({
    required String id,
    required String name,
    String? slug,
    String? description,
    CategoryImage? image,
    CategoryImage? banner,
    String? badge,
  }) {
    return Category(
      id: id,
      name: name,
      slug: slug ?? _generateSlug(name),
      type: CategoryType.featured,
      description: description,
      image: image,
      banner: banner,
      isFeatured: true,
      badge: badge,
    );
  }

  /// Creates a sale/promotional category.
  factory Category.sale({
    required String id,
    required String name,
    String? slug,
    String? description,
    CategoryImage? banner,
    DateTime? activeUntil,
  }) {
    return Category(
      id: id,
      name: name,
      slug: slug ?? _generateSlug(name),
      type: CategoryType.sale,
      description: description,
      banner: banner,
      badge: 'Sale',
      badgeColor: '#FF0000',
      activeUntil: activeUntil,
    );
  }

  /// Creates a brand category.
  factory Category.brand({
    required String id,
    required String name,
    String? slug,
    String? description,
    CategoryImage? logo,
  }) {
    return Category(
      id: id,
      name: name,
      slug: slug ?? _generateSlug(name),
      type: CategoryType.brand,
      description: description,
      image: logo,
    );
  }

  /// Creates a menu-only category (no products).
  factory Category.menu({
    required String id,
    required String name,
    String? slug,
    List<Category> children = const [],
    String? customUrl,
  }) {
    return Category(
      id: id,
      name: name,
      slug: slug ?? _generateSlug(name),
      type: CategoryType.menu,
      children: children,
      allowProducts: false,
      customUrl: customUrl,
    );
  }

  /// Creates a [Category] from JSON.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? json['label'] ?? '',
      slug: json['slug'] ?? json['handle'] ?? json['url_key'],
      type: CategoryTypeExtension.fromString(json['type']),
      shortDescription: json['short_description'] ?? json['shortDescription'],
      description: json['description'] ?? json['body'] ?? json['content'],
      parentId: json['parent_id']?.toString() ?? json['parentId']?.toString(),
      children: _parseChildren(json['children'] ?? json['subcategories']),
      level: json['level'] ?? json['depth'] ?? 0,
      path: _parseStringList(json['path'] ?? json['breadcrumb']),
      image: _parseImage(json['image'] ?? json['cover']),
      thumbnail: _parseImage(json['thumbnail'] ?? json['thumb']),
      icon: _parseImage(json['icon']),
      banner: _parseImage(json['banner'] ?? json['hero']),
      backgroundImage: _parseImage(json['background'] ?? json['bg_image']),
      color: json['color'] ?? json['primary_color'],
      accentColor: json['accent_color'] ?? json['secondary_color'],
      backgroundColor: json['background_color'] ?? json['bg_color'],
      textColor: json['text_color'],
      productCount:
          json['product_count'] ?? json['productCount'] ?? json['count'] ?? 0,
      totalProductCount:
          json['total_product_count'] ?? json['totalProductCount'] ?? 0,
      sortOrder: json['sort_order'] ??
          json['sortOrder'] ??
          json['position'] ??
          json['order'] ??
          0,
      isActive: json['is_active'] ?? json['active'] ?? json['enabled'] ?? true,
      isVisible: json['is_visible'] ?? json['visible'] ?? json['show'] ?? true,
      isFeatured: json['is_featured'] ?? json['featured'] ?? false,
      includeInMenu: json['include_in_menu'] ??
          json['in_menu'] ??
          json['show_in_menu'] ??
          true,
      includeInSearch: json['include_in_search'] ?? json['searchable'] ?? true,
      allowProducts: json['allow_products'] ?? json['has_products'] ?? true,
      displayMode: _parseDisplayMode(json['display_mode'] ?? json['view']),
      gridColumns: json['grid_columns'] ?? json['columns'],
      defaultSort: _parseSortOption(json['default_sort'] ?? json['sort']),
      activeFrom: _parseDateTime(json['active_from'] ?? json['start_date']),
      activeUntil: _parseDateTime(json['active_until'] ?? json['end_date']),
      seoTitle: json['seo_title'] ?? json['meta_title'],
      seoDescription: json['seo_description'] ?? json['meta_description'],
      seoKeywords:
          _parseStringList(json['seo_keywords'] ?? json['meta_keywords']),
      canonicalUrl: json['canonical_url'] ?? json['canonical'],
      ogImageUrl: json['og_image'] ?? json['social_image'],
      customUrl: json['custom_url'] ?? json['external_url'] ?? json['link'],
      openInNewTab: json['open_in_new_tab'] ??
          json['new_tab'] ??
          json['target_blank'] ??
          false,
      badge: json['badge'] ?? json['label_text'],
      badgeColor: json['badge_color'] ?? json['label_color'],
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
      metadata: json['metadata'] ?? json['meta'] ?? json['custom_attributes'],
    );
  }

  /// Converts this [Category] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (slug != null) 'slug': slug,
        'type': type.name,
        if (shortDescription != null) 'short_description': shortDescription,
        if (description != null) 'description': description,
        if (parentId != null) 'parent_id': parentId,
        if (children.isNotEmpty)
          'children': children.map((c) => c.toJson()).toList(),
        'level': level,
        if (path.isNotEmpty) 'path': path,
        if (image != null) 'image': image!.toJson(),
        if (thumbnail != null) 'thumbnail': thumbnail!.toJson(),
        if (icon != null) 'icon': icon!.toJson(),
        if (banner != null) 'banner': banner!.toJson(),
        if (backgroundImage != null) 'background': backgroundImage!.toJson(),
        if (color != null) 'color': color,
        if (accentColor != null) 'accent_color': accentColor,
        if (backgroundColor != null) 'background_color': backgroundColor,
        if (textColor != null) 'text_color': textColor,
        'product_count': productCount,
        'total_product_count': totalProductCount,
        'sort_order': sortOrder,
        'is_active': isActive,
        'is_visible': isVisible,
        'is_featured': isFeatured,
        'include_in_menu': includeInMenu,
        'include_in_search': includeInSearch,
        'allow_products': allowProducts,
        'display_mode': displayMode.name,
        if (gridColumns != null) 'grid_columns': gridColumns,
        if (defaultSort != null) 'default_sort': defaultSort!.name,
        if (activeFrom != null) 'active_from': activeFrom!.toIso8601String(),
        if (activeUntil != null) 'active_until': activeUntil!.toIso8601String(),
        if (seoTitle != null) 'seo_title': seoTitle,
        if (seoDescription != null) 'seo_description': seoDescription,
        if (seoKeywords.isNotEmpty) 'seo_keywords': seoKeywords,
        if (canonicalUrl != null) 'canonical_url': canonicalUrl,
        if (ogImageUrl != null) 'og_image': ogImageUrl,
        if (customUrl != null) 'custom_url': customUrl,
        'open_in_new_tab': openInNewTab,
        if (badge != null) 'badge': badge,
        if (badgeColor != null) 'badge_color': badgeColor,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns `true` if this is a root category.
  bool get isRoot => parentId == null && level == 0;

  /// Returns `true` if this category has subcategories.
  bool get hasChildren => children.isNotEmpty;

  /// Returns `true` if this is a leaf category (no children).
  bool get isLeaf => children.isEmpty;

  /// Returns `true` if this category has products.
  bool get hasProducts => productCount > 0 || totalProductCount > 0;

  /// Returns `true` if this category is currently within its active period.
  bool get isWithinActivePeriod {
    final now = DateTime.now();
    if (activeFrom != null && now.isBefore(activeFrom!)) return false;
    if (activeUntil != null && now.isAfter(activeUntil!)) return false;
    return true;
  }

  /// Returns `true` if this category should be displayed.
  bool get shouldDisplay => isActive && isVisible && isWithinActivePeriod;

  /// Returns `true` if this category is a promotional type.
  bool get isPromotional => type.isPromotional;

  /// Returns the effective display image.
  CategoryImage? get displayImage => image ?? thumbnail ?? icon;

  /// Returns the full breadcrumb path as names.
  String get breadcrumb {
    if (path.isEmpty) return name;
    return '${path.join(' > ')} > $name';
  }

  /// Returns the number of direct children.
  int get childCount => children.length;

  /// Returns all descendants (children, grandchildren, etc.).
  List<Category> get allDescendants {
    final result = <Category>[];
    for (final child in children) {
      result.add(child);
      result.addAll(child.allDescendants);
    }
    return result;
  }

  /// Returns the total count of all descendants.
  int get descendantCount => allDescendants.length;

  /// Returns `true` if this category has a custom URL.
  bool get hasCustomUrl => customUrl != null && customUrl!.isNotEmpty;

  /// Returns the URL for this category.
  String get url => customUrl ?? '/category/${slug ?? id}';

  /// Returns `true` if a badge should be shown.
  bool get hasBadge => badge != null && badge!.isNotEmpty;

  // ─────────────────────────────────────────────────────────────────────────
  // Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Finds a child category by ID (searches recursively).
  Category? findChild(String childId) {
    for (final child in children) {
      if (child.id == childId) return child;
      final found = child.findChild(childId);
      if (found != null) return found;
    }
    return null;
  }

  /// Finds a child category by slug (searches recursively).
  Category? findChildBySlug(String childSlug) {
    for (final child in children) {
      if (child.slug == childSlug) return child;
      final found = child.findChildBySlug(childSlug);
      if (found != null) return found;
    }
    return null;
  }

  /// Returns all leaf categories (categories without children).
  List<Category> getLeafCategories() {
    if (isLeaf) return [this];
    final result = <Category>[];
    for (final child in children) {
      result.addAll(child.getLeafCategories());
    }
    return result;
  }

  /// Returns categories at a specific level.
  List<Category> getCategoriesAtLevel(int targetLevel) {
    if (level == targetLevel) return [this];
    final result = <Category>[];
    for (final child in children) {
      result.addAll(child.getCategoriesAtLevel(targetLevel));
    }
    return result;
  }

  /// Returns the path to this category as a list of categories.
  List<Category> getPathCategories(List<Category> allCategories) {
    final result = <Category>[];
    for (final id in path) {
      final cat = allCategories.firstWhere(
        (c) => c.id == id,
        orElse: () => Category(id: id, name: id),
      );
      result.add(cat);
    }
    return result;
  }

  /// Adds a child category.
  Category addChild(Category child) {
    return copyWith(
      children: [
        ...children,
        child.copyWith(
          parentId: id,
          level: level + 1,
          path: [...path, id],
        ),
      ],
    );
  }

  /// Removes a child category by ID.
  Category removeChild(String childId) {
    return copyWith(
      children: children.where((c) => c.id != childId).toList(),
    );
  }

  /// Updates a child category.
  Category updateChild(Category updatedChild) {
    return copyWith(
      children: children
          .map((c) => c.id == updatedChild.id ? updatedChild : c)
          .toList(),
    );
  }

  /// Copies this [Category] with optional new values.
  Category copyWith({
    String? id,
    String? name,
    String? slug,
    CategoryType? type,
    String? shortDescription,
    String? description,
    String? parentId,
    List<Category>? children,
    int? level,
    List<String>? path,
    CategoryImage? image,
    CategoryImage? thumbnail,
    CategoryImage? icon,
    CategoryImage? banner,
    CategoryImage? backgroundImage,
    String? color,
    String? accentColor,
    String? backgroundColor,
    String? textColor,
    int? productCount,
    int? totalProductCount,
    int? sortOrder,
    bool? isActive,
    bool? isVisible,
    bool? isFeatured,
    bool? includeInMenu,
    bool? includeInSearch,
    bool? allowProducts,
    CategoryDisplayMode? displayMode,
    int? gridColumns,
    ProductSortOption? defaultSort,
    DateTime? activeFrom,
    DateTime? activeUntil,
    String? seoTitle,
    String? seoDescription,
    List<String>? seoKeywords,
    String? canonicalUrl,
    String? ogImageUrl,
    String? customUrl,
    bool? openInNewTab,
    String? badge,
    String? badgeColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      type: type ?? this.type,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
      level: level ?? this.level,
      path: path ?? this.path,
      image: image ?? this.image,
      thumbnail: thumbnail ?? this.thumbnail,
      icon: icon ?? this.icon,
      banner: banner ?? this.banner,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      color: color ?? this.color,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      productCount: productCount ?? this.productCount,
      totalProductCount: totalProductCount ?? this.totalProductCount,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      isVisible: isVisible ?? this.isVisible,
      isFeatured: isFeatured ?? this.isFeatured,
      includeInMenu: includeInMenu ?? this.includeInMenu,
      includeInSearch: includeInSearch ?? this.includeInSearch,
      allowProducts: allowProducts ?? this.allowProducts,
      displayMode: displayMode ?? this.displayMode,
      gridColumns: gridColumns ?? this.gridColumns,
      defaultSort: defaultSort ?? this.defaultSort,
      activeFrom: activeFrom ?? this.activeFrom,
      activeUntil: activeUntil ?? this.activeUntil,
      seoTitle: seoTitle ?? this.seoTitle,
      seoDescription: seoDescription ?? this.seoDescription,
      seoKeywords: seoKeywords ?? this.seoKeywords,
      canonicalUrl: canonicalUrl ?? this.canonicalUrl,
      ogImageUrl: ogImageUrl ?? this.ogImageUrl,
      customUrl: customUrl ?? this.customUrl,
      openInNewTab: openInNewTab ?? this.openInNewTab,
      badge: badge ?? this.badge,
      badgeColor: badgeColor ?? this.badgeColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────────────────

  static String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  static List<Category> _parseChildren(dynamic children) {
    if (children == null) return [];
    if (children is List) {
      return children
          .whereType<Map<String, dynamic>>()
          .map((c) => Category.fromJson(c))
          .toList();
    }
    return [];
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  static CategoryImage? _parseImage(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return CategoryImage.network(url: value);
    }
    if (value is Map<String, dynamic>) {
      return CategoryImage.fromJson(value);
    }
    return null;
  }

  static CategoryDisplayMode _parseDisplayMode(dynamic value) {
    if (value == null) return CategoryDisplayMode.grid;
    switch (value.toString().toLowerCase()) {
      case 'list':
        return CategoryDisplayMode.list;
      case 'grid':
        return CategoryDisplayMode.grid;
      case 'carousel':
      case 'slider':
        return CategoryDisplayMode.carousel;
      case 'masonry':
        return CategoryDisplayMode.masonry;
      case 'compact':
        return CategoryDisplayMode.compact;
      case 'featured':
        return CategoryDisplayMode.featured;
      default:
        return CategoryDisplayMode.grid;
    }
  }

  static ProductSortOption? _parseSortOption(dynamic value) {
    if (value == null) return null;
    switch (value.toString().toLowerCase()) {
      case 'name':
      case 'name_asc':
      case 'alphabetical':
        return ProductSortOption.nameAsc;
      case 'name_desc':
        return ProductSortOption.nameDesc;
      case 'price':
      case 'price_asc':
      case 'price_low':
        return ProductSortOption.priceAsc;
      case 'price_desc':
      case 'price_high':
        return ProductSortOption.priceDesc;
      case 'newest':
      case 'date':
      case 'date_desc':
        return ProductSortOption.newest;
      case 'oldest':
      case 'date_asc':
        return ProductSortOption.oldest;
      case 'popular':
      case 'popularity':
      case 'best_selling':
        return ProductSortOption.popularity;
      case 'rating':
      case 'rating_desc':
        return ProductSortOption.rating;
      case 'featured':
        return ProductSortOption.featured;
      case 'random':
        return ProductSortOption.random;
      default:
        return null;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        type,
        parentId,
        level,
        isActive,
        isVisible,
        sortOrder,
      ];
}

/// Display modes for category pages.
enum CategoryDisplayMode {
  /// Grid layout with equal-sized items.
  grid,

  /// List layout with items in rows.
  list,

  /// Horizontal carousel/slider.
  carousel,

  /// Masonry/pinterest-style layout.
  masonry,

  /// Compact layout with smaller items.
  compact,

  /// Featured layout with highlighted items.
  featured,
}

/// Sort options for products in a category.
enum ProductSortOption {
  /// Sort by name A-Z.
  nameAsc,

  /// Sort by name Z-A.
  nameDesc,

  /// Sort by price low to high.
  priceAsc,

  /// Sort by price high to low.
  priceDesc,

  /// Sort by newest first.
  newest,

  /// Sort by oldest first.
  oldest,

  /// Sort by popularity/sales.
  popularity,

  /// Sort by rating.
  rating,

  /// Sort by featured status.
  featured,

  /// Random order.
  random,
}

/// Extension methods for [ProductSortOption].
extension ProductSortOptionExtension on ProductSortOption {
  /// Returns a human-readable label.
  String get label {
    switch (this) {
      case ProductSortOption.nameAsc:
        return 'Name (A-Z)';
      case ProductSortOption.nameDesc:
        return 'Name (Z-A)';
      case ProductSortOption.priceAsc:
        return 'Price (Low to High)';
      case ProductSortOption.priceDesc:
        return 'Price (High to Low)';
      case ProductSortOption.newest:
        return 'Newest';
      case ProductSortOption.oldest:
        return 'Oldest';
      case ProductSortOption.popularity:
        return 'Most Popular';
      case ProductSortOption.rating:
        return 'Highest Rated';
      case ProductSortOption.featured:
        return 'Featured';
      case ProductSortOption.random:
        return 'Random';
    }
  }
}

/// Extension methods for [CategoryDisplayMode].
extension CategoryDisplayModeExtension on CategoryDisplayMode {
  /// Returns a human-readable label.
  String get label {
    switch (this) {
      case CategoryDisplayMode.grid:
        return 'Grid';
      case CategoryDisplayMode.list:
        return 'List';
      case CategoryDisplayMode.carousel:
        return 'Carousel';
      case CategoryDisplayMode.masonry:
        return 'Masonry';
      case CategoryDisplayMode.compact:
        return 'Compact';
      case CategoryDisplayMode.featured:
        return 'Featured';
    }
  }

  /// Returns the icon name for this display mode.
  String get iconName {
    switch (this) {
      case CategoryDisplayMode.grid:
        return 'grid_view';
      case CategoryDisplayMode.list:
        return 'view_list';
      case CategoryDisplayMode.carousel:
        return 'view_carousel';
      case CategoryDisplayMode.masonry:
        return 'dashboard';
      case CategoryDisplayMode.compact:
        return 'view_compact';
      case CategoryDisplayMode.featured:
        return 'featured_play_list';
    }
  }
}
