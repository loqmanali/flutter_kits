import 'package:equatable/equatable.dart';

/// Base class for all notification-related failures.
///
/// This abstract class provides a common structure for handling errors
/// that occur in the notification system. It extends [Equatable] to
/// enable value equality for testing and comparison purposes.
///
/// ## Usage
/// ```dart
/// // Create a custom failure
/// final failure = CustomNotificationFailure(
///   message: 'Failed to send notification',
///   code: 'SEND_FAILED',
///   originalError: exception,
/// );
///
/// // Handle failure
/// failure.fold(
///   (failure) => showError(failure.message),
///   (success) => showSuccess(),
/// );
/// ```
abstract class NotificationFailure extends Equatable {
  /// Human-readable error message.
  ///
  /// This message should be suitable for display to users or
  /// for logging purposes. It should describe what went wrong
  /// in clear, understandable language.
  final String message;

  /// Optional error code for programmatic handling.
  ///
  /// Error codes allow for specific error handling logic
  /// without relying on error message strings. This is useful
  /// for internationalization and automated error handling.
  final String? code;

  /// The original error that caused this failure.
  ///
  /// This can contain the original exception or error object
  /// that triggered this failure. Useful for debugging and
  /// detailed error reporting, but should not be exposed to users.
  final dynamic originalError;

  /// Creates a new notification failure.
  ///
  /// ## Parameters
  /// - [message]: Human-readable error description
  /// - [code]: Optional error code for programmatic handling
  /// - [originalError]: Original exception that caused the failure
  const NotificationFailure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code, originalError];
}

/// Failure related to Firebase Cloud Messaging (FCM) operations.
///
/// This failure is used when errors occur during FCM token management,
/// topic subscriptions, or message handling. It typically indicates
/// issues with the Firebase service or network connectivity.
///
/// ## Common Causes
/// - Network connectivity issues
/// - Invalid FCM configuration
/// - Token refresh failures
/// - Topic subscription errors
/// - Firebase service unavailability
///
/// ## Example
/// ```dart
/// throw FCMFailure(
///   message: 'Failed to refresh FCM token',
///   code: 'TOKEN_REFRESH_FAILED',
///   originalError: firebaseException,
/// );
/// ```
class FCMFailure extends NotificationFailure {
  /// Creates a new FCM failure.
  ///
  /// ## Parameters
  /// - [message]: Human-readable error description
  /// - [code]: Optional error code for programmatic handling
  /// - [originalError]: Original exception that caused the failure
  const FCMFailure({required super.message, super.code, super.originalError});
}

