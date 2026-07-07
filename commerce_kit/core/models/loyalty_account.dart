import 'package:equatable/equatable.dart';

import '../enums/loyalty_tier.dart';
import '../enums/points_transaction_type.dart';
import 'money.dart';

/// Represents a user's loyalty account.
class LoyaltyAccount extends Equatable {
  /// Unique account identifier.
  final String id;

  /// User ID.
  final String userId;

  /// Current points balance.
  final int pointsBalance;

  /// Lifetime points earned.
  final int lifetimePoints;

  /// Lifetime points redeemed.
  final int lifetimeRedeemed;

  /// Current tier.
  final LoyaltyTier tier;

  /// Points needed for next tier.
  final int? pointsToNextTier;

  /// Progress percentage to next tier (0-100).
  final double? nextTierProgress;

  /// Points expiring soon.
  final int expiringPoints;

  /// Expiration date for expiring points.
  final DateTime? expiringPointsDate;

  /// Points to money conversion rate (points per currency unit).
  final double pointsPerUnit;

  /// Currency for conversion.
  final String currency;

  /// Current multiplier (based on tier and promotions).
  final double currentMultiplier;

  /// Whether account is active.
  final bool isActive;

  /// Account creation date.
  final DateTime createdAt;

  /// Last activity date.
  final DateTime? lastActivityAt;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  /// Creates a [LoyaltyAccount].
  const LoyaltyAccount({
    required this.id,
    required this.userId,
    this.pointsBalance = 0,
    this.lifetimePoints = 0,
    this.lifetimeRedeemed = 0,
    this.tier = LoyaltyTier.none,
    this.pointsToNextTier,
    this.nextTierProgress,
    this.expiringPoints = 0,
    this.expiringPointsDate,
    this.pointsPerUnit = 100,
    this.currency = 'EGP',
    this.currentMultiplier = 1.0,
    this.isActive = true,
    required this.createdAt,
    this.lastActivityAt,
    this.metadata = const {},
  });

  /// Returns the money value of current points.
  Money get pointsValue =>
      Money(pointsBalance / pointsPerUnit, currency: currency);

  /// Returns the money value for a given number of points.
  Money valueForPoints(int points) =>
      Money(points / pointsPerUnit, currency: currency);

  /// Returns the points needed for a given money amount.
  int pointsForValue(Money amount) => (amount.amount * pointsPerUnit).round();

  /// Returns true if user has enough points for redemption.
  bool hasEnoughPoints(int requiredPoints) => pointsBalance >= requiredPoints;

  /// Returns true if user has enough points for a money value.
  bool hasEnoughPointsForValue(Money amount) =>
      hasEnoughPoints(pointsForValue(amount));

