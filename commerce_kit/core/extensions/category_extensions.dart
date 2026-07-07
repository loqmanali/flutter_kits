import '../enums/category_type.dart';
import '../models/category.dart';

/// Extension methods for [Category].
extension CategoryExtension on Category {
  /// Returns `true` if this category is empty (no products and no children with products).
  bool get isEmpty => !hasProducts && children.every((c) => c.isEmpty);

  /// Returns `true` if this category or any of its children has products.
  bool get hasAnyProducts =>
      hasProducts || children.any((c) => c.hasAnyProducts);

  /// Returns the total product count including all descendants.
  int get recursiveProductCount {
    var count = productCount;
    for (final child in children) {
      count += child.recursiveProductCount;
    }
    return count;
  }

  /// Returns a flat list of this category and all its descendants.
  List<Category> get flatten {
    final result = <Category>[this];
    for (final child in children) {
      result.addAll(child.flatten);
    }
    return result;
  }

  /// Returns only the visible categories from children.
  List<Category> get visibleChildren =>
      children.where((c) => c.shouldDisplay).toList();

  /// Returns only the menu categories from children.
  List<Category> get menuChildren =>
      children.where((c) => c.includeInMenu && c.shouldDisplay).toList();

  /// Returns only the featured categories from children.
  List<Category> get featuredChildren =>
      children.where((c) => c.isFeatured && c.shouldDisplay).toList();

  /// Returns categories sorted by sort order.
  List<Category> get sortedChildren {
    final sorted = List<Category>.from(children);
    sorted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  /// Returns the maximum depth of the category tree.
  int get maxDepth {
    if (children.isEmpty) return level;
    return children.map((c) => c.maxDepth).reduce((a, b) => a > b ? a : b);
  }

  /// Filters children by category type.
  List<Category> childrenOfType(CategoryType type) =>
      children.where((c) => c.type == type).toList();

  /// Searches for categories matching the query.
  List<Category> search(String query) {
    final lowerQuery = query.toLowerCase();
    final results = <Category>[];

    if (name.toLowerCase().contains(lowerQuery) ||
        (description?.toLowerCase().contains(lowerQuery) ?? false)) {
      results.add(this);
    }

    for (final child in children) {
      results.addAll(child.search(query));
    }

    return results;
  }

  /// Returns categories that match the predicate.
  List<Category> where(bool Function(Category) test) {
    final results = <Category>[];
    if (test(this)) results.add(this);
    for (final child in children) {
      results.addAll(child.where(test));
    }
    return results;
  }

  /// Maps each category in the tree.
  List<T> mapTree<T>(T Function(Category) transform) {
    final results = <T>[transform(this)];
    for (final child in children) {
      results.addAll(child.mapTree(transform));
    }
    return results;
  }

  /// Returns the category at the given path.
  Category? getAtPath(List<String> pathIds) {
    if (pathIds.isEmpty) return this;

    final nextId = pathIds.first;
    final child = children.firstWhere(
      (c) => c.id == nextId,
      orElse: () => const Category(id: '', name: ''),
    );

    if (child.id.isEmpty) return null;
    return child.getAtPath(pathIds.sublist(1));
  }

  /// Returns siblings (other children of the parent).
  List<Category> getSiblings(List<Category> allCategories) {
    if (parentId == null) {
      return allCategories
          .where((c) => c.parentId == null && c.id != id)
          .toList();
    }

    final parent = allCategories.firstWhere(
      (c) => c.id == parentId,
      orElse: () => const Category(id: '', name: ''),
    );

    if (parent.id.isEmpty) return [];
    return parent.children.where((c) => c.id != id).toList();
  }

  /// Returns the full path as a list of category names.
  List<String> getPathNames(List<Category> allCategories) {
    final names = <String>[];
    for (final id in path) {
      final cat = allCategories.firstWhere(
        (c) => c.id == id,
        orElse: () => Category(id: id, name: id),
      );
      names.add(cat.name);
    }
    names.add(name);
    return names;
  }
}

/// Extension methods for lists of categories.
extension CategoryListExtension on List<Category> {
  /// Returns only root categories.
  List<Category> get roots => where((c) => c.isRoot).toList();

  /// Returns only visible categories.
  List<Category> get visible => where((c) => c.shouldDisplay).toList();

  /// Returns only featured categories.
  List<Category> get featured => where((c) => c.isFeatured).toList();

  /// Returns only active categories.
  List<Category> get active => where((c) => c.isActive).toList();

  /// Returns categories that should appear in menus.
  List<Category> get forMenu =>
      where((c) => c.includeInMenu && c.shouldDisplay).toList();

  /// Returns categories that should appear in search.
  List<Category> get searchable =>
      where((c) => c.includeInSearch && c.shouldDisplay).toList();

