import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/notification_channels.dart';

class NotificationChannelService {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationChannelService(this._plugin);

  Future<void> createChannels() async {
    final platform = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      for (final channel in NotificationChannels.channels) {
        await platform.createNotificationChannel(channel);
      }
    }
  }
  
  Future<void> deleteChannel(String channelId) async {
    final platform = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      await platform.deleteNotificationChannel(channelId);
    }
  }
}