  /// Creates a [LoyaltyAccount] from JSON.
  factory LoyaltyAccount.fromJson(Map<String, dynamic> json) {
    return LoyaltyAccount(
      id: json['id'] as String,
      userId: json['user_id'] ?? json['userId'] as String,
      pointsBalance:
          json['points_balance'] ?? json['pointsBalance'] ?? json['points'] as int? ?? 0,
      lifetimePoints:
          json['lifetime_points'] ?? json['lifetimePoints'] as int? ?? 0,
      lifetimeRedeemed:
          json['lifetime_redeemed'] ?? json['lifetimeRedeemed'] as int? ?? 0,
      tier: json['tier'] != null
          ? LoyaltyTier.values.firstWhere(
              (e) => e.name == json['tier'],
              orElse: () => LoyaltyTier.none,
            )
          : LoyaltyTier.none,
      pointsToNextTier:
          json['points_to_next_tier'] ?? json['pointsToNextTier'] as int?,
      nextTierProgress:
          (json['next_tier_progress'] ?? json['nextTierProgress'] as num?)
              ?.toDouble(),
      expiringPoints:
          json['expiring_points'] ?? json['expiringPoints'] as int? ?? 0,
      expiringPointsDate: json['expiring_points_date'] != null
          ? DateTime.parse(json['expiring_points_date'] as String)
          : json['expiringPointsDate'] != null
              ? DateTime.parse(json['expiringPointsDate'] as String)
              : null,
      pointsPerUnit:
          (json['points_per_unit'] ?? json['pointsPerUnit'] as num?)?.toDouble() ??
              100,
      currency: json['currency'] as String? ?? 'EGP',
      currentMultiplier:
          (json['current_multiplier'] ?? json['currentMultiplier'] as num?)
                  ?.toDouble() ??
              1.0,
      isActive: json['is_active'] ?? json['isActive'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.parse(json['last_activity_at'] as String)
          : json['lastActivityAt'] != null
              ? DateTime.parse(json['lastActivityAt'] as String)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'points_balance': pointsBalance,
        'lifetime_points': lifetimePoints,
        'lifetime_redeemed': lifetimeRedeemed,
        'tier': tier.name,
        'points_to_next_tier': pointsToNextTier,
        'next_tier_progress': nextTierProgress,
        'expiring_points': expiringPoints,
        'expiring_points_date': expiringPointsDate?.toIso8601String(),
        'points_per_unit': pointsPerUnit,
        'currency': currency,
        'current_multiplier': currentMultiplier,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'last_activity_at': lastActivityAt?.toIso8601String(),
        'metadata': metadata,
      };

  /// Creates a copy with updated values.
  LoyaltyAccount copyWith({
    String? id,
    String? userId,
    int? pointsBalance,
    int? lifetimePoints,
    int? lifetimeRedeemed,
    LoyaltyTier? tier,
    int? pointsToNextTier,
    double? nextTierProgress,
    int? expiringPoints,
    DateTime? expiringPointsDate,
    double? pointsPerUnit,
    String? currency,
    double? currentMultiplier,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    Map<String, dynamic>? metadata,
  }) {
    return LoyaltyAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      lifetimeRedeemed: lifetimeRedeemed ?? this.lifetimeRedeemed,
      tier: tier ?? this.tier,
      pointsToNextTier: pointsToNextTier ?? this.pointsToNextTier,
      nextTierProgress: nextTierProgress ?? this.nextTierProgress,
      expiringPoints: expiringPoints ?? this.expiringPoints,
      expiringPointsDate: expiringPointsDate ?? this.expiringPointsDate,
      pointsPerUnit: pointsPerUnit ?? this.pointsPerUnit,
      currency: currency ?? this.currency,
      currentMultiplier: currentMultiplier ?? this.currentMultiplier,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        pointsBalance,
        lifetimePoints,
        lifetimeRedeemed,
        tier,
        pointsToNextTier,
        nextTierProgress,
        expiringPoints,
        expiringPointsDate,
        pointsPerUnit,
        currency,
        currentMultiplier,
        isActive,
        createdAt,
        lastActivityAt,
        metadata,
      ];
}

/// Represents a points transaction.
class PointsTransaction extends Equatable {
  /// Unique transaction identifier.
  final String id;

  /// User ID.
  final String userId;

  /// Transaction type.
  final PointsTransactionType type;

  /// Points amount (positive for credit, stored as absolute value).
  final int points;

  /// Points balance after transaction.
  final int? balanceAfter;

  /// Related order ID.
  final String? orderId;

  /// Description/reason.
  final String? description;

  /// Money value equivalent.
  final Money? moneyValue;

  /// Expiration date for earned points.
  final DateTime? expiresAt;

  /// Transaction date.
  final DateTime createdAt;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  /// Creates a [PointsTransaction].
  const PointsTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.points,
    this.balanceAfter,
    this.orderId,
    this.description,
    this.moneyValue,
    this.expiresAt,
    required this.createdAt,
    this.metadata = const {},
  });

  /// Returns signed points value.
  int get signedPoints => type.isCredit ? points : -points;

