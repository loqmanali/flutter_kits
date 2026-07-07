import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';

/// Configuration for the search results list appearance.
///
/// Customize item styling, icons, and empty state messages.
class SearchResultsListConfig {
  /// Message shown when no results are found.
  final String emptyMessage;

  /// Message shown when search hasn't started.
  final String initialMessage;

  /// Icon shown for each result item.
  final IconData resultIcon;

  /// Background color of the results list.
  final Color? backgroundColor;

  /// Whether to show result type/category.
  final bool showResultType;

  /// Maximum number of results to display.
  final int maxResults;

  /// Creates a new [SearchResultsListConfig].
  const SearchResultsListConfig({
    this.emptyMessage = 'No locations found',
    this.initialMessage = 'Start typing to search',
    this.resultIcon = Icons.location_on_outlined,
    this.backgroundColor,
    this.showResultType = true,
    this.maxResults = 10,
  });
}

/// A list widget displaying search results.
///
/// Shows location search results with icons and addresses,
/// handles empty states, and triggers selection on tap.
///
/// ## Usage
///
/// ```dart
/// SearchResultsList(
///   config: SearchResultsListConfig(
///     emptyMessage: 'No places found',
///     showResultType: true,
///   ),
///   onResultSelected: (result) {
///     // Handle selection
///   },
/// )
/// ```
///
/// ## Features
///
/// - Displays search results with icons and addresses
/// - Shows loading indicator during search
/// - Handles empty and initial states
/// - Customizable appearance
class SearchResultsList extends ConsumerWidget {
  /// List configuration.
  final SearchResultsListConfig config;

  /// Called when a result is selected.
  final void Function(SearchResult result)? onResultSelected;

  /// Custom builder for result items.
  final Widget Function(BuildContext, SearchResult, int)? itemBuilder;

  /// Custom builder for empty state.
  final Widget Function(BuildContext)? emptyBuilder;

  /// Creates a new [SearchResultsList].
  const SearchResultsList({
    super.key,
    this.config = const SearchResultsListConfig(),
    this.onResultSelected,
    this.itemBuilder,
    this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationPickerProvider);

    // Show initial message if no search has been performed
    if (state.searchQuery.isEmpty && state.searchResults.isEmpty) {
      return _buildEmptyState(context, config.initialMessage);
    }

    // Show loading indicator
    if (state.isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show empty message if no results
    if (state.searchResults.isEmpty) {
      if (emptyBuilder != null) {
        return emptyBuilder!(context);
      }
      return _buildEmptyState(context, config.emptyMessage);
    }

    // Show results
    final results = state.searchResults.take(config.maxResults).toList();

    return Container(
      color:
          config.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final result = results[index];

          if (itemBuilder != null) {
            return itemBuilder!(context, result, index);
          }

          return _buildResultItem(context, ref, result);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 48,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(
      BuildContext context, WidgetRef ref, SearchResult result,) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getIconForType(result.type),
          color: theme.primaryColor,
        ),
      ),
      title: Text(
        result.location.displayName ?? 'Unknown Location',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: config.showResultType && result.type != null
          ? Text(
              _formatResultType(result.type!, result.category),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            )
          : null,
      onTap: () {
        if (onResultSelected != null) {
          onResultSelected!(result);
        } else {
          ref.read(locationPickerProvider.notifier).selectSearchResult(result);
        }
      },
    );
  }

  IconData _getIconForType(String? type) {
    if (type == null) return config.resultIcon;

    switch (type.toLowerCase()) {
      case 'house':
      case 'residential':
      case 'apartments':
        return Icons.home;
      case 'restaurant':
      case 'cafe':
      case 'fast_food':
        return Icons.restaurant;
      case 'hospital':
      case 'clinic':
      case 'pharmacy':
        return Icons.local_hospital;
      case 'school':
      case 'university':
      case 'college':
        return Icons.school;
      case 'shop':
      case 'supermarket':
      case 'mall':
        return Icons.shopping_bag;
      case 'bank':
      case 'atm':
        return Icons.account_balance;
      case 'hotel':
      case 'motel':
        return Icons.hotel;
      case 'park':
      case 'garden':
        return Icons.park;
      case 'bus_station':
      case 'train_station':
      case 'subway':
        return Icons.directions_transit;
      case 'airport':
        return Icons.flight;
      case 'gas_station':
      case 'fuel':
        return Icons.local_gas_station;
      case 'parking':
        return Icons.local_parking;
      case 'mosque':
      case 'church':
      case 'place_of_worship':
        return Icons.place;
      default:
        return config.resultIcon;
    }
  }

  String _formatResultType(String type, String? category) {
    final formattedType = type
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');

    if (category != null && category != type) {
      return '$formattedType • $category';
    }

    return formattedType;
  }
}
