import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';

class InAppNotificationBanner extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const InAppNotificationBanner({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: notification.imageUrl != null
            ? CircleAvatar(backgroundImage: NetworkImage(notification.imageUrl!))
            : const CircleAvatar(child: Icon(Icons.notifications)),
        title: Text(notification.title),
        subtitle: Text(notification.body),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onDismiss,
        ),
      ),
    );
  }
}