  /// Returns formatted points string.
  String get formattedPoints => '${type.sign}$points';

  /// Creates a [PointsTransaction] from JSON.
  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    return PointsTransaction(
      id: json['id'] as String,
      userId: json['user_id'] ?? json['userId'] as String,
      type: PointsTransactionType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'earned'),
        orElse: () => PointsTransactionType.earned,
      ),
      points: (json['points'] as int).abs(),
      balanceAfter: json['balance_after'] ?? json['balanceAfter'] as int?,
      orderId: json['order_id'] ?? json['orderId'] as String?,
      description: json['description'] as String?,
      moneyValue: json['money_value'] != null
          ? Money.fromJson(json['money_value'] as Map<String, dynamic>)
          : json['moneyValue'] != null
              ? Money((json['moneyValue'] as num).toDouble())
              : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : json['expiresAt'] != null
              ? DateTime.parse(json['expiresAt'] as String)
              : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type.name,
        'points': points,
        'balance_after': balanceAfter,
        'order_id': orderId,
        'description': description,
        'money_value': moneyValue?.toJson(),
        'expires_at': expiresAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'metadata': metadata,
      };

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        points,
        balanceAfter,
        orderId,
        description,
        moneyValue,
        expiresAt,
        createdAt,
        metadata,
      ];
}

/// Represents tier benefits.
class TierBenefits extends Equatable {
  /// The tier.
  final LoyaltyTier tier;

  /// Points multiplier.
  final double pointsMultiplier;

  /// Free shipping threshold (null = no free shipping).
  final Money? freeShippingThreshold;

  /// Exclusive discount percentage.
  final double? exclusiveDiscount;

  /// Priority support.
  final bool prioritySupport;

  /// Early access to sales.
  final bool earlyAccess;

  /// Birthday bonus points.
  final int? birthdayBonusPoints;

  /// List of benefit descriptions.
  final List<String> benefits;

  /// Creates [TierBenefits].
  const TierBenefits({
    required this.tier,
    this.pointsMultiplier = 1.0,
    this.freeShippingThreshold,
    this.exclusiveDiscount,
    this.prioritySupport = false,
    this.earlyAccess = false,
    this.birthdayBonusPoints,
    this.benefits = const [],
  });

  /// Creates from JSON.
  factory TierBenefits.fromJson(Map<String, dynamic> json) {
    return TierBenefits(
      tier: LoyaltyTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => LoyaltyTier.none,
      ),
      pointsMultiplier:
          (json['points_multiplier'] ?? json['pointsMultiplier'] as num?)
                  ?.toDouble() ??
              1.0,
      freeShippingThreshold: json['free_shipping_threshold'] != null
          ? Money.fromJson(
              json['free_shipping_threshold'] as Map<String, dynamic>,
            )
          : null,
      exclusiveDiscount:
          (json['exclusive_discount'] ?? json['exclusiveDiscount'] as num?)
              ?.toDouble(),
      prioritySupport:
          json['priority_support'] ?? json['prioritySupport'] as bool? ?? false,
      earlyAccess:
          json['early_access'] ?? json['earlyAccess'] as bool? ?? false,
      birthdayBonusPoints:
          json['birthday_bonus_points'] ?? json['birthdayBonusPoints'] as int?,
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'points_multiplier': pointsMultiplier,
        'free_shipping_threshold': freeShippingThreshold?.toJson(),
        'exclusive_discount': exclusiveDiscount,
        'priority_support': prioritySupport,
        'early_access': earlyAccess,
        'birthday_bonus_points': birthdayBonusPoints,
        'benefits': benefits,
      };

  @override
  List<Object?> get props => [
        tier,
        pointsMultiplier,
        freeShippingThreshold,
        exclusiveDiscount,
        prioritySupport,
        earlyAccess,
        birthdayBonusPoints,
        benefits,
      ];
}