  /// Returns categories sorted by sort order.
  List<Category> get sorted {
    final list = List<Category>.from(this);
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  /// Returns categories sorted by name.
  List<Category> get sortedByName {
    final list = List<Category>.from(this);
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  /// Returns categories sorted by product count.
  List<Category> get sortedByProductCount {
    final list = List<Category>.from(this);
    list.sort((a, b) => b.productCount.compareTo(a.productCount));
    return list;
  }

  /// Filters categories by type.
  List<Category> ofType(CategoryType type) =>
      where((c) => c.type == type).toList();

  /// Filters categories by parent ID.
  List<Category> withParent(String? parentId) =>
      where((c) => c.parentId == parentId).toList();

  /// Filters categories by level.
  List<Category> atLevel(int level) => where((c) => c.level == level).toList();

  /// Finds a category by ID.
  Category? findById(String id) {
    for (final cat in this) {
      if (cat.id == id) return cat;
      final found = cat.findChild(id);
      if (found != null) return found;
    }
    return null;
  }

  /// Finds a category by slug.
  Category? findBySlug(String slug) {
    for (final cat in this) {
      if (cat.slug == slug) return cat;
      final found = cat.findChildBySlug(slug);
      if (found != null) return found;
    }
    return null;
  }

  /// Returns a flat list of all categories.
  List<Category> get flattened {
    final result = <Category>[];
    for (final cat in this) {
      result.addAll(cat.flatten);
    }
    return result;
  }

  /// Builds a tree structure from a flat list.
  List<Category> buildTree() {
    final map = <String, Category>{};
    final roots = <Category>[];

    // First pass: create map
    for (final cat in this) {
      map[cat.id] = cat;
    }

    // Second pass: build tree
    for (final cat in this) {
      if (cat.parentId == null || !map.containsKey(cat.parentId)) {
        roots.add(cat);
      } else {
        final parent = map[cat.parentId]!;
        map[cat.parentId!] = parent.addChild(cat);
      }
    }

    return roots;
  }

  /// Returns the total product count across all categories.
  int get totalProductCount => fold(0, (sum, cat) => sum + cat.productCount);

  /// Returns the maximum depth across all category trees.
  int get maxDepth {
    if (isEmpty) return 0;
    return map((c) => c.maxDepth).reduce((a, b) => a > b ? a : b);
  }

  /// Groups categories by type.
  Map<CategoryType, List<Category>> groupByType() {
    final groups = <CategoryType, List<Category>>{};
    for (final cat in this) {
      groups.putIfAbsent(cat.type, () => []).add(cat);
    }
    return groups;
  }

  /// Groups categories by parent ID.
  Map<String?, List<Category>> groupByParent() {
    final groups = <String?, List<Category>>{};
    for (final cat in this) {
      groups.putIfAbsent(cat.parentId, () => []).add(cat);
    }
    return groups;
  }

  /// Searches categories by name or description.
  List<Category> search(String query) {
    final lowerQuery = query.toLowerCase();
    return flattened.where((cat) {
      return cat.name.toLowerCase().contains(lowerQuery) ||
          (cat.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (cat.seoKeywords.any((k) => k.toLowerCase().contains(lowerQuery)));
    }).toList();
  }
}

/// Extension methods for building category navigation.
extension CategoryNavigationExtension on List<Category> {
  /// Builds a navigation menu structure.
  List<CategoryMenuItem> buildMenu({int maxDepth = 3}) {
    return roots.forMenu.sorted.map((cat) {
      return CategoryMenuItem.fromCategory(cat, maxDepth: maxDepth);
    }).toList();
  }

  /// Builds breadcrumb trail for a category.
  List<CategoryBreadcrumb> buildBreadcrumb(String categoryId) {
    final category = findById(categoryId);
    if (category == null) return [];

    final breadcrumbs = <CategoryBreadcrumb>[];

    // Add ancestors
    for (final ancestorId in category.path) {
      final ancestor = findById(ancestorId);
      if (ancestor != null) {
        breadcrumbs.add(
          CategoryBreadcrumb(
            id: ancestor.id,
            name: ancestor.name,
            slug: ancestor.slug,
            url: ancestor.url,
          ),
        );
      }
    }

    // Add current category
    breadcrumbs.add(
      CategoryBreadcrumb(
        id: category.id,
        name: category.name,
        slug: category.slug,
        url: category.url,
        isActive: true,
      ),
    );

    return breadcrumbs;
  }
}

/// Represents a menu item in category navigation.
class CategoryMenuItem {
  final String id;
  final String name;
  final String? slug;
  final String url;
  final String? iconName;
  final String? badge;
  final String? badgeColor;
  final bool isActive;
  final bool openInNewTab;
  final List<CategoryMenuItem> children;

  const CategoryMenuItem({
    required this.id,
    required this.name,
    this.slug,
    required this.url,
    this.iconName,
    this.badge,
    this.badgeColor,
    this.isActive = false,
    this.openInNewTab = false,
    this.children = const [],
  });

  factory CategoryMenuItem.fromCategory(
    Category category, {
    int maxDepth = 3,
    int currentDepth = 0,
  }) {
    return CategoryMenuItem(
      id: category.id,
      name: category.name,
      slug: category.slug,
      url: category.url,
      iconName: category.icon?.iconName,
      badge: category.badge,
      badgeColor: category.badgeColor,
      openInNewTab: category.openInNewTab,
      children: currentDepth < maxDepth
          ? category.menuChildren.map((child) {
              return CategoryMenuItem.fromCategory(
                child,
                maxDepth: maxDepth,
                currentDepth: currentDepth + 1,
              );
            }).toList()
          : [],
    );
  }

  bool get hasChildren => children.isNotEmpty;
}

/// Represents a breadcrumb item.
class CategoryBreadcrumb {
  final String id;
  final String name;
  final String? slug;
  final String url;
  final bool isActive;

  const CategoryBreadcrumb({
    required this.id,
    required this.name,
    this.slug,
    required this.url,
    this.isActive = false,
  });
}
