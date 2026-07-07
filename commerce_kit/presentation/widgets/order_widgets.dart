import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/order_status.dart';
import '../../core/models/order.dart';
import '../providers/order_provider.dart';

/// A widget to display order status with icon and color.
class OrderStatusBadge extends StatelessWidget {
  /// The order status.
  final OrderStatus status;

  /// Size variant.
  final bool compact;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 4 : 8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: compact ? 14 : 16,
            color: color,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            status.label,
            style: (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium)
                ?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.indigo;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.dispatched:
        return Colors.cyan;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
      case OrderStatus.pickedUp:
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        return Colors.red;
      case OrderStatus.refunded:
      case OrderStatus.returned:
      case OrderStatus.returning:
        return Colors.amber;
      case OrderStatus.onHold:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.inventory_2_outlined;
      case OrderStatus.dispatched:
        return Icons.local_shipping_outlined;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.pickedUp:
        return Icons.shopping_bag;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.failed:
        return Icons.error_outline;
      case OrderStatus.refunded:
        return Icons.currency_exchange;
      case OrderStatus.onHold:
        return Icons.pause_circle_outline;
      case OrderStatus.returning:
        return Icons.keyboard_return;
      case OrderStatus.returned:
        return Icons.assignment_return;
    }
  }
}

/// A card widget to display order summary.
class OrderCard extends StatelessWidget {
  /// The order.
  final Order order;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Callback when reorder is pressed.
  final VoidCallback? onReorder;

