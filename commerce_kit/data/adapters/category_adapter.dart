import '../../core/enums/category_type.dart';
import '../../core/models/category.dart';
import '../../core/models/category_image.dart';

/// Abstract adapter for converting external category data to [Category] objects.
///
/// Implement this interface to integrate with any backend API format.
///
/// ## Usage
///
/// ```dart
/// class MyApiCategoryAdapter implements CategoryAdapter<MyApiCategory> {
///   @override
///   Category fromExternal(MyApiCategory external) {
///     return Category(
///       id: external.categoryId,
///       name: external.title,
///       // ... map other fields
///     );
///   }
///
///   @override
///   MyApiCategory toExternal(Category category) {
///     return MyApiCategory(
///       categoryId: category.id,
///       title: category.name,
///       // ... map other fields
///     );
///   }
/// }
/// ```
abstract class CategoryAdapter<T> {
  /// Converts external data to a [Category].
  Category fromExternal(T external);

  /// Converts a [Category] to external format.
  T toExternal(Category category);

  /// Converts a list of external data to categories.
  List<Category> fromExternalList(List<T> external);

  /// Converts a list of categories to external format.
  List<T> toExternalList(List<Category> categories);
}

/// Adapter for converting Map data to [Category] objects.
///
/// This is the default adapter for JSON-like data structures.
class MapCategoryAdapter implements CategoryAdapter<Map<String, dynamic>> {
  /// Creates a [MapCategoryAdapter].
  const MapCategoryAdapter();

  @override
  Category fromExternal(Map<String, dynamic> external) {
    return Category.fromJson(external);
  }

  @override
  Map<String, dynamic> toExternal(Category category) {
    return category.toJson();
  }

  @override
  List<Category> fromExternalList(List<Map<String, dynamic>> external) {
    return external.map(fromExternal).toList();
  }

  @override
  List<Map<String, dynamic>> toExternalList(List<Category> categories) {
    return categories.map(toExternal).toList();
  }
}

/// Configurable JSON adapter for categories with custom field mappings.
///
/// Use this adapter when your API uses different field names than the defaults.
///
/// ## Usage
///
/// ```dart
/// final adapter = JsonCategoryAdapter(
///   idField: 'category_id',
///   nameField: 'title',
///   slugField: 'url_key',
///   descriptionField: 'content',
///   parentIdField: 'parent',
///   imageField: 'cover_image',
///   childrenField: 'subcategories',
/// );
///
/// final category = adapter.fromJson(apiResponse);
/// ```
class JsonCategoryAdapter implements CategoryAdapter<Map<String, dynamic>> {
  /// Field name for category ID.
  final String idField;

  /// Field name for category name.
  final String nameField;

  /// Field name for slug.
  final String slugField;

  /// Field name for category type.
  final String typeField;

  /// Field name for short description.
  final String shortDescriptionField;

  /// Field name for description.
  final String descriptionField;

  /// Field name for parent ID.
  final String parentIdField;

  /// Field name for children/subcategories.
  final String childrenField;

  /// Field name for level/depth.
  final String levelField;

  /// Field name for path/breadcrumb.
  final String pathField;

  /// Field name for main image.
  final String imageField;

  /// Field name for thumbnail.
  final String thumbnailField;

  /// Field name for icon.
  final String iconField;

  /// Field name for banner.
  final String bannerField;

  /// Field name for product count.
  final String productCountField;

  /// Field name for sort order.
  final String sortOrderField;

  /// Field name for active status.
  final String isActiveField;

  /// Field name for visibility.
  final String isVisibleField;

  /// Field name for featured status.
  final String isFeaturedField;

  /// Field name for include in menu.
  final String includeInMenuField;

  /// Custom type mapping.
  final Map<String, CategoryType>? typeMapping;

  /// Custom parser for images.
  final CategoryImage? Function(dynamic)? imageParser;

  /// Creates a [JsonCategoryAdapter].
  const JsonCategoryAdapter({
    this.idField = 'id',
    this.nameField = 'name',
    this.slugField = 'slug',
    this.typeField = 'type',
    this.shortDescriptionField = 'short_description',
    this.descriptionField = 'description',
    this.parentIdField = 'parent_id',
    this.childrenField = 'children',
    this.levelField = 'level',
    this.pathField = 'path',
    this.imageField = 'image',
    this.thumbnailField = 'thumbnail',
    this.iconField = 'icon',
    this.bannerField = 'banner',
    this.productCountField = 'product_count',
    this.sortOrderField = 'sort_order',
    this.isActiveField = 'is_active',
    this.isVisibleField = 'is_visible',
    this.isFeaturedField = 'is_featured',
    this.includeInMenuField = 'include_in_menu',
    this.typeMapping,
    this.imageParser,
  });

