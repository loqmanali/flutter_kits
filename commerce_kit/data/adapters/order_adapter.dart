import '../../core/models/order.dart';

/// Abstract adapter for converting API responses to [Order] models.
///
/// Implement this interface to map your specific API response format
/// to the commerce kit's internal [Order] model.
///
/// ## Usage
///
/// ```dart
/// class MyOrderAdapter extends OrderAdapter<MyApiOrder> {
///   @override
///   Order fromResponse(MyApiOrder response) {
///     return Order(
///       id: response.orderId,
///       orderNumber: response.number,
///       status: mapStatus(response.status),
///       // ... map other fields
///     );
///   }
/// }
/// ```
abstract class OrderAdapter<T> {
  /// Converts an API response to an [Order].
  Order fromResponse(T response);

  /// Converts an [Order] back to an API response format.
  T toResponse(Order order) {
    throw UnimplementedError('toResponse not implemented');
  }

  /// Converts a list of API responses to a list of [Order]s.
  List<Order> fromResponseList(List<T> responses) {
    return responses.map(fromResponse).toList();
  }

  /// Safely converts an API response, returning null on error.
  Order? tryFromResponse(T response) {
    try {
      return fromResponse(response);
    } catch (_) {
      return null;
    }
  }
}

/// Adapter for Map (JSON) to [Order].
///
/// This adapter uses the built-in `Order.fromJson` by default but allows
/// custom field mappings and transformations.
///
/// ## Default JSON Structure
///
/// The default adapter expects the standard Order JSON structure.
/// See [Order.fromJson] for the expected format.
///
/// ## Custom Transformation Example
///
/// ```dart
/// final adapter = JsonOrderAdapter(
///   transformer: (json) {
///     // Transform your API response to match Order.fromJson format
///     return {
///       'id': json['order_id'],
///       'order_number': json['number'],
///       'status': json['state'],
///       'payment_status': json['payment']['status'],
///       'payment_method': json['payment']['method'],
///       'items': json['line_items'],
///       'summary': {
///         'subtotal': json['totals']['subtotal'],
///         'total': json['totals']['grand_total'],
///       },
///       // ... other mappings
///     };
///   },
/// );
/// ```
class JsonOrderAdapter extends OrderAdapter<Map<String, dynamic>> {
  /// Optional transformer to preprocess JSON before conversion.
  final Map<String, dynamic> Function(Map<String, dynamic>)? transformer;

  /// Field mappings for simple field renaming.
  final OrderFieldMapping? fieldMapping;

  JsonOrderAdapter({this.transformer, this.fieldMapping});

  @override
  Order fromResponse(Map<String, dynamic> response) {
    Map<String, dynamic> json = response;

    // Apply custom transformer if provided
    if (transformer != null) {
      json = transformer!(response);
    }
    // Apply field mapping if provided
    else if (fieldMapping != null) {
      json = _applyFieldMapping(response, fieldMapping!);
    }

    return Order.fromJson(json);
  }

  @override
  Map<String, dynamic> toResponse(Order order) {
    return order.toJson();
  }

  Map<String, dynamic> _applyFieldMapping(
    Map<String, dynamic> json,
    OrderFieldMapping mapping,
  ) {
    return {
      'id': json[mapping.id],
      'order_number': json[mapping.orderNumber],
      'user_id': json[mapping.userId],
      'status': json[mapping.status],
      'payment_status': json[mapping.paymentStatus],
      'payment_method': json[mapping.paymentMethod],
      'items': json[mapping.items],
      'summary': json[mapping.summary],
      'shipping_address': json[mapping.shippingAddress],
      'billing_address': json[mapping.billingAddress],
      'shipping_method': json[mapping.shippingMethod],
      'delivery_time_slot': json[mapping.deliveryTimeSlot],
      'estimated_delivery_min': json[mapping.estimatedDeliveryMin],
      'estimated_delivery_max': json[mapping.estimatedDeliveryMax],
      'actual_delivery_time': json[mapping.actualDeliveryTime],
      'customer_note': json[mapping.customerNote],
      'internal_note': json[mapping.internalNote],
      'coupon_code': json[mapping.couponCode],
      'wallet_used': json[mapping.walletUsed],
      'points_redeemed': json[mapping.pointsRedeemed],
      'points_earned': json[mapping.pointsEarned],
      'cashback_earned': json[mapping.cashbackEarned],
      'created_at': json[mapping.createdAt],
      'updated_at': json[mapping.updatedAt],
      'confirmed_at': json[mapping.confirmedAt],
      'completed_at': json[mapping.completedAt],
      'cancelled_at': json[mapping.cancelledAt],
      'cancellation_reason': json[mapping.cancellationReason],
      'tracking_number': json[mapping.trackingNumber],
      'tracking_url': json[mapping.trackingUrl],
      'driver': json[mapping.driver],
      'source': json[mapping.source],
      'platform': json[mapping.platform],
      'metadata': json[mapping.metadata],
    };
  }
}

