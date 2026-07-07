import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/sort_option.dart';
import '../../core/models/product_filter.dart';
import '../../core/models/search_result.dart';
import '../providers/search_provider.dart';

/// A search bar widget for product search.
class ProductSearchBar extends StatefulWidget {
  /// Hint text.
  final String hintText;

  /// Callback when search is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Leading icon.
  final Widget? leading;

  /// Trailing widget.
  final Widget? trailing;

  /// Auto focus.
  final bool autoFocus;

  /// Show clear button.
  final bool showClearButton;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  /// Text style.
  final TextStyle? textStyle;

  /// Hint style.
  final TextStyle? hintStyle;

  const ProductSearchBar({
    super.key,
    this.hintText = 'Search products...',
    this.onSubmitted,
    this.onChanged,
    this.leading,
    this.trailing,
    this.autoFocus = false,
    this.showClearButton = true,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.textStyle,
    this.hintStyle,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Row(
        children: [
          widget.leading ??
              Icon(
                Icons.search,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autoFocus,
              style: widget.textStyle ?? theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: widget.hintStyle ??
                    theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                setState(() {});
                widget.onChanged?.call(value);
              },
              onSubmitted: widget.onSubmitted,
            ),
          ),
          if (widget.showClearButton && _controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
                setState(() {});
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 8),
            widget.trailing!,
          ],
        ],
      ),
    );
  }
}

/// A connected search bar that works with the search provider.
class ConnectedSearchBar extends ConsumerStatefulWidget {
  /// Hint text.
  final String hintText;

  /// Auto focus.
  final bool autoFocus;

  /// Debounce duration for suggestions.
  final Duration debounceDuration;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  const ConnectedSearchBar({
    super.key,
    this.hintText = 'Search products...',
    this.autoFocus = false,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.backgroundColor,
    this.borderRadius = 12.0,
  });

  @override
  ConsumerState<ConnectedSearchBar> createState() => _ConnectedSearchBarState();
}

class _ConnectedSearchBarState extends ConsumerState<ConnectedSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autoFocus,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                ref.read(searchProvider.notifier).setQuery(value);
                ref.read(searchProvider.notifier).getSuggestions(value);
              },
              onSubmitted: (_) {
                ref.read(searchProvider.notifier).search();
              },
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                _controller.clear();
                ref.read(searchProvider.notifier).clearQuery();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

/// A widget to display search suggestions.
class SearchSuggestionsWidget extends StatelessWidget {
  /// List of suggestions.
  final List<SearchSuggestion> suggestions;

  /// Callback when a suggestion is selected.
  final ValueChanged<SearchSuggestion>? onSuggestionSelected;

  /// Max items to show.
  final int maxItems;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  const SearchSuggestionsWidget({
    super.key,
    required this.suggestions,
    this.onSuggestionSelected,
    this.maxItems = 5,
    this.backgroundColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final displaySuggestions = suggestions.take(maxItems).toList();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: displaySuggestions.map((suggestion) {
          return ListTile(
            leading: Icon(_getIconForType(suggestion.type)),
            title: Text(suggestion.text),
            subtitle: suggestion.count != null
                ? Text('${suggestion.count} results')
                : null,
            trailing: suggestion.type == SuggestionType.recent
                ? const Icon(Icons.north_west, size: 16)
                : null,
            onTap: () => onSuggestionSelected?.call(suggestion),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForType(SuggestionType type) {
    switch (type) {
      case SuggestionType.query:
        return Icons.search;
      case SuggestionType.product:
        return Icons.shopping_bag_outlined;
      case SuggestionType.category:
        return Icons.category_outlined;
      case SuggestionType.brand:
        return Icons.store_outlined;
      case SuggestionType.recent:
        return Icons.history;
      case SuggestionType.popular:
        return Icons.trending_up;
    }
  }
}

/// A widget to display recent searches.
class RecentSearchesWidget extends StatelessWidget {
  /// List of recent searches.
  final List<String> recentSearches;

  /// Callback when a search is selected.
  final ValueChanged<String>? onSearchSelected;

  /// Callback when a search is removed.
  final ValueChanged<String>? onSearchRemoved;

  /// Callback to clear all searches.
  final VoidCallback? onClearAll;

  /// Title.
  final String title;

  /// Max items to show.
  final int maxItems;

  const RecentSearchesWidget({
    super.key,
    required this.recentSearches,
    this.onSearchSelected,
    this.onSearchRemoved,
    this.onClearAll,
    this.title = 'Recent Searches',
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final displaySearches = recentSearches.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onClearAll != null)
                TextButton(
                  onPressed: onClearAll,
                  child: const Text('Clear All'),
                ),
            ],
          ),
        ),
        ...displaySearches.map((search) {
          return ListTile(
            leading: const Icon(Icons.history, size: 20),
            title: Text(search),
            trailing: onSearchRemoved != null
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => onSearchRemoved?.call(search),
                  )
                : null,
            onTap: () => onSearchSelected?.call(search),
          );
        }),
      ],
    );
  }
}

