/// Represents available payment methods.
enum PaymentMethod {
  /// Cash on delivery
  cashOnDelivery,

  /// Credit/Debit card
  card,

  /// Apple Pay
  applePay,

  /// Google Pay
  googlePay,

  /// PayPal
  paypal,

  /// In-app wallet balance
  wallet,

  /// Bank transfer
  bankTransfer,

  /// Buy now pay later services
  bnpl,

  /// Cryptocurrency
  crypto,

  /// Store credit
  storeCredit,

  /// Gift card
  giftCard,

  /// Points redemption only
  pointsOnly,

  /// Mixed payment (wallet + other method)
  mixed,
}

/// Extension methods for [PaymentMethod].
extension PaymentMethodExtension on PaymentMethod {
  /// Returns true if this is a digital/online payment method
  bool get isDigital =>
      this == PaymentMethod.card ||
      this == PaymentMethod.applePay ||
      this == PaymentMethod.googlePay ||
      this == PaymentMethod.paypal ||
      this == PaymentMethod.wallet ||
      this == PaymentMethod.crypto;

  /// Returns true if this payment method requires online processing
  bool get requiresOnlineProcessing =>
      this == PaymentMethod.card ||
      this == PaymentMethod.applePay ||
      this == PaymentMethod.googlePay ||
      this == PaymentMethod.paypal ||
      this == PaymentMethod.bnpl ||
      this == PaymentMethod.crypto;

  /// Returns true if this is a mobile wallet payment
  bool get isMobileWallet =>
      this == PaymentMethod.applePay || this == PaymentMethod.googlePay;

  /// Returns true if payment is collected on delivery
  bool get isPayOnDelivery => this == PaymentMethod.cashOnDelivery;

  /// Returns true if this uses stored balance
  bool get usesStoredBalance =>
      this == PaymentMethod.wallet ||
      this == PaymentMethod.storeCredit ||
      this == PaymentMethod.giftCard ||
      this == PaymentMethod.pointsOnly;

  /// Returns a human-readable label
  String get label {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.bnpl:
        return 'Buy Now Pay Later';
      case PaymentMethod.crypto:
        return 'Cryptocurrency';
      case PaymentMethod.storeCredit:
        return 'Store Credit';
      case PaymentMethod.giftCard:
        return 'Gift Card';
      case PaymentMethod.pointsOnly:
        return 'Pay with Points';
      case PaymentMethod.mixed:
        return 'Mixed Payment';
    }
  }

  /// Returns the icon name for this payment method
  String get iconName {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return 'cash';
      case PaymentMethod.card:
        return 'credit_card';
      case PaymentMethod.applePay:
        return 'apple_pay';
      case PaymentMethod.googlePay:
        return 'google_pay';
      case PaymentMethod.paypal:
        return 'paypal';
      case PaymentMethod.wallet:
        return 'wallet';
      case PaymentMethod.bankTransfer:
        return 'bank';
      case PaymentMethod.bnpl:
        return 'schedule';
      case PaymentMethod.crypto:
        return 'currency_bitcoin';
      case PaymentMethod.storeCredit:
        return 'store';
      case PaymentMethod.giftCard:
        return 'card_giftcard';
      case PaymentMethod.pointsOnly:
        return 'stars';
      case PaymentMethod.mixed:
        return 'payments';
    }
  }
}
