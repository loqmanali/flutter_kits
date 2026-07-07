/// Product sort options.
enum SortOption {
  /// Sort by relevance (default for search).
  relevance,

  /// Sort by name A-Z.
  nameAsc,

  /// Sort by name Z-A.
  nameDesc,

  /// Sort by price low to high.
  priceLowToHigh,

  /// Sort by price high to low.
  priceHighToLow,

  /// Sort by newest first.
  newest,

  /// Sort by oldest first.
  oldest,

  /// Sort by popularity (most ordered).
  popularity,

  /// Sort by rating (highest first).
  rating,

  /// Sort by discount percentage (highest first).
  discount,

  /// Sort by best selling.
  bestSelling,

  /// Sort by featured items first.
  featured,

  /// Random order.
  random,
}

/// Extension methods for [SortOption].
extension SortOptionExtension on SortOption {
  /// Display label for the sort option.
  String get label {
    switch (this) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.nameDesc:
        return 'Name (Z-A)';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.newest:
        return 'Newest';
      case SortOption.oldest:
        return 'Oldest';
      case SortOption.popularity:
        return 'Popularity';
      case SortOption.rating:
        return 'Rating';
      case SortOption.discount:
        return 'Discount';
      case SortOption.bestSelling:
        return 'Best Selling';
      case SortOption.featured:
        return 'Featured';
      case SortOption.random:
        return 'Random';
    }
  }

  /// Short label for compact display.
  String get shortLabel {
    switch (this) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.nameAsc:
        return 'A-Z';
      case SortOption.nameDesc:
        return 'Z-A';
      case SortOption.priceLowToHigh:
        return 'Price ↑';
      case SortOption.priceHighToLow:
        return 'Price ↓';
      case SortOption.newest:
        return 'Newest';
      case SortOption.oldest:
        return 'Oldest';
      case SortOption.popularity:
        return 'Popular';
      case SortOption.rating:
        return 'Rating';
      case SortOption.discount:
        return 'Discount';
      case SortOption.bestSelling:
        return 'Best';
      case SortOption.featured:
        return 'Featured';
      case SortOption.random:
        return 'Random';
    }
  }

  /// Whether this sort is based on price.
  bool get isPriceSort =>
      this == SortOption.priceLowToHigh || this == SortOption.priceHighToLow;

  /// Whether this sort is ascending.
  bool get isAscending {
    switch (this) {
      case SortOption.nameAsc:
      case SortOption.priceLowToHigh:
      case SortOption.oldest:
        return true;
      default:
        return false;
    }
  }

  /// API parameter name.
  String get apiParam {
    switch (this) {
      case SortOption.relevance:
        return 'relevance';
      case SortOption.nameAsc:
        return 'name_asc';
      case SortOption.nameDesc:
        return 'name_desc';
      case SortOption.priceLowToHigh:
        return 'price_asc';
      case SortOption.priceHighToLow:
        return 'price_desc';
      case SortOption.newest:
        return 'created_desc';
      case SortOption.oldest:
        return 'created_asc';
      case SortOption.popularity:
        return 'popularity';
      case SortOption.rating:
        return 'rating';
      case SortOption.discount:
        return 'discount';
      case SortOption.bestSelling:
        return 'best_selling';
      case SortOption.featured:
        return 'featured';
      case SortOption.random:
        return 'random';
    }
  }
}
