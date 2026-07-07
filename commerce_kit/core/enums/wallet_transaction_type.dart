/// Represents the type of wallet transaction.
enum WalletTransactionType {
  /// Money added to wallet (top-up)
  credit,

  /// Money used from wallet (payment)
  debit,

  /// Refund credited to wallet
  refund,

  /// Cashback reward
  cashback,

  /// Promotional credit
  promotional,

  /// Points converted to wallet balance
  pointsConversion,

  /// Gift card redeemed to wallet
  giftCardRedemption,

  /// Wallet transfer received
  transferIn,

  /// Wallet transfer sent
  transferOut,

  /// Adjustment (manual correction)
  adjustment,

  /// Expired promotional balance
  expiration,

  /// Withdrawal to external account
  withdrawal,
}

/// Extension methods for [WalletTransactionType].
extension WalletTransactionTypeExtension on WalletTransactionType {
  /// Returns true if this transaction adds to balance
  bool get isCredit =>
      this == WalletTransactionType.credit ||
      this == WalletTransactionType.refund ||
      this == WalletTransactionType.cashback ||
      this == WalletTransactionType.promotional ||
      this == WalletTransactionType.pointsConversion ||
      this == WalletTransactionType.giftCardRedemption ||
      this == WalletTransactionType.transferIn;

  /// Returns true if this transaction reduces balance
  bool get isDebit =>
      this == WalletTransactionType.debit ||
      this == WalletTransactionType.transferOut ||
      this == WalletTransactionType.expiration ||
      this == WalletTransactionType.withdrawal;

  /// Returns true if this is a promotional/bonus transaction
  bool get isBonus =>
      this == WalletTransactionType.cashback ||
      this == WalletTransactionType.promotional;

  /// Returns true if this transaction can expire
  bool get canExpire =>
      this == WalletTransactionType.promotional ||
      this == WalletTransactionType.cashback;

  /// Returns a human-readable label
  String get label {
    switch (this) {
      case WalletTransactionType.credit:
        return 'Top Up';
      case WalletTransactionType.debit:
        return 'Payment';
      case WalletTransactionType.refund:
        return 'Refund';
      case WalletTransactionType.cashback:
        return 'Cashback';
      case WalletTransactionType.promotional:
        return 'Promotional Credit';
      case WalletTransactionType.pointsConversion:
        return 'Points Conversion';
      case WalletTransactionType.giftCardRedemption:
        return 'Gift Card';
      case WalletTransactionType.transferIn:
        return 'Transfer Received';
      case WalletTransactionType.transferOut:
        return 'Transfer Sent';
      case WalletTransactionType.adjustment:
        return 'Adjustment';
      case WalletTransactionType.expiration:
        return 'Expired';
      case WalletTransactionType.withdrawal:
        return 'Withdrawal';
    }
  }

  /// Returns the sign for display (+/-)
  String get sign => isCredit ? '+' : '-';
}
