import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/notification_topics.dart';
import '../../domain/entities/notification_priority.dart';
import '../../domain/entities/notification_request.dart';
import '../../domain/entities/notification_target_type.dart';
import '../../services/fcm_admin_service.dart';

// =============================================================================
// PROVIDERS - Riverpod 3.0 Style (without codegen)
// =============================================================================

/// Provider for the FCM Admin API service using Firebase HTTP v1 API
///
/// The service account JSON file is loaded from assets.
/// Uses OAuth2 authentication with JWT signing.
///
/// Make sure the service account JSON file is in assets:
/// ```yaml
/// assets:
///   - assets/burger-republic-app-359140fa6f0a.json
/// ```
final fcmAdminServiceProvider = FutureProvider<FCMAdminService>((ref) async {
  try {
    // Try to initialize from assets
    return await FCMAdminServiceImpl.fromAssets();
  } catch (e) {
    // If initialization fails, throw the error to be handled by the UI
    throw Exception('FCM Service initialization failed: $e');
  }
});

// =============================================================================
// STATE - Notification Composer
// =============================================================================

/// State for the notification admin composer
class NotificationComposerState {
  final String title;
  final String body;
  final String imageUrl;
  final NotificationTargetType targetType;
  final String? selectedTopic;
  final String? deviceToken;
  final String? customDataKey;
  final String? customDataValue;
  final FCMNotificationPriority priority;
  final bool isSending;
  final String? errorMessage;
  final String? successMessage;
  final bool isServiceInitialized;

  const NotificationComposerState({
    this.title = '',
    this.body = '',
    this.imageUrl = '',
    this.targetType = NotificationTargetType.allUsers,
    this.selectedTopic,
    this.deviceToken,
    this.customDataKey,
    this.customDataValue,
    this.priority = FCMNotificationPriority.normal,
    this.isSending = false,
    this.errorMessage,
    this.successMessage,
    this.isServiceInitialized = false,
  });

  NotificationComposerState copyWith({
    String? title,
    String? body,
    String? imageUrl,
    NotificationTargetType? targetType,
    String? selectedTopic,
    String? deviceToken,
    String? customDataKey,
    String? customDataValue,
    FCMNotificationPriority? priority,
    bool? isSending,
    String? errorMessage,
    String? successMessage,
    bool? isServiceInitialized,
  }) {
    return NotificationComposerState(
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      targetType: targetType ?? this.targetType,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      deviceToken: deviceToken ?? this.deviceToken,
      customDataKey: customDataKey ?? this.customDataKey,
      customDataValue: customDataValue ?? this.customDataValue,
      priority: priority ?? this.priority,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isServiceInitialized: isServiceInitialized ?? this.isServiceInitialized,
    );
  }

  /// Clear all messages
  NotificationComposerState clearMessages() {
    return copyWith();
  }
}

// =============================================================================
// NOTIFIER - Riverpod 3.0 Notifier Pattern
// =============================================================================

/// Notifier for managing notification composer state
/// Uses Riverpod 3.0 Notifier pattern with proper initialization
class NotificationComposerNotifier extends Notifier<NotificationComposerState> {
  @override
  NotificationComposerState build() {
    // Start initialization in background
    _initializeFcmService();
    return const NotificationComposerState();
  }

