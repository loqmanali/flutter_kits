/// Represents the status of an order.
enum OrderStatus {
  /// Order has been created but not yet confirmed
  pending,

  /// Order has been confirmed
  confirmed,

  /// Order is being prepared
  preparing,

  /// Order is ready for pickup/delivery
  ready,

  /// Order has been dispatched/shipped
  dispatched,

  /// Order is out for delivery
  outForDelivery,

  /// Order has been delivered
  delivered,

  /// Order was picked up by customer
  pickedUp,

  /// Order has been completed
  completed,

  /// Order was cancelled
  cancelled,

  /// Order was refunded
  refunded,

  /// Order failed (payment or other issue)
  failed,

  /// Order is on hold (e.g., awaiting stock)
  onHold,

  /// Order is being returned
  returning,

  /// Order has been returned
  returned,
}

/// Extension methods for [OrderStatus].
extension OrderStatusExtension on OrderStatus {
  /// Returns true if order is in an active processing state
  bool get isActive =>
      this == OrderStatus.pending ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.preparing ||
      this == OrderStatus.ready ||
      this == OrderStatus.dispatched ||
      this == OrderStatus.outForDelivery ||
      this == OrderStatus.onHold;

  /// Returns true if order has been successfully fulfilled
  bool get isFulfilled =>
      this == OrderStatus.delivered ||
      this == OrderStatus.pickedUp ||
      this == OrderStatus.completed;

  /// Returns true if order was cancelled or failed
  bool get isCancelledOrFailed =>
      this == OrderStatus.cancelled || this == OrderStatus.failed;

  /// Returns true if order can be cancelled
  bool get canBeCancelled =>
      this == OrderStatus.pending ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.onHold;

  /// Returns true if order can be modified
  bool get canBeModified =>
      this == OrderStatus.pending || this == OrderStatus.confirmed;

  /// Returns true if order is in delivery phase
  bool get isInDelivery =>
      this == OrderStatus.dispatched || this == OrderStatus.outForDelivery;

  /// Returns true if order has been refunded or returned
  bool get isRefundedOrReturned =>
      this == OrderStatus.refunded ||
      this == OrderStatus.returning ||
      this == OrderStatus.returned;

  /// Returns true if order is in a final state
  bool get isFinal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.pickedUp ||
      this == OrderStatus.completed ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.failed ||
      this == OrderStatus.refunded ||
      this == OrderStatus.returned;

  /// Returns a human-readable label
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.dispatched:
        return 'Dispatched';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
      case OrderStatus.failed:
        return 'Failed';
      case OrderStatus.onHold:
        return 'On Hold';
      case OrderStatus.returning:
        return 'Returning';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  /// Returns the step number for tracking (1-5 for typical delivery flow)
  int get trackingStep {
    switch (this) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
      case OrderStatus.dispatched:
        return 3;
      case OrderStatus.outForDelivery:
        return 4;
      case OrderStatus.delivered:
      case OrderStatus.pickedUp:
      case OrderStatus.completed:
        return 5;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
      case OrderStatus.failed:
      case OrderStatus.onHold:
      case OrderStatus.returning:
      case OrderStatus.returned:
        return -1;
    }
  }
}
