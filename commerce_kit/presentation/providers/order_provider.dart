import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/order_status.dart';
import '../../core/models/order.dart';

/// Sort options for orders.
enum OrderSortOption {
  /// Most recent first.
  mostRecent,

  /// Oldest first.
  oldest,

  /// By status.
  byStatus,

  /// By total amount.
  byAmount,
}

/// Filter options for orders.
class OrderFilter {
  /// Filter by status.
  final OrderStatus? status;

  /// Filter by statuses (multiple).
  final List<OrderStatus> statuses;

  /// Date range start.
  final DateTime? fromDate;

  /// Date range end.
  final DateTime? toDate;

  /// Search query (order number, etc.).
  final String? query;

  /// Sort option.
  final OrderSortOption sortBy;

  /// Creates an [OrderFilter].
  const OrderFilter({
    this.status,
    this.statuses = const [],
    this.fromDate,
    this.toDate,
    this.query,
    this.sortBy = OrderSortOption.mostRecent,
  });

  /// Default filter.
  static const OrderFilter defaults = OrderFilter();

  /// Filter for active orders.
  static const OrderFilter active = OrderFilter(
    statuses: [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.dispatched,
      OrderStatus.outForDelivery,
    ],
  );

  /// Filter for completed orders.
  static const OrderFilter completed = OrderFilter(
    statuses: [OrderStatus.delivered, OrderStatus.pickedUp],
  );

  /// Filter for cancelled orders.
  static const OrderFilter cancelled = OrderFilter(
    statuses: [OrderStatus.cancelled, OrderStatus.refunded],
  );

  /// Whether any filter is active.
  bool get hasActiveFilters =>
      status != null ||
      statuses.isNotEmpty ||
      fromDate != null ||
      toDate != null ||
      (query != null && query!.isNotEmpty);