/// Field mapping for [Order] JSON conversion.
///
/// Use this to map different field names from your API to the expected
/// Order field names without writing a full transformer.
class OrderFieldMapping {
  final String id;
  final String orderNumber;
  final String userId;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String items;
  final String summary;
  final String shippingAddress;
  final String billingAddress;
  final String shippingMethod;
  final String deliveryTimeSlot;
  final String estimatedDeliveryMin;
  final String estimatedDeliveryMax;
  final String actualDeliveryTime;
  final String customerNote;
  final String internalNote;
  final String couponCode;
  final String walletUsed;
  final String pointsRedeemed;
  final String pointsEarned;
  final String cashbackEarned;
  final String createdAt;
  final String updatedAt;
  final String confirmedAt;
  final String completedAt;
  final String cancelledAt;
  final String cancellationReason;
  final String trackingNumber;
  final String trackingUrl;
  final String driver;
  final String source;
  final String platform;
  final String metadata;

  const OrderFieldMapping({
    this.id = 'id',
    this.orderNumber = 'order_number',
    this.userId = 'user_id',
    this.status = 'status',
    this.paymentStatus = 'payment_status',
    this.paymentMethod = 'payment_method',
    this.items = 'items',
    this.summary = 'summary',
    this.shippingAddress = 'shipping_address',
    this.billingAddress = 'billing_address',
    this.shippingMethod = 'shipping_method',
    this.deliveryTimeSlot = 'delivery_time_slot',
    this.estimatedDeliveryMin = 'estimated_delivery_min',
    this.estimatedDeliveryMax = 'estimated_delivery_max',
    this.actualDeliveryTime = 'actual_delivery_time',
    this.customerNote = 'customer_note',
    this.internalNote = 'internal_note',
    this.couponCode = 'coupon_code',
    this.walletUsed = 'wallet_used',
    this.pointsRedeemed = 'points_redeemed',
    this.pointsEarned = 'points_earned',
    this.cashbackEarned = 'cashback_earned',
    this.createdAt = 'created_at',
    this.updatedAt = 'updated_at',
    this.confirmedAt = 'confirmed_at',
    this.completedAt = 'completed_at',
    this.cancelledAt = 'cancelled_at',
    this.cancellationReason = 'cancellation_reason',
    this.trackingNumber = 'tracking_number',
    this.trackingUrl = 'tracking_url',
    this.driver = 'driver',
    this.source = 'source',
    this.platform = 'platform',
    this.metadata = 'metadata',
  });

  /// Default field mapping using snake_case.
  static const defaults = OrderFieldMapping();

