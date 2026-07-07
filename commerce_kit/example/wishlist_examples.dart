// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../commerce_kit.dart';

/// Examples demonstrating the Wishlist System functionality.
///
/// This file shows how to:
/// - Create and manage wishlists
/// - Add/remove products from wishlist
/// - Configure price drop notifications
/// - Use wishlist adapters for API integration
class WishlistExamples {
  /// Run all wishlist examples.
  static void runAll() {
    print('\n════════════════════════════════════════════════════════════════');
    print('WISHLIST SYSTEM EXAMPLES');
    print('════════════════════════════════════════════════════════════════\n');

    _modelExamples();
    _adapterExamples();
    _notificationExamples();
  }

  /// Examples of using Wishlist models directly.
  static void _modelExamples() {
    print('▶ Model Examples');
    print('─' * 60);

    // Create an empty wishlist
    final wishlist = Wishlist.empty(userId: 'user_123');
    print('  Created empty wishlist: ${wishlist.name}');
    print('  Item count: ${wishlist.itemCount}');

    // Create a sample product
    const product = Product(
      id: 'burger_deluxe',
      name: 'Deluxe Burger',
      description: 'A premium burger with all the fixings',
      price: Money(25.99),
      images: [
        ProductImage(
          id: 'img1',
          url: 'https://example.com/burger.jpg',
          altText: 'Deluxe Burger',
        ),
      ],
    );

    // Add product to wishlist
    final updatedWishlist =
        wishlist.addProduct(product, note: 'Want to try this!');
    print('\n  After adding product:');
    print('  Item count: ${updatedWishlist.itemCount}');
    print(
      '  Contains burger: ${updatedWishlist.containsProduct('burger_deluxe')}',
    );

    // Get wishlist item
    final item = updatedWishlist.getItem('burger_deluxe');
    if (item != null) {
      print('\n  Wishlist item details:');
      print('  Product: ${item.productName}');
      print('  Note: ${item.note}');
      print('  Added at: ${item.addedAt}');
      print('  Is on sale: ${item.isOnSale}');
    }

    // Remove product from wishlist
    final afterRemove = updatedWishlist.removeProduct('burger_deluxe');
    print('\n  After removing product:');
    print('  Item count: ${afterRemove.itemCount}');
  }

  /// Examples of using Wishlist adapters for API integration.
  static void _adapterExamples() {
    print('\n▶ Adapter Examples');
    print('─' * 60);

    // Example API response for wishlist
    final apiResponse = {
      'id': 'wishlist_001',
      'user_id': 'user_123',
      'name': 'My Favorites',
      'description': 'Products I want to buy',
      'items': [
        {
          'id': 'item_001',
          'product_id': 'burger_classic',
          'note': 'For weekend',
          'priority': 1,
          'added_at': '2025-01-15T10:30:00Z',
          'is_purchased': false,
          'notification': {
            'on_price_drop': true,
            'price_drop_threshold': 10.0,
            'on_back_in_stock': true,
            'on_sale': true,
          },
        },
        {
          'id': 'item_002',
          'product_id': 'fries_large',
          'priority': 2,
          'added_at': '2025-01-16T14:00:00Z',
          'is_purchased': false,
        },
      ],
      'is_default': true,
      'is_public': false,
      'created_at': '2025-01-10T09:00:00Z',
      'updated_at': '2025-01-16T14:00:00Z',
    };

    // Parse using default adapter
    final adapter = JsonWishlistAdapter();
    final wishlist = adapter.fromResponse(apiResponse);

    print('  Parsed wishlist:');
    print('  Name: ${wishlist.name}');
    print('  Description: ${wishlist.description}');
    print('  Items: ${wishlist.itemCount}');
    print('  Is default: ${wishlist.isDefault}');

    // Access items
    for (final item in wishlist.items) {
      print('\n  Item: ${item.productId}');
      print('    Priority: ${item.priority}');
      print('    Has notification: ${item.notification != null}');
      if (item.notification != null) {
        print('    Price drop alert: ${item.notification!.onPriceDrop}');
      }
    }

    // Convert back to JSON
    final json = adapter.toResponse(wishlist);
    print('\n  Converted back to JSON successfully');
  }

