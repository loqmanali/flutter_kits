import '../../core/enums/order_status.dart';
import '../../core/models/order.dart';

/// Abstract repository interface for order operations.
///
/// Implement this interface to provide order management functionality
/// with your preferred data source (API, local cache, etc.).
///
/// ## Usage
///
/// ```dart
/// class ApiOrderRepository implements OrderRepository {
///   final ApiClient _client;
///
///   ApiOrderRepository(this._client);
///
///   @override
///   Future<List<Order>> getOrderHistory({
///     int page = 1,
///     int pageSize = 20,
///     OrderStatus? status,
///   }) async {
///     final response = await _client.get('/orders', {
///       'page': page,
///       'per_page': pageSize,
///       if (status != null) 'status': status.name,
///     });
///     return response.data.map((json) => Order.fromJson(json)).toList();
///   }
///
///   // ... implement other methods
/// }
/// ```
abstract class OrderRepository {
  /// Gets order history for the current user.
  ///
  /// [page] - Page number (1-indexed).
  /// [pageSize] - Number of orders per page.
  /// [status] - Optional status filter.
  ///
  /// Returns a list of orders.
  Future<List<Order>> getOrderHistory({
    int page = 1,
    int pageSize = 20,
    OrderStatus? status,
  });

  /// Gets a single order by ID.
  ///
  /// [orderId] - The order ID.
  ///
  /// Returns the order or null if not found.
  Future<Order?> getOrderById(String orderId);

  /// Gets a single order by order number.
  ///
  /// [orderNumber] - The display order number.
  ///
  /// Returns the order or null if not found.
  Future<Order?> getOrderByNumber(String orderNumber);

  /// Gets the current/active order (if any).
  ///
  /// Returns the current order or null.
  Future<Order?> getCurrentOrder();

  /// Tracks an order's delivery status.
  ///
  /// [orderId] - The order ID to track.
  ///
  /// Returns the order with updated tracking info.
  Future<Order> trackOrder(String orderId);

  /// Cancels an order.
  ///
  /// [orderId] - The order ID to cancel.
  /// [reason] - Reason for cancellation.
  ///
  /// Returns the cancelled order.
  Future<Order> cancelOrder(String orderId, {String? reason});

  /// Requests a refund for an order.
  ///
  /// [orderId] - The order ID.
  /// [itemIds] - Optional list of item IDs to refund (all if empty).
  /// [reason] - Reason for refund request.
  ///
  /// Returns the updated order.
  Future<Order> requestRefund(
    String orderId, {
    List<String>? itemIds,
    required String reason,
  });

  /// Reorders a previous order.
  ///
  /// [orderId] - The order ID to reorder.
  ///
  /// Returns the new order.
  Future<Order> reorder(String orderId);

  /// Gets orders by status.
  ///
  /// [status] - The status to filter by.
  /// [page] - Page number (1-indexed).
  /// [pageSize] - Number of orders per page.
  ///
  /// Returns a list of orders with the specified status.
  Future<List<Order>> getOrdersByStatus(
    OrderStatus status, {
    int page = 1,
    int pageSize = 20,
  });

  /// Gets orders within a date range.
  ///
  /// [startDate] - Start of date range.
  /// [endDate] - End of date range.
  /// [page] - Page number (1-indexed).
  /// [pageSize] - Number of orders per page.
  ///
  /// Returns a list of orders within the date range.
  Future<List<Order>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int page = 1,
    int pageSize = 20,
  });

  /// Rates an order after delivery.
  ///
  /// [orderId] - The order ID.
  /// [rating] - Rating (1-5).
  /// [feedback] - Optional feedback text.
  Future<void> rateOrder(
    String orderId, {
    required int rating,
    String? feedback,
  });

  /// Rates delivery experience.
  ///
  /// [orderId] - The order ID.
  /// [rating] - Rating (1-5).
  /// [feedback] - Optional feedback text.
  Future<void> rateDelivery(
    String orderId, {
    required int rating,
    String? feedback,
  });

  /// Gets order statistics.
  ///
  /// Returns order statistics (total orders, total spent, etc.).
  Future<OrderStats> getOrderStats();

  /// Stream of order updates.
  ///
  /// [orderId] - The order ID to watch.
  ///
  /// Returns a stream of order updates.
  Stream<Order> watchOrder(String orderId);

  /// Stream of current order updates.
  Stream<Order?> get currentOrderStream;
}

/// Order statistics.
class OrderStats {
  /// Total number of orders.
  final int totalOrders;

  /// Total number of completed orders.
  final int completedOrders;

  /// Total number of cancelled orders.
  final int cancelledOrders;

  /// Total amount spent.
  final double totalSpent;

  /// Average order value.
  final double averageOrderValue;

  /// Number of orders this month.
  final int ordersThisMonth;

  /// Amount spent this month.
  final double spentThisMonth;

  const OrderStats({
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.totalSpent = 0,
    this.averageOrderValue = 0,
    this.ordersThisMonth = 0,
    this.spentThisMonth = 0,
  });

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      totalOrders: json['total_orders'] ?? json['totalOrders'] ?? 0,
      completedOrders: json['completed_orders'] ?? json['completedOrders'] ?? 0,
      cancelledOrders: json['cancelled_orders'] ?? json['cancelledOrders'] ?? 0,
      totalSpent:
          (json['total_spent'] ?? json['totalSpent'] ?? 0).toDouble(),
      averageOrderValue:
          (json['average_order_value'] ?? json['averageOrderValue'] ?? 0)
              .toDouble(),
      ordersThisMonth:
          json['orders_this_month'] ?? json['ordersThisMonth'] ?? 0,
      spentThisMonth:
          (json['spent_this_month'] ?? json['spentThisMonth'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_orders': totalOrders,
        'completed_orders': completedOrders,
        'cancelled_orders': cancelledOrders,
        'total_spent': totalSpent,
        'average_order_value': averageOrderValue,
        'orders_this_month': ordersThisMonth,
        'spent_this_month': spentThisMonth,
      };
}
