/// Types of categories in an e-commerce system.
///
/// Categories can serve different purposes and have different behaviors
/// based on their type.
enum CategoryType {
  /// Standard product category.
  /// Used for organizing products into logical groups.
  standard,

  /// Featured category that appears prominently.
  /// Usually displayed on homepage or special sections.
  featured,

  /// Sale/promotion category.
  /// Contains products that are on sale or part of a promotion.
  sale,

  /// New arrivals category.
  /// Contains recently added products.
  newArrivals,

  /// Best sellers category.
  /// Contains top-selling products.
  bestSellers,

  /// Seasonal category.
  /// Categories that are only relevant during certain seasons.
  seasonal,

  /// Collection category.
  /// A curated collection of products (e.g., "Summer Collection").
  collection,

  /// Brand category.
  /// Categories organized by brand/manufacturer.
  brand,

  /// Virtual/filter category.
  /// Not a real category but used for filtering (e.g., "Under $50").
  virtual,

  /// Menu category.
  /// Used for navigation menus, may not contain products directly.
  menu,

  /// Hidden category.
  /// Not visible to customers but used internally.
  hidden,

  /// Archive category.
  /// Contains discontinued or archived products.
  archive,
}

/// Extension methods for [CategoryType].
extension CategoryTypeExtension on CategoryType {
  /// Returns a human-readable label for this type.
  String get label {
    switch (this) {
      case CategoryType.standard:
        return 'Standard';
      case CategoryType.featured:
        return 'Featured';
      case CategoryType.sale:
        return 'Sale';
      case CategoryType.newArrivals:
        return 'New Arrivals';
      case CategoryType.bestSellers:
        return 'Best Sellers';
      case CategoryType.seasonal:
        return 'Seasonal';
      case CategoryType.collection:
        return 'Collection';
      case CategoryType.brand:
        return 'Brand';
      case CategoryType.virtual:
        return 'Virtual';
      case CategoryType.menu:
        return 'Menu';
      case CategoryType.hidden:
        return 'Hidden';
      case CategoryType.archive:
        return 'Archive';
    }
  }

  /// Returns `true` if this category type is visible to customers.
  bool get isVisible {
    switch (this) {
      case CategoryType.hidden:
      case CategoryType.archive:
      case CategoryType.virtual:
        return false;
      default:
        return true;
    }
  }

  /// Returns `true` if this category type can contain products.
  bool get canContainProducts {
    switch (this) {
      case CategoryType.menu:
      case CategoryType.virtual:
        return false;
      default:
        return true;
    }
  }

  /// Returns `true` if this is a promotional category type.
  bool get isPromotional {
    switch (this) {
      case CategoryType.featured:
      case CategoryType.sale:
      case CategoryType.newArrivals:
      case CategoryType.bestSellers:
      case CategoryType.seasonal:
      case CategoryType.collection:
        return true;
      default:
        return false;
    }
  }

  /// Returns `true` if this category should be highlighted.
  bool get shouldHighlight {
    switch (this) {
      case CategoryType.featured:
      case CategoryType.sale:
      case CategoryType.newArrivals:
        return true;
      default:
        return false;
    }
  }

  /// Returns the default sort order for this type.
  int get defaultSortOrder {
    switch (this) {
      case CategoryType.featured:
        return 0;
      case CategoryType.sale:
        return 1;
      case CategoryType.newArrivals:
        return 2;
      case CategoryType.bestSellers:
        return 3;
      case CategoryType.collection:
        return 4;
      case CategoryType.seasonal:
        return 5;
      case CategoryType.standard:
        return 10;
      case CategoryType.brand:
        return 20;
      case CategoryType.menu:
        return 30;
      case CategoryType.virtual:
        return 40;
      case CategoryType.archive:
        return 50;
      case CategoryType.hidden:
        return 100;
    }
  }

  /// Returns the icon name for this category type.
  String get iconName {
    switch (this) {
      case CategoryType.standard:
        return 'category';
      case CategoryType.featured:
        return 'star';
      case CategoryType.sale:
        return 'local_offer';
      case CategoryType.newArrivals:
        return 'new_releases';
      case CategoryType.bestSellers:
        return 'trending_up';
      case CategoryType.seasonal:
        return 'ac_unit';
      case CategoryType.collection:
        return 'collections';
      case CategoryType.brand:
        return 'business';
      case CategoryType.virtual:
        return 'filter_list';
      case CategoryType.menu:
        return 'menu';
      case CategoryType.hidden:
        return 'visibility_off';
      case CategoryType.archive:
        return 'archive';
    }
  }

  /// Creates a [CategoryType] from a string value.
  static CategoryType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'standard':
      case 'default':
      case 'normal':
        return CategoryType.standard;
      case 'featured':
      case 'highlight':
      case 'promoted':
        return CategoryType.featured;
      case 'sale':
      case 'discount':
      case 'promo':
      case 'promotion':
        return CategoryType.sale;
      case 'new':
      case 'new_arrivals':
      case 'newarrivals':
      case 'latest':
        return CategoryType.newArrivals;
      case 'bestsellers':
      case 'best_sellers':
      case 'popular':
      case 'top':
        return CategoryType.bestSellers;
      case 'seasonal':
      case 'season':
        return CategoryType.seasonal;
      case 'collection':
      case 'curated':
        return CategoryType.collection;
      case 'brand':
      case 'vendor':
      case 'manufacturer':
        return CategoryType.brand;
      case 'virtual':
      case 'filter':
      case 'smart':
        return CategoryType.virtual;
      case 'menu':
      case 'navigation':
      case 'nav':
        return CategoryType.menu;
      case 'hidden':
      case 'private':
      case 'internal':
        return CategoryType.hidden;
      case 'archive':
      case 'archived':
      case 'discontinued':
        return CategoryType.archive;
      default:
        return CategoryType.standard;
    }
  }
}