  /// Examples of wishlist notifications.
  static void _notificationExamples() {
    print('\n▶ Notification Examples');
    print('─' * 60);

    // Create notification settings
    const notification = WishlistNotification(
      onPriceDrop: true,
      priceDropThreshold: 15.0, // Alert when price drops 15% or more
      onBackInStock: true,
      onSale: true,
    );

    print('  Notification settings:');
    print('  Price drop alert: ${notification.onPriceDrop}');
    print('  Threshold: ${notification.priceDropThreshold}%');
    print('  Back in stock: ${notification.onBackInStock}');
    print('  On sale: ${notification.onSale}');

    // Use predefined notification settings
    print('\n  Predefined settings:');
    print(
      '  Defaults: Price drop=${WishlistNotification.defaults.onPriceDrop}',
    );
    print('  All enabled: Price drop=${WishlistNotification.all.onPriceDrop}');
    print('  None: Price drop=${WishlistNotification.none.onPriceDrop}');

    // Create wishlist item with notification
    final item = WishlistItem(
      id: 'item_001',
      productId: 'burger_special',
      note: 'Wait for sale',
      addedAt: DateTime.now(),
      notification: notification,
    );

    print('\n  Created item with notifications:');
    print('  Product: ${item.productId}');
    print('  Notification configured: ${item.notification != null}');
  }
}

/// Example of using WishlistProvider in a widget.
///
/// ```dart
/// class WishlistScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final wishlistState = ref.watch(wishlistProvider);
///     final itemCount = ref.watch(wishlistCountProvider);
///
///     return Scaffold(
///       appBar: AppBar(
///         title: Text('Wishlist ($itemCount)'),
///       ),
///       body: wishlistState.isLoading
///           ? const CircularProgressIndicator()
///           : ListView.builder(
///               itemCount: wishlistState.items.length,
///               itemBuilder: (ctx, i) {
///                 final item = wishlistState.items[i];
///                 return WishlistItemCard(
///                   item: item,
///                   onRemove: () {
///                     ref.read(wishlistProvider.notifier)
///                         .removeProduct(item.productId);
///                   },
///                 );
///               },
///             ),
///     );
///   }
/// }
/// ```
void wishlistProviderUsageExample(WidgetRef ref) {
  // Get the wishlist notifier
  final notifier = ref.read(wishlistProvider.notifier);

  // Create a sample product
  const product = Product(
    id: 'burger_new',
    name: 'New Burger',
    description: 'Try our newest burger',
    price: Money(19.99),
  );

  // Add product to wishlist
  notifier.addProduct(product);

  // Add with note
  notifier.addProduct(product, note: 'Want to try this soon!');

  // Check if product is in wishlist
  final isInWishlist = ref.read(isInWishlistProvider('burger_new'));
  print('Is in wishlist: $isInWishlist');

  // Toggle wishlist (add if not in, remove if in)
  notifier.toggleProduct(product);

  // Remove product
  notifier.removeProduct('burger_new');

  // Get wishlist count
  final count = ref.read(wishlistItemCountProvider);
  print('Wishlist count: $count');

  // Get items on sale
  final onSaleItems = ref.read(onSaleWishlistItemsProvider);
  print('Items on sale: ${onSaleItems.length}');

  // Clear wishlist
  notifier.clear();
}

/// Example of a wishlist toggle button widget.
///
/// ```dart
/// class WishlistButton extends ConsumerWidget {
///   final Product product;
///
///   const WishlistButton({required this.product});
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final isInWishlist = ref.watch(isInWishlistProvider(product.id));
///
///     return IconButton(
///       icon: Icon(
///         isInWishlist ? Icons.favorite : Icons.favorite_border,
///         color: isInWishlist ? Colors.red : null,
///       ),
///       onPressed: () {
///         ref.read(wishlistProvider.notifier).toggleProduct(product);
///       },
///     );
///   }
/// }
/// ```
