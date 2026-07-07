import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../packages/commerce_kit/core/extensions/money_riverpod_extension.dart';
import '../../../packages/commerce_kit/core/models/money.dart';

/// Example widget showing how to use locale-aware money formatting
class MoneyExampleWidget extends ConsumerWidget {
  const MoneyExampleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const price = Money(99.99);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default formatting (uses currency code):',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          price.formatted,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        Text(
          'Locale-aware formatting (changes based on app language):',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          price.formattedWithContext(context),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        Text(
          'Context-based formatting (alternative method):',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          price.formattedWithContext(context),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),

        // Show current language for demonstration
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Language Info:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text('Locale: ${Localizations.localeOf(context)}'),
              Text(
                'Is Arabic: ${Localizations.localeOf(context).languageCode == 'ar'}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Simple usage example in a checkout or cart context
class PriceDisplayExample extends ConsumerWidget {
  final Money amount;

  const PriceDisplayExample({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          // This will show "ج.م" in Arabic and "EGP" in English
          amount.formattedWithContext(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
