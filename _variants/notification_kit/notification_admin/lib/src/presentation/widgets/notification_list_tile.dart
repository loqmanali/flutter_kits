import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationListTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationListTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.status == NotificationStatus.read || notification.readAt != null;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        color: theme.colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      child: ListTile(
        onTap: onTap,
        tileColor: isRead ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        leading: notification.imageUrl != null
            ? CircleAvatar(backgroundImage: NetworkImage(notification.imageUrl!))
            : CircleAvatar(
                backgroundColor: isRead ? theme.disabledColor : theme.colorScheme.primary,
                child: Icon(
                  Icons.notifications,
                  color: isRead ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
                ),
              ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              DateFormat.yMMMd().add_jm().format(notification.createdAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