  OrderFilter copyWith({
    OrderStatus? status,
    List<OrderStatus>? statuses,
    DateTime? fromDate,
    DateTime? toDate,
    String? query,
    OrderSortOption? sortBy,
    bool clearStatus = false,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearQuery = false,
  }) {
    return OrderFilter(
      status: clearStatus ? null : (status ?? this.status),
      statuses: statuses ?? this.statuses,
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      query: clearQuery ? null : (query ?? this.query),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// State for order management.
class OrdersState {
  /// All orders.
  final List<Order> orders;

  /// Currently selected order.
  final Order? selectedOrder;

  /// Current filter.
  final OrderFilter filter;

  /// Whether loading.
  final bool isLoading;

  /// Error message.
  final String? error;

  /// Current page for pagination.
  final int page;

  /// Whether there are more orders.
  final bool hasMore;

  const OrdersState({
    this.orders = const [],
    this.selectedOrder,
    this.filter = const OrderFilter(),
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  /// Creates initial state.
  factory OrdersState.initial() => const OrdersState();

  /// Filtered and sorted orders.
  List<Order> get filteredOrders {
    var result = orders.toList();

    // Apply status filter
    if (filter.status != null) {
      result = result.where((o) => o.status == filter.status).toList();
    }

    // Apply statuses filter
    if (filter.statuses.isNotEmpty) {
      result = result.where((o) => filter.statuses.contains(o.status)).toList();
    }

    // Apply date range
    if (filter.fromDate != null) {
      result = result.where((o) => o.createdAt.isAfter(filter.fromDate!)).toList();
    }
    if (filter.toDate != null) {
      result = result
          .where((o) => o.createdAt.isBefore(filter.toDate!.add(const Duration(days: 1))))
          .toList();
    }

    // Apply search query
    if (filter.query != null && filter.query!.isNotEmpty) {
      final query = filter.query!.toLowerCase();
      result = result.where((o) {
        return o.orderNumber.toLowerCase().contains(query) ||
            o.id.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    switch (filter.sortBy) {
      case OrderSortOption.mostRecent:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case OrderSortOption.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case OrderSortOption.byStatus:
        result.sort((a, b) => a.status.index.compareTo(b.status.index));
      case OrderSortOption.byAmount:
        result.sort((a, b) => b.summary.total.amount.compareTo(a.summary.total.amount));
    }

    return result;
  }

  /// Active orders.
  List<Order> get activeOrders =>
      orders.where((o) => o.status.isActive).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Completed orders.
  List<Order> get completedOrders =>
      orders.where((o) => o.status.isFulfilled).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Cancelled orders.
  List<Order> get cancelledOrders =>
      orders.where((o) => o.status.isCancelledOrFailed).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  OrdersState copyWith({
    List<Order>? orders,
    Order? selectedOrder,
    OrderFilter? filter,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
    bool clearSelectedOrder = false,
    bool clearError = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      selectedOrder: clearSelectedOrder ? null : (selectedOrder ?? this.selectedOrder),
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Notifier for order management.
class OrdersNotifier extends Notifier<OrdersState> {
  /// Callback to load orders.
  Future<List<Order>> Function({int page, OrderFilter filter})? _loadOrdersCallback;

  /// Callback to load a single order.
  Future<Order> Function(String orderId)? _loadOrderCallback;

  /// Callback to cancel an order.
  Future<Order> Function(String orderId, String? reason)? _cancelOrderCallback;

  /// Callback to reorder (create new order from existing).
  Future<void> Function(Order order)? _reorderCallback;

  @override
  OrdersState build() {
    return OrdersState.initial();
  }

  /// Sets the load orders callback.
  void setLoadOrdersCallback(
    Future<List<Order>> Function({int page, OrderFilter filter}) callback,
  ) {
    _loadOrdersCallback = callback;
  }

  /// Sets the load order callback.
  void setLoadOrderCallback(
    Future<Order> Function(String orderId) callback,
  ) {
    _loadOrderCallback = callback;
  }

  /// Sets the cancel order callback.
  void setCancelOrderCallback(
    Future<Order> Function(String orderId, String? reason) callback,
  ) {
    _cancelOrderCallback = callback;
  }

  /// Sets the reorder callback.
  void setReorderCallback(
    Future<void> Function(Order order) callback,
  ) {
    _reorderCallback = callback;
  }

  /// Loads orders.
  Future<void> loadOrders({bool refresh = false}) async {
    if (_loadOrdersCallback == null) return;

    if (refresh) {
      state = state.copyWith(page: 1, orders: [], hasMore: true);
    }

    if (!state.hasMore && !refresh) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final orders = await _loadOrdersCallback!(
        page: state.page,
        filter: state.filter,
      );

      state = state.copyWith(
        orders: refresh ? orders : [...state.orders, ...orders],
        isLoading: false,
        page: state.page + 1,
        hasMore: orders.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Loads a specific order.
  Future<void> loadOrder(String orderId) async {
    if (_loadOrderCallback == null) {
      // Try to find in existing orders
      final existing = state.orders.where((o) => o.id == orderId).firstOrNull;
      if (existing != null) {
        state = state.copyWith(selectedOrder: existing);
      }
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final order = await _loadOrderCallback!(orderId);

      // Update in orders list if exists
      final updatedOrders = state.orders.map((o) {
        return o.id == orderId ? order : o;
      }).toList();

      state = state.copyWith(
        orders: updatedOrders,
        selectedOrder: order,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Selects an order.
  void selectOrder(Order order) {
    state = state.copyWith(selectedOrder: order);
  }

  /// Clears selected order.
  void clearSelectedOrder() {
    state = state.copyWith(clearSelectedOrder: true);
  }

  /// Sets the filter.
  void setFilter(OrderFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Sets the sort option.
  void setSortOption(OrderSortOption sortOption) {
    state = state.copyWith(
      filter: state.filter.copyWith(sortBy: sortOption),
    );
  }

  /// Filters by status.
  void filterByStatus(OrderStatus? status) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        status: status,
        clearStatus: status == null,
      ),
    );
  }

  /// Sets date range.
  void setDateRange(DateTime? fromDate, DateTime? toDate) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        fromDate: fromDate,
        toDate: toDate,
        clearFromDate: fromDate == null,
        clearToDate: toDate == null,
      ),
    );
  }

  /// Sets search query.
  void setSearchQuery(String? query) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        query: query,
        clearQuery: query == null || query.isEmpty,
      ),
    );
  }

  /// Clears all filters.
  void clearFilters() {
    state = state.copyWith(filter: const OrderFilter());
  }

  /// Cancels an order.
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    final order = state.orders.where((o) => o.id == orderId).firstOrNull;
    if (order == null || !order.canCancel) {
      state = state.copyWith(error: 'Order cannot be cancelled');
      return false;
    }

    if (_cancelOrderCallback == null) {
      state = state.copyWith(error: 'Cancel callback not configured');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final cancelledOrder = await _cancelOrderCallback!(orderId, reason);

      // Update in orders list
      final updatedOrders = state.orders.map((o) {
        return o.id == orderId ? cancelledOrder : o;
      }).toList();

      state = state.copyWith(
        orders: updatedOrders,
        selectedOrder: state.selectedOrder?.id == orderId
            ? cancelledOrder
            : state.selectedOrder,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reorders from an existing order.
  Future<void> reorder(Order order) async {
    if (_reorderCallback != null) {
      await _reorderCallback!(order);
    }
  }

  /// Adds or updates an order in the list.
  void upsertOrder(Order order) {
    final exists = state.orders.any((o) => o.id == order.id);

    if (exists) {
      final updatedOrders = state.orders.map((o) {
        return o.id == order.id ? order : o;
      }).toList();
      state = state.copyWith(orders: updatedOrders);
    } else {
      state = state.copyWith(orders: [order, ...state.orders]);
    }
  }

  /// Clears error.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Main orders provider.
final ordersProvider = NotifierProvider<OrdersNotifier, OrdersState>(
  OrdersNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Selector Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for all orders.
final allOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider.select((s) => s.orders));
});

/// Provider for filtered orders.
final filteredOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider.select((s) => s.filteredOrders));
});

/// Provider for active orders.
final activeOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider.select((s) => s.activeOrders));
});

/// Provider for completed orders.
final completedOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider.select((s) => s.completedOrders));
});

