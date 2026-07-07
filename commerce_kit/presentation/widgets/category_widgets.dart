import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/category_extensions.dart';
import '../../core/models/category.dart';
import '../providers/category_provider.dart';

/// A widget that displays a category card.
///
/// Shows category image, name, description, and product count.
class CategoryCard extends StatelessWidget {
  /// The category to display.
  final Category category;

  /// Callback when the category is tapped.
  final VoidCallback? onTap;

  /// Whether to show the product count.
  final bool showProductCount;

  /// Whether to show the description.
  final bool showDescription;

  /// Whether to show the badge.
  final bool showBadge;

  /// Card elevation.
  final double elevation;

  /// Card border radius.
  final double borderRadius;

  /// Image height.
  final double imageHeight;

  /// Creates a [CategoryCard].
  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.showProductCount = true,
    this.showDescription = false,
    this.showBadge = true,
    this.elevation = 2,
    this.borderRadius = 12,
    this.imageHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                _buildImage(),
                if (showBadge && category.hasBadge) _buildBadge(),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showDescription && category.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      category.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (showProductCount && category.productCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${category.productCount} products',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final image = category.displayImage;

    if (image == null) {
      return Container(
        height: imageHeight,
        color: category.backgroundColor != null
            ? _parseColor(category.backgroundColor!)
            : Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.category,
            size: 48,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    if (image.isIcon) {
      return Container(
        height: imageHeight,
        color: category.backgroundColor != null
            ? _parseColor(category.backgroundColor!)
            : Colors.grey[200],
        child: Center(
          child: Icon(
            _getIconData(image.iconName ?? 'category'),
            size: 48,
            color: image.iconColor != null
                ? _parseColor(image.iconColor!)
                : Colors.grey[600],
          ),
        ),
      );
    }

    return SizedBox(
      height: imageHeight,
      width: double.infinity,
      child: Image.network(
        image.url!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 48),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: category.badgeColor != null
              ? _parseColor(category.badgeColor!)
              : Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          category.badge!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  IconData _getIconData(String name) {
    // Map common icon names to Material Icons
    final icons = <String, IconData>{
      'category': Icons.category,
      'restaurant': Icons.restaurant,
      'fastfood': Icons.fastfood,
      'local_pizza': Icons.local_pizza,
      'local_cafe': Icons.local_cafe,
      'local_bar': Icons.local_bar,
      'shopping_bag': Icons.shopping_bag,
      'store': Icons.store,
      'star': Icons.star,
      'favorite': Icons.favorite,
      'new_releases': Icons.new_releases,
      'local_offer': Icons.local_offer,
      'trending_up': Icons.trending_up,
    };
    return icons[name] ?? Icons.category;
  }
}

/// A widget that displays a category chip.
class CategoryChip extends StatelessWidget {
  /// The category to display.
  final Category category;

  /// Callback when the chip is tapped.
  final VoidCallback? onTap;

  /// Whether the chip is selected.
  final bool isSelected;

  /// Whether to show the icon.
  final bool showIcon;

  /// Whether to show the product count.
  final bool showCount;

  /// Creates a [CategoryChip].
  const CategoryChip({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
    this.showIcon = true,
    this.showCount = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      avatar: showIcon && category.icon != null
          ? Icon(
              _getIconData(category.icon!.iconName ?? 'category'),
              size: 18,
            )
          : null,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.name),
          if (showCount && category.productCount > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${category.productCount}',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    final icons = <String, IconData>{
      'category': Icons.category,
      'restaurant': Icons.restaurant,
      'fastfood': Icons.fastfood,
      'star': Icons.star,
      'local_offer': Icons.local_offer,
    };
    return icons[name] ?? Icons.category;
  }
}

/// A widget that displays a horizontal list of categories.
class CategoryList extends StatelessWidget {
  /// The categories to display.
  final List<Category> categories;

  /// Callback when a category is tapped.
  final void Function(Category)? onCategoryTap;

  /// The selected category ID.
  final String? selectedId;

  /// Height of the list.
  final double height;

  /// Padding around the list.
  final EdgeInsets padding;

  /// Spacing between items.
  final double spacing;

  /// Creates a [CategoryList].
  const CategoryList({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.selectedId,
    this.height = 120,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryListItem(
            category: category,
            isSelected: category.id == selectedId,
            onTap:
                onCategoryTap != null ? () => onCategoryTap!(category) : null,
          );
        },
      ),
    );
  }
}

class _CategoryListItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CategoryListItem({
    required this.category,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Image circle
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildImage(),
            ),
          ),
          const SizedBox(height: 8),
          // Name
          SizedBox(
            width: 80,
            child: Text(
              category.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : null,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final image = category.displayImage;

    if (image == null || !image.isNetwork) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.category, color: Colors.grey),
      );
    }

    return Image.network(
      image.url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.category, color: Colors.grey),
      ),
    );
  }
}

/// A widget that displays a grid of categories.
class CategoryGrid extends StatelessWidget {
  /// The categories to display.
  final List<Category> categories;

  /// Callback when a category is tapped.
  final void Function(Category)? onCategoryTap;

  /// Number of columns.
  final int crossAxisCount;

  /// Aspect ratio of each item.
  final double childAspectRatio;

  /// Spacing between items.
  final double spacing;

  /// Padding around the grid.
  final EdgeInsets padding;

  /// Creates a [CategoryGrid].
  const CategoryGrid({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.spacing = 16,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          onTap: onCategoryTap != null ? () => onCategoryTap!(category) : null,
        );
      },
    );
  }
}

/// A widget that displays a category tree with expandable items.
class CategoryTreeView extends StatefulWidget {
  /// The root categories to display.
  final List<Category> categories;

  /// Callback when a category is tapped.
  final void Function(Category)? onCategoryTap;