  /// Creates a WooCommerce-compatible adapter.
  factory JsonCategoryAdapter.wooCommerce() {
    return const JsonCategoryAdapter(
      parentIdField: 'parent',
      productCountField: 'count',
      sortOrderField: 'menu_order',
    );
  }

  /// Creates a Shopify-compatible adapter.
  factory JsonCategoryAdapter.shopify() {
    return const JsonCategoryAdapter(
      nameField: 'title',
      slugField: 'handle',
      descriptionField: 'body_html',
      productCountField: 'products_count',
    );
  }

  /// Creates a Magento-compatible adapter.
  factory JsonCategoryAdapter.magento() {
    return const JsonCategoryAdapter(
      slugField: 'url_key',
      childrenField: 'children_data',
      sortOrderField: 'position',
    );
  }

  /// Creates a PrestaShop-compatible adapter.
  factory JsonCategoryAdapter.prestaShop() {
    return const JsonCategoryAdapter(
      idField: 'id_category',
      slugField: 'link_rewrite',
      parentIdField: 'id_parent',
      levelField: 'level_depth',
      sortOrderField: 'position',
      isActiveField: 'active',
    );
  }

  /// Creates an OpenCart-compatible adapter.
  factory JsonCategoryAdapter.openCart() {
    return const JsonCategoryAdapter(
      idField: 'category_id',
      isActiveField: 'status',
    );
  }

  @override
  Category fromExternal(Map<String, dynamic> external) {
    return fromJson(external);
  }

  @override
  Map<String, dynamic> toExternal(Category category) {
    return toJson(category);
  }

  @override
  List<Category> fromExternalList(List<Map<String, dynamic>> external) {
    return external.map(fromExternal).toList();
  }

  @override
  List<Map<String, dynamic>> toExternalList(List<Category> categories) {
    return categories.map(toExternal).toList();
  }

  /// Converts JSON to a [Category].
  Category fromJson(Map<String, dynamic> json) {
    return Category(
      id: _getString(json, idField) ?? '',
      name: _getString(json, nameField) ?? '',
      slug: _getString(json, slugField),
      type: _parseType(json[typeField]),
      shortDescription: _getString(json, shortDescriptionField),
      description: _getString(json, descriptionField),
      parentId: _getString(json, parentIdField),
      children: _parseChildren(json[childrenField]),
      level: _getInt(json, levelField) ?? 0,
      path: _parseStringList(json[pathField]),
      image: _parseImage(json[imageField]),
      thumbnail: _parseImage(json[thumbnailField]),
      icon: _parseImage(json[iconField]),
      banner: _parseImage(json[bannerField]),
      productCount: _getInt(json, productCountField) ?? 0,
      sortOrder: _getInt(json, sortOrderField) ?? 0,
      isActive: _getBool(json, isActiveField) ?? true,
      isVisible: _getBool(json, isVisibleField) ?? true,
      isFeatured: _getBool(json, isFeaturedField) ?? false,
      includeInMenu: _getBool(json, includeInMenuField) ?? true,
      metadata: json['metadata'] ?? json['meta'],
    );
  }

