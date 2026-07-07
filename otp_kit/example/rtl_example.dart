import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:otp_kit/otp_kit.dart';

/// Example showcasing RTL support side-by-side with LTR.
class RTLExample extends ConsumerWidget {
  const RTLExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ltrConfig = OTPTheme.custom(context: context, length: 4);
    final rtlConfig = OTPTheme.custom(context: context, length: 4, isRTL: true);

    return Scaffold(
      appBar: AppBar(title: const Text('RTL Support')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'LTR (Left-to-Right)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            OTPTextField(
              config: ltrConfig,
              onCompleted: (otp) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('LTR OTP: $otp')));
              },
            ),
            const SizedBox(height: 48),
            const Text(
              'RTL (Right-to-Left)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Cells fill from right to left for Arabic / Hebrew flows.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            OTPTextField(
              config: rtlConfig,
              onCompleted: (otp) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('RTL OTP: $otp')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
