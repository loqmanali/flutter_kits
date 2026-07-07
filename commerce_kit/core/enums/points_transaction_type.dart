/// Represents the type of points transaction.
enum PointsTransactionType {
  /// Points earned from purchase
  earned,

  /// Points redeemed for discount
  redeemed,

  /// Points expired
  expired,

  /// Bonus points (promotional)
  bonus,

  /// Points from referral
  referral,

  /// Points adjustment (manual)
  adjustment,

  /// Points refunded (order cancelled)
  refunded,

  /// Points transferred in
  transferIn,

  /// Points transferred out
  transferOut,

  /// Points from review/feedback
  review,

  /// Points from birthday/anniversary
  birthday,

  /// Points from tier upgrade bonus
  tierBonus,

  /// Points converted to wallet balance
  converted,

  /// Points from completing profile
  profile,

  /// Points from social sharing
  social,
}

/// Extension methods for [PointsTransactionType].
extension PointsTransactionTypeExtension on PointsTransactionType {
  /// Returns true if this transaction adds points
  bool get isCredit =>
      this == PointsTransactionType.earned ||
      this == PointsTransactionType.bonus ||
      this == PointsTransactionType.referral ||
      this == PointsTransactionType.refunded ||
      this == PointsTransactionType.transferIn ||
      this == PointsTransactionType.review ||
      this == PointsTransactionType.birthday ||
      this == PointsTransactionType.tierBonus ||
      this == PointsTransactionType.profile ||
      this == PointsTransactionType.social;

  /// Returns true if this transaction removes points
  bool get isDebit =>
      this == PointsTransactionType.redeemed ||
      this == PointsTransactionType.expired ||
      this == PointsTransactionType.transferOut ||
      this == PointsTransactionType.converted;

  /// Returns true if this is a bonus/promotional type
  bool get isBonus =>
      this == PointsTransactionType.bonus ||
      this == PointsTransactionType.birthday ||
      this == PointsTransactionType.tierBonus;

  /// Returns true if points from engagement activities
  bool get isEngagement =>
      this == PointsTransactionType.review ||
      this == PointsTransactionType.profile ||
      this == PointsTransactionType.social;

  /// Returns a human-readable label
  String get label {
    switch (this) {
      case PointsTransactionType.earned:
        return 'Points Earned';
      case PointsTransactionType.redeemed:
        return 'Points Redeemed';
      case PointsTransactionType.expired:
        return 'Points Expired';
      case PointsTransactionType.bonus:
        return 'Bonus Points';
      case PointsTransactionType.referral:
        return 'Referral Bonus';
      case PointsTransactionType.adjustment:
        return 'Adjustment';
      case PointsTransactionType.refunded:
        return 'Points Refunded';
      case PointsTransactionType.transferIn:
        return 'Transfer Received';
      case PointsTransactionType.transferOut:
        return 'Transfer Sent';
      case PointsTransactionType.review:
        return 'Review Reward';
      case PointsTransactionType.birthday:
        return 'Birthday Bonus';
      case PointsTransactionType.tierBonus:
        return 'Tier Bonus';
      case PointsTransactionType.converted:
        return 'Converted to Cash';
      case PointsTransactionType.profile:
        return 'Profile Completion';
      case PointsTransactionType.social:
        return 'Social Sharing';
    }
  }

  /// Returns the sign for display (+/-)
  String get sign => isCredit ? '+' : '-';
}