  /// CamelCase field mapping.
  static const camelCase = OrderFieldMapping(
    orderNumber: 'orderNumber',
    userId: 'userId',
    paymentStatus: 'paymentStatus',
    paymentMethod: 'paymentMethod',
    shippingAddress: 'shippingAddress',
    billingAddress: 'billingAddress',
    shippingMethod: 'shippingMethod',
    deliveryTimeSlot: 'deliveryTimeSlot',
    estimatedDeliveryMin: 'estimatedDeliveryMin',
    estimatedDeliveryMax: 'estimatedDeliveryMax',
    actualDeliveryTime: 'actualDeliveryTime',
    customerNote: 'customerNote',
    internalNote: 'internalNote',
    couponCode: 'couponCode',
    walletUsed: 'walletUsed',
    pointsRedeemed: 'pointsRedeemed',
    pointsEarned: 'pointsEarned',
    cashbackEarned: 'cashbackEarned',
    createdAt: 'createdAt',
    updatedAt: 'updatedAt',
    confirmedAt: 'confirmedAt',
    completedAt: 'completedAt',
    cancelledAt: 'cancelledAt',
    cancellationReason: 'cancellationReason',
    trackingNumber: 'trackingNumber',
    trackingUrl: 'trackingUrl',
  );
}

/// Adapter for order history list responses.
///
/// Many APIs return order history in a paginated format.
/// This adapter handles the common pagination patterns.
///
/// ## Usage
///
/// ```dart
/// final adapter = JsonOrderHistoryAdapter(
///   ordersKey: 'data',
///   totalKey: 'meta.total',
///   pageKey: 'meta.current_page',
/// );
///
/// final result = adapter.fromResponse(apiResponse);
/// print(result.orders); // List<Order>
/// print(result.total); // Total count
/// print(result.page); // Current page
/// ```
class JsonOrderHistoryAdapter {
  /// Key for the orders array in the response.
  final String ordersKey;

  /// Key for total count (supports dot notation for nested keys).
  final String? totalKey;

  /// Key for current page.
  final String? pageKey;

  /// Key for page size.
  final String? pageSizeKey;

  /// Key for has more flag.
  final String? hasMoreKey;

  /// Order adapter to use for individual orders.
  final JsonOrderAdapter? orderAdapter;

  JsonOrderHistoryAdapter({
    this.ordersKey = 'orders',
    this.totalKey,
    this.pageKey,
    this.pageSizeKey,
    this.hasMoreKey,
    this.orderAdapter,
  });

  /// Parses an order history response.
  OrderHistoryResult fromResponse(Map<String, dynamic> response) {
    final adapter = orderAdapter ?? JsonOrderAdapter();

    // Get orders list
    final ordersData = _getNestedValue(response, ordersKey);
    final orders = <Order>[];
    if (ordersData is List) {
      for (final item in ordersData) {
        if (item is Map<String, dynamic>) {
          final order = adapter.tryFromResponse(item);
          if (order != null) {
            orders.add(order);
          }
        }
      }
    }

    // Get pagination info
    final total =
        totalKey != null ? _parseInt(_getNestedValue(response, totalKey!)) : null;
    final page =
        pageKey != null ? _parseInt(_getNestedValue(response, pageKey!)) : null;
    final pageSize = pageSizeKey != null
        ? _parseInt(_getNestedValue(response, pageSizeKey!))
        : null;
    final hasMore = hasMoreKey != null
        ? _getNestedValue(response, hasMoreKey!) == true
        : null;

    return OrderHistoryResult(
      orders: orders,
      total: total,
      page: page,
      pageSize: pageSize,
      hasMore: hasMore,
    );
  }

  dynamic _getNestedValue(Map<String, dynamic> json, String key) {
    final parts = key.split('.');
    dynamic value = json;
    for (final part in parts) {
      if (value is Map<String, dynamic>) {
        value = value[part];
      } else {
        return null;
      }
    }
    return value;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

/// Result from parsing an order history response.
class OrderHistoryResult {
  /// List of orders.
  final List<Order> orders;

  /// Total number of orders (if available).
  final int? total;

  /// Current page number (if paginated).
  final int? page;

  /// Page size (if paginated).
  final int? pageSize;

  /// Whether there are more orders to load.
  final bool? hasMore;

  const OrderHistoryResult({
    required this.orders,
    this.total,
    this.page,
    this.pageSize,
    this.hasMore,
  });

  /// Whether the result is empty.
  bool get isEmpty => orders.isEmpty;

  /// Whether the result has orders.
  bool get isNotEmpty => orders.isNotEmpty;

  /// Number of orders in this result.
  int get count => orders.length;
}
