import '../../core/enums/order_status.dart';
import '../../core/models/order.dart';
import '../repositories/order_repository.dart';

/// Use case for getting order history.
class GetOrderHistoryUseCase {
  final OrderRepository _repository;

  GetOrderHistoryUseCase(this._repository);

  /// Gets paginated order history.
  Future<List<Order>> call({
    int page = 1,
    int pageSize = 20,
    OrderStatus? status,
  }) async {
    return _repository.getOrderHistory(
      page: page,
      pageSize: pageSize,
      status: status,
    );
  }
}

/// Use case for getting a single order.
class GetOrderUseCase {
  final OrderRepository _repository;

  GetOrderUseCase(this._repository);

  /// Gets an order by ID.
  Future<Order?> call(String orderId) async {
    return _repository.getOrderById(orderId);
  }

  /// Gets an order by order number.
  Future<Order?> byNumber(String orderNumber) async {
    return _repository.getOrderByNumber(orderNumber);
  }
}

/// Use case for getting the current active order.
class GetCurrentOrderUseCase {
  final OrderRepository _repository;

  GetCurrentOrderUseCase(this._repository);

  /// Gets the current active order.
  Future<Order?> call() async {
    return _repository.getCurrentOrder();
  }
}

/// Use case for tracking an order.
class TrackOrderUseCase {
  final OrderRepository _repository;

  TrackOrderUseCase(this._repository);

  /// Tracks an order's delivery status.
  Future<Order> call(String orderId) async {
    return _repository.trackOrder(orderId);
  }
}

/// Use case for cancelling an order.
class CancelOrderUseCase {
  final OrderRepository _repository;

  CancelOrderUseCase(this._repository);

  /// Cancels an order.
  ///
  /// Validates that the order can be cancelled before attempting.
  Future<Order> call(String orderId, {String? reason}) async {
    final order = await _repository.getOrderById(orderId);

    if (order == null) {
      throw OrderNotFoundException(orderId);
    }

    if (!order.canCancel) {
      throw OrderCannotBeCancelledException(orderId, order.status);
    }

    return _repository.cancelOrder(orderId, reason: reason);
  }
}

/// Use case for requesting a refund.
class RequestRefundUseCase {
  final OrderRepository _repository;

  RequestRefundUseCase(this._repository);

  /// Requests a refund for an order.
  Future<Order> call(
    String orderId, {
    List<String>? itemIds,
    required String reason,
  }) async {
    if (reason.isEmpty) {
      throw OrderValidationException(['Refund reason is required']);
    }

    return _repository.requestRefund(
      orderId,
      itemIds: itemIds,
      reason: reason,
    );
  }
}

/// Use case for reordering a previous order.
class ReorderUseCase {
  final OrderRepository _repository;

  ReorderUseCase(this._repository);

  /// Creates a new order from a previous order.
  Future<Order> call(String orderId) async {
    return _repository.reorder(orderId);
  }
}

/// Use case for getting orders by status.
class GetOrdersByStatusUseCase {
  final OrderRepository _repository;

  GetOrdersByStatusUseCase(this._repository);

  /// Gets orders with a specific status.
  Future<List<Order>> call(
    OrderStatus status, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return _repository.getOrdersByStatus(
      status,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Use case for getting orders by date range.
class GetOrdersByDateRangeUseCase {
  final OrderRepository _repository;

  GetOrdersByDateRangeUseCase(this._repository);

  /// Gets orders within a date range.
  Future<List<Order>> call(
    DateTime startDate,
    DateTime endDate, {
    int page = 1,
    int pageSize = 20,
  }) async {
    if (startDate.isAfter(endDate)) {
      throw OrderValidationException(['Start date must be before end date']);
    }

    return _repository.getOrdersByDateRange(
      startDate,
      endDate,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Use case for rating an order.
class RateOrderUseCase {
  final OrderRepository _repository;

  RateOrderUseCase(this._repository);

  /// Rates an order.
  Future<void> call(
    String orderId, {
    required int rating,
    String? feedback,
  }) async {
    if (rating < 1 || rating > 5) {
      throw OrderValidationException(['Rating must be between 1 and 5']);
    }

    return _repository.rateOrder(
      orderId,
      rating: rating,
      feedback: feedback,
    );
  }
}

/// Use case for rating delivery experience.
class RateDeliveryUseCase {
  final OrderRepository _repository;

  RateDeliveryUseCase(this._repository);

  /// Rates the delivery experience.
  Future<void> call(
    String orderId, {
    required int rating,
    String? feedback,
  }) async {
    if (rating < 1 || rating > 5) {
      throw OrderValidationException(['Rating must be between 1 and 5']);
    }

    return _repository.rateDelivery(
      orderId,
      rating: rating,
      feedback: feedback,
    );
  }
}

/// Use case for getting order statistics.
class GetOrderStatsUseCase {
  final OrderRepository _repository;

  GetOrderStatsUseCase(this._repository);

  /// Gets order statistics for the current user.
  Future<OrderStats> call() async {
    return _repository.getOrderStats();
  }
}

/// Use case for watching order updates.
class WatchOrderUseCase {
  final OrderRepository _repository;

  WatchOrderUseCase(this._repository);

  /// Returns a stream of order updates.
  Stream<Order> call(String orderId) {
    return _repository.watchOrder(orderId);
  }
}

/// Exception thrown when an order is not found.
class OrderNotFoundException implements Exception {
  final String orderId;

  OrderNotFoundException(this.orderId);

  @override
  String toString() => 'Order not found: $orderId';
}

/// Exception thrown when an order cannot be cancelled.
class OrderCannotBeCancelledException implements Exception {
  final String orderId;
  final OrderStatus currentStatus;

  OrderCannotBeCancelledException(this.orderId, this.currentStatus);

  @override
  String toString() =>
      'Order $orderId cannot be cancelled (current status: ${currentStatus.name})';
}

/// Exception thrown when order validation fails.
class OrderValidationException implements Exception {
  final List<String> errors;

  OrderValidationException(this.errors);

  @override
  String toString() => errors.join(', ');
}
