/// Represents the status of a payment transaction.
enum PaymentStatus {
  /// Payment not yet initiated
  pending,

  /// Payment is awaiting authorization
  awaitingAuthorization,

  /// Payment has been authorized but not captured
  authorized,

  /// Payment is being processed
  processing,

  /// Payment completed successfully
  completed,

  /// Payment failed
  failed,

  /// Payment was declined
  declined,

  /// Payment was cancelled
  cancelled,

  /// Payment was refunded (fully)
  refunded,

  /// Payment was partially refunded
  partiallyRefunded,

  /// Payment is disputed/chargebacked
  disputed,

  /// Payment expired (e.g., bank transfer not received)
  expired,

  /// Payment requires additional action (e.g., 3DS verification)
  requiresAction,
}

/// Extension methods for [PaymentStatus].
extension PaymentStatusExtension on PaymentStatus {
  /// Returns true if payment is in a final successful state
  bool get isSuccessful =>
      this == PaymentStatus.completed || this == PaymentStatus.authorized;

  /// Returns true if payment is in a final failed state
  bool get isFailed =>
      this == PaymentStatus.failed ||
      this == PaymentStatus.declined ||
      this == PaymentStatus.expired;

  /// Returns true if payment is still in progress
  bool get isInProgress =>
      this == PaymentStatus.pending ||
      this == PaymentStatus.awaitingAuthorization ||
      this == PaymentStatus.processing ||
      this == PaymentStatus.requiresAction;

  /// Returns true if payment was cancelled or refunded
  bool get isCancelled =>
      this == PaymentStatus.cancelled ||
      this == PaymentStatus.refunded ||
      this == PaymentStatus.partiallyRefunded;

  /// Returns true if payment requires user action
  bool get requiresUserAction => this == PaymentStatus.requiresAction;

  /// Returns true if payment can be refunded
  bool get canBeRefunded =>
      this == PaymentStatus.completed || this == PaymentStatus.authorized;

  /// Returns true if payment can be captured (for authorized payments)
  bool get canBeCaptured => this == PaymentStatus.authorized;

  /// Returns a human-readable label
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.awaitingAuthorization:
        return 'Awaiting Authorization';
      case PaymentStatus.authorized:
        return 'Authorized';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.declined:
        return 'Declined';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
      case PaymentStatus.disputed:
        return 'Disputed';
      case PaymentStatus.expired:
        return 'Expired';
      case PaymentStatus.requiresAction:
        return 'Requires Action';
    }
  }
}
