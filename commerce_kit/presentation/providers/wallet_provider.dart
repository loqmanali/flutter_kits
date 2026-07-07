import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/wallet_transaction_type.dart';
import '../../core/models/money.dart';
import '../../core/models/wallet.dart';

/// Wallet state.
class WalletState {
  /// Wallet account.
  final Wallet? wallet;

  /// Transaction history.
  final List<WalletTransaction> transactions;

  /// Loading state.
  final bool isLoading;

  /// Error message.
  final String? error;

  const WalletState({
    this.wallet,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  const WalletState.initial()
      : wallet = null,
        transactions = const [],
        isLoading = false,
        error = null;

  WalletState copyWith({
    Wallet? wallet,
    List<WalletTransaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Convenience getters
  bool get hasWallet => wallet != null;
  Money get balance => wallet?.balance ?? const Money.zero();
  Money get totalBalance => wallet?.totalBalance ?? const Money.zero();
  Money get promotionalBalance =>
      wallet?.promotionalBalance ?? const Money.zero();
  Money get cashbackBalance => wallet?.cashbackBalance ?? const Money.zero();
  bool get isActive => wallet?.isActive ?? false;
}

/// Wallet notifier.
class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() {
    return const WalletState.initial();
  }

  /// Sets the wallet.
  void setWallet(Wallet wallet) {
    state = state.copyWith(wallet: wallet);
  }

  /// Updates wallet from API response.
  void updateFromJson(Map<String, dynamic> json) {
    final wallet = Wallet.fromJson(json);
    state = state.copyWith(wallet: wallet);
  }

  /// Sets transaction history.
  void setTransactions(List<WalletTransaction> transactions) {
    state = state.copyWith(transactions: transactions);
  }

  /// Adds a transaction.
  void addTransaction(WalletTransaction transaction) {
    state = state.copyWith(
      transactions: [transaction, ...state.transactions],
    );
  }

  /// Simulates adding money to wallet.
  void topUp(Money amount, {String? description}) {
    if (state.wallet == null) return;

    final transaction = WalletTransaction(
      id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
      walletId: state.wallet!.id,
      type: WalletTransactionType.credit,
      amount: amount,
      balanceAfter: state.wallet!.balance + amount,
      description: description ?? 'Top up',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      wallet: state.wallet!.copyWith(
        balance: state.wallet!.balance + amount,
        updatedAt: DateTime.now(),
      ),
      transactions: [transaction, ...state.transactions],
    );
  }

  /// Simulates using wallet for payment.
  bool useForPayment(Money amount, {String? orderId, String? description}) {
    if (state.wallet == null) return false;
    if (!state.wallet!.canCover(amount)) return false;

    final transaction = WalletTransaction(
      id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
      walletId: state.wallet!.id,
      type: WalletTransactionType.debit,
      amount: amount,
      balanceAfter: state.wallet!.totalBalance - amount,
      orderId: orderId,
      description: description ?? 'Payment',
      createdAt: DateTime.now(),
    );

    // Deduct from promotional first, then cashback, then main balance
    var remaining = amount;
    var newPromotional = state.wallet!.promotionalBalance;
    var newCashback = state.wallet!.cashbackBalance;
    var newBalance = state.wallet!.balance;

    if (remaining <= newPromotional) {
      newPromotional = newPromotional - remaining;
      remaining = const Money.zero();
    } else {
      remaining = remaining - newPromotional;
      newPromotional = const Money.zero();
    }

    if (remaining.isPositive && remaining <= newCashback) {
      newCashback = newCashback - remaining;
      remaining = const Money.zero();
    } else if (remaining.isPositive) {
      remaining = remaining - newCashback;
      newCashback = const Money.zero();
    }

    if (remaining.isPositive) {
      newBalance = newBalance - remaining;
    }

    state = state.copyWith(
      wallet: state.wallet!.copyWith(
        balance: newBalance,
        promotionalBalance: newPromotional,
        cashbackBalance: newCashback,
        updatedAt: DateTime.now(),
      ),
      transactions: [transaction, ...state.transactions],
    );

    return true;
  }

  /// Simulates receiving a refund.
  void refund(Money amount, {String? orderId, String? description}) {
    if (state.wallet == null) return;

    final transaction = WalletTransaction(
      id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
      walletId: state.wallet!.id,
      type: WalletTransactionType.refund,
      amount: amount,
      balanceAfter: state.wallet!.balance + amount,
      orderId: orderId,
      description: description ?? 'Refund',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      wallet: state.wallet!.copyWith(
        balance: state.wallet!.balance + amount,
        updatedAt: DateTime.now(),
      ),
      transactions: [transaction, ...state.transactions],
    );
  }

  /// Simulates receiving cashback.
  void addCashback(Money amount, {String? orderId, String? description}) {
    if (state.wallet == null) return;

    final transaction = WalletTransaction(
      id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
      walletId: state.wallet!.id,
      type: WalletTransactionType.cashback,
      amount: amount,
      balanceAfter: state.wallet!.totalBalance + amount,
      orderId: orderId,
      description: description ?? 'Cashback',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      wallet: state.wallet!.copyWith(
        cashbackBalance: state.wallet!.cashbackBalance + amount,
        updatedAt: DateTime.now(),
      ),
      transactions: [transaction, ...state.transactions],
    );
  }

  /// Simulates receiving promotional credit.
  void addPromotionalCredit(
    Money amount, {
    String? description,
    DateTime? expiresAt,
  }) {
    if (state.wallet == null) return;

    final transaction = WalletTransaction(
      id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
      walletId: state.wallet!.id,
      type: WalletTransactionType.promotional,
      amount: amount,
      balanceAfter: state.wallet!.totalBalance + amount,
      description: description ?? 'Promotional credit',
      expiresAt: expiresAt,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      wallet: state.wallet!.copyWith(
        promotionalBalance: state.wallet!.promotionalBalance + amount,
        promotionalExpiresAt: expiresAt ?? state.wallet!.promotionalExpiresAt,
        updatedAt: DateTime.now(),
      ),
      transactions: [transaction, ...state.transactions],
    );
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

  /// Clears wallet data.
  void clear() {
    state = const WalletState.initial();
  }
}

/// Main wallet provider.
final walletProvider =
    NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Selector Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for wallet.
final walletAccountProvider = Provider<Wallet?>((ref) {
  return ref.watch(walletProvider.select((s) => s.wallet));
});

/// Provider for main balance.
final walletBalanceProvider = Provider<Money>((ref) {
  return ref.watch(walletProvider.select((s) => s.balance));
});

/// Provider for total balance.
final walletTotalBalanceProvider = Provider<Money>((ref) {
  return ref.watch(walletProvider.select((s) => s.totalBalance));
});

/// Provider for promotional balance.
final walletPromotionalBalanceProvider = Provider<Money>((ref) {
  return ref.watch(walletProvider.select((s) => s.promotionalBalance));
});

/// Provider for cashback balance.
final walletCashbackBalanceProvider = Provider<Money>((ref) {
  return ref.watch(walletProvider.select((s) => s.cashbackBalance));
});

/// Provider for balance breakdown.
final walletBalanceBreakdownProvider =
    Provider<WalletBalanceBreakdown>((ref) {
  final wallet = ref.watch(walletAccountProvider);
  if (wallet == null) {
    return const WalletBalanceBreakdown();
  }
  return WalletBalanceBreakdown(
    mainBalance: wallet.balance,
    promotionalBalance: wallet.promotionalBalance,
    cashbackBalance: wallet.cashbackBalance,
    pendingBalance: wallet.pendingBalance,
  );
});

/// Provider for transaction history.
final walletTransactionsProvider = Provider<List<WalletTransaction>>((ref) {
  return ref.watch(walletProvider.select((s) => s.transactions));
});

/// Provider for wallet active state.
final walletActiveProvider = Provider<bool>((ref) {
  return ref.watch(walletProvider.select((s) => s.isActive));
});

/// Provider for wallet loading state.
final walletLoadingProvider = Provider<bool>((ref) {
  return ref.watch(walletProvider.select((s) => s.isLoading));
});

/// Provider for wallet error.
final walletErrorProvider = Provider<String?>((ref) {
  return ref.watch(walletProvider.select((s) => s.error));
});

/// Provider for checking if wallet has balance.
final hasWalletBalanceProvider = Provider<bool>((ref) {
  return ref.watch(walletTotalBalanceProvider).isPositive;
});

/// Family provider for checking if wallet can cover amount.
final canCoverAmountProvider = Provider.family<bool, Money>((ref, amount) {
  final wallet = ref.watch(walletAccountProvider);
  return wallet?.canCover(amount) ?? false;
});

/// Family provider for usable amount.
final usableWalletAmountProvider = Provider.family<Money, Money>((ref, maxAmount) {
  final wallet = ref.watch(walletAccountProvider);
  return wallet?.usableAmount(maxAmount) ?? const Money.zero();
});

/// Provider for expiring promotional balance.
final expiringPromotionalProvider =
    Provider<({Money amount, DateTime? expiresAt, bool isExpiringSoon})>((ref) {
  final wallet = ref.watch(walletAccountProvider);
  return (
    amount: wallet?.promotionalBalance ?? const Money.zero(),
    expiresAt: wallet?.promotionalExpiresAt,
    isExpiringSoon: wallet?.isPromotionalExpiringSoon ?? false,
  );
});