/// A connected recent searches widget.
class ConnectedRecentSearchesWidget extends ConsumerWidget {
  /// Title.
  final String title;

  /// Max items to show.
  final int maxItems;

  const ConnectedRecentSearchesWidget({
    super.key,
    this.title = 'Recent Searches',
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSearches = ref.watch(recentSearchesProvider);
    final notifier = ref.read(searchProvider.notifier);

    return RecentSearchesWidget(
      recentSearches: recentSearches,
      title: title,
      maxItems: maxItems,
      onSearchSelected: (search) {
        notifier.setQuery(search);
        notifier.search();
      },
      onSearchRemoved: notifier.removeRecentSearch,
      onClearAll: notifier.clearRecentSearches,
    );
  }
}

/// A widget to display sort options.
class SortOptionsWidget extends StatelessWidget {
  /// Currently selected sort option.
  final SortOption selectedOption;

  /// Available sort options.
  final List<SortOption> options;

  /// Callback when option is selected.
  final ValueChanged<SortOption>? onOptionSelected;

  /// Display as dropdown or chips.
  final bool asDropdown;

  const SortOptionsWidget({
    super.key,
    required this.selectedOption,
    this.options = SortOption.values,
    this.onOptionSelected,
    this.asDropdown = true,
  });

  @override
  Widget build(BuildContext context) {
    if (asDropdown) {
      return DropdownButton<SortOption>(
        value: selectedOption,
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option.label),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onOptionSelected?.call(value);
          }
        },
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selectedOption;
        return ChoiceChip(
          label: Text(option.shortLabel),
          selected: isSelected,
          onSelected: (_) => onOptionSelected?.call(option),
        );
      }).toList(),
    );
  }
}

/// A connected sort options widget.
class ConnectedSortOptionsWidget extends ConsumerWidget {
  /// Available sort options.
  final List<SortOption> options;

  /// Display as dropdown or chips.
  final bool asDropdown;

  /// Whether to sort locally or trigger new search.
  final bool sortLocally;

  const ConnectedSortOptionsWidget({
    super.key,
    this.options = SortOption.values,
    this.asDropdown = true,
    this.sortLocally = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider);
    final notifier = ref.read(searchProvider.notifier);

    return SortOptionsWidget(
      selectedOption: filter.sortBy,
      options: options,
      asDropdown: asDropdown,
      onOptionSelected: (option) {
        if (sortLocally) {
          notifier.sortResultsLocally(option);
        } else {
          notifier.setSortOption(option);
          notifier.search();
        }
      },
    );
  }
}

/// A widget to display active filters as chips.
class ActiveFiltersWidget extends StatelessWidget {
  /// The current filter.
  final ProductFilter filter;

  /// Callback when a filter is removed.
  final void Function(ProductFilter updatedFilter)? onFilterRemoved;

  /// Callback to clear all filters.
  final VoidCallback? onClearAll;