/// Failure related to local notification operations.
///
/// This failure is used when errors occur during local notification
/// display, scheduling, or management. It typically indicates issues
/// with the device's notification system or permissions.
///
/// ## Common Causes
/// - Missing notification permissions
/// - Invalid notification channel configuration
/// - Scheduling conflicts
/// - Platform-specific notification limitations
/// - Local notification plugin errors
///
/// ## Example
/// ```dart
/// throw LocalNotificationFailure(
///   message: 'Notification permission denied',
///   code: 'PERMISSION_DENIED',
///   originalError: permissionException,
/// );
/// ```
class LocalNotificationFailure extends NotificationFailure {
  /// Creates a new local notification failure.
  ///
  /// ## Parameters
  /// - [message]: Human-readable error description
  /// - [code]: Optional error code for programmatic handling
  /// - [originalError]: Original exception that caused the failure
  const LocalNotificationFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Failure related to notification permission handling.
///
/// This failure is used when errors occur during permission requests,
/// status checks, or settings navigation. It typically indicates
/// issues with user permissions or system restrictions.
///
/// ## Common Causes
/// - User denies notification permission
/// - Permission permanently denied
/// - System restrictions on notifications
/// - Settings navigation failures
/// - Platform-specific permission issues
///
/// ## Example
/// ```dart
/// throw PermissionFailure(
///   message: 'Notification permission permanently denied',
///   code: 'PERMANENTLY_DENIED',
///   originalError: permissionException,
/// );
/// ```
class PermissionFailure extends NotificationFailure {
  /// Creates a new permission failure.
  ///
  /// ## Parameters
  /// - [message]: Human-readable error description
  /// - [code]: Optional error code for programmatic handling
  /// - [originalError]: Original exception that caused the failure
  const PermissionFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Failure related to notification scheduling operations.
///
/// This failure is used when errors occur during notification scheduling,
/// cancellation, or time management. It typically indicates issues with
/// the scheduling system or invalid time configurations.
///
/// ## Common Causes
/// - Invalid scheduled time (in the past)
/// - Scheduling conflicts
/// - System restrictions on background tasks
/// - Timezone configuration issues
/// - Battery optimization interference
///
/// ## Example
/// ```dart
/// throw SchedulingFailure(
///   message: 'Cannot schedule notification in the past',
///   code: 'INVALID_TIME',
///   originalError: schedulingException,
/// );
/// ```
class SchedulingFailure extends NotificationFailure {
  /// Creates a new scheduling failure.
  ///
  /// ## Parameters
  /// - [message]: Human-readable error description
  /// - [code]: Optional error code for programmatic handling
  /// - [originalError]: Original exception that caused the failure
  const SchedulingFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Failure related to data storage operations.
///
/// This failure is used when errors occur during storage of notification
/// data, settings, or history. It typically indicates issues with the
/// underlying storage mechanism or data corruption.
///
/// ## Common Causes
/// - Storage device full or unavailable
/// - Data corruption during serialization/deserialization
/// - Permission issues accessing storage
/// - Database connection failures
/// - Invalid data format
///
/// ## Example
/// ```dart
/// throw StorageFailure(
///   message: 'Failed to save notification settings',
///   code: 'SAVE_FAILED',
///   originalError: storageException,
/// );
/// ```
class StorageFailure extends NotificationFailure {
  /// Creates a new storage failure.
  ///
  /// ## Parameters
  /// - [message]: Human-readable error description
  /// - [code]: Optional error code for programmatic handling
  /// - [originalError]: Original exception that caused the failure
  const StorageFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Failure related to notification payload parsing.
///
/// This failure is used when errors occur during parsing of notification
/// payload data from FCM messages or local storage. It typically indicates
/// issues with data format or missing required fields.
///
/// ## Common Causes
/// - Invalid JSON format in payload
/// - Missing required payload fields
/// - Invalid deep link type
/// - Malformed navigation data
/// - Data type mismatches
///
/// ## Example
/// ```dart
/// throw PayloadParsingFailure(
///   message: 'Invalid payload format',
///   code: 'INVALID_FORMAT',
///   originalError: jsonException,
/// );
/// ```
class PayloadParsingFailure extends NotificationFailure {
  /// Creates a new payload parsing failure.
  ///
  /// ## Parameters
  /// - [message]: Human-readable error description
  /// - [code]: Optional error code for programmatic handling
  /// - [originalError]: Original exception that caused the failure
  const PayloadParsingFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Failure related to notification channel operations.
///
/// This failure is used when errors occur during notification channel
/// creation, configuration, or management. It typically indicates
/// issues with channel setup or platform-specific limitations.
///
/// ## Common Causes
/// - Invalid channel configuration
/// - Channel creation failures
/// - Platform-specific channel limitations
/// - Channel name conflicts
/// - Missing required channel properties
///
/// ## Example
/// ```dart
/// throw ChannelFailure(
///   message: 'Failed to create notification channel',
///   code: 'CHANNEL_CREATION_FAILED',
///   originalError: channelException,
/// );
/// ```
class ChannelFailure extends NotificationFailure {
  /// Creates a new channel failure.
  ///
  /// ## Parameters
  /// - [message]: Human-readable error description
  /// - [code]: Optional error code for programmatic handling
  /// - [originalError]: Original exception that caused the failure
  const ChannelFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}
