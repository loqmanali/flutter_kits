import 'package:permission_handler/permission_handler.dart';

/// Data source interface for platform-specific notification operations.
///
/// This abstract class defines the contract for handling notification
/// permissions and platform-specific settings using the permission_handler
/// plugin. It provides a clean abstraction over platform permission APIs.
///
/// ## Implementation Notes
/// - All methods should handle platform-specific differences gracefully
/// - Permission status should be checked before requesting permissions
/// - Settings navigation should fallback gracefully if not supported
/// - Error handling should account for user denial and system restrictions
abstract class PlatformNotificationDataSource {
  /// Requests notification permission from the user.
  ///
  /// Prompts the user to grant notification permissions for the app.
  /// This should be called when the app first needs to show notifications
  /// or when the user explicitly enables notifications.
  ///
  /// ## Returns
  /// - [PermissionStatus.granted] if permission is granted
  /// - [PermissionStatus.denied] if permission is denied
  /// - [PermissionStatus.permanentlyDenied] if permission is permanently denied
  /// - [PermissionStatus.limited] if limited permission is granted (iOS)
  /// - [PermissionStatus.restricted] if permission is restricted by system
  ///
  /// ## Usage
  /// ```dart
  /// final status = await dataSource.requestPermission();
  /// if (status.isGranted) {
  ///   // Permission granted - can show notifications
  ///   initializeNotifications();
  /// } else {
  ///   // Permission denied - show explanation or alternative
  ///   showPermissionDeniedDialog();
  /// }
  /// ```
  Future<PermissionStatus> requestPermission();

  /// Gets the current notification permission status.
  ///
  /// Checks the current permission status without prompting the user.
  /// This should be used to determine if notifications can be shown
  /// or if permission needs to be requested.
  ///
  /// ## Returns
  /// Current [PermissionStatus] for notifications
  ///
  /// ## Usage
  /// ```dart
  /// final status = await dataSource.getPermissionStatus();
  /// if (status.isGranted) {
  ///   showNotification();
  /// } else if (status.isDenied) {
  ///   showPermissionRequestDialog();
  /// } else if (status.isPermanentlyDenied) {
  ///   showSettingsPrompt();
  /// }
  /// ```
  Future<PermissionStatus> getPermissionStatus();

  /// Opens the app settings screen for notification permissions.
  ///
  /// Navigates the user to the system settings where they can manually
  /// enable or disable notification permissions. This should be used
  /// when permissions are permanently denied and the user needs to
  /// manually change the setting.
  ///
  /// ## Returns
  /// - [true] if settings were opened successfully
  /// - [false] if settings could not be opened (not supported or failed)
  ///
  /// ## Usage
  /// ```dart
  /// final opened = await dataSource.openSettings();
  /// if (!opened) {
  ///   // Could not open settings - show manual instructions
  ///   showManualSettingsInstructions();
  /// }
  /// ```
  Future<bool> openSettings();
}

/// Permission Handler implementation of [PlatformNotificationDataSource].
///
/// This class wraps the permission_handler plugin and provides
/// a clean interface for platform-specific notification permission
/// operations. It handles all the low-level permission interactions
/// and exposes them through the data source interface.
///
/// ## Platform Support
/// - **Android**: Handles notification permissions for API 33+
/// - **iOS**: Handles notification permissions with proper authorization
/// - **Other platforms**: Gracefully handles unsupported platforms
///
/// ## Error Handling
/// All permission exceptions are propagated to the caller.
/// Repository layer should handle these errors and convert them to appropriate domain failures.
///
/// ## Best Practices
/// - Always check permission status before requesting
/// - Provide clear UI explanations for why permissions are needed
/// - Handle permanently denied permissions with settings navigation
/// - Consider showing permission rationale on Android
class PlatformNotificationDataSourceImpl
    implements PlatformNotificationDataSource {
  @override
  Future<PermissionStatus> requestPermission() async {
    return await Permission.notification.request();
  }

  @override
  Future<PermissionStatus> getPermissionStatus() async {
    return await Permission.notification.status;
  }

  @override
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
