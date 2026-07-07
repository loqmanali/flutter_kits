import 'package:equatable/equatable.dart';

/// Represents user notification preferences and settings.
///
/// This entity contains all the configurable notification preferences
/// that users can control through the app's notification settings.
/// It enables granular control over different types of notifications
/// and their delivery methods.
///
/// ## Usage
/// ```dart
/// final settings = NotificationSettings(
///   enabled: true,
///   soundEnabled: true,
///   vibrationEnabled: false,
///   promotionalEnabled: false,
///   quietHoursStart: DateTime(2023, 1, 1, 22, 0), // 10 PM
///   quietHoursEnd: DateTime(2023, 1, 1, 8, 0),   // 8 AM
/// );
///
/// // Update settings
/// await notificationSettingsRepository.updateSettings(settings);
/// ```
class NotificationSettings extends Equatable {
  /// Whether notifications are globally enabled.
  ///
  /// When false, no notifications will be delivered regardless
  /// of other settings. This is the master toggle.
  final bool enabled;

  /// Whether notification sounds are enabled.
  ///
  /// When true, notifications will play sound when delivered.
  /// When false, notifications will be silent.
  final bool soundEnabled;

  /// Whether vibration is enabled for notifications.
  ///
  /// When true, the device will vibrate when notifications
  /// are received (if supported by the device).
  final bool vibrationEnabled;

  /// Whether badge counts are enabled.
  ///
  /// When true, notifications contribute to the app icon
  /// badge count on supported platforms.
  final bool badgeEnabled;

  /// Whether in-app notifications are enabled.
  ///
  /// When true, notifications will be displayed as banners
  /// or alerts within the app interface.
  final bool inAppEnabled;

  /// Whether promotional notifications are enabled.
  ///
  /// When true, marketing and promotional notifications
  /// will be delivered to the user.
  final bool promotionalEnabled;

  /// Whether order update notifications are enabled.
  ///
  /// When true, notifications about order status,
  /// delivery updates, and order-related information will be delivered.
  final bool orderUpdatesEnabled;

  /// Whether news and update notifications are enabled.
  ///
  /// When true, app news, announcements, and informational
  /// notifications will be delivered.
  final bool newsEnabled;

  /// Per-channel notification settings.
  ///
  /// Maps channel IDs to boolean values indicating whether
  /// notifications for that channel are enabled.
  final Map<String, bool> channelSettings;

  /// Topic subscription preferences.
  ///
  /// Maps topic names to boolean values indicating whether
  /// the user is subscribed to that topic.
  final Map<String, bool> topicSubscriptions;

  /// Optional path to a custom notification sound file.
  ///
  /// When provided, this sound will be used instead of the
  /// default notification sound.
  final String? customSoundPath;

  /// Start time for quiet hours (do not disturb).
  ///
  /// During quiet hours, notifications will be silenced or
  /// delivered with reduced intrusiveness. The time component
  /// is used; the date component is ignored.
  final DateTime? quietHoursStart;

  /// End time for quiet hours (do not disturb).
  ///
  /// When quiet hours end, normal notification behavior resumes.
  /// The time component is used; the date component is ignored.
  final DateTime? quietHoursEnd;

  const NotificationSettings({
    this.enabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.badgeEnabled = true,
    this.inAppEnabled = true,
    this.promotionalEnabled = true,
    this.orderUpdatesEnabled = true,
    this.newsEnabled = true,
    this.channelSettings = const {},
    this.topicSubscriptions = const {},
    this.customSoundPath,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  @override
  List<Object?> get props => [
        enabled,
        soundEnabled,
        vibrationEnabled,
        badgeEnabled,
        inAppEnabled,
        promotionalEnabled,
        orderUpdatesEnabled,
        newsEnabled,
        channelSettings,
        topicSubscriptions,
        customSoundPath,
        quietHoursStart,
        quietHoursEnd,
      ];

  /// Creates a copy of this settings object with updated values.
  ///
  /// Useful for updating specific settings while preserving
  /// other existing preferences.
  ///
  /// For nullable fields that you want to explicitly set to null,
  /// use the `clearCustomSoundPath`, `clearQuietHoursStart`, or
  /// `clearQuietHoursEnd` parameters set to `true`.
  NotificationSettings copyWith({
    bool? enabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? badgeEnabled,
    bool? inAppEnabled,
    bool? promotionalEnabled,
    bool? orderUpdatesEnabled,
    bool? newsEnabled,
    Map<String, bool>? channelSettings,
    Map<String, bool>? topicSubscriptions,
    String? customSoundPath,
    bool clearCustomSoundPath = false,
    DateTime? quietHoursStart,
    bool clearQuietHoursStart = false,
    DateTime? quietHoursEnd,
    bool clearQuietHoursEnd = false,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      badgeEnabled: badgeEnabled ?? this.badgeEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      promotionalEnabled: promotionalEnabled ?? this.promotionalEnabled,
      orderUpdatesEnabled: orderUpdatesEnabled ?? this.orderUpdatesEnabled,
      newsEnabled: newsEnabled ?? this.newsEnabled,
      channelSettings: channelSettings ?? this.channelSettings,
      topicSubscriptions: topicSubscriptions ?? this.topicSubscriptions,
      customSoundPath:
          clearCustomSoundPath ? null : (customSoundPath ?? this.customSoundPath),
      quietHoursStart:
          clearQuietHoursStart ? null : (quietHoursStart ?? this.quietHoursStart),
      quietHoursEnd:
          clearQuietHoursEnd ? null : (quietHoursEnd ?? this.quietHoursEnd),
    );
  }
}
