import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_providers.dart';
import '../providers/notification_state.dart';
import '../widgets/notification_list_tile.dart';
import 'notification_settings_page.dart';

class NotificationHistoryPage extends ConsumerStatefulWidget {
  const NotificationHistoryPage({super.key});

  @override
  ConsumerState<NotificationHistoryPage> createState() =>
      _NotificationHistoryPageState();
}

class _NotificationHistoryPageState
    extends ConsumerState<NotificationHistoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize notification system if not already
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).initialize();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more notifications when user is near the bottom
      ref.read(notificationProvider.notifier).loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ref.read(notificationProvider.notifier).markAllAsRead();
            },
            tooltip: 'Mark all as read',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const NotificationSettingsPage();
                  },
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.initStatus == NotificationInitStatus.loading &&
              state.recentNotifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.recentNotifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: state.recentNotifications.length +
                (state.hasMoreNotifications ||
                        state.recentNotifications.isNotEmpty
                    ? 1
                    : 0),
            itemBuilder: (context, index) {
              // Show loading indicator or "no more" message at the bottom
              if (index == state.recentNotifications.length) {
                if (state.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (!state.hasMoreNotifications &&
                    state.recentNotifications.isNotEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No more notifications',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }

              final notification = state.recentNotifications[index];
              return NotificationListTile(
                notification: notification,
                onTap: () {
                  ref
                      .read(notificationProvider.notifier)
                      .markAsRead(notification.id);
                  // Handle tap action if any
                },
                onDismiss: () {
                  ref
                      .read(notificationProvider.notifier)
                      .deleteNotification(notification.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
