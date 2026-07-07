import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/coupon.dart';
import '../../core/models/money.dart';
import '../providers/coupon_provider.dart';

/// A widget for entering and applying coupon codes.
class CouponInputWidget extends StatefulWidget {
  /// Current coupon code.
  final String? currentCode;

  /// Whether a coupon is applied.
  final bool isApplied;

  /// Validation message.
  final String? message;

  /// Whether validation succeeded.
  final bool? isValid;

  /// Whether validating.
  final bool isValidating;

  /// Callback when apply is pressed.
  final ValueChanged<String>? onApply;

  /// Callback when remove is pressed.
  final VoidCallback? onRemove;

  /// Hint text.
  final String hintText;

  /// Apply button text.
  final String applyText;

  /// Remove button text.
  final String removeText;

  /// Background color.
  final Color? backgroundColor;

  /// Border color.
  final Color? borderColor;

  /// Success color.
  final Color? successColor;

  /// Error color.
  final Color? errorColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  /// Prefix icon.
  final Widget? prefixIcon;

  const CouponInputWidget({
    super.key,
    this.currentCode,
    this.isApplied = false,
    this.message,
    this.isValid,
    this.isValidating = false,
    this.onApply,
    this.onRemove,
    this.hintText = 'Enter coupon code',
    this.applyText = 'Apply',
    this.removeText = 'Remove',
    this.backgroundColor,
    this.borderColor,
    this.successColor,
    this.errorColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
    this.prefixIcon,
  });

  @override
  State<CouponInputWidget> createState() => _CouponInputWidgetState();
}

