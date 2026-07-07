import 'package:equatable/equatable.dart';

/// Represents a notification channel configuration.
///
/// Notification channels organize notifications by type and allow users
/// to control notification preferences for different categories of messages.
/// Required for Android 8.0 (API level 26) and above.
///
/// ## Usage
/// ```dart
/// final channel = NotificationChannelEntity(
///   id: 'orders',
///   name: 'Order Updates',
///   description: 'Notifications about your order status',
///   importance: true,
///   enableVibration: true,
///   playSound: true,
/// );
///
/// // Create channel on Android
/// await notificationPlugin.createNotificationChannel(channel);
/// ```
class NotificationChannelEntity extends Equatable {
  /// Unique identifier for the channel.
  ///
  /// Used to reference this channel when creating notifications.
  /// Must be unique across all channels in the app.
  final String id;

  /// User-visible name for the channel.
  ///
  /// Displayed in the app's notification settings.
  final String name;

  /// Optional description of the channel's purpose.
  ///
  /// Provides additional context about the types of notifications
  /// sent through this channel. Displayed in notification settings.
  final String? description;

  /// Whether the channel has high importance.
  ///
  /// High importance channels can make sound and appear on screen.
  /// Low importance channels are silent and won't interrupt.
  final bool importance;

  /// Whether notifications in this channel show badges.
  ///
  /// When true, notifications from this channel contribute to
  /// the app icon badge count.
  final bool showBadge;

  /// Whether notifications in this channel vibrate.
  ///
  /// When true, notifications will trigger device vibration
  /// if vibration is enabled system-wide.
  final bool enableVibration;

  /// Whether notifications in this channel play sound.
  ///
  /// When true, notifications will play the default notification
  /// sound or a custom sound if specified.
  final bool playSound;

  const NotificationChannelEntity({
    required this.id,
    required this.name,
    this.description,
    this.importance = true,
    this.showBadge = true,
    this.enableVibration = true,
    this.playSound = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        importance,
        showBadge,
        enableVibration,
        playSound,
      ];
}