/// Provider for cancelled orders.
final cancelledOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider.select((s) => s.cancelledOrders));
});

/// Provider for selected order.
final selectedOrderProvider = Provider<Order?>((ref) {
  return ref.watch(ordersProvider.select((s) => s.selectedOrder));
});

/// Provider for orders loading state.
final ordersLoadingProvider = Provider<bool>((ref) {
  return ref.watch(ordersProvider.select((s) => s.isLoading));
});

/// Provider for orders error.
final ordersErrorProvider = Provider<String?>((ref) {
  return ref.watch(ordersProvider.select((s) => s.error));
});

/// Provider for current filter.
final orderFilterProvider = Provider<OrderFilter>((ref) {
  return ref.watch(ordersProvider.select((s) => s.filter));
});

/// Provider for has more orders.
final hasMoreOrdersProvider = Provider<bool>((ref) {
  return ref.watch(ordersProvider.select((s) => s.hasMore));
});

/// Provider for order count.
final orderCountProvider = Provider<int>((ref) {
  return ref.watch(ordersProvider.select((s) => s.orders.length));
});

/// Provider for active order count.
final activeOrderCountProvider = Provider<int>((ref) {
  return ref.watch(ordersProvider.select((s) => s.activeOrders.length));
});

/// Provider for a specific order by ID.
final orderByIdProvider = Provider.family<Order?, String>((ref, orderId) {
  final orders = ref.watch(allOrdersProvider);
  return orders.where((o) => o.id == orderId).firstOrNull;
});

/// Provider for orders by status.
final ordersByStatusProvider =
    Provider.family<List<Order>, OrderStatus>((ref, status) {
  final orders = ref.watch(allOrdersProvider);
  return orders.where((o) => o.status == status).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// Provider for recent orders (last N).
final recentOrdersProvider = Provider.family<List<Order>, int>((ref, count) {
  final orders = ref.watch(allOrdersProvider);
  final sorted = List<Order>.from(orders)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sorted.take(count).toList();
});

/// Provider for most recent active order.
final mostRecentActiveOrderProvider = Provider<Order?>((ref) {
  final activeOrders = ref.watch(activeOrdersProvider);
  return activeOrders.isNotEmpty ? activeOrders.first : null;
});

/// Provider for order filter active state.
final hasActiveOrderFiltersProvider = Provider<bool>((ref) {
  return ref.watch(ordersProvider.select((s) => s.filter.hasActiveFilters));
});

/// Provider for orders in date range.
final ordersInDateRangeProvider =
    Provider.family<List<Order>, ({DateTime from, DateTime to})>((ref, range) {
  final orders = ref.watch(allOrdersProvider);
  return orders.where((o) {
    return o.createdAt.isAfter(range.from) &&
        o.createdAt.isBefore(range.to.add(const Duration(days: 1)));
  }).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});
