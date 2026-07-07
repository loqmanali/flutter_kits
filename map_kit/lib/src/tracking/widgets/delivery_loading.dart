import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

/// Widget that shows loading state for delivery tracking
class DeliveryLoadingIndicator extends ConsumerWidget {
  final Widget? loadingWidget;
  final String? loadingText;
  final Widget child;

  const DeliveryLoadingIndicator({
    super.key,
    this.loadingWidget,
    this.loadingText,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      deliveryTrackingProvider.select((s) => s.isLoading),
    );

    if (isLoading) {
      return loadingWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                if (loadingText != null) ...[
                  const SizedBox(height: 16),
                  Text(loadingText!),
                ],
              ],
            ),
          );
    }

    return child;
  }
}

/// Widget that shows error state for delivery tracking
class DeliveryErrorHandler extends ConsumerWidget {
  final Widget Function(BuildContext, String error)? errorBuilder;
  final Widget child;
  final bool showErrorAsSnackBar;

  const DeliveryErrorHandler({
    super.key,
    this.errorBuilder,
    required this.child,
    this.showErrorAsSnackBar = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMessage = ref.watch(
      deliveryTrackingProvider.select((s) => s.errorMessage),
    );

    if (errorMessage != null && !showErrorAsSnackBar) {
      if (errorBuilder != null) {
        return errorBuilder!(context, errorMessage);
      }
    }

    // Show as snackbar if configured
    if (errorMessage != null && showErrorAsSnackBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      });
    }

    return child;
  }
}
