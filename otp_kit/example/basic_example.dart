import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:otp_kit/otp_kit.dart';

/// Basic example of using OTPTextField
///
/// This example shows the simplest way to use the OTP module
class BasicOTPExample extends ConsumerWidget {
  const BasicOTPExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic OTP Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              OTPTextField(
                config: OTPTheme.defaultLight(context),
                onCompleted: (otp) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('OTP Entered: $otp')));
                },
                onChanged: (value) {
                  debugPrint('OTP value changed: $value');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