  /// Converts a [Category] to JSON.
  Map<String, dynamic> toJson(Category category) {
    return {
      idField: category.id,
      nameField: category.name,
      if (category.slug != null) slugField: category.slug,
      typeField: category.type.name,
      if (category.shortDescription != null)
        shortDescriptionField: category.shortDescription,
      if (category.description != null) descriptionField: category.description,
      if (category.parentId != null) parentIdField: category.parentId,
      if (category.children.isNotEmpty)
        childrenField: category.children.map((c) => toJson(c)).toList(),
      levelField: category.level,
      if (category.path.isNotEmpty) pathField: category.path,
      if (category.image != null) imageField: category.image!.toJson(),
      if (category.thumbnail != null)
        thumbnailField: category.thumbnail!.toJson(),
      if (category.icon != null) iconField: category.icon!.toJson(),
      if (category.banner != null) bannerField: category.banner!.toJson(),
      productCountField: category.productCount,
      sortOrderField: category.sortOrder,
      isActiveField: category.isActive,
      isVisibleField: category.isVisible,
      isFeaturedField: category.isFeatured,
      includeInMenuField: category.includeInMenu,
      if (category.metadata != null) 'metadata': category.metadata,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────────────────

  String? _getString(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value == null) return null;
    return value.toString();
  }

  int? _getInt(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _getBool(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return null;
  }

  CategoryType _parseType(dynamic value) {
    if (value == null) return CategoryType.standard;

    // Check custom mapping first
    if (typeMapping != null) {
      final mapped = typeMapping![value.toString()];
      if (mapped != null) return mapped;
    }

    return CategoryTypeExtension.fromString(value.toString());
  }

  List<Category> _parseChildren(dynamic children) {
    if (children == null) return [];
    if (children is List) {
      return children
          .whereType<Map<String, dynamic>>()
          .map((c) => fromJson(c))
          .toList();
    }
    return [];
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      // Handle different separators
      if (value.contains('/')) {
        return value.split('/').where((e) => e.isNotEmpty).toList();
      }
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  CategoryImage? _parseImage(dynamic value) {
    // Use custom parser if provided
    if (imageParser != null) {
      return imageParser!(value);
    }

    if (value == null) return null;

    if (value is String) {
      return CategoryImage.network(url: value);
    }

    if (value is Map<String, dynamic>) {
      // Handle various image object formats
      final url = value['url'] ??
          value['src'] ??
          value['source'] ??
          value['path'] ??
          value['href'];

      if (url != null) {
        return CategoryImage.network(
          url: url.toString(),
          id: value['id']?.toString(),
          alt: value['alt'] ?? value['alt_text'],
          title: value['title'],
          width: value['width'],
          height: value['height'],
        );
      }
    }

    return null;
  }
}

/// Adapter for nested/hierarchical category structures.
///
/// Handles APIs that return categories with nested children.
class NestedCategoryAdapter extends MapCategoryAdapter {
  /// Field name for children.
  final String childrenField;

  /// Maximum depth to parse.
  final int maxDepth;

  /// Creates a [NestedCategoryAdapter].
  NestedCategoryAdapter({
    this.childrenField = 'children',
    this.maxDepth = 10,
  });

  @override
  Category fromExternal(Map<String, dynamic> external) {
    return _parseWithDepth(external, 0, []);
  }

  Category _parseWithDepth(
    Map<String, dynamic> json,
    int currentLevel,
    List<String> currentPath,
  ) {
    final id = json['id']?.toString() ?? '';
    final children = <Category>[];

    // Parse children if not at max depth
    if (currentLevel < maxDepth && json[childrenField] != null) {
      final childList = json[childrenField] as List?;
      if (childList != null) {
        for (final childJson in childList) {
          if (childJson is Map<String, dynamic>) {
            children.add(
              _parseWithDepth(
                childJson,
                currentLevel + 1,
                [...currentPath, id],
              ),
            );
          }
        }
      }
    }

    return Category.fromJson(json).copyWith(
      level: currentLevel,
      path: currentPath,
      children: children,
    );
  }
}

/// Adapter for flat category lists that need to be converted to a tree.
///
/// Handles APIs that return all categories in a flat list with parent IDs.
class FlatCategoryAdapter extends MapCategoryAdapter {
  /// Field name for parent ID.
  final String parentIdField;

  /// Creates a [FlatCategoryAdapter].
  FlatCategoryAdapter({
    this.parentIdField = 'parent_id',
  });

  /// Converts a flat list of categories to a tree structure.
  List<Category> fromFlatList(List<Map<String, dynamic>> flatList) {
    // First pass: create all categories
    final categories = <String, Category>{};
    for (final json in flatList) {
      final category = Category.fromJson(json);
      categories[category.id] = category;
    }

    // Second pass: build tree
    final roots = <Category>[];
    for (final json in flatList) {
      final id = json['id']?.toString() ?? '';
      final parentId = json[parentIdField]?.toString();

      final category = categories[id]!;

      if (parentId == null ||
          parentId.isEmpty ||
          !categories.containsKey(parentId)) {
        // This is a root category
        roots.add(_buildSubtree(category, categories, []));
      }
    }

    return roots;
  }

  Category _buildSubtree(
    Category category,
    Map<String, Category> allCategories,
    List<String> path,
  ) {
    // Find children
    final children = allCategories.values
        .where((c) => c.parentId == category.id)
        .map((c) => _buildSubtree(c, allCategories, [...path, category.id]))
        .toList();

    return category.copyWith(
      level: path.length,
      path: path,
      children: children,
    );
  }
}
