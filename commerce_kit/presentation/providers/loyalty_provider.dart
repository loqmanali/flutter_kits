import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/loyalty_tier.dart';
import '../../core/enums/points_transaction_type.dart';
import '../../core/models/loyalty_account.dart';
import '../../core/models/money.dart';

/// Loyalty state.
class LoyaltyState {
  /// Loyalty account.
  final LoyaltyAccount? account;

  /// Transaction history.
  final List<PointsTransaction> transactions;

  /// Tier benefits.
  final TierBenefits? tierBenefits;

  /// Loading state.
  final bool isLoading;

  /// Error message.
  final String? error;

  const LoyaltyState({
    this.account,
    this.transactions = const [],
    this.tierBenefits,
    this.isLoading = false,
    this.error,
  });

  const LoyaltyState.initial()
      : account = null,
        transactions = const [],
        tierBenefits = null,
        isLoading = false,
        error = null;

  LoyaltyState copyWith({
    LoyaltyAccount? account,
    List<PointsTransaction>? transactions,
    TierBenefits? tierBenefits,
    bool? isLoading,
    String? error,
  }) {
    return LoyaltyState(
      account: account ?? this.account,
      transactions: transactions ?? this.transactions,
      tierBenefits: tierBenefits ?? this.tierBenefits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Convenience getters
  bool get isEnrolled => account != null && account!.tier != LoyaltyTier.none;
  int get pointsBalance => account?.pointsBalance ?? 0;
  LoyaltyTier get tier => account?.tier ?? LoyaltyTier.none;
  Money get pointsValue => account?.pointsValue ?? const Money.zero();
  double get currentMultiplier => account?.currentMultiplier ?? 1.0;
  bool get hasExpiringPoints =>
      account != null && account!.expiringPoints > 0;
}

/// Loyalty notifier.
class LoyaltyNotifier extends Notifier<LoyaltyState> {
  @override
  LoyaltyState build() {
    return const LoyaltyState.initial();
  }

  /// Sets the loyalty account.
  void setAccount(LoyaltyAccount account) {
    state = state.copyWith(account: account);
  }

  /// Updates loyalty account from API response.
  void updateFromJson(Map<String, dynamic> json) {
    final account = LoyaltyAccount.fromJson(json);
    state = state.copyWith(account: account);
  }

  /// Sets transaction history.
  void setTransactions(List<PointsTransaction> transactions) {
    state = state.copyWith(transactions: transactions);
  }

  /// Adds a transaction.
  void addTransaction(PointsTransaction transaction) {
    state = state.copyWith(
      transactions: [transaction, ...state.transactions],
    );
  }

  /// Sets tier benefits.
  void setTierBenefits(TierBenefits benefits) {
    state = state.copyWith(tierBenefits: benefits);
  }

  /// Simulates earning points.
  void earnPoints(int points, {String? description, String? orderId}) {
    if (state.account == null) return;

    final transaction = PointsTransaction(
      id: 'pt_${DateTime.now().millisecondsSinceEpoch}',
      userId: state.account!.userId,
      type: PointsTransactionType.earned,
      points: points,
      balanceAfter: state.account!.pointsBalance + points,
      orderId: orderId,
      description: description,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      account: state.account!.copyWith(
        pointsBalance: state.account!.pointsBalance + points,
        lifetimePoints: state.account!.lifetimePoints + points,
        lastActivityAt: DateTime.now(),
      ),
      transactions: [transaction, ...state.transactions],
    );
  }

  /// Simulates redeeming points.
  bool redeemPoints(int points, {String? description, String? orderId}) {
    if (state.account == null) return false;
    if (!state.account!.hasEnoughPoints(points)) return false;

    final transaction = PointsTransaction(
      id: 'pt_${DateTime.now().millisecondsSinceEpoch}',
      userId: state.account!.userId,
      type: PointsTransactionType.redeemed,
      points: points,
      balanceAfter: state.account!.pointsBalance - points,
      orderId: orderId,
      description: description,
      moneyValue: state.account!.valueForPoints(points),
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      account: state.account!.copyWith(
        pointsBalance: state.account!.pointsBalance - points,
        lifetimeRedeemed: state.account!.lifetimeRedeemed + points,
        lastActivityAt: DateTime.now(),
      ),
      transactions: [transaction, ...state.transactions],
    );

    return true;
  }

  /// Sets loading state.
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Sets error.
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Clears error.
  void clearError() {
    state = state.copyWith();
  }

  /// Clears loyalty data.
  void clear() {
    state = const LoyaltyState.initial();
  }
}

/// Main loyalty provider.
final loyaltyProvider =
    NotifierProvider<LoyaltyNotifier, LoyaltyState>(LoyaltyNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Selector Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for loyalty account.
final loyaltyAccountProvider = Provider<LoyaltyAccount?>((ref) {
  return ref.watch(loyaltyProvider.select((s) => s.account));
});

/// Provider for points balance.
final pointsBalanceProvider = Provider<int>((ref) {
  return ref.watch(loyaltyProvider.select((s) => s.pointsBalance));
});

/// Provider for points value.
final pointsValueProvider = Provider<Money>((ref) {
  return ref.watch(loyaltyProvider.select((s) => s.pointsValue));
});

/// Provider for loyalty tier.
final loyaltyTierProvider = Provider<LoyaltyTier>((ref) {
  return ref.watch(loyaltyProvider.select((s) => s.tier));
});

/// Provider for tier benefits.
final tierBenefitsProvider = Provider<TierBenefits?>((ref) {
  return ref.watch(loyaltyProvider.select((s) => s.tierBenefits));
});

/// Provider for points multiplier.
final pointsMultiplierProvider = Provider<double>((ref) {
  return ref.watch(loyaltyProvider.select((s) => s.currentMultiplier));
});

/// Provider for transaction history.
final pointsTransactionsProvider = Provider<List<PointsTransaction>>((ref) {
  return ref.watch(loyaltyProvider.select((s) => s.transactions));
});

/// Provider for enrollment status.
final isLoyaltyEnrolledProvider = Provider<bool>((ref) {
  return ref.watch(loyaltyProvider.select((s) => s.isEnrolled));
});

/// Provider for expiring points info.
final expiringPointsProvider =
    Provider<({int points, DateTime? expiresAt})>((ref) {
  final account = ref.watch(loyaltyAccountProvider);
  return (
    points: account?.expiringPoints ?? 0,
    expiresAt: account?.expiringPointsDate,
  );
});

/// Provider for next tier progress.
final nextTierProgressProvider =
    Provider<({LoyaltyTier? nextTier, int? pointsNeeded, double? progress})>(
        (ref) {
  final account = ref.watch(loyaltyAccountProvider);
  return (
    nextTier: account?.tier.nextTier,
    pointsNeeded: account?.pointsToNextTier,
    progress: account?.nextTierProgress,
  );
});

/// Provider for loyalty loading state.
final loyaltyLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loyaltyProvider.select((s) => s.isLoading));
});

/// Provider for loyalty error.
final loyaltyErrorProvider = Provider<String?>((ref) {
  return ref.watch(loyaltyProvider.select((s) => s.error));
});

/// Family provider for checking if user can redeem specific points.
final canRedeemPointsProvider = Provider.family<bool, int>((ref, points) {
  final account = ref.watch(loyaltyAccountProvider);
  return account?.hasEnoughPoints(points) ?? false;
});

/// Family provider for calculating points value.
final pointsToValueProvider = Provider.family<Money, int>((ref, points) {
  final account = ref.watch(loyaltyAccountProvider);
  return account?.valueForPoints(points) ?? const Money.zero();
});

/// Family provider for calculating points needed for value.
final valueToPointsProvider = Provider.family<int, Money>((ref, value) {
  final account = ref.watch(loyaltyAccountProvider);
  return account?.pointsForValue(value) ?? 0;
});