  /// The selected category ID.
  final String? selectedId;

  /// Initially expanded category IDs.
  final Set<String> initiallyExpanded;

  /// Creates a [CategoryTreeView].
  const CategoryTreeView({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.selectedId,
    this.initiallyExpanded = const {},
  });

  @override
  State<CategoryTreeView> createState() => _CategoryTreeViewState();
}

class _CategoryTreeViewState extends State<CategoryTreeView> {
  late Set<String> _expandedIds;

  @override
  void initState() {
    super.initState();
    _expandedIds = Set.from(widget.initiallyExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.categories.map((cat) => _buildTreeItem(cat, 0)).toList(),
    );
  }

  Widget _buildTreeItem(Category category, int depth) {
    final isExpanded = _expandedIds.contains(category.id);
    final isSelected = widget.selectedId == category.id;
    final hasChildren = category.hasChildren;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (hasChildren) {
              setState(() {
                if (isExpanded) {
                  _expandedIds.remove(category.id);
                } else {
                  _expandedIds.add(category.id);
                }
              });
            }
            widget.onCategoryTap?.call(category);
          },
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0 + (depth * 24.0),
              right: 16,
              top: 12,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : null,
            ),
            child: Row(
              children: [
                // Expand icon
                if (hasChildren)
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                // Category icon
                if (category.icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.category,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                // Name
                Expanded(
                  child: Text(
                    category.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : null,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                ),
                // Product count
                if (category.productCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${category.productCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Children
        if (isExpanded && hasChildren)
          ...category.children.map((child) => _buildTreeItem(child, depth + 1)),
      ],
    );
  }
}

/// A widget that displays breadcrumb navigation for categories.
class CategoryBreadcrumbWidget extends StatelessWidget {
  /// The breadcrumb items.
  final List<CategoryBreadcrumbWidgetItem> items;

  /// Callback when an item is tapped.
  final void Function(String categoryId)? onItemTap;

  /// Separator widget.
  final Widget separator;

  /// Creates a [CategoryBreadcrumbWidget].
  const CategoryBreadcrumbWidget({
    super.key,
    required this.items,
    this.onItemTap,
    this.separator = const Icon(Icons.chevron_right, size: 16),
  });

  /// Creates breadcrumb from category extensions.
  factory CategoryBreadcrumbWidget.fromCategory({
    required List<Category> allCategories,
    required String categoryId,
    void Function(String)? onItemTap,
  }) {
    final breadcrumbs = allCategories.buildBreadcrumb(categoryId);
    return CategoryBreadcrumbWidget(
      items: breadcrumbs
          .map(
            (b) => CategoryBreadcrumbWidgetItem(
              id: b.id,
              name: b.name,
              isActive: b.isActive,
            ),
          )
          .toList(),
      onItemTap: onItemTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: separator,
              ),
            _buildItem(context, items[i], theme),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    CategoryBreadcrumbWidgetItem item,
    ThemeData theme,
  ) {
    if (item.isActive) {
      return Text(
        item.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return InkWell(
      onTap: onItemTap != null ? () => onItemTap!(item.id) : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          item.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// A breadcrumb item.
class CategoryBreadcrumbWidgetItem {
  final String id;
  final String name;
  final bool isActive;

  const CategoryBreadcrumbWidgetItem({
    required this.id,
    required this.name,
    this.isActive = false,
  });
}

/// A widget that displays a dropdown for category selection.
class CategoryDropdown extends StatelessWidget {
  /// The categories to display.
  final List<Category> categories;

  /// The selected category ID.
  final String? selectedId;

  /// Callback when selection changes.
  final void Function(String?)? onChanged;

  /// Hint text when nothing is selected.
  final String hint;

  /// Whether to show the product count.
  final bool showProductCount;

  /// Whether to include an "All" option.
  final bool includeAll;

  /// Label for the "All" option.
  final String allLabel;

  /// Creates a [CategoryDropdown].
  const CategoryDropdown({
    super.key,
    required this.categories,
    this.selectedId,
    this.onChanged,
    this.hint = 'Select category',
    this.showProductCount = true,
    this.includeAll = false,
    this.allLabel = 'All Categories',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      hint: Text(hint),
      onChanged: onChanged,
      items: [
        if (includeAll)
          DropdownMenuItem<String>(
            child: Text(allLabel),
          ),
        ...categories.flattened.map((category) {
          final indent = '  ' * category.level;
          return DropdownMenuItem<String>(
            value: category.id,
            child: Row(
              children: [
                Text('$indent${category.name}'),
                if (showProductCount && category.productCount > 0) ...[
                  const Spacer(),
                  Text(
                    '(${category.productCount})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// A widget that displays categories with Riverpod integration.
class CategoryListView extends ConsumerWidget {
  /// Callback when a category is tapped.
  final void Function(Category)? onCategoryTap;

  /// Whether to show only menu categories.
  final bool menuOnly;

  /// Whether to show only featured categories.
  final bool featuredOnly;

  /// Creates a [CategoryListView].
  const CategoryListView({
    super.key,
    this.onCategoryTap,
    this.menuOnly = false,
    this.featuredOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(categoriesLoadingProvider);
    final error = ref.watch(categoriesErrorProvider);

    List<Category> categories;
    if (featuredOnly) {
      categories = ref.watch(featuredCategoriesProvider);
    } else if (menuOnly) {
      categories = ref.watch(menuCategoriesProvider);
    } else {
      categories = ref.watch(categoryTreeProvider);
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text('Error: $error'));
    }

    if (categories.isEmpty) {
      return const Center(child: Text('No categories'));
    }

    return CategoryList(
      categories: categories,
      onCategoryTap: onCategoryTap,
      selectedId: ref.watch(selectedCategoryProvider)?.id,
    );
  }
}