class _CouponInputWidgetState extends State<CouponInputWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentCode);
  }

  @override
  void didUpdateWidget(CouponInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentCode != oldWidget.currentCode) {
      _controller.text = widget.currentCode ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveSuccessColor = widget.successColor ?? Colors.green;
    final effectiveErrorColor = widget.errorColor ?? theme.colorScheme.error;

    Color? getMessageColor() {
      if (widget.isValid == null) return null;
      return widget.isValid! ? effectiveSuccessColor : effectiveErrorColor;
    }

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.borderColor != null
            ? Border.all(color: widget.borderColor!)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !widget.isApplied && !widget.isValidating,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: widget.prefixIcon ??
                        const Icon(Icons.local_offer_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (widget.isApplied)
                OutlinedButton(
                  onPressed: widget.onRemove,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: effectiveErrorColor,
                    side: BorderSide(color: effectiveErrorColor),
                  ),
                  child: Text(widget.removeText),
                )
              else
                ElevatedButton(
                  onPressed: widget.isValidating ||
                          _controller.text.trim().isEmpty
                      ? null
                      : () => widget.onApply?.call(_controller.text.trim()),
                  child: widget.isValidating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.applyText),
                ),
            ],
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  widget.isValid == true
                      ? Icons.check_circle
                      : Icons.error_outline,
                  size: 16,
                  color: getMessageColor(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.message!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: getMessageColor(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A connected coupon input widget.
class ConnectedCouponInputWidget extends ConsumerWidget {
  /// Hint text.
  final String hintText;

  /// Apply button text.
  final String applyText;

  /// Remove button text.
  final String removeText;

  /// Order amount for validation.
  final Money orderAmount;

  /// Background color.
  final Color? backgroundColor;

  /// Border color.
  final Color? borderColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  /// Prefix icon.
  final Widget? prefixIcon;

  const ConnectedCouponInputWidget({
    super.key,
    required this.orderAmount,
    this.hintText = 'Enter coupon code',
    this.applyText = 'Apply',
    this.removeText = 'Remove',
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponState = ref.watch(couponProvider);
    final message = ref.watch(couponMessageProvider);

    return CouponInputWidget(
      currentCode: couponState.appliedCoupon?.code ?? couponState.inputCode,
      isApplied: couponState.hasCouponApplied,
      message: message,
      isValid: couponState.validation?.isValid,
      isValidating: couponState.isValidating,
      hintText: hintText,
      applyText: applyText,
      removeText: removeText,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      prefixIcon: prefixIcon,
      onApply: (code) async {
        await ref.read(couponProvider.notifier).validateAndApply(
              code,
              orderAmount: orderAmount,
            );
      },
      onRemove: () {
        ref.read(couponProvider.notifier).removeCoupon();
      },
    );
  }
}

/// A widget to display an applied coupon.
class AppliedCouponWidget extends StatelessWidget {
  /// Applied coupon.
  final Coupon coupon;

  /// Discount amount.
  final Money discountAmount;

  /// Callback when remove is pressed.
  final VoidCallback? onRemove;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const AppliedCouponWidget({
    super.key,
    required this.coupon,
    required this.discountAmount,
    this.onRemove,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.code,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                Text(
                  coupon.formattedDiscount,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${discountAmount.formatted}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 20),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}

/// A connected applied coupon widget.
class ConnectedAppliedCouponWidget extends ConsumerWidget {
  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding.
  final EdgeInsets padding;

  const ConnectedAppliedCouponWidget({
    super.key,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupon = ref.watch(appliedCouponProvider);
    final discount = ref.watch(couponDiscountAmountProvider);

    if (coupon == null) {
      return const SizedBox.shrink();
    }

    return AppliedCouponWidget(
      coupon: coupon,
      discountAmount: discount,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
      onRemove: () {
        ref.read(couponProvider.notifier).removeCoupon();
      },
    );
  }
}

/// A widget to display available coupons.
class AvailableCouponsWidget extends StatelessWidget {
  /// List of coupons.
  final List<Coupon> coupons;

  /// Currently applied coupon.
  final Coupon? appliedCoupon;

  /// Callback when coupon is selected.
  final ValueChanged<Coupon>? onSelect;

  /// Title.
  final String? title;

  /// Empty state widget.
  final Widget? emptyWidget;

  /// Border radius.
  final double borderRadius;

  /// Spacing between items.
  final double spacing;

  const AvailableCouponsWidget({
    super.key,
    required this.coupons,
    this.appliedCoupon,
    this.onSelect,
    this.title,
    this.emptyWidget,
    this.borderRadius = 12.0,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (coupons.isEmpty) {
      return emptyWidget ?? const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ...coupons.map((coupon) => Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: _CouponCard(
                coupon: coupon,
                isApplied: coupon.id == appliedCoupon?.id,
                onSelect: onSelect,
                borderRadius: borderRadius,
              ),
            ),),
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  final Coupon coupon;
  final bool isApplied;
  final ValueChanged<Coupon>? onSelect;
  final double borderRadius;

  const _CouponCard({
    required this.coupon,
    required this.isApplied,
    this.onSelect,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = coupon.isValid;

    return InkWell(
      onTap: isValid && !isApplied ? () => onSelect?.call(coupon) : null,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isApplied
              ? Colors.green.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isApplied
                ? Colors.green
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_offer,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        coupon.code,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isValid) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            coupon.isExpired ? 'Expired' : 'Unavailable',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon.formattedDiscount,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (coupon.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        coupon.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (coupon.minimumOrderAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Min. order: ${coupon.minimumOrderAmount!.formatted}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isApplied)
              const Icon(Icons.check_circle, color: Colors.green)
            else if (isValid)
              const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

/// A connected available coupons widget.
class ConnectedAvailableCouponsWidget extends ConsumerWidget {
  /// Title.
  final String? title;

  /// Empty state widget.
  final Widget? emptyWidget;

  /// Border radius.
  final double borderRadius;

  /// Spacing between items.
  final double spacing;

  /// Order amount for validation.
  final Money orderAmount;

  const ConnectedAvailableCouponsWidget({
    super.key,
    required this.orderAmount,
    this.title,
    this.emptyWidget,
    this.borderRadius = 12.0,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = ref.watch(validCouponsProvider);
    final appliedCoupon = ref.watch(appliedCouponProvider);

    return AvailableCouponsWidget(
      coupons: coupons,
      appliedCoupon: appliedCoupon,
      title: title,
      emptyWidget: emptyWidget,
      borderRadius: borderRadius,
      spacing: spacing,
      onSelect: (coupon) async {
        await ref.read(couponProvider.notifier).validateAndApply(
              coupon.code,
              orderAmount: orderAmount,
            );
      },
    );
  }
}
