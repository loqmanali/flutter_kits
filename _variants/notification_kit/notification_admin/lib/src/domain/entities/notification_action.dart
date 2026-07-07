import 'package:equatable/equatable.dart';

/// Represents an action that can be performed on a notification.
///
/// Notification actions appear as buttons beneath notifications and allow
/// users to perform quick actions without opening the app. Each action
/// can trigger specific behavior when tapped.
///
/// ## Usage
/// ```dart
/// final action = NotificationAction(
///   id: 'view_order',
///   title: 'View Order',
///   icon: 'shopping_cart',
///   requiresForeground: true,
/// );
///
/// // Add to notification
/// final notification = NotificationEntity(
///   // ... other properties
///   actions: [action],
/// );
/// ```
class NotificationAction extends Equatable {
  /// Unique identifier for the action.
  ///
  /// Used to identify which action was tapped when handling
  /// notification interactions. Must be unique within the notification.
  final String id;

  /// Display title for the action button.
  ///
  /// This text appears on the action button in the notification.
  final String title;

  /// Optional icon resource for the action.
  ///
  /// Can be a drawable resource name or icon identifier.
  /// Platform-specific implementation may vary.
  final String? icon;

  /// Whether the action is destructive.
  ///
  /// Destructive actions are displayed in red on iOS to indicate
  /// potentially harmful operations (like delete or dismiss).
  final bool isDestructive;

  /// Whether the action requires the app to be brought to foreground.
  ///
  /// When true, tapping the action will open the app. This is required
  /// for actions that need user interaction or app processing.
  final bool requiresForeground;

  const NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.isDestructive = false,
    this.requiresForeground = true,
  });

  @override
  List<Object?> get props =>
      [id, title, icon, isDestructive, requiresForeground];
}