  /// Initialize FCM service and update state
  Future<void> _initializeFcmService() async {
    try {
      await ref.read(fcmAdminServiceProvider.future);
      state = state.copyWith(isServiceInitialized: true);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'FCM Service initialization error: $e',
        isServiceInitialized: false,
      );
    }
  }

  // Get the FCM service asynchronously
  Future<FCMAdminService> _getFcmService() async {
    return ref.read(fcmAdminServiceProvider.future);
  }

  void updateTitle(String value) {
    state = state.clearMessages().copyWith(title: value);
  }

  void updateBody(String value) {
    state = state.clearMessages().copyWith(body: value);
  }

  void updateImageUrl(String value) {
    state = state.clearMessages().copyWith(imageUrl: value);
  }

  void updateTargetType(NotificationTargetType type) {
    state = state.clearMessages().copyWith(
          targetType: type,
          selectedTopic: type == NotificationTargetType.topic
              ? NotificationTopics.promotions
              : null,
        );
  }

  void updateTopic(String topic) {
    state = state.clearMessages().copyWith(selectedTopic: topic);
  }

  void updateDeviceToken(String token) {
    state = state.clearMessages().copyWith(deviceToken: token);
  }

  void updateCustomDataKey(String key) {
    state = state.clearMessages().copyWith(customDataKey: key);
  }

  void updateCustomDataValue(String value) {
    state = state.clearMessages().copyWith(customDataValue: value);
  }

  void updatePriority(FCMNotificationPriority priority) {
    state = state.clearMessages().copyWith(priority: priority);
  }

  void clearMessages() {
    state = state.clearMessages();
  }

  Future<void> sendNotification() async {
    // Check if service is initialized
    if (!state.isServiceInitialized) {
      state = state.copyWith(
        errorMessage:
            'FCM Service is not initialized. Please wait or restart the app.',
      );
      return;
    }

    // Clear previous messages and set loading
    state = state.clearMessages().copyWith(isSending: true);

    // Build the request
    final data = (state.customDataKey?.isNotEmpty == true &&
            state.customDataValue?.isNotEmpty == true)
        ? {state.customDataKey!: state.customDataValue!}
        : null;

    final request = NotificationRequest(
      title: state.title,
      body: state.body,
      imageUrl: state.imageUrl.isEmpty ? null : state.imageUrl,
      targetType: state.targetType,
      topic: state.selectedTopic,
      deviceToken: state.deviceToken,
      data: data,
      priority: state.priority,
      clickAction: 'FLUTTER_NOTIFICATION_CLICK',
    );

    try {
      // Send the notification
      final fcmService = await _getFcmService();
      final result = await fcmService.sendNotification(request);

      result.fold(
        (failure) {
          state = state.copyWith(
            isSending: false,
            errorMessage: failure.message,
          );
        },
        (sendResult) {
          if (sendResult.success) {
            state = state.copyWith(
              isSending: false,
              successMessage: 'Notification sent successfully!',
            );
          } else {
            state = state.copyWith(
              isSending: false,
              errorMessage: sendResult.error ?? 'Failed to send notification',
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const NotificationComposerState();
  }

  /// Retry FCM service initialization
  Future<void> retryInitialization() async {
    state = state.copyWith(
      isServiceInitialized: false,
    );
    await _initializeFcmService();
  }
}

/// Provider for the notification composer notifier
/// Riverpod 3.0 NotifierProvider pattern
final notificationComposerProvider =
    NotifierProvider<NotificationComposerNotifier, NotificationComposerState>(
  NotificationComposerNotifier.new,
);

// =============================================================================
// TOPICS PROVIDER
// =============================================================================

/// Provider for available topics
final availableTopicsProvider = Provider<List<TopicItem>>((ref) {
  return [
    const TopicItem(
      key: NotificationTopics.all,
      label: 'All Users',
      icon: 'people',
    ),
    const TopicItem(
      key: NotificationTopics.promotions,
      label: 'Promotions',
      icon: 'tag',
    ),
    const TopicItem(
      key: NotificationTopics.news,
      label: 'News',
      icon: 'newspaper',
    ),
    const TopicItem(
      key: NotificationTopics.updates,
      label: 'Updates',
      icon: 'refresh',
    ),
    const TopicItem(
      key: NotificationTopics.android,
      label: 'Android Users',
      icon: 'android',
    ),
    const TopicItem(
      key: NotificationTopics.ios,
      label: 'iOS Users',
      icon: 'apple',
    ),
  ];
});

// =============================================================================
// MODEL - Topic Item
// =============================================================================

/// Model for a topic item
class TopicItem {
  final String key;
  final String label;
  final String icon;

  const TopicItem({
    required this.key,
    required this.label,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicItem &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
}