  const ActiveFiltersWidget({
    super.key,
    required this.filter,
    this.onFilterRemoved,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (!filter.hasActiveFilters) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final chips = <Widget>[];

    // Query chip
    if (filter.hasQuery) {
      chips.add(
        _buildChip(
          context,
          'Search: ${filter.query}',
          () => onFilterRemoved?.call(filter.copyWith(clearQuery: true)),
        ),
      );
    }

    // Category chips
    for (final categoryId in filter.categoryIds) {
      chips.add(
        _buildChip(
          context,
          'Category: $categoryId',
          () => onFilterRemoved?.call(filter.removeCategory(categoryId)),
        ),
      );
    }

    // Price range chip
    if (filter.hasPriceRange) {
      final priceText = filter.minPrice != null && filter.maxPrice != null
          ? '${filter.minPrice!.formatted} - ${filter.maxPrice!.formatted}'
          : filter.minPrice != null
              ? 'From ${filter.minPrice!.formatted}'
              : 'Up to ${filter.maxPrice!.formatted}';
      chips.add(
        _buildChip(
          context,
          priceText,
          () => onFilterRemoved?.call(
            filter.copyWith(clearMinPrice: true, clearMaxPrice: true),
          ),
        ),
      );
    }

    // On sale chip
    if (filter.onSaleOnly) {
      chips.add(
        _buildChip(
          context,
          'On Sale',
          () => onFilterRemoved?.call(filter.copyWith(onSaleOnly: false)),
        ),
      );
    }

    // In stock chip
    if (filter.inStockOnly) {
      chips.add(
        _buildChip(
          context,
          'In Stock',
          () => onFilterRemoved?.call(filter.copyWith(inStockOnly: false)),
        ),
      );
    }

    // Featured chip
    if (filter.featuredOnly) {
      chips.add(
        _buildChip(
          context,
          'Featured',
          () => onFilterRemoved?.call(filter.copyWith(featuredOnly: false)),
        ),
      );
    }

    // Tag chips
    for (final tag in filter.tags) {
      chips.add(
        _buildChip(
          context,
          tag,
          () => onFilterRemoved?.call(filter.removeTag(tag)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Filters (${filter.activeFilterCount})',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onClearAll != null)
              TextButton(
                onPressed: onClearAll,
                child: const Text('Clear All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    VoidCallback? onRemove,
  ) {
    return Chip(
      label: Text(label),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 16),
    );
  }
}

/// A connected active filters widget.
class ConnectedActiveFiltersWidget extends ConsumerWidget {
  const ConnectedActiveFiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider);
    final notifier = ref.read(searchProvider.notifier);

    return ActiveFiltersWidget(
      filter: filter,
      onFilterRemoved: notifier.setFilter,
      onClearAll: notifier.clearFilter,
    );
  }
}

/// A widget to display search results count.
class SearchResultsCountWidget extends StatelessWidget {
  /// Total count.
  final int totalCount;

  /// Current showing count.
  final int showingCount;

  /// Search time in milliseconds.
  final int? searchTimeMs;

  const SearchResultsCountWidget({
    super.key,
    required this.totalCount,
    required this.showingCount,
    this.searchTimeMs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String text = '$totalCount result${totalCount == 1 ? '' : 's'}';
    if (searchTimeMs != null) {
      text += ' (${searchTimeMs}ms)';
    }

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// A connected search results count widget.
class ConnectedSearchResultsCountWidget extends ConsumerWidget {
  const ConnectedSearchResultsCountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);

    if (results == null) return const SizedBox.shrink();

    return SearchResultsCountWidget(
      totalCount: results.totalItems,
      showingCount: results.items.length,
      searchTimeMs: results.searchTimeMs,
    );
  }
}

/// A filter bottom sheet widget.
class FilterBottomSheet extends StatefulWidget {
  /// Initial filter.
  final ProductFilter initialFilter;

  /// Available filters.
  final AvailableFilters? availableFilters;

  /// Callback when filter is applied.
  final ValueChanged<ProductFilter>? onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
    this.availableFilters,
    this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ProductFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filter = const ProductFilter.none();
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Toggle filters
          SwitchListTile(
            title: const Text('On Sale Only'),
            value: _filter.onSaleOnly,
            onChanged: (value) {
              setState(() {
                _filter = _filter.copyWith(onSaleOnly: value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('In Stock Only'),
            value: _filter.inStockOnly,
            onChanged: (value) {
              setState(() {
                _filter = _filter.copyWith(inStockOnly: value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Featured Only'),
            value: _filter.featuredOnly,
            onChanged: (value) {
              setState(() {
                _filter = _filter.copyWith(featuredOnly: value);
              });
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onApply?.call(_filter);
                Navigator.of(context).pop();
              },
              child: Text(
                'Apply Filters (${_filter.activeFilterCount})',
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Shows the filter bottom sheet.
Future<ProductFilter?> showFilterBottomSheet(
  BuildContext context, {
  required ProductFilter currentFilter,
  AvailableFilters? availableFilters,
}) {
  return showModalBottomSheet<ProductFilter>(
    context: context,
    isScrollControlled: true,
    builder: (context) => FilterBottomSheet(
      initialFilter: currentFilter,
      availableFilters: availableFilters,
      onApply: (filter) => Navigator.of(context).pop(filter),
    ),
  );
}