  /// Show reorder button.
  final bool showReorderButton;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onReorder,
    this.showReorderButton = true,
    this.backgroundColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Order number and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Items preview
            Text(
              '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                order.items.take(3).map((i) => i.name).join(', ') +
                    (order.items.length > 3 ? '...' : ''),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            // Footer - Total and actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        order.summary.total.formatted,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showReorderButton && order.status.isFulfilled)
                  OutlinedButton.icon(
                    onPressed: onReorder,
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Reorder'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// A list of orders.
class OrdersList extends StatelessWidget {
  /// Orders to display.
  final List<Order> orders;

  /// Callback when an order is tapped.
  final void Function(Order order)? onOrderTap;

  /// Callback when reorder is pressed.
  final void Function(Order order)? onReorder;

  /// Empty state widget.
  final Widget? emptyWidget;

  /// Loading state.
  final bool isLoading;

  /// Has more orders to load.
  final bool hasMore;

  /// Callback when load more is triggered.
  final VoidCallback? onLoadMore;

  /// Item spacing.
  final double spacing;

  const OrdersList({
    super.key,
    required this.orders,
    this.onOrderTap,
    this.onReorder,
    this.emptyWidget,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty && !isLoading) {
      return emptyWidget ?? _buildEmptyState(context);
    }

    return ListView.separated(
      itemCount: orders.length + (hasMore || isLoading ? 1 : 0),
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        if (index == orders.length) {
          if (isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (hasMore) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: onLoadMore,
                  child: const Text('Load More'),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final order = orders[index];
        return OrderCard(
          order: order,
          onTap: onOrderTap != null ? () => onOrderTap!(order) : null,
          onReorder: onReorder != null ? () => onReorder!(order) : null,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your orders will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A connected orders list.
class ConnectedOrdersList extends ConsumerWidget {
  /// Callback when an order is tapped.
  final void Function(Order order)? onOrderTap;

  /// Callback when reorder is pressed.
  final void Function(Order order)? onReorder;

  /// Empty state widget.
  final Widget? emptyWidget;

  const ConnectedOrdersList({
    super.key,
    this.onOrderTap,
    this.onReorder,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(filteredOrdersProvider);
    final isLoading = ref.watch(ordersLoadingProvider);
    final hasMore = ref.watch(hasMoreOrdersProvider);
    final notifier = ref.read(ordersProvider.notifier);

    return OrdersList(
      orders: orders,
      isLoading: isLoading,
      hasMore: hasMore,
      emptyWidget: emptyWidget,
      onOrderTap: onOrderTap,
      onReorder: onReorder,
      onLoadMore: () => notifier.loadOrders(),
    );
  }
}

/// Order tracking timeline widget.
class OrderTrackingTimeline extends StatelessWidget {
  /// The order.
  final Order order;

  /// Whether to show expanded details.
  final bool expanded;

  const OrderTrackingTimeline({
    super.key,
    required this.order,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _getTrackingSteps();
    final currentStep = order.status.trackingStep;

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = currentStep >= index + 1;
        final isCurrent = currentStep == index + 1;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    border: isCurrent
                        ? Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : step.icon,
                    size: 14,
                    color: isCompleted
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: expanded ? 48 : 32,
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Step content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCompleted || isCurrent
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (expanded && step.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        step.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<_TrackingStep> _getTrackingSteps() {
    return [
      _TrackingStep(
        title: 'Order Placed',
        subtitle: 'Your order has been received',
        icon: Icons.receipt_outlined,
      ),
      _TrackingStep(
        title: 'Confirmed',
        subtitle: 'Order confirmed and being prepared',
        icon: Icons.check_circle_outline,
      ),
      _TrackingStep(
        title: 'Preparing',
        subtitle: 'Your order is being prepared',
        icon: Icons.restaurant,
      ),
      _TrackingStep(
        title: 'On the Way',
        subtitle: 'Your order is out for delivery',
        icon: Icons.delivery_dining,
      ),
      _TrackingStep(
        title: 'Delivered',
        subtitle: 'Your order has been delivered',
        icon: Icons.check_circle,
      ),
    ];
  }
}

class _TrackingStep {
  final String title;
  final String? subtitle;
  final IconData icon;

  _TrackingStep({
    required this.title,
    this.subtitle,
    required this.icon,
  });
}

/// Order detail header widget.
class OrderDetailHeader extends StatelessWidget {
  /// The order.
  final Order order;

  /// Callback when cancel is pressed.
  final VoidCallback? onCancel;

  /// Callback when contact support is pressed.
  final VoidCallback? onContactSupport;

  const OrderDetailHeader({
    super.key,
    required this.order,
    this.onCancel,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(order.createdAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            OrderStatusBadge(status: order.status),
          ],
        ),
        const SizedBox(height: 16),
        if (order.canCancel || onContactSupport != null)
          Row(
            children: [
              if (order.canCancel && onCancel != null)
                OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Order'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              if (order.canCancel && onCancel != null && onContactSupport != null)
                const SizedBox(width: 12),
              if (onContactSupport != null)
                OutlinedButton.icon(
                  onPressed: onContactSupport,
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Contact Support'),
                ),
            ],
          ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Order items list widget.
class OrderItemsList extends StatelessWidget {
  /// The order.
  final Order order;

  /// Whether to show prices.
  final bool showPrices;

  const OrderItemsList({
    super.key,
    required this.order,
    this.showPrices = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...order.items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.fastfood,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.optionsSummary.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.optionsSummary,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${item.quantity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showPrices)
                  Text(
                    item.finalPrice.formatted,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Order summary widget.
class OrderDetailSummaryWidget extends StatelessWidget {
  /// The order.
  final Order order;

  const OrderDetailSummaryWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = order.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildRow(context, 'Subtotal', summary.subtotal.formatted),
        if (summary.totalDiscount.isPositive)
          _buildRow(
            context,
            'Discount${order.couponCode != null ? ' (${order.couponCode})' : ''}',
            '-${summary.totalDiscount.formatted}',
            valueColor: Colors.green,
          ),
        if (summary.shippingCost.isPositive)
          _buildRow(context, 'Delivery Fee', summary.shippingCost.formatted),
        if (summary.serviceFee.isPositive)
          _buildRow(context, 'Service Fee', summary.serviceFee.formatted),
        if (summary.tax.isPositive)
          _buildRow(context, 'Tax', summary.tax.formatted),
        if (order.walletUsed.isPositive)
          _buildRow(
            context,
            'Wallet',
            '-${order.walletUsed.formatted}',
            valueColor: Colors.green,
          ),
        const Divider(height: 24),
        _buildRow(
          context,
          'Total',
          summary.total.formatted,
          isBold: true,
          valueColor: theme.colorScheme.primary,
        ),
        if (order.pointsEarned > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Text(
                  'You earned ${order.pointsEarned} points!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          Text(
            value,
            style: isBold
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor,
                    fontWeight: valueColor != null ? FontWeight.w500 : null,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Order filter tabs widget.
class OrderFilterTabs extends StatelessWidget {
  /// Currently selected filter.
  final OrderFilter currentFilter;

  /// Callback when filter changes.
  final ValueChanged<OrderFilter>? onFilterChanged;

  const OrderFilterTabs({
    super.key,
    required this.currentFilter,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTab(context, 'All', const OrderFilter()),
          const SizedBox(width: 8),
          _buildTab(context, 'Active', OrderFilter.active),
          const SizedBox(width: 8),
          _buildTab(context, 'Completed', OrderFilter.completed),
          const SizedBox(width: 8),
          _buildTab(context, 'Cancelled', OrderFilter.cancelled),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, OrderFilter filter) {
    final isSelected = _filtersMatch(currentFilter, filter);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterChanged?.call(filter),
    );
  }

  bool _filtersMatch(OrderFilter a, OrderFilter b) {
    if (a.statuses.isEmpty && b.statuses.isEmpty) return true;
    if (a.statuses.length != b.statuses.length) return false;
    return a.statuses.every((s) => b.statuses.contains(s));
  }
}

/// A connected order filter tabs.
class ConnectedOrderFilterTabs extends ConsumerWidget {
  const ConnectedOrderFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(orderFilterProvider);
    final notifier = ref.read(ordersProvider.notifier);

    return OrderFilterTabs(
      currentFilter: filter,
      onFilterChanged: notifier.setFilter,
    );
  }
}

/// Active order banner widget.
class ActiveOrderBanner extends StatelessWidget {
  /// The active order.
  final Order order;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Background color.
  final Color? backgroundColor;

  const ActiveOrderBanner({
    super.key,
    required this.order,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(order.status),
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.status.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.inventory_2_outlined;
      case OrderStatus.dispatched:
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      default:
        return Icons.receipt_outlined;
    }
  }
}

/// A connected active order banner.
class ConnectedActiveOrderBanner extends ConsumerWidget {
  /// Callback when tapped.
  final VoidCallback? onTap;

  const ConnectedActiveOrderBanner({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(mostRecentActiveOrderProvider);

    if (order == null) {
      return const SizedBox.shrink();
    }

    return ActiveOrderBanner(
      order: order,
      onTap: onTap,
    );
  }
}
