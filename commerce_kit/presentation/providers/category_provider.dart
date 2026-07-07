import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/category_type.dart';
import '../../core/extensions/category_extensions.dart';
import '../../core/models/category.dart';

/// State for categories management.
class CategoriesState {
  /// All categories (flat list).
  final List<Category> categories;

  /// Categories organized as a tree.
  final List<Category> categoryTree;

  /// Currently selected category.
  final Category? selectedCategory;

  /// Loading state.
  final bool isLoading;

  /// Error message if any.
  final String? error;

  /// Last update time.
  final DateTime? lastUpdated;

  /// Creates a [CategoriesState].
  const CategoriesState({
    this.categories = const [],
    this.categoryTree = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  /// Creates an empty state.
  const CategoriesState.initial()
      : categories = const [],
        categoryTree = const [],
        selectedCategory = null,
        isLoading = false,
        error = null,
        lastUpdated = null;

  /// Creates a loading state.
  const CategoriesState.loading()
      : categories = const [],
        categoryTree = const [],
        selectedCategory = null,
        isLoading = true,
        error = null,
        lastUpdated = null;

  /// Copies this state with optional new values.
  CategoriesState copyWith({
    List<Category>? categories,
    List<Category>? categoryTree,
    Category? selectedCategory,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    bool clearSelectedCategory = false,
    bool clearError = false,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      categoryTree: categoryTree ?? this.categoryTree,
      selectedCategory:
          clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Notifier for managing categories state.
class CategoriesNotifier extends Notifier<CategoriesState> {
  @override
  CategoriesState build() {
    return const CategoriesState.initial();
  }

  /// Sets the categories from a list.
  void setCategories(List<Category> categories) {
    final tree = categories.buildTree();
    state = state.copyWith(
      categories: categories,
      categoryTree: tree,
      lastUpdated: DateTime.now(),
      clearError: true,
    );
  }

  /// Sets the category tree directly.
  void setCategoryTree(List<Category> tree) {
    final flat = tree.flattened;
    state = state.copyWith(
      categories: flat,
      categoryTree: tree,
      lastUpdated: DateTime.now(),
      clearError: true,
    );
  }

  /// Adds a category.
  void addCategory(Category category) {
    final categories = [...state.categories, category];
    setCategories(categories);
  }

  /// Updates a category.
  void updateCategory(Category category) {
    final categories = state.categories.map((c) {
      return c.id == category.id ? category : c;
    }).toList();
    setCategories(categories);
  }

  /// Removes a category by ID.
  void removeCategory(String categoryId) {
    final categories = state.categories.where((c) => c.id != categoryId).toList();
    setCategories(categories);

    // Clear selection if removed category was selected
    if (state.selectedCategory?.id == categoryId) {
      state = state.copyWith(clearSelectedCategory: true);
    }
  }

  /// Selects a category by ID.
  void selectCategory(String? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearSelectedCategory: true);
      return;
    }

    final category = state.categories.findById(categoryId);
    state = state.copyWith(selectedCategory: category);
  }

  /// Selects a category by slug.
  void selectCategoryBySlug(String slug) {
    final category = state.categories.findBySlug(slug);
    state = state.copyWith(selectedCategory: category);
  }

  /// Clears the selected category.
  void clearSelection() {
    state = state.copyWith(clearSelectedCategory: true);
  }

  /// Sets loading state.
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Sets error state.
  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  /// Clears error.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clears all categories.
  void clear() {
    state = const CategoriesState.initial();
  }
}

/// Main categories provider.
final categoriesProvider =
    NotifierProvider<CategoriesNotifier, CategoriesState>(CategoriesNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Selector Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for all categories (flat list).
final allCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoriesProvider).categories;
});

/// Provider for category tree (root categories with children).
final categoryTreeProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoriesProvider).categoryTree;
});

/// Provider for root categories only.
final rootCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoryTreeProvider).roots;
});

/// Provider for visible categories.
final visibleCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoryTreeProvider).visible;
});

/// Provider for featured categories.
final featuredCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(allCategoriesProvider).featured;
});

/// Provider for menu categories.
final menuCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoryTreeProvider).forMenu;
});

/// Provider for currently selected category.
final selectedCategoryProvider = Provider<Category?>((ref) {
  return ref.watch(categoriesProvider).selectedCategory;
});

/// Provider for loading state.
final categoriesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(categoriesProvider).isLoading;
});

/// Provider for error state.
final categoriesErrorProvider = Provider<String?>((ref) {
  return ref.watch(categoriesProvider).error;
});

/// Provider for categories count.
final categoriesCountProvider = Provider<int>((ref) {
  return ref.watch(allCategoriesProvider).length;
});

/// Provider for category by ID.
final categoryByIdProvider = Provider.family<Category?, String>((ref, id) {
  return ref.watch(allCategoriesProvider).findById(id);
});

/// Provider for category by slug.
final categoryBySlugProvider = Provider.family<Category?, String>((ref, slug) {
  return ref.watch(allCategoriesProvider).findBySlug(slug);
});

/// Provider for children of a category.
final categoryChildrenProvider = Provider.family<List<Category>, String>((ref, parentId) {
  final category = ref.watch(categoryByIdProvider(parentId));
  return category?.children ?? [];
});

/// Provider for categories of a specific type.
final categoriesByTypeProvider =
    Provider.family<List<Category>, CategoryType>((ref, type) {
  return ref.watch(allCategoriesProvider).ofType(type);
});

/// Provider for categories at a specific level.
final categoriesAtLevelProvider = Provider.family<List<Category>, int>((ref, level) {
  return ref.watch(allCategoriesProvider).atLevel(level);
});

/// Provider for breadcrumb trail.
final categoryBreadcrumbProvider =
    Provider.family<List<CategoryBreadcrumb>, String>((ref, categoryId) {
  return ref.watch(allCategoriesProvider).buildBreadcrumb(categoryId);
});

/// Provider for category menu items.
final categoryMenuProvider = Provider<List<CategoryMenuItem>>((ref) {
  return ref.watch(categoryTreeProvider).buildMenu();
});

/// Provider for searching categories.
final categorySearchProvider =
    Provider.family<List<Category>, String>((ref, query) {
  if (query.isEmpty) return [];
  return ref.watch(allCategoriesProvider).search(query);
});

/// Provider for total product count across all categories.
final totalCategoryProductCountProvider = Provider<int>((ref) {
  return ref.watch(allCategoriesProvider).totalProductCount;
});

/// Provider for categories grouped by type.
final categoriesGroupedByTypeProvider =
    Provider<Map<CategoryType, List<Category>>>((ref) {
  return ref.watch(allCategoriesProvider).groupByType();
});
