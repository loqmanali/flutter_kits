# API Integration Guide

A comprehensive guide for integrating Commerce Kit with any backend API, regardless of its response structure.

## Table of Contents

- [Overview](#overview)
- [The Adapter Pattern](#the-adapter-pattern)
- [Step-by-Step Integration](#step-by-step-integration)
  - [Step 1: Analyze Your API Response](#step-1-analyze-your-api-response)
  - [Step 2: Create Your Adapter](#step-2-create-your-adapter)
  - [Step 3: Handle Nested Responses](#step-3-handle-nested-responses)
  - [Step 4: Map Enums and Types](#step-4-map-enums-and-types)
  - [Step 5: Handle Edge Cases](#step-5-handle-edge-cases)
- [Common API Patterns](#common-api-patterns)
  - [REST APIs](#rest-apis)
  - [GraphQL APIs](#graphql-apis)
  - [Firebase/Firestore](#firebasefirestore)
  - [Supabase](#supabase)
- [Pre-built Platform Adapters](#pre-built-platform-adapters)
- [Advanced Techniques](#advanced-techniques)
  - [Composite Adapters](#composite-adapters)
  - [Caching Layer](#caching-layer)
  - [Error Mapping](#error-mapping)
  - [Pagination Handling](#pagination-handling)
- [Testing Your Integration](#testing-your-integration)
- [Troubleshooting](#troubleshooting)
- [Review System Integration](#review-system-integration)
- [Wishlist Integration](#wishlist-integration)
- [Search & Filter Integration](#search--filter-integration)
- [Analytics Integration](#analytics-integration)

---

## Overview

Commerce Kit uses the **Adapter Pattern** to decouple your API response structure from the internal models. This means:

1. **Your API** can return data in any format
2. **Your Adapter** translates it to Commerce Kit models
3. **Commerce Kit** works with its internal models

```
┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
│  Your API   │ ──► │   Adapter   │ ──► │  Commerce Kit   │
│  (any JSON) │     │ (your code) │     │    (models)     │
└─────────────┘     └─────────────┘     └─────────────────┘
```

**Benefits:**
- API changes don't break your app (just update the adapter)
- Easy to switch backends
- Testable in isolation
- Type-safe throughout

---

## The Adapter Pattern

### Base Adapter Interface

```dart
/// Abstract adapter for mapping external types to internal types
abstract class ProductAdapter<T> {
  /// Convert external format to internal Product
  Product fromExternal(T external);

  /// Convert internal Product to external format
  T toExternal(Product product);

  /// Convert list of external items
  List<Product> fromExternalList(List<T> items) {
    return items.map(fromExternal).toList();
  }
}
```

### What Adapters Do

| Method | Purpose | When Called |
|--------|---------|-------------|
| `fromExternal()` | API → Commerce Kit | After fetching data |
| `toExternal()` | Commerce Kit → API | Before sending data |
| `fromExternalList()` | Batch conversion | After fetching lists |

---

## Step-by-Step Integration

### Step 1: Analyze Your API Response

First, understand your API's response structure. Here's an example:

```json
// Your API response
{
  "status": "success",
  "data": {
    "items": [
      {
        "product_id": "p-123",
        "product_name": "Classic Burger",
        "product_desc": "Delicious beef burger",
        "base_price": 1299,  // Price in cents
        "original_price": 1499,
        "currency_code": "USD",
        "is_available": true,
        "stock_qty": 50,
        "category_ids": ["cat-1", "cat-2"],
        "product_images": [
          {"image_url": "https://...", "is_main": true}
        ],
        "customizations": [
          {
            "custom_id": "size",
            "custom_name": "Size",
            "must_select": true,
            "choices": [
              {"choice_id": "s", "choice_label": "Small", "extra_price": 0},
              {"choice_id": "m", "choice_label": "Medium", "extra_price": 200},
              {"choice_id": "l", "choice_label": "Large", "extra_price": 400}
            ]
          }
        ],
        "product_variations": [
          {
            "var_id": "v-1",
            "var_sku": "BRG-S",
            "var_price": 1299,
            "var_options": {"size": "s"},
            "var_stock": 20
          }
        ]
      }
    ]
  }
}
```

**Document the differences:**

| API Field | Commerce Kit Field | Transformation |
|-----------|-------------------|----------------|
| `product_id` | `id` | Direct mapping |
| `product_name` | `name` | Direct mapping |
| `base_price` | `price` | Divide by 100 (cents → dollars) |
| `is_available` | `stockStatus` | Convert to enum |
| `customizations` | `options` | Deep transform |

### Step 2: Create Your Adapter

```dart
import 'package:commerce_kit/commerce_kit.dart';

class MyApiProductAdapter extends ProductAdapter<Map<String, dynamic>> {

  @override
  Product fromExternal(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] as String,
      name: json['product_name'] as String,
      description: json['product_desc'] as String?,

      // Price transformation: cents to dollars
      price: Money(
        (json['base_price'] as int) / 100,
        currency: json['currency_code'] as String? ?? 'USD',
      ),

      // Compare at price for sales
      compareAtPrice: json['original_price'] != null
          ? Money((json['original_price'] as int) / 100)
          : null,

      // Stock status mapping
      stockStatus: _mapStockStatus(json),
      stockQuantity: json['stock_qty'] as int?,

      // Type detection
      type: _detectProductType(json),

      // Categories
      categories: List<String>.from(json['category_ids'] ?? []),

      // Images
      images: _mapImages(json['product_images'] as List?),

      // Options (customizations)
      options: _mapOptions(json['customizations'] as List?),

      // Variants
      variants: _mapVariants(json['product_variations'] as List?),
    );
  }

  @override
  Map<String, dynamic> toExternal(Product product) {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'product_desc': product.description,
      'base_price': (product.price.amount * 100).round(),
      'original_price': product.compareAtPrice != null
          ? (product.compareAtPrice!.amount * 100).round()
          : null,
      'currency_code': product.price.currency,
      'is_available': product.stockStatus == StockStatus.inStock,
      'stock_qty': product.stockQuantity,
      'category_ids': product.categories,
      'product_images': product.images.map((img) => {
        'image_url': img.url,
        'is_main': img.isPrimary,
      }).toList(),
      // ... other fields
    };
  }

  // Helper: Map stock status
  StockStatus _mapStockStatus(Map<String, dynamic> json) {
    final isAvailable = json['is_available'] as bool? ?? false;
    final quantity = json['stock_qty'] as int? ?? 0;

    if (!isAvailable) return StockStatus.outOfStock;
    if (quantity == 0) return StockStatus.outOfStock;
    if (quantity < 5) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  // Helper: Detect product type
  ProductType _detectProductType(Map<String, dynamic> json) {
    final hasVariants = (json['product_variations'] as List?)?.isNotEmpty ?? false;
    final hasOptions = (json['customizations'] as List?)?.isNotEmpty ?? false;

    if (hasVariants) return ProductType.variable;
    if (hasOptions) return ProductType.configurable;
    return ProductType.simple;
  }

  // Helper: Map images
  List<ProductImage> _mapImages(List? images) {
    if (images == null || images.isEmpty) return [];

    return images.map((img) => ProductImage(
      url: img['image_url'] as String,
      isPrimary: img['is_main'] as bool? ?? false,
      alt: img['alt_text'] as String?,
    )).toList();
  }

  // Helper: Map options (customizations)
  List<ProductOption> _mapOptions(List? customizations) {
    if (customizations == null) return [];

    return customizations.map((custom) => ProductOption(
      id: custom['custom_id'] as String,
      name: custom['custom_name'] as String,
      isRequired: custom['must_select'] as bool? ?? false,
      type: _inferVariantType(custom['custom_id'] as String),
      values: (custom['choices'] as List?)?.map((choice) =>
        ProductOptionValue(
          id: choice['choice_id'] as String,
          label: choice['choice_label'] as String,
          priceModifier: choice['extra_price'] != null
              ? Money((choice['extra_price'] as int) / 100)
              : Money.zero,
        )
      ).toList() ?? [],
    )).toList();
  }

  // Helper: Map variants
  List<ProductVariant> _mapVariants(List? variations) {
    if (variations == null) return [];

    return variations.map((v) => ProductVariant(
      id: v['var_id'] as String,
      sku: v['var_sku'] as String?,
      price: Money((v['var_price'] as int) / 100),
      selectedOptions: Map<String, String>.from(v['var_options'] ?? {}),
      stockQuantity: v['var_stock'] as int?,
      stockStatus: (v['var_stock'] as int? ?? 0) > 0
          ? StockStatus.inStock
          : StockStatus.outOfStock,
    )).toList();
  }

  // Helper: Infer variant type from ID
  VariantType _inferVariantType(String id) {
    final lowerId = id.toLowerCase();
    if (lowerId.contains('size')) return VariantType.size;
    if (lowerId.contains('color') || lowerId.contains('colour')) return VariantType.color;
    if (lowerId.contains('material')) return VariantType.material;
    return VariantType.custom;
  }
}
```

### Step 3: Handle Nested Responses

Many APIs wrap data in nested structures:

```dart
class MyApiService {
  final Dio _dio;
  final MyApiProductAdapter _adapter;

  MyApiService(this._dio) : _adapter = MyApiProductAdapter();

  /// Fetch products with response unwrapping
  Future<List<Product>> getProducts() async {
    final response = await _dio.get('/api/products');

    // Handle nested response structure
    final data = response.data as Map<String, dynamic>;

    // Check for success
    if (data['status'] != 'success') {
      throw ApiException(data['message'] ?? 'Unknown error');
    }

    // Unwrap nested data
    final items = data['data']['items'] as List;

    // Convert using adapter
    return _adapter.fromExternalList(
      items.cast<Map<String, dynamic>>(),
    );
  }

  /// Fetch single product
  Future<Product> getProduct(String id) async {
    final response = await _dio.get('/api/products/$id');
    final data = response.data as Map<String, dynamic>;

    if (data['status'] != 'success') {
      throw ApiException(data['message'] ?? 'Product not found');
    }

    return _adapter.fromExternal(data['data']['product']);
  }
}
```

### Step 4: Map Enums and Types

Create dedicated mappers for enum values:

```dart
/// Enum mapper for stock status
class StockStatusMapper {
  static const Map<String, StockStatus> _fromApi = {
    'in_stock': StockStatus.inStock,
    'out_of_stock': StockStatus.outOfStock,
    'low_stock': StockStatus.lowStock,
    'backorder': StockStatus.onBackorder,
    'preorder': StockStatus.preOrder,
    'discontinued': StockStatus.discontinued,
    // Handle variations
    'available': StockStatus.inStock,
    'unavailable': StockStatus.outOfStock,
    'coming_soon': StockStatus.preOrder,
  };

  static const Map<StockStatus, String> _toApi = {
    StockStatus.inStock: 'in_stock',
    StockStatus.outOfStock: 'out_of_stock',
    StockStatus.lowStock: 'low_stock',
    StockStatus.onBackorder: 'backorder',
    StockStatus.preOrder: 'preorder',
    StockStatus.discontinued: 'discontinued',
  };

  static StockStatus fromApi(String? value) {
    if (value == null) return StockStatus.outOfStock;
    return _fromApi[value.toLowerCase()] ?? StockStatus.outOfStock;
  }

  static String toApi(StockStatus status) {
    return _toApi[status] ?? 'out_of_stock';
  }
}

/// Similar mappers for other enums
class ProductTypeMapper {
  static ProductType fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'simple':
      case 'basic':
        return ProductType.simple;
      case 'variable':
      case 'variant':
      case 'configurable':
        return ProductType.variable;
      case 'bundle':
      case 'grouped':
      case 'kit':
        return ProductType.bundle;
      case 'digital':
      case 'virtual':
      case 'downloadable':
        return ProductType.digital;
      case 'subscription':
      case 'recurring':
        return ProductType.subscription;
      default:
        return ProductType.simple;
    }
  }
}

class PaymentMethodMapper {
  static PaymentMethod fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'cod':
      case 'cash':
      case 'cash_on_delivery':
        return PaymentMethod.cashOnDelivery;
      case 'card':
      case 'credit_card':
      case 'debit_card':
        return PaymentMethod.card;
      case 'apple_pay':
      case 'applepay':
        return PaymentMethod.applePay;
      case 'google_pay':
      case 'googlepay':
        return PaymentMethod.googlePay;
      case 'wallet':
      case 'balance':
        return PaymentMethod.wallet;
      case 'paypal':
        return PaymentMethod.paypal;
      default:
        return PaymentMethod.card;
    }
  }
}
```

### Step 5: Handle Edge Cases

```dart
class RobustProductAdapter extends ProductAdapter<Map<String, dynamic>> {

  @override
  Product fromExternal(Map<String, dynamic> json) {
    try {
      return Product(
        // Required fields with fallbacks
        id: _getString(json, 'id', fallback: _generateId()),
        name: _getString(json, 'name', fallback: 'Unnamed Product'),

        // Price with multiple field attempts
        price: _getPrice(json, ['price', 'base_price', 'amount', 'cost']),

        // Optional with null safety
        description: _getStringOrNull(json, 'description'),

        // Stock with boolean check
        stockStatus: _getStockStatus(json),
        stockQuantity: _getIntOrNull(json, 'stock'),

        // Lists with empty fallback
        images: _safeList(json, 'images', _mapImage),
        options: _safeList(json, 'options', _mapOption),
        variants: _safeList(json, 'variants', _mapVariant),
        categories: _safeStringList(json, 'categories'),

        // Type detection
        type: _detectType(json),
      );
    } catch (e, stackTrace) {
      // Log error for debugging
      debugPrint('Error parsing product: $e');
      debugPrint('JSON: $json');
      debugPrint('Stack: $stackTrace');

      // Return minimal product or rethrow
      throw AdapterException(
        'Failed to parse product',
        originalError: e,
        data: json,
      );
    }
  }

  // Safe string extraction
  String _getString(Map<String, dynamic> json, String key, {required String fallback}) {
    final value = json[key];
    if (value == null) return fallback;
    return value.toString();
  }

  String? _getStringOrNull(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String && value.isEmpty) return null;
    return value.toString();
  }

  // Try multiple field names for price
  Money _getPrice(Map<String, dynamic> json, List<String> fieldNames) {
    for (final field in fieldNames) {
      final value = json[field];
      if (value != null) {
        return _parsePrice(value, json['currency'] as String?);
      }
    }
    return Money.zero;
  }

  Money _parsePrice(dynamic value, String? currency) {
    double amount;

    if (value is int) {
      // Check if cents or dollars
      amount = value > 10000 ? value / 100 : value.toDouble();
    } else if (value is double) {
      amount = value;
    } else if (value is String) {
      // Remove currency symbols
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      amount = double.tryParse(cleaned) ?? 0;
    } else {
      amount = 0;
    }

    return Money(amount, currency: currency ?? 'USD');
  }

  // Safe int extraction
  int? _getIntOrNull(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Safe list with mapper
  List<T> _safeList<T>(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final list = json[key];
    if (list == null || list is! List) return [];

    return list
        .whereType<Map<String, dynamic>>()
        .map((item) {
          try {
            return mapper(item);
          } catch (e) {
            debugPrint('Error mapping item in $key: $e');
            return null;
          }
        })
        .whereType<T>()
        .toList();
  }

  // Safe string list
  List<String> _safeStringList(Map<String, dynamic> json, String key) {
    final list = json[key];
    if (list == null || list is! List) return [];
    return list.map((e) => e.toString()).toList();
  }

  // Stock status with multiple checks
  StockStatus _getStockStatus(Map<String, dynamic> json) {
    // Check explicit status field
    if (json['stock_status'] != null) {
      return StockStatusMapper.fromApi(json['stock_status'] as String?);
    }

    // Check availability boolean
    if (json['is_available'] == false || json['available'] == false) {
      return StockStatus.outOfStock;
    }

    // Check quantity
    final qty = _getIntOrNull(json, 'stock') ??
                _getIntOrNull(json, 'quantity') ??
                _getIntOrNull(json, 'stock_quantity');

    if (qty != null) {
      if (qty <= 0) return StockStatus.outOfStock;
      if (qty < 5) return StockStatus.lowStock;
    }

    return StockStatus.inStock;
  }

  // Type detection
  ProductType _detectType(Map<String, dynamic> json) {
    // Explicit type
    if (json['type'] != null) {
      return ProductTypeMapper.fromApi(json['type'] as String?);
    }

    // Detect from structure
    final hasVariants = (json['variants'] as List?)?.isNotEmpty ?? false;
    final hasOptions = (json['options'] as List?)?.isNotEmpty ?? false;
    final isDigital = json['is_digital'] == true || json['downloadable'] == true;
    final isSubscription = json['is_subscription'] == true || json['recurring'] == true;

    if (isSubscription) return ProductType.subscription;
    if (isDigital) return ProductType.digital;
    if (hasVariants) return ProductType.variable;
    if (hasOptions) return ProductType.configurable;
    return ProductType.simple;
  }

  // Generate ID if missing
  String _generateId() => 'gen-${DateTime.now().millisecondsSinceEpoch}';

  // Map helpers (implement based on your API)
  ProductImage _mapImage(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'] as String? ?? json['src'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? json['is_main'] as bool? ?? false,
      alt: json['alt'] as String?,
    );
  }

  ProductOption _mapOption(Map<String, dynamic> json) {
    return ProductOption(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isRequired: json['required'] as bool? ?? false,
      values: _safeList(json, 'values', (v) => ProductOptionValue(
        id: v['id'] as String? ?? '',
        label: v['label'] as String? ?? v['name'] as String? ?? '',
        priceModifier: _parsePrice(v['price'], null),
      )),
    );
  }

  ProductVariant _mapVariant(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String? ?? '',
      sku: json['sku'] as String?,
      price: _parsePrice(json['price'], json['currency'] as String?),
      stockQuantity: _getIntOrNull(json, 'stock'),
      selectedOptions: Map<String, String>.from(json['options'] ?? {}),
    );
  }

  @override
  Map<String, dynamic> toExternal(Product product) {
    // Implement reverse mapping
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price.amount,
      'currency': product.price.currency,
      // ... etc
    };
  }
}
```

---

## Common API Patterns

### REST APIs

```dart
class RestApiService {
  final Dio _dio;
  final ProductAdapter<Map<String, dynamic>> _productAdapter;
  final CategoryAdapter<Map<String, dynamic>> _categoryAdapter;

  RestApiService({
    required String baseUrl,
    String? apiKey,
  }) : _dio = Dio(BaseOptions(
         baseUrl: baseUrl,
         headers: apiKey != null ? {'X-API-Key': apiKey} : null,
       )),
       _productAdapter = MyApiProductAdapter(),
       _categoryAdapter = MyCategoryAdapter();

  // Products
  Future<List<Product>> getProducts({
    int page = 1,
    int perPage = 20,
    String? category,
    String? search,
  }) async {
    final response = await _dio.get('/products', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (category != null) 'category': category,
      if (search != null) 'search': search,
    });

    final items = response.data['data'] as List;
    return _productAdapter.fromExternalList(items.cast());
  }

  Future<Product> getProduct(String id) async {
    final response = await _dio.get('/products/$id');
    return _productAdapter.fromExternal(response.data['data']);
  }

  // Categories
  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/categories');
    final items = response.data['data'] as List;
    return items.map((e) => _categoryAdapter.fromExternal(e)).toList();
  }

  // Cart sync (if server-side cart)
  Future<Cart> syncCart(Cart cart) async {
    final response = await _dio.post('/cart/sync', data: {
      'items': cart.items.map((item) => {
        'product_id': item.productId,
        'quantity': item.quantity,
        'options': item.selectedOptions,
      }).toList(),
    });

    // Parse server response back to Cart
    return _parseCartResponse(response.data);
  }

  // Orders
  Future<Order> createOrder(CheckoutSession session) async {
    final response = await _dio.post('/orders', data: {
      'items': session.items.map(_cartItemToJson).toList(),
      'shipping_address': _addressToJson(session.shippingAddress!),
      'billing_address': session.billingAddressSameAsShipping
          ? _addressToJson(session.shippingAddress!)
          : _addressToJson(session.billingAddress!),
      'payment_method': session.selectedPaymentMethod?.name,
      'shipping_method': session.selectedShippingMethod?.id,
      'coupon_code': session.appliedCoupon?.code,
      'points_to_redeem': session.pointsToRedeem,
      'use_wallet': session.useWallet,
      'wallet_amount': session.walletAmountToUse?.amount,
      'tip': session.tipAmount?.amount,
      'notes': session.notes,
    });

    return _parseOrderResponse(response.data);
  }
}
```

### GraphQL APIs

```dart
class GraphQLApiService {
  final GraphQLClient _client;
  final ProductAdapter<Map<String, dynamic>> _adapter;

  GraphQLApiService(String endpoint)
      : _client = GraphQLClient(
          link: HttpLink(endpoint),
          cache: GraphQLCache(),
        ),
        _adapter = MyApiProductAdapter();

  Future<List<Product>> getProducts({
    int first = 20,
    String? after,
    String? categoryId,
  }) async {
    const query = r'''
      query GetProducts($first: Int!, $after: String, $categoryId: ID) {
        products(first: $first, after: $after, categoryId: $categoryId) {
          edges {
            node {
              id
              name
              description
              price {
                amount
                currencyCode
              }
              compareAtPrice {
                amount
                currencyCode
              }
              availableForSale
              totalInventory
              images(first: 5) {
                edges {
                  node {
                    url
                    altText
                  }
                }
              }
              variants(first: 100) {
                edges {
                  node {
                    id
                    sku
                    price {
                      amount
                    }
                    selectedOptions {
                      name
                      value
                    }
                    quantityAvailable
                  }
                }
              }
              options {
                id
                name
                values
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    ''';

    final result = await _client.query(QueryOptions(
      document: gql(query),
      variables: {
        'first': first,
        if (after != null) 'after': after,
        if (categoryId != null) 'categoryId': categoryId,
      },
    ));

    if (result.hasException) {
      throw result.exception!;
    }

    final edges = result.data!['products']['edges'] as List;
    return edges.map((edge) {
      final node = edge['node'] as Map<String, dynamic>;
      return _adapter.fromExternal(_transformGraphQLNode(node));
    }).toList();
  }

  Map<String, dynamic> _transformGraphQLNode(Map<String, dynamic> node) {
    // Transform GraphQL structure to expected format
    return {
      'id': node['id'],
      'name': node['name'],
      'description': node['description'],
      'price': (node['price'] as Map)['amount'],
      'currency': (node['price'] as Map)['currencyCode'],
      'compare_at_price': (node['compareAtPrice'] as Map?)?['amount'],
      'is_available': node['availableForSale'],
      'stock': node['totalInventory'],
      'images': (node['images']['edges'] as List).map((e) => {
        'url': e['node']['url'],
        'alt': e['node']['altText'],
      }).toList(),
      'variants': (node['variants']['edges'] as List).map((e) => {
        'id': e['node']['id'],
        'sku': e['node']['sku'],
        'price': e['node']['price']['amount'],
        'stock': e['node']['quantityAvailable'],
        'options': Map.fromEntries(
          (e['node']['selectedOptions'] as List).map((opt) =>
            MapEntry(opt['name'], opt['value'])
          ),
        ),
      }).toList(),
      'options': (node['options'] as List).map((opt) => {
        'id': opt['id'],
        'name': opt['name'],
        'values': (opt['values'] as List).map((v) => {
          'id': v,
          'label': v,
        }).toList(),
      }).toList(),
    };
  }
}
```

### Firebase/Firestore

```dart
class FirestoreProductService {
  final FirebaseFirestore _firestore;
  final ProductAdapter<Map<String, dynamic>> _adapter;

  FirestoreProductService()
      : _firestore = FirebaseFirestore.instance,
        _adapter = FirestoreProductAdapter();

  /// Stream of products (real-time updates)
  Stream<List<Product>> watchProducts({
    String? categoryId,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection('products');

    if (categoryId != null) {
      query = query.where('categories', arrayContains: categoryId);
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = {'id': doc.id, ...doc.data()};
        return _adapter.fromExternal(data);
      }).toList();
    });
  }

  /// Get single product
  Future<Product?> getProduct(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();
    if (!doc.exists) return null;

    final data = {'id': doc.id, ...doc.data()!};
    return _adapter.fromExternal(data);
  }

  /// Batch get products
  Future<List<Product>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    // Firestore limits to 10 items per whereIn query
    final chunks = _chunk(ids, 10);
    final products = <Product>[];

    for (final chunk in chunks) {
      final snapshot = await _firestore
          .collection('products')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      products.addAll(snapshot.docs.map((doc) {
        final data = {'id': doc.id, ...doc.data()};
        return _adapter.fromExternal(data);
      }));
    }

    return products;
  }

  List<List<T>> _chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, min(i + size, list.length)));
    }
    return chunks;
  }
}

/// Adapter for Firestore document structure
class FirestoreProductAdapter extends ProductAdapter<Map<String, dynamic>> {
  @override
  Product fromExternal(Map<String, dynamic> doc) {
    return Product(
      id: doc['id'] as String,
      name: doc['name'] as String,
      description: doc['description'] as String?,
      price: Money(
        (doc['price'] as num).toDouble(),
        currency: doc['currency'] as String? ?? 'USD',
      ),
      compareAtPrice: doc['compareAtPrice'] != null
          ? Money((doc['compareAtPrice'] as num).toDouble())
          : null,
      stockStatus: StockStatusMapper.fromApi(doc['stockStatus'] as String?),
      stockQuantity: doc['stock'] as int?,
      type: ProductTypeMapper.fromApi(doc['type'] as String?),
      categories: List<String>.from(doc['categories'] ?? []),
      images: (doc['images'] as List?)?.map((img) => ProductImage(
        url: img['url'] as String,
        isPrimary: img['isPrimary'] as bool? ?? false,
      )).toList() ?? [],
      // Firestore timestamps
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (doc['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Map<String, dynamic> toExternal(Product product) {
    return {
      'name': product.name,
      'description': product.description,
      'price': product.price.amount,
      'currency': product.price.currency,
      'compareAtPrice': product.compareAtPrice?.amount,
      'stockStatus': StockStatusMapper.toApi(product.stockStatus),
      'stock': product.stockQuantity,
      'type': product.type.name,
      'categories': product.categories,
      'images': product.images.map((img) => {
        'url': img.url,
        'isPrimary': img.isPrimary,
      }).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
```

### Supabase

```dart
class SupabaseProductService {
  final SupabaseClient _supabase;
  final ProductAdapter<Map<String, dynamic>> _adapter;

  SupabaseProductService(this._supabase)
      : _adapter = SupabaseProductAdapter();

  /// Get products with pagination
  Future<List<Product>> getProducts({
    int page = 0,
    int pageSize = 20,
    String? categoryId,
    String? search,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    var query = _supabase
        .from('products')
        .select('''
          *,
          images:product_images(*),
          variants:product_variants(*),
          options:product_options(
            *,
            values:option_values(*)
          ),
          categories:product_categories(category_id)
        ''');

    if (categoryId != null) {
      query = query.contains('categories', [categoryId]);
    }

    if (search != null && search.isNotEmpty) {
      query = query.textSearch('name', search);
    }

    final data = await query
        .order(orderBy, ascending: ascending)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((item) {
      return _adapter.fromExternal(item as Map<String, dynamic>);
    }).toList();
  }

  /// Real-time product updates
  Stream<Product> watchProduct(String id) {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) {
          if (data.isEmpty) throw Exception('Product not found');
          return _adapter.fromExternal(data.first);
        });
  }
}

class SupabaseProductAdapter extends ProductAdapter<Map<String, dynamic>> {
  @override
  Product fromExternal(Map<String, dynamic> row) {
    return Product(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      price: Money((row['price'] as num).toDouble()),
      compareAtPrice: row['compare_at_price'] != null
          ? Money((row['compare_at_price'] as num).toDouble())
          : null,
      stockStatus: StockStatusMapper.fromApi(row['stock_status'] as String?),
      stockQuantity: row['stock_quantity'] as int?,
      sku: row['sku'] as String?,
      type: ProductTypeMapper.fromApi(row['type'] as String?),
      // Handle joined tables
      images: (row['images'] as List?)?.map((img) => ProductImage(
        url: img['url'] as String,
        isPrimary: img['is_primary'] as bool? ?? false,
      )).toList() ?? [],
      variants: (row['variants'] as List?)?.map((v) => ProductVariant(
        id: v['id'] as String,
        sku: v['sku'] as String?,
        price: Money((v['price'] as num).toDouble()),
        stockQuantity: v['stock_quantity'] as int?,
      )).toList() ?? [],
      options: (row['options'] as List?)?.map((opt) => ProductOption(
        id: opt['id'] as String,
        name: opt['name'] as String,
        isRequired: opt['is_required'] as bool? ?? false,
        values: (opt['values'] as List?)?.map((v) => ProductOptionValue(
          id: v['id'] as String,
          label: v['label'] as String,
          priceModifier: v['price_modifier'] != null
              ? Money((v['price_modifier'] as num).toDouble())
              : Money.zero,
        )).toList() ?? [],
      )).toList() ?? [],
      categories: (row['categories'] as List?)
          ?.map((c) => c['category_id'] as String)
          .toList() ?? [],
    );
  }

  @override
  Map<String, dynamic> toExternal(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price.amount,
      'compare_at_price': product.compareAtPrice?.amount,
      'stock_status': product.stockStatus.name,
      'stock_quantity': product.stockQuantity,
      'sku': product.sku,
      'type': product.type.name,
    };
  }
}
```

---

## Pre-built Platform Adapters

Commerce Kit includes pre-configured adapters for popular platforms:

### WooCommerce

```dart
final adapter = JsonProductAdapter.wooCommerce();

// Use with WooCommerce REST API
final response = await dio.get(
  'https://yoursite.com/wp-json/wc/v3/products',
  queryParameters: {'consumer_key': 'xxx', 'consumer_secret': 'xxx'},
);

final products = adapter.fromExternalList(response.data);
```

### Shopify

```dart
final adapter = JsonProductAdapter.shopify();

// Use with Shopify Admin API
final response = await dio.get(
  'https://yourstore.myshopify.com/admin/api/2024-01/products.json',
  options: Options(headers: {'X-Shopify-Access-Token': 'xxx'}),
);

final products = adapter.fromExternalList(response.data['products']);
```

### Custom JSON Adapter

```dart
// Configure adapter for any JSON structure
final adapter = JsonProductAdapter(
  // Field mappings
  idField: 'product_id',
  nameField: 'title',
  descriptionField: 'body_html',
  priceField: 'base_price',
  compareAtPriceField: 'original_price',
  typeField: 'product_type',
  skuField: 'sku_code',
  stockStatusField: 'availability',
  stockQuantityField: 'inventory_count',
  imagesField: 'media',
  variantsField: 'variations',
  optionsField: 'customization_options',
  categoriesField: 'category_ids',

  // Type mappings
  typeMapping: {
    'standard': ProductType.simple,
    'with_variants': ProductType.variable,
    'customizable': ProductType.configurable,
    'package': ProductType.bundle,
  },

  stockStatusMapping: {
    'available': StockStatus.inStock,
    'limited': StockStatus.lowStock,
    'unavailable': StockStatus.outOfStock,
    'coming_soon': StockStatus.preOrder,
  },

  // Custom price parser (e.g., for cents)
  priceParser: (value) => (value as int) / 100,

  // Custom image mapper
  imageMapper: (imageData) => ProductImage(
    url: imageData['src'] as String,
    isPrimary: imageData['position'] == 1,
    alt: imageData['alt_text'] as String?,
  ),
);
```

---

## Advanced Techniques

### Composite Adapters

Combine multiple adapters for complex scenarios:

```dart
class CompositeProductAdapter extends ProductAdapter<Map<String, dynamic>> {
  final ProductAdapter<Map<String, dynamic>> _baseAdapter;
  final List<ProductEnricher> _enrichers;

  CompositeProductAdapter({
    ProductAdapter<Map<String, dynamic>>? baseAdapter,
    List<ProductEnricher>? enrichers,
  })  : _baseAdapter = baseAdapter ?? MyApiProductAdapter(),
        _enrichers = enrichers ?? [];

  @override
  Product fromExternal(Map<String, dynamic> json) {
    // Base conversion
    var product = _baseAdapter.fromExternal(json);

    // Apply enrichers
    for (final enricher in _enrichers) {
      product = enricher.enrich(product, json);
    }

    return product;
  }

  @override
  Map<String, dynamic> toExternal(Product product) {
    return _baseAdapter.toExternal(product);
  }
}

/// Enricher interface
abstract class ProductEnricher {
  Product enrich(Product product, Map<String, dynamic> rawData);
}

/// Add rating data from separate field
class RatingEnricher implements ProductEnricher {
  @override
  Product enrich(Product product, Map<String, dynamic> rawData) {
    final rating = rawData['rating'] as Map<String, dynamic>?;
    if (rating == null) return product;

    return product.copyWith(
      metadata: {
        ...product.metadata,
        'rating': rating['average'],
        'reviewCount': rating['count'],
      },
    );
  }
}

/// Add inventory data from warehouse info
class InventoryEnricher implements ProductEnricher {
  @override
  Product enrich(Product product, Map<String, dynamic> rawData) {
    final warehouses = rawData['warehouses'] as List?;
    if (warehouses == null) return product;

    final totalStock = warehouses.fold<int>(
      0,
      (sum, w) => sum + (w['stock'] as int? ?? 0),
    );

    return product.copyWith(
      stockQuantity: totalStock,
      stockStatus: totalStock > 0
          ? (totalStock < 5 ? StockStatus.lowStock : StockStatus.inStock)
          : StockStatus.outOfStock,
    );
  }
}

// Usage
final adapter = CompositeProductAdapter(
  enrichers: [
    RatingEnricher(),
    InventoryEnricher(),
  ],
);
```

### Caching Layer

```dart
class CachedProductService {
  final ProductApiService _api;
  final Cache<String, Product> _productCache;
  final Cache<String, List<Product>> _listCache;
  final Duration _cacheDuration;

  CachedProductService(
    this._api, {
    Duration cacheDuration = const Duration(minutes: 5),
  })  : _cacheDuration = cacheDuration,
        _productCache = Cache<String, Product>(),
        _listCache = Cache<String, List<Product>>();

  Future<Product> getProduct(String id, {bool forceRefresh = false}) async {
    final cacheKey = 'product_$id';

    if (!forceRefresh) {
      final cached = _productCache.get(cacheKey);
      if (cached != null) return cached;
    }

    final product = await _api.getProduct(id);
    _productCache.set(cacheKey, product, duration: _cacheDuration);
    return product;
  }

  Future<List<Product>> getProducts({
    int page = 1,
    String? category,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'products_${category ?? 'all'}_$page';

    if (!forceRefresh) {
      final cached = _listCache.get(cacheKey);
      if (cached != null) return cached;
    }

    final products = await _api.getProducts(page: page, category: category);
    _listCache.set(cacheKey, products, duration: _cacheDuration);
    return products;
  }

  void invalidateProduct(String id) {
    _productCache.remove('product_$id');
    // Also invalidate lists that might contain this product
    _listCache.clear();
  }

  void invalidateAll() {
    _productCache.clear();
    _listCache.clear();
  }
}

/// Simple in-memory cache
class Cache<K, V> {
  final _cache = <K, _CacheEntry<V>>{};

  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value;
  }

  void set(K key, V value, {required Duration duration}) {
    _cache[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(duration),
    );
  }

  void remove(K key) => _cache.remove(key);
  void clear() => _cache.clear();
}

class _CacheEntry<V> {
  final V value;
  final DateTime expiresAt;

  _CacheEntry({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

### Error Mapping

```dart
class ApiErrorMapper {
  static CommerceException mapError(dynamic error) {
    if (error is DioException) {
      return _mapDioError(error);
    }
    if (error is FirebaseException) {
      return _mapFirebaseError(error);
    }
    return CommerceException(
      'Unknown error occurred',
      originalError: error,
    );
  }

  static CommerceException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout');

      case DioExceptionType.badResponse:
        return _mapHttpError(error.response);

      case DioExceptionType.cancel:
        return CommerceException('Request cancelled');

      case DioExceptionType.connectionError:
        return NetworkException('No internet connection');

      default:
        return NetworkException('Network error');
    }
  }

  static CommerceException _mapHttpError(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;
    final message = data is Map ? data['message'] as String? : null;

    switch (statusCode) {
      case 400:
        return ValidationException(message ?? 'Invalid request');
      case 401:
        return AuthException('Not authenticated');
      case 403:
        return AuthException('Access denied');
      case 404:
        return NotFoundException(message ?? 'Resource not found');
      case 409:
        return ConflictException(message ?? 'Conflict');
      case 422:
        return ValidationException(message ?? 'Validation failed');
      case 429:
        return RateLimitException('Too many requests');
      case 500:
      case 502:
      case 503:
        return ServerException(message ?? 'Server error');
      default:
        return CommerceException(message ?? 'HTTP error $statusCode');
    }
  }

  static CommerceException _mapFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return AuthException('Permission denied');
      case 'not-found':
        return NotFoundException('Document not found');
      case 'unavailable':
        return NetworkException('Service unavailable');
      default:
        return CommerceException(error.message ?? 'Firebase error');
    }
  }
}

// Exception types
class NetworkException extends CommerceException {
  NetworkException(super.message);
}

class AuthException extends CommerceException {
  AuthException(super.message);
}

class NotFoundException extends CommerceException {
  NotFoundException(super.message);
}

class ValidationException extends CommerceException {
  ValidationException(super.message);
}

class ConflictException extends CommerceException {
  ConflictException(super.message);
}

class RateLimitException extends CommerceException {
  RateLimitException(super.message);
}

class ServerException extends CommerceException {
  ServerException(super.message);
}
```

### Pagination Handling

```dart
class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final String? nextCursor;
  final String? previousCursor;

  PaginatedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.nextCursor,
    this.previousCursor,
  });

  factory PaginatedResult.fromResponse(
    Map<String, dynamic> response,
    List<T> items,
  ) {
    final meta = response['meta'] as Map<String, dynamic>? ?? {};
    final pagination = response['pagination'] as Map<String, dynamic>? ?? meta;

    final page = pagination['page'] as int? ??
                 pagination['current_page'] as int? ?? 1;
    final pageSize = pagination['per_page'] as int? ??
                     pagination['page_size'] as int? ?? items.length;
    final totalItems = pagination['total'] as int? ??
                       pagination['total_count'] as int? ?? items.length;
    final totalPages = pagination['total_pages'] as int? ??
                       pagination['last_page'] as int? ??
                       (totalItems / pageSize).ceil();

    return PaginatedResult(
      items: items,
      page: page,
      pageSize: pageSize,
      totalItems: totalItems,
      totalPages: totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
      nextCursor: pagination['next_cursor'] as String?,
      previousCursor: pagination['previous_cursor'] as String?,
    );
  }
}

class PaginatedProductService {
  final ProductApiService _api;
  final ProductAdapter<Map<String, dynamic>> _adapter;

  PaginatedProductService(this._api, this._adapter);

  Future<PaginatedResult<Product>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? search,
    String? cursor,
  }) async {
    final response = await _api.getRawProducts(
      page: page,
      pageSize: pageSize,
      category: category,
      search: search,
      cursor: cursor,
    );

    final itemsJson = response['data'] as List? ??
                      response['items'] as List? ??
                      response['products'] as List? ?? [];

    final products = itemsJson
        .map((json) => _adapter.fromExternal(json as Map<String, dynamic>))
        .toList();

    return PaginatedResult.fromResponse(response, products);
  }
}
```

---

## Testing Your Integration

### Unit Testing Adapters

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyApiProductAdapter', () {
    late MyApiProductAdapter adapter;

    setUp(() {
      adapter = MyApiProductAdapter();
    });

    test('should parse simple product correctly', () {
      final json = {
        'product_id': 'p-123',
        'product_name': 'Test Product',
        'base_price': 1299,
        'currency_code': 'USD',
        'is_available': true,
        'stock_qty': 50,
      };

      final product = adapter.fromExternal(json);

      expect(product.id, 'p-123');
      expect(product.name, 'Test Product');
      expect(product.price.amount, 12.99);
      expect(product.price.currency, 'USD');
      expect(product.stockStatus, StockStatus.inStock);
      expect(product.stockQuantity, 50);
    });

    test('should handle missing optional fields', () {
      final json = {
        'product_id': 'p-123',
        'product_name': 'Test Product',
        'base_price': 999,
      };

      final product = adapter.fromExternal(json);

      expect(product.id, 'p-123');
      expect(product.description, isNull);
      expect(product.compareAtPrice, isNull);
      expect(product.images, isEmpty);
      expect(product.variants, isEmpty);
    });

    test('should detect low stock correctly', () {
      final json = {
        'product_id': 'p-123',
        'product_name': 'Low Stock Product',
        'base_price': 999,
        'is_available': true,
        'stock_qty': 3,
      };

      final product = adapter.fromExternal(json);

      expect(product.stockStatus, StockStatus.lowStock);
    });

    test('should parse variants correctly', () {
      final json = {
        'product_id': 'p-123',
        'product_name': 'Variable Product',
        'base_price': 999,
        'product_variations': [
          {
            'var_id': 'v-1',
            'var_sku': 'SKU-1',
            'var_price': 1099,
            'var_options': {'size': 'L'},
            'var_stock': 10,
          },
        ],
      };

      final product = adapter.fromExternal(json);

      expect(product.type, ProductType.variable);
      expect(product.variants, hasLength(1));
      expect(product.variants.first.id, 'v-1');
      expect(product.variants.first.price.amount, 10.99);
      expect(product.variants.first.selectedOptions, {'size': 'L'});
    });

    test('should convert back to external format', () {
      final product = Product(
        id: 'p-123',
        name: 'Test Product',
        price: Money(12.99, currency: 'USD'),
        type: ProductType.simple,
      );

      final json = adapter.toExternal(product);

      expect(json['product_id'], 'p-123');
      expect(json['product_name'], 'Test Product');
      expect(json['base_price'], 1299);
      expect(json['currency_code'], 'USD');
    });
  });
}
```

### Integration Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('ProductApiService', () {
    late MockDio mockDio;
    late ProductApiService service;

    setUp(() {
      mockDio = MockDio();
      service = ProductApiService(mockDio);
    });

    test('should fetch and parse products', () async {
      when(() => mockDio.get('/api/products')).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '/api/products'),
        data: {
          'status': 'success',
          'data': {
            'items': [
              {
                'product_id': 'p-1',
                'product_name': 'Product 1',
                'base_price': 999,
              },
              {
                'product_id': 'p-2',
                'product_name': 'Product 2',
                'base_price': 1999,
              },
            ],
          },
        },
      ));

      final products = await service.getProducts();

      expect(products, hasLength(2));
      expect(products[0].id, 'p-1');
      expect(products[1].id, 'p-2');
    });

    test('should throw on API error', () async {
      when(() => mockDio.get('/api/products')).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '/api/products'),
        data: {
          'status': 'error',
          'message': 'Unauthorized',
        },
      ));

      expect(
        () => service.getProducts(),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
```

### Mock Data Generator

```dart
class MockProductGenerator {
  static Product simple({
    String? id,
    String? name,
    double? price,
    StockStatus? stockStatus,
  }) {
    return Product(
      id: id ?? 'mock-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Mock Product',
      price: Money(price ?? 9.99),
      type: ProductType.simple,
      stockStatus: stockStatus ?? StockStatus.inStock,
    );
  }

  static Product variable({
    String? id,
    String? name,
    int variantCount = 3,
  }) {
    return Product(
      id: id ?? 'mock-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Mock Variable Product',
      price: Money(19.99),
      type: ProductType.variable,
      stockStatus: StockStatus.inStock,
      options: [
        ProductOption(
          id: 'size',
          name: 'Size',
          isRequired: true,
          values: ['S', 'M', 'L']
              .map((s) => ProductOptionValue(id: s, label: s))
              .toList(),
        ),
      ],
      variants: List.generate(variantCount, (i) => ProductVariant(
        id: 'var-$i',
        sku: 'SKU-$i',
        price: Money(19.99 + (i * 2)),
        selectedOptions: {'size': ['S', 'M', 'L'][i % 3]},
        stockQuantity: 10,
      )),
    );
  }

  static List<Product> list({int count = 10}) {
    return List.generate(count, (i) => simple(
      id: 'product-$i',
      name: 'Product $i',
      price: 9.99 + (i * 5),
    ));
  }

  static Map<String, dynamic> rawJson({
    String? id,
    String? name,
    int? price,
  }) {
    return {
      'product_id': id ?? 'mock-${DateTime.now().millisecondsSinceEpoch}',
      'product_name': name ?? 'Mock Product',
      'base_price': price ?? 999,
      'currency_code': 'USD',
      'is_available': true,
      'stock_qty': 50,
    };
  }
}
```

---

## Troubleshooting

### Common Issues

#### 1. Price Showing Wrong Values

**Problem:** Prices are 100x too large or too small.

**Solution:** Check if API returns cents or dollars.

```dart
// API returns cents (999 = $9.99)
price: Money((json['price'] as int) / 100)

// API returns dollars (9.99 = $9.99)
price: Money((json['price'] as num).toDouble())
```

#### 2. Stock Status Always Wrong

**Problem:** Products always show as in/out of stock.

**Solution:** Check all possible stock indicators.

```dart
StockStatus _getStock(Map<String, dynamic> json) {
  // Check explicit status
  final status = json['stock_status'] ?? json['availability'];
  if (status != null) return StockStatusMapper.fromApi(status);

  // Check boolean flags
  if (json['is_available'] == false) return StockStatus.outOfStock;
  if (json['in_stock'] == false) return StockStatus.outOfStock;

  // Check quantity
  final qty = json['stock'] ?? json['quantity'] ?? json['inventory'];
  if (qty is int) {
    if (qty <= 0) return StockStatus.outOfStock;
    if (qty < 5) return StockStatus.lowStock;
  }

  return StockStatus.inStock;
}
```

#### 3. Images Not Loading

**Problem:** Product images are null or empty.

**Solution:** Handle different image structures.

```dart
List<ProductImage> _parseImages(dynamic images) {
  if (images == null) return [];

  if (images is String) {
    // Single image URL
    return [ProductImage(url: images, isPrimary: true)];
  }

  if (images is List) {
    return images.asMap().entries.map((entry) {
      final img = entry.value;
      if (img is String) {
        return ProductImage(url: img, isPrimary: entry.key == 0);
      }
      if (img is Map) {
        return ProductImage(
          url: img['url'] ?? img['src'] ?? img['image_url'] ?? '',
          isPrimary: img['is_primary'] ?? img['is_main'] ?? entry.key == 0,
          alt: img['alt'] ?? img['alt_text'],
        );
      }
      return null;
    }).whereType<ProductImage>().toList();
  }

  return [];
}
```

#### 4. Variants Not Matching Options

**Problem:** Selected variant doesn't match option selections.

**Solution:** Ensure consistent option key/value mapping.

```dart
ProductVariant? findMatchingVariant(
  List<ProductVariant> variants,
  Map<String, String> selections,
) {
  for (final variant in variants) {
    bool matches = true;

    for (final entry in selections.entries) {
      final variantValue = variant.selectedOptions[entry.key];
      if (variantValue == null || variantValue != entry.value) {
        // Try case-insensitive match
        if (variantValue?.toLowerCase() != entry.value.toLowerCase()) {
          matches = false;
          break;
        }
      }
    }

    if (matches) return variant;
  }

  return null;
}
```

#### 5. Currency Symbol Issues

**Problem:** Wrong currency symbol or formatting.

**Solution:** Configure CommerceConfig properly.

```dart
CommerceConfig.initialize(
  currency: 'SAR',
  currencySymbol: 'ر.س',
  currencyPosition: CurrencyPosition.after, // "100.00 ر.س"
  locale: 'ar_SA',
  decimalSeparator: '.',
  thousandsSeparator: ',',
  decimalPlaces: 2,
);
```

### Debug Logging

```dart
class DebugProductAdapter extends ProductAdapter<Map<String, dynamic>> {
  final ProductAdapter<Map<String, dynamic>> _inner;
  final bool logInput;
  final bool logOutput;

  DebugProductAdapter(
    this._inner, {
    this.logInput = true,
    this.logOutput = true,
  });

  @override
  Product fromExternal(Map<String, dynamic> json) {
    if (logInput) {
      debugPrint('=== ADAPTER INPUT ===');
      debugPrint(const JsonEncoder.withIndent('  ').convert(json));
    }

    try {
      final product = _inner.fromExternal(json);

      if (logOutput) {
        debugPrint('=== ADAPTER OUTPUT ===');
        debugPrint('ID: ${product.id}');
        debugPrint('Name: ${product.name}');
        debugPrint('Price: ${product.price.formatted}');
        debugPrint('Type: ${product.type}');
        debugPrint('Stock: ${product.stockStatus}');
        debugPrint('Images: ${product.images.length}');
        debugPrint('Variants: ${product.variants.length}');
        debugPrint('Options: ${product.options.length}');
      }

      return product;
    } catch (e, stack) {
      debugPrint('=== ADAPTER ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack: $stack');
      debugPrint('Input: ${const JsonEncoder.withIndent('  ').convert(json)}');
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toExternal(Product product) => _inner.toExternal(product);
}

// Usage
final adapter = DebugProductAdapter(
  MyApiProductAdapter(),
  logInput: kDebugMode,
  logOutput: kDebugMode,
);
```

---

## Summary

1. **Analyze your API** - Understand the response structure
2. **Create an adapter** - Map API fields to Commerce Kit models
3. **Handle edge cases** - Null values, missing fields, type variations
4. **Map enums carefully** - Create dedicated mappers for consistent conversion
5. **Add caching** - Reduce API calls and improve performance
6. **Test thoroughly** - Unit test adapters, integration test services
7. **Debug with logging** - Use debug adapters during development

The adapter pattern gives you complete flexibility to integrate with any backend while keeping your app code clean and maintainable.

---

## Review System Integration

### Review Adapter

```dart
class ReviewAdapter {
  Review fromExternal(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] as String?,
      content: json['content'] as String?,
      images: (json['images'] as List?)?.cast<String>() ?? [],
      isVerifiedPurchase: json['verified_purchase'] as bool? ?? false,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      status: _mapReviewStatus(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      response: json['merchant_response'] != null
          ? ReviewResponse(
              content: json['merchant_response']['content'] as String,
              respondedAt: DateTime.parse(
                json['merchant_response']['responded_at'] as String,
              ),
            )
          : null,
    );
  }

  ReviewStatus _mapReviewStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending': return ReviewStatus.pending;
      case 'approved': return ReviewStatus.approved;
      case 'rejected': return ReviewStatus.rejected;
      case 'flagged': return ReviewStatus.flagged;
      default: return ReviewStatus.approved;
    }
  }

  RatingStats parseRatingStats(Map<String, dynamic> json) {
    return RatingStats(
      averageRating: (json['average'] as num).toDouble(),
      totalReviews: json['total_reviews'] as int,
      distribution: Map.fromEntries(
        [1, 2, 3, 4, 5].map((star) => MapEntry(
          star,
          json['distribution']?['$star'] as int? ?? 0,
        )),
      ),
      verifiedPurchaseCount: json['verified_count'] as int? ?? 0,
      withImagesCount: json['with_images_count'] as int? ?? 0,
    );
  }
}
```

### Review Service

```dart
class ReviewApiService {
  final Dio _dio;
  final ReviewAdapter _adapter = ReviewAdapter();

  ReviewApiService(this._dio);

  Future<List<Review>> getProductReviews(
    String productId, {
    int page = 1,
    int perPage = 10,
    ReviewSortOption sort = ReviewSortOption.newest,
    ReviewFilter? filter,
  }) async {
    final response = await _dio.get(
      '/products/$productId/reviews',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'sort': sort.name,
        if (filter?.minRating != null) 'min_rating': filter!.minRating,
        if (filter?.verifiedOnly == true) 'verified_only': true,
        if (filter?.withImagesOnly == true) 'with_images': true,
      },
    );

    final reviews = (response.data['reviews'] as List)
        .map((json) => _adapter.fromExternal(json))
        .toList();

    return reviews;
  }

  Future<RatingStats> getRatingStats(String productId) async {
    final response = await _dio.get('/products/$productId/ratings');
    return _adapter.parseRatingStats(response.data);
  }

  Future<Review> submitReview({
    required String productId,
    required double rating,
    String? title,
    String? content,
    List<String>? imageUrls,
  }) async {
    final response = await _dio.post(
      '/products/$productId/reviews',
      data: {
        'rating': rating,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (imageUrls != null) 'images': imageUrls,
      },
    );

    return _adapter.fromExternal(response.data['review']);
  }

  Future<void> voteHelpful(String reviewId) async {
    await _dio.post('/reviews/$reviewId/helpful');
  }
}
```

---

## Wishlist Integration

### Wishlist Adapter

```dart
class WishlistAdapter {
  WishlistItem fromExternal(
    Map<String, dynamic> json,
    ProductAdapter<Map<String, dynamic>> productAdapter,
  ) {
    return WishlistItem(
      id: json['id'] as String,
      product: productAdapter.fromExternal(json['product']),
      addedAt: DateTime.parse(json['added_at'] as String),
      notification: json['notification'] != null
          ? WishlistNotification(
              onPriceDrop: json['notification']['price_drop'] as bool? ?? false,
              onBackInStock: json['notification']['back_in_stock'] as bool? ?? false,
              targetPrice: json['notification']['target_price'] != null
                  ? Money((json['notification']['target_price'] as num).toDouble())
                  : null,
            )
          : null,
      notes: json['notes'] as String?,
    );
  }

  Wishlist parseWishlist(
    Map<String, dynamic> json,
    ProductAdapter<Map<String, dynamic>> productAdapter,
  ) {
    return Wishlist(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'My Wishlist',
      items: (json['items'] as List?)
          ?.map((item) => fromExternal(item, productAdapter))
          .toList() ?? [],
      isPublic: json['is_public'] as bool? ?? false,
      shareUrl: json['share_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
```

### Wishlist Service

```dart
class WishlistApiService {
  final Dio _dio;
  final WishlistAdapter _adapter = WishlistAdapter();
  final ProductAdapter<Map<String, dynamic>> _productAdapter;

  WishlistApiService(this._dio, this._productAdapter);

  Future<Wishlist> getWishlist() async {
    final response = await _dio.get('/wishlist');
    return _adapter.parseWishlist(response.data, _productAdapter);
  }

  Future<WishlistItem> addToWishlist(
    String productId, {
    WishlistNotification? notification,
    String? notes,
  }) async {
    final response = await _dio.post(
      '/wishlist/items',
      data: {
        'product_id': productId,
        if (notification != null) 'notification': {
          'price_drop': notification.onPriceDrop,
          'back_in_stock': notification.onBackInStock,
          if (notification.targetPrice != null)
            'target_price': notification.targetPrice!.amount,
        },
        if (notes != null) 'notes': notes,
      },
    );

    return _adapter.fromExternal(response.data['item'], _productAdapter);
  }

  Future<void> removeFromWishlist(String itemId) async {
    await _dio.delete('/wishlist/items/$itemId');
  }

  Future<void> updateNotification(
    String itemId,
    WishlistNotification notification,
  ) async {
    await _dio.patch(
      '/wishlist/items/$itemId/notification',
      data: {
        'price_drop': notification.onPriceDrop,
        'back_in_stock': notification.onBackInStock,
        if (notification.targetPrice != null)
          'target_price': notification.targetPrice!.amount,
      },
    );
  }
}
```

---

## Search & Filter Integration

### Search Adapter

```dart
class SearchAdapter {
  final ProductAdapter<Map<String, dynamic>> _productAdapter;

  SearchAdapter(this._productAdapter);

  SearchResult<Product> parseSearchResult(Map<String, dynamic> json) {
    return SearchResult<Product>(
      items: (json['products'] as List)
          .map((p) => _productAdapter.fromExternal(p))
          .toList(),
      totalCount: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['per_page'] as int,
      hasMore: json['has_more'] as bool? ?? false,
      query: json['query'] as String?,
      appliedFilters: json['applied_filters'] != null
          ? _parseProductFilter(json['applied_filters'])
          : null,
      availableFilters: json['available_filters'] != null
          ? _parseAvailableFilters(json['available_filters'])
          : null,
    );
  }

  ProductFilter _parseProductFilter(Map<String, dynamic> json) {
    return ProductFilter(
      query: json['query'] as String?,
      categories: (json['categories'] as List?)?.cast<String>(),
      minPrice: json['min_price'] != null
          ? Money((json['min_price'] as num).toDouble())
          : null,
      maxPrice: json['max_price'] != null
          ? Money((json['max_price'] as num).toDouble())
          : null,
      attributes: json['attributes'] != null
          ? Map<String, List<String>>.from(
              (json['attributes'] as Map).map(
                (k, v) => MapEntry(k as String, (v as List).cast<String>()),
              ),
            )
          : null,
      inStockOnly: json['in_stock_only'] as bool?,
      onSaleOnly: json['on_sale_only'] as bool?,
      sortBy: _parseSortOption(json['sort_by'] as String?),
    );
  }

  AvailableFilters _parseAvailableFilters(Map<String, dynamic> json) {
    return AvailableFilters(
      categories: (json['categories'] as List?)
          ?.map((c) => FilterOption(
                id: c['id'] as String,
                label: c['name'] as String,
                count: c['count'] as int? ?? 0,
              ))
          .toList(),
      priceRange: json['price_range'] != null
          ? FilterPriceRange(
              min: Money((json['price_range']['min'] as num).toDouble()),
              max: Money((json['price_range']['max'] as num).toDouble()),
            )
          : null,
      attributes: (json['attributes'] as Map?)?.map(
        (key, values) => MapEntry(
          key as String,
          (values as List)
              .map((v) => FilterOption(
                    id: v['id'] as String,
                    label: v['label'] as String,
                    count: v['count'] as int? ?? 0,
                  ))
              .toList(),
        ),
      ),
    );
  }

  SortOption _parseSortOption(String? value) {
    switch (value?.toLowerCase()) {
      case 'relevance': return SortOption.relevance;
      case 'newest': return SortOption.newest;
      case 'price_asc': return SortOption.priceAsc;
      case 'price_desc': return SortOption.priceDesc;
      case 'name_asc': return SortOption.nameAsc;
      case 'name_desc': return SortOption.nameDesc;
      case 'rating': return SortOption.rating;
      case 'popularity': return SortOption.popularity;
      case 'best_selling': return SortOption.bestSelling;
      default: return SortOption.relevance;
    }
  }

  List<SearchSuggestion> parseSuggestions(List<dynamic> json) {
    return json.map((s) => SearchSuggestion(
      text: s['text'] as String,
      type: _parseSuggestionType(s['type'] as String?),
      productId: s['product_id'] as String?,
      categoryId: s['category_id'] as String?,
      imageUrl: s['image_url'] as String?,
      highlightedText: s['highlighted'] as String?,
    )).toList();
  }

  SuggestionType _parseSuggestionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'query': return SuggestionType.query;
      case 'product': return SuggestionType.product;
      case 'category': return SuggestionType.category;
      case 'brand': return SuggestionType.brand;
      case 'recent': return SuggestionType.recent;
      case 'trending': return SuggestionType.trending;
      case 'correction': return SuggestionType.correction;
      default: return SuggestionType.query;
    }
  }
}
```

### Search Service

```dart
class SearchApiService {
  final Dio _dio;
  final SearchAdapter _adapter;

  SearchApiService(this._dio, ProductAdapter<Map<String, dynamic>> productAdapter)
      : _adapter = SearchAdapter(productAdapter);

  Future<SearchResult<Product>> search({
    String? query,
    ProductFilter? filter,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get(
      '/search',
      queryParameters: {
        if (query != null) 'q': query,
        'page': page,
        'per_page': perPage,
        if (filter?.categories != null) 'categories': filter!.categories!.join(','),
        if (filter?.minPrice != null) 'min_price': filter!.minPrice!.amount,
        if (filter?.maxPrice != null) 'max_price': filter!.maxPrice!.amount,
        if (filter?.inStockOnly == true) 'in_stock': true,
        if (filter?.onSaleOnly == true) 'on_sale': true,
        if (filter?.sortBy != null) 'sort': filter!.sortBy!.name,
        if (filter?.attributes != null)
          ...filter!.attributes!.map((k, v) => MapEntry('attr_$k', v.join(','))),
      },
    );

    return _adapter.parseSearchResult(response.data);
  }

  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    final response = await _dio.get(
      '/search/suggestions',
      queryParameters: {'q': query},
    );

    return _adapter.parseSuggestions(response.data['suggestions'] as List);
  }
}
```

---

## Analytics Integration

### Analytics Adapter

```dart
class AnalyticsAdapter {
  Map<String, dynamic> productViewedToJson(Product product) {
    return {
      'event': 'product_viewed',
      'product_id': product.id,
      'product_name': product.name,
      'price': product.price.amount,
      'currency': product.price.currency,
      'category': product.categories.firstOrNull,
    };
  }

  Map<String, dynamic> addToCartToJson(CartItem item) {
    return {
      'event': 'add_to_cart',
      'product_id': item.productId,
      'product_name': item.name,
      'quantity': item.quantity,
      'price': item.price.amount,
      'currency': item.price.currency,
      'variant_id': item.variantId,
    };
  }

  Map<String, dynamic> purchaseToJson(Order order) {
    return {
      'event': 'purchase',
      'order_id': order.id,
      'total': order.summary.total.amount,
      'currency': order.summary.total.currency,
      'items': order.items.map((item) => {
        'product_id': item.productId,
        'product_name': item.name,
        'quantity': item.quantity,
        'price': item.price.amount,
      }).toList(),
      'coupon': order.summary.appliedCoupon?.code,
      'shipping': order.summary.shipping.amount,
    };
  }

  Map<String, dynamic> searchToJson(String query, int resultsCount) {
    return {
      'event': 'search',
      'query': query,
      'results_count': resultsCount,
    };
  }
}
```

### Analytics Service

```dart
class AnalyticsService {
  final Dio _dio;
  final AnalyticsAdapter _adapter = AnalyticsAdapter();
  final List<AnalyticsProvider> _providers;

  AnalyticsService(this._dio, {List<AnalyticsProvider>? providers})
      : _providers = providers ?? [];

  Future<void> trackProductViewed(Product product) async {
    final data = _adapter.productViewedToJson(product);
    await _sendToAllProviders(data);
  }

  Future<void> trackAddToCart(CartItem item) async {
    final data = _adapter.addToCartToJson(item);
    await _sendToAllProviders(data);
  }

  Future<void> trackPurchase(Order order) async {
    final data = _adapter.purchaseToJson(order);
    await _sendToAllProviders(data);
  }

  Future<void> trackSearch(String query, int resultsCount) async {
    final data = _adapter.searchToJson(query, resultsCount);
    await _sendToAllProviders(data);
  }

  Future<void> _sendToAllProviders(Map<String, dynamic> data) async {
    // Send to internal analytics API
    try {
      await _dio.post('/analytics/events', data: data);
    } catch (e) {
      debugPrint('Failed to send analytics to API: $e');
    }

    // Send to external providers
    for (final provider in _providers) {
      try {
        await provider.track(data);
      } catch (e) {
        debugPrint('Failed to send analytics to ${provider.name}: $e');
      }
    }
  }
}

/// Abstract analytics provider for third-party integrations
abstract class AnalyticsProvider {
  String get name;
  Future<void> track(Map<String, dynamic> event);
}

/// Firebase Analytics provider
class FirebaseAnalyticsProvider implements AnalyticsProvider {
  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsProvider(this._analytics);

  @override
  String get name => 'Firebase';

  @override
  Future<void> track(Map<String, dynamic> event) async {
    await _analytics.logEvent(
      name: event['event'] as String,
      parameters: Map<String, Object>.from(event)..remove('event'),
    );
  }
}

/// Mixpanel provider
class MixpanelProvider implements AnalyticsProvider {
  final Mixpanel _mixpanel;

  MixpanelProvider(this._mixpanel);

  @override
  String get name => 'Mixpanel';

  @override
  Future<void> track(Map<String, dynamic> event) async {
    _mixpanel.track(
      event['event'] as String,
      properties: Map<String, dynamic>.from(event)..remove('event'),
    );
  }
}
```
