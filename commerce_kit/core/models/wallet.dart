import 'package:equatable/equatable.dart';

import '../enums/wallet_transaction_type.dart';
import 'money.dart';

/// Represents a user's wallet account.
class Wallet extends Equatable {
  /// Unique wallet identifier.
  final String id;

  /// User ID.
  final String userId;

  /// Main balance (from top-ups).
  final Money balance;

  /// Promotional/bonus balance (may expire).
  final Money promotionalBalance;

  /// Cashback balance.
  final Money cashbackBalance;

  /// Total available balance.
  Money get totalBalance => balance + promotionalBalance + cashbackBalance;

  /// Pending balance (e.g., refunds being processed).
  final Money pendingBalance;

  /// Currency.
  final String currency;

  /// Whether wallet is active.
  final bool isActive;

  /// Maximum balance allowed.
  final Money? maxBalance;

  /// Minimum top-up amount.
  final Money? minTopUp;

  /// Maximum top-up amount.
  final Money? maxTopUp;

  /// Promotional balance expiration date.
  final DateTime? promotionalExpiresAt;

  /// Cashback expiration date.
  final DateTime? cashbackExpiresAt;

  /// Creation date.
  final DateTime createdAt;

  /// Last updated date.
  final DateTime updatedAt;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  /// Creates a [Wallet].
  const Wallet({
    required this.id,
    required this.userId,
    this.balance = const Money.zero(),
    this.promotionalBalance = const Money.zero(),
    this.cashbackBalance = const Money.zero(),
    this.pendingBalance = const Money.zero(),
    this.currency = 'EGP',
    this.isActive = true,
    this.maxBalance,
    this.minTopUp,
    this.maxTopUp,
    this.promotionalExpiresAt,
    this.cashbackExpiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  /// Returns true if wallet has balance.
  bool get hasBalance => totalBalance.isPositive;

  /// Returns true if wallet can cover the amount.
  bool canCover(Money amount) => totalBalance >= amount;

  /// Returns the amount that can be used (min of balance and amount).
  Money usableAmount(Money amount) {
    if (totalBalance >= amount) {
      return amount;
    }
    return totalBalance;
  }

  /// Returns true if promotional balance is expiring soon (within 7 days).
  bool get isPromotionalExpiringSoon {
    if (promotionalExpiresAt == null || promotionalBalance.isZero) {
      return false;
    }
    return promotionalExpiresAt!.difference(DateTime.now()).inDays <= 7;
  }

  /// Creates a [Wallet] from JSON.
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      userId: json['user_id'] ?? json['userId'] as String,
      balance: json['balance'] != null
          ? Money.fromJson(json['balance'] as Map<String, dynamic>)
          : const Money.zero(),
      promotionalBalance: json['promotional_balance'] != null
          ? Money.fromJson(json['promotional_balance'] as Map<String, dynamic>)
          : json['promotionalBalance'] != null
              ? Money((json['promotionalBalance'] as num).toDouble())
              : const Money.zero(),
      cashbackBalance: json['cashback_balance'] != null
          ? Money.fromJson(json['cashback_balance'] as Map<String, dynamic>)
          : json['cashbackBalance'] != null
              ? Money((json['cashbackBalance'] as num).toDouble())
              : const Money.zero(),
      pendingBalance: json['pending_balance'] != null
          ? Money.fromJson(json['pending_balance'] as Map<String, dynamic>)
          : json['pendingBalance'] != null
              ? Money((json['pendingBalance'] as num).toDouble())
              : const Money.zero(),
      currency: json['currency'] as String? ?? 'EGP',
      isActive: json['is_active'] ?? json['isActive'] as bool? ?? true,
      maxBalance: json['max_balance'] != null
          ? Money.fromJson(json['max_balance'] as Map<String, dynamic>)
          : null,
      minTopUp: json['min_top_up'] != null
          ? Money.fromJson(json['min_top_up'] as Map<String, dynamic>)
          : null,
      maxTopUp: json['max_top_up'] != null
          ? Money.fromJson(json['max_top_up'] as Map<String, dynamic>)
          : null,
      promotionalExpiresAt: json['promotional_expires_at'] != null
          ? DateTime.parse(json['promotional_expires_at'] as String)
          : json['promotionalExpiresAt'] != null
              ? DateTime.parse(json['promotionalExpiresAt'] as String)
              : null,
      cashbackExpiresAt: json['cashback_expires_at'] != null
          ? DateTime.parse(json['cashback_expires_at'] as String)
          : json['cashbackExpiresAt'] != null
              ? DateTime.parse(json['cashbackExpiresAt'] as String)
              : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'balance': balance.toJson(),
        'promotional_balance': promotionalBalance.toJson(),
        'cashback_balance': cashbackBalance.toJson(),
        'pending_balance': pendingBalance.toJson(),
        'total_balance': totalBalance.toJson(),
        'currency': currency,
        'is_active': isActive,
        'max_balance': maxBalance?.toJson(),
        'min_top_up': minTopUp?.toJson(),
        'max_top_up': maxTopUp?.toJson(),
        'promotional_expires_at': promotionalExpiresAt?.toIso8601String(),
        'cashback_expires_at': cashbackExpiresAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'metadata': metadata,
      };

  /// Creates a copy with updated values.
  Wallet copyWith({
    String? id,
    String? userId,
    Money? balance,
    Money? promotionalBalance,
    Money? cashbackBalance,
    Money? pendingBalance,
    String? currency,
    bool? isActive,
    Money? maxBalance,
    Money? minTopUp,
    Money? maxTopUp,
    DateTime? promotionalExpiresAt,
    DateTime? cashbackExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      promotionalBalance: promotionalBalance ?? this.promotionalBalance,
      cashbackBalance: cashbackBalance ?? this.cashbackBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      maxBalance: maxBalance ?? this.maxBalance,
      minTopUp: minTopUp ?? this.minTopUp,
      maxTopUp: maxTopUp ?? this.maxTopUp,
      promotionalExpiresAt: promotionalExpiresAt ?? this.promotionalExpiresAt,
      cashbackExpiresAt: cashbackExpiresAt ?? this.cashbackExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        balance,
        promotionalBalance,
        cashbackBalance,
        pendingBalance,
        currency,
        isActive,
        maxBalance,
        minTopUp,
        maxTopUp,
        promotionalExpiresAt,
        cashbackExpiresAt,
        createdAt,
        updatedAt,
        metadata,
      ];
}

/// Represents a wallet transaction.
class WalletTransaction extends Equatable {
  /// Unique transaction identifier.
  final String id;

  /// Wallet ID.
  final String walletId;

  /// Transaction type.
  final WalletTransactionType type;

  /// Transaction amount (always positive).
  final Money amount;

  /// Balance after transaction.
  final Money? balanceAfter;

  /// Related order ID.
  final String? orderId;

  /// Description.
  final String? description;

  /// Reference number.
  final String? referenceNumber;

  /// Expiration date (for promotional credits).
  final DateTime? expiresAt;

  /// Transaction date.
  final DateTime createdAt;

  /// Whether transaction is pending.
  final bool isPending;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  /// Creates a [WalletTransaction].
  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    this.balanceAfter,
    this.orderId,
    this.description,
    this.referenceNumber,
    this.expiresAt,
    required this.createdAt,
    this.isPending = false,
    this.metadata = const {},
  });

