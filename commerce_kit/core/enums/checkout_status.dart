/// Represents the status of a checkout session.
enum CheckoutStatus {
  /// Initial state when checkout is created
  pending,

  /// Customer is entering shipping information
  shippingInfo,

  /// Customer is selecting payment method
  paymentMethod,

  /// Customer is reviewing order before confirmation
  review,

  /// Payment is being processed
  processing,

  /// Checkout completed successfully
  completed,

  /// Checkout was cancelled by user
  cancelled,

  /// Checkout failed due to error
  failed,

  /// Checkout expired (timeout)
  expired,
}

/// Extension methods for [CheckoutStatus].
extension CheckoutStatusExtension on CheckoutStatus {
  /// Returns true if checkout is in a final state (completed, cancelled, failed, expired)
  bool get isFinal =>
      this == CheckoutStatus.completed ||
      this == CheckoutStatus.cancelled ||
      this == CheckoutStatus.failed ||
      this == CheckoutStatus.expired;

  /// Returns true if checkout is in an active/editable state
  bool get isActive =>
      this == CheckoutStatus.pending ||
      this == CheckoutStatus.shippingInfo ||
      this == CheckoutStatus.paymentMethod ||
      this == CheckoutStatus.review;

  /// Returns true if checkout is currently processing
  bool get isProcessing => this == CheckoutStatus.processing;

  /// Returns true if checkout was successful
  bool get isSuccessful => this == CheckoutStatus.completed;

  /// Returns a human-readable label
  String get label {
    switch (this) {
      case CheckoutStatus.pending:
        return 'Pending';
      case CheckoutStatus.shippingInfo:
        return 'Shipping Information';
      case CheckoutStatus.paymentMethod:
        return 'Payment Method';
      case CheckoutStatus.review:
        return 'Review Order';
      case CheckoutStatus.processing:
        return 'Processing';
      case CheckoutStatus.completed:
        return 'Completed';
      case CheckoutStatus.cancelled:
        return 'Cancelled';
      case CheckoutStatus.failed:
        return 'Failed';
      case CheckoutStatus.expired:
        return 'Expired';
    }
  }

  /// Returns the step number for progress indication (1-4 for active states)
  int get stepNumber {
    switch (this) {
      case CheckoutStatus.pending:
      case CheckoutStatus.shippingInfo:
        return 1;
      case CheckoutStatus.paymentMethod:
        return 2;
      case CheckoutStatus.review:
        return 3;
      case CheckoutStatus.processing:
      case CheckoutStatus.completed:
        return 4;
      case CheckoutStatus.cancelled:
      case CheckoutStatus.failed:
      case CheckoutStatus.expired:
        return 0;
    }
  }
}
