import 'package:flutter/material.dart';

class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const NotificationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enable Notifications'),
      content: const Text(
        'Stay updated with the latest offers, order updates, and news by enabling notifications.',
      ),
      actions: [
        TextButton(
          onPressed: onDeny,
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: onAllow,
          child: const Text('Allow'),
        ),
      ],
    );
  }
}