  /// Returns signed amount.
  Money get signedAmount => type.isCredit ? amount : -amount;

  /// Returns formatted amount string.
  String get formattedAmount => '${type.sign}${amount.formatted}';

  /// Creates a [WalletTransaction] from JSON.
  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      walletId: json['wallet_id'] ?? json['walletId'] as String,
      type: WalletTransactionType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'credit'),
        orElse: () => WalletTransactionType.credit,
      ),
      amount: json['amount'] != null
          ? Money.fromJson(json['amount'] as Map<String, dynamic>)
          : Money((json['value'] as num?)?.toDouble() ?? 0),
      balanceAfter: json['balance_after'] != null
          ? Money.fromJson(json['balance_after'] as Map<String, dynamic>)
          : json['balanceAfter'] != null
              ? Money((json['balanceAfter'] as num).toDouble())
              : null,
      orderId: json['order_id'] ?? json['orderId'] as String?,
      description: json['description'] as String?,
      referenceNumber:
          json['reference_number'] ?? json['referenceNumber'] as String?,
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
      isPending: json['is_pending'] ?? json['isPending'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'wallet_id': walletId,
        'type': type.name,
        'amount': amount.toJson(),
        'balance_after': balanceAfter?.toJson(),
        'order_id': orderId,
        'description': description,
        'reference_number': referenceNumber,
        'expires_at': expiresAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'is_pending': isPending,
        'metadata': metadata,
      };

  @override
  List<Object?> get props => [
        id,
        walletId,
        type,
        amount,
        balanceAfter,
        orderId,
        description,
        referenceNumber,
        expiresAt,
        createdAt,
        isPending,
        metadata,
      ];
}

/// Wallet balance breakdown.
class WalletBalanceBreakdown extends Equatable {
  /// Main balance.
  final Money mainBalance;

  /// Promotional balance.
  final Money promotionalBalance;

  /// Cashback balance.
  final Money cashbackBalance;

  /// Pending balance.
  final Money pendingBalance;

  /// Total available.
  Money get totalAvailable =>
      mainBalance + promotionalBalance + cashbackBalance;

  /// Creates a [WalletBalanceBreakdown].
  const WalletBalanceBreakdown({
    this.mainBalance = const Money.zero(),
    this.promotionalBalance = const Money.zero(),
    this.cashbackBalance = const Money.zero(),
    this.pendingBalance = const Money.zero(),
  });

  /// Creates from JSON.
  factory WalletBalanceBreakdown.fromJson(Map<String, dynamic> json) {
    return WalletBalanceBreakdown(
      mainBalance: json['main_balance'] != null
          ? Money.fromJson(json['main_balance'] as Map<String, dynamic>)
          : const Money.zero(),
      promotionalBalance: json['promotional_balance'] != null
          ? Money.fromJson(json['promotional_balance'] as Map<String, dynamic>)
          : const Money.zero(),
      cashbackBalance: json['cashback_balance'] != null
          ? Money.fromJson(json['cashback_balance'] as Map<String, dynamic>)
          : const Money.zero(),
      pendingBalance: json['pending_balance'] != null
          ? Money.fromJson(json['pending_balance'] as Map<String, dynamic>)
          : const Money.zero(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'main_balance': mainBalance.toJson(),
        'promotional_balance': promotionalBalance.toJson(),
        'cashback_balance': cashbackBalance.toJson(),
        'pending_balance': pendingBalance.toJson(),
        'total_available': totalAvailable.toJson(),
      };

  @override
  List<Object?> get props => [
        mainBalance,
        promotionalBalance,
        cashbackBalance,
        pendingBalance,
      ];
}
