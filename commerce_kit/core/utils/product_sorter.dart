import 'dart:math';

import '../enums/sort_option.dart';
import '../models/product.dart';

/// Utility class for sorting products.
class ProductSorter {
  ProductSorter._();

  /// Sorts a list of products by the given sort option.
  static List<Product> sort(List<Product> products, SortOption sortBy) {
    if (products.isEmpty) return products;

    final sorted = List<Product>.from(products);

    switch (sortBy) {
      case SortOption.relevance:
        // Keep original order (relevance is typically from search)
        return sorted;

      case SortOption.nameAsc:
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;

      case SortOption.nameDesc:
        sorted.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;

      case SortOption.priceLowToHigh:
        sorted.sort((a, b) => a.price.amount.compareTo(b.price.amount));
        break;

      case SortOption.priceHighToLow:
        sorted.sort((a, b) => b.price.amount.compareTo(a.price.amount));
        break;

      case SortOption.newest:
        sorted.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        break;

      case SortOption.oldest:
        sorted.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          return aDate.compareTo(bDate);
        });
        break;

      case SortOption.popularity:
        sorted.sort((a, b) {
          final aPopularity = a.metadata?['popularity'] as int? ?? 0;
          final bPopularity = b.metadata?['popularity'] as int? ?? 0;
          return bPopularity.compareTo(aPopularity);
        });
        break;

      case SortOption.rating:
        sorted.sort((a, b) {
          final aRating = a.rating ?? 0.0;
          final bRating = b.rating ?? 0.0;
          return bRating.compareTo(aRating);
        });
        break;

      case SortOption.discount:
        sorted.sort((a, b) {
          final aDiscount = _calculateDiscountPercent(a);
          final bDiscount = _calculateDiscountPercent(b);
          return bDiscount.compareTo(aDiscount);
        });
        break;

      case SortOption.bestSelling:
        sorted.sort((a, b) {
          final aSales = a.metadata?['sales_count'] as int? ?? 0;
          final bSales = b.metadata?['sales_count'] as int? ?? 0;
          return bSales.compareTo(aSales);
        });
        break;

      case SortOption.featured:
        sorted.sort((a, b) {
          final aFeatured = a.isFeatured ? 1 : 0;
          final bFeatured = b.isFeatured ? 1 : 0;
          if (aFeatured != bFeatured) return bFeatured.compareTo(aFeatured);
          // Secondary sort by name for featured items
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;

      case SortOption.random:
        sorted.shuffle(Random());
        break;
    }

    return sorted;
  }

  /// Sorts products with a secondary sort option.
  static List<Product> sortWithSecondary(
    List<Product> products,
    SortOption primary,
    SortOption secondary,
  ) {
    // First apply primary sort
    var sorted = sort(products, primary);

    // Group by primary sort key and apply secondary within groups
    // This is a simplified implementation - for complex sorting,
    // consider using a custom comparator
    if (primary == SortOption.featured) {
      final featured = sorted.where((p) => p.isFeatured).toList();
      final notFeatured = sorted.where((p) => !p.isFeatured).toList();
      sorted = [...sort(featured, secondary), ...sort(notFeatured, secondary)];
    }

    return sorted;
  }

  /// Creates a comparator for the given sort option.
  static Comparator<Product> comparator(SortOption sortBy) {
    switch (sortBy) {
      case SortOption.nameAsc:
        return (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());

      case SortOption.nameDesc:
        return (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase());

      case SortOption.priceLowToHigh:
        return (a, b) => a.price.amount.compareTo(b.price.amount);

      case SortOption.priceHighToLow:
        return (a, b) => b.price.amount.compareTo(a.price.amount);

      case SortOption.newest:
        return (a, b) {
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          return bDate.compareTo(aDate);
        };

      case SortOption.oldest:
        return (a, b) {
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          return aDate.compareTo(bDate);
        };

      case SortOption.discount:
        return (a, b) {
          final aDiscount = _calculateDiscountPercent(a);
          final bDiscount = _calculateDiscountPercent(b);
          return bDiscount.compareTo(aDiscount);
        };

      default:
        return (a, b) => 0; // No sorting
    }
  }

  /// Calculates discount percentage for a product.
  static double _calculateDiscountPercent(Product product) {
    if (product.compareAtPrice == null || product.compareAtPrice!.isZero) {
      return 0;
    }
    final original = product.compareAtPrice!.amount;
    final current = product.price.amount;
    if (original <= current) return 0;
    return ((original - current) / original) * 100;
  }
}

/// Extension for sorting product lists.
extension ProductListSortExtension on List<Product> {
  /// Sorts products by the given option.
  List<Product> sortedBy(SortOption sortBy) {
    return ProductSorter.sort(this, sortBy);
  }

  /// Sorts by price low to high.
  List<Product> sortedByPriceAsc() {
    return ProductSorter.sort(this, SortOption.priceLowToHigh);
  }

  /// Sorts by price high to low.
  List<Product> sortedByPriceDesc() {
    return ProductSorter.sort(this, SortOption.priceHighToLow);
  }

  /// Sorts by name A-Z.
  List<Product> sortedByNameAsc() {
    return ProductSorter.sort(this, SortOption.nameAsc);
  }

  /// Sorts by newest first.
  List<Product> sortedByNewest() {
    return ProductSorter.sort(this, SortOption.newest);
  }

  /// Sorts by rating.
  List<Product> sortedByRating() {
    return ProductSorter.sort(this, SortOption.rating);
  }

  /// Shuffles randomly.
  List<Product> shuffled() {
    return ProductSorter.sort(this, SortOption.random);
  }
}
