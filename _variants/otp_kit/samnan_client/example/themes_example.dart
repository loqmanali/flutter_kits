import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:otp_kit/otp_kit.dart';

/// Example showcasing every preset under [OTPTheme].
class ThemesExample extends ConsumerWidget {
  const ThemesExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The order here mirrors the order documented in the README.
    final entries = <(String, OTPConfig)>[
      ('Default Light', OTPTheme.defaultLight(context)),
      ('Default Dark', OTPTheme.defaultDark(context)),
      ('Minimal', OTPTheme.minimal(context)),
      ('Rounded', OTPTheme.rounded(context)),
      ('Modern', OTPTheme.modern(context)),
      ('Compact', OTPTheme.compact(context)),
      ('Large (Accessible)', OTPTheme.large(context)),
      ('Secure (Obscured)', OTPTheme.secure(context)),
      ('Premium', OTPTheme.premium(context)),
      ('Underline', OTPTheme.underline(context)),
      ('Adaptive', OTPTheme.adaptive(context)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('OTP Themes')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final (title, config) = entries[i];
          return _ThemeCard(title: title, config: config);
        },
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.title, required this.config});

  final String title;
  final OTPConfig config;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            OTPTextField(
              config: config,
              onCompleted: (otp) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$title: $otp')));
              },
            ),
            const SizedBox(height: 8),
            Text(
              'length: ${config.length}  ·  type: ${config.inputType.name}'
              '  ·  size: ${config.size.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
