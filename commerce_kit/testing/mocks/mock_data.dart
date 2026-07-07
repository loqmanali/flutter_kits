import '../../core/enums/order_status.dart';
import '../../core/enums/payment_method.dart';
import '../../core/enums/payment_status.dart';
import '../../core/enums/stock_status.dart';
import '../../core/models/cart.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/category.dart';
import '../../core/models/money.dart';
import '../../core/models/order.dart';
import '../../core/models/order_item.dart';
import '../../core/models/order_summary.dart';
import '../../core/models/product.dart';
import '../../core/models/product_image.dart';
import '../../core/models/review.dart';
import '../../core/models/shipping_address.dart';

/// Mock data generators for testing.
class MockData {
  MockData._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a mock product.
  static Product product({
    String? id,
    String? name,
    String? description,
    Money? price,
    Money? compareAtPrice,
    List<ProductImage>? images,
    StockStatus? stockStatus,
    int? stockQuantity,
    String? categoryId,
  }) {
    final productId = id ?? 'product_${DateTime.now().millisecondsSinceEpoch}';
    return Product(
      id: productId,
      name: name ?? 'Test Product',
      description: description ?? 'A test product description',
      price: price ?? const Money(29.99),
      compareAtPrice: compareAtPrice,
      images: images ??
          [
            const ProductImage(
              id: 'img_1',
              url: 'https://example.com/product.jpg',
              altText: 'Product image',
            ),
          ],
      stockStatus: stockStatus ?? StockStatus.inStock,
      stockQuantity: stockQuantity ?? 100,
      categoryIds: categoryId != null ? [categoryId] : [],
    );
  }

  /// Creates a list of mock products.
  static List<Product> products({int count = 5}) {
    return List.generate(
      count,
      (i) => product(
        id: 'product_$i',
        name: 'Product ${i + 1}',
        price: Money(9.99 + (i * 10)),
      ),
    );
  }

  /// Creates a mock product with variants.
  static Product productWithVariants({
    String? id,
    String? name,
  }) {
    return product(
      id: id ?? 'product_with_variants',
      name: name ?? 'Product with Variants',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a mock category.
  static Category category({
    String? id,
    String? name,
    String? description,
    String? parentId,
    int? productCount,
  }) {
    return Category(
      id: id ?? 'category_${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Category',
      description: description ?? 'A test category',
      parentId: parentId,
      productCount: productCount ?? 10,
    );
  }

  /// Creates a list of mock categories.
  static List<Category> categories({int count = 3}) {
    return List.generate(
      count,
      (i) => category(
        id: 'category_$i',
        name: 'Category ${i + 1}',
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CART
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a mock cart item.
  static CartItem cartItem({
    String? id,
    String? productId,
    String? name,
    int? quantity,
    Money? price,
    ProductImage? image,
  }) {
    return CartItem(
      id: id ?? 'cart_item_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId ?? 'product_1',
      name: name ?? 'Cart Item',
      quantity: quantity ?? 1,
      price: price ?? const Money(19.99),
      image: image ??
          const ProductImage(
            id: 'img_1',
            url: 'https://example.com/item.jpg',
          ),
    );
  }

  /// Creates a mock cart with items.
  static Cart cart({
    String? id,
    List<CartItem>? items,
    String? couponCode,
  }) {
    return Cart(
      id: id ?? 'cart_${DateTime.now().millisecondsSinceEpoch}',
      items: items ??
          [
            cartItem(id: 'item_1', name: 'Item 1', quantity: 2),
            cartItem(id: 'item_2', name: 'Item 2', quantity: 1),
          ],
      couponCode: couponCode,
    );
  }

  /// Creates an empty cart.
  static Cart emptyCart({String? id}) {
    return Cart(
      id: id ?? 'empty_cart',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a mock order item.
  static OrderItem orderItem({
    String? id,
    String? productId,
    String? name,
    int? quantity,
    Money? unitPrice,
  }) {
    return OrderItem(
      id: id ?? 'order_item_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId ?? 'product_1',
      name: name ?? 'Order Item',
      quantity: quantity ?? 1,
      unitPrice: unitPrice ?? const Money(19.99),
    );
  }

  /// Creates a mock order summary.
  static OrderSummary orderSummary({
    Money? subtotal,
    Money? shippingCost,
    Money? tax,
    Money? orderDiscount,
  }) {
    return OrderSummary(
      subtotal: subtotal ?? const Money(59.97),
      shippingCost: shippingCost ?? const Money(5.00),
      tax: tax ?? const Money(6.00),
      orderDiscount: orderDiscount ?? const Money.zero(),
    );
  }

  /// Creates a mock order.
  static Order order({
    String? id,
    String? orderNumber,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    List<OrderItem>? items,
    OrderSummary? summary,
    ShippingAddress? shippingAddress,
    DateTime? createdAt,
  }) {
    final now = DateTime.now();
    return Order(
      id: id ?? 'order_${now.millisecondsSinceEpoch}',
      orderNumber: orderNumber ?? 'ORD-${now.millisecondsSinceEpoch}',
      status: status ?? OrderStatus.pending,
      paymentStatus: paymentStatus ?? PaymentStatus.pending,
      paymentMethod: paymentMethod ?? PaymentMethod.card,
      items: items ??
          [
            orderItem(id: 'item_1', name: 'Order Item 1'),
            orderItem(id: 'item_2', name: 'Order Item 2'),
          ],
      summary: summary ?? orderSummary(),
      shippingAddress: shippingAddress ?? MockData.shippingAddress(),
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
  }

  /// Creates a list of mock orders.
  static List<Order> orders({int count = 3}) {
    return List.generate(
      count,
      (i) => order(
        id: 'order_$i',
        orderNumber: 'ORD-${1000 + i}',
        status: OrderStatus.values[i % OrderStatus.values.length],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADDRESSES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a mock shipping address.
  static ShippingAddress shippingAddress({
    String? id,
    String? fullName,
    String? phone,
    String? addressLine1,
    String? city,
    String? country,
  }) {
    return ShippingAddress(
      id: id ?? 'address_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName ?? 'John Doe',
      phone: phone ?? '+1234567890',
      addressLine1: addressLine1 ?? '123 Test Street',
      city: city ?? 'Test City',
      country: country ?? 'Egypt',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REVIEWS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a mock review.
  static Review review({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    double? rating,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    final now = DateTime.now();
    return Review(
      id: id ?? 'review_${now.millisecondsSinceEpoch}',
      productId: productId ?? 'product_1',
      userId: userId ?? 'user_1',
      userName: userName ?? 'Test User',
      rating: rating ?? 4.0,
      title: title ?? 'Great product!',
      content:
          content ?? 'This is a test review with enough content to be valid.',
      createdAt: createdAt ?? now,
    );
  }

  /// Creates mock rating stats.
  static RatingStats ratingStats({
    String? productId,
    double? averageRating,
    int? totalReviews,
    Map<int, int>? distribution,
  }) {
    return RatingStats(
      productId: productId ?? 'product_1',
      averageRating: averageRating ?? 4.2,
      totalReviews: totalReviews ?? 150,
      distribution: distribution ??
          const {
            5: 80,
            4: 40,
            3: 15,
            2: 10,
            1: 5,
          },
    );
  }

  /// Creates a list of mock reviews.
  static List<Review> reviews({int count = 5, String? productId}) {
    return List.generate(
      count,
      (i) => review(
        id: 'review_$i',
        productId: productId ?? 'product_1',
        rating: ((i % 5) + 1).toDouble(),
        userName: 'User ${i + 1}',
      ),
    );
  }
}
