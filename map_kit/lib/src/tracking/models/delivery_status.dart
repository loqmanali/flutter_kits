import 'package:flutter/material.dart';

/// Represents the current status of a delivery in its lifecycle.
///
/// The delivery progresses through these statuses in order:
/// 1. [preparing] - Order is being prepared at the origin
/// 2. [pickedUp] - Driver has picked up the order
/// 3. [onTheWay] - Driver is en route to the destination
/// 4. [arriving] - Driver is nearby (typically within a few minutes)
/// 5. [delivered] - Order has been delivered
///
/// ## Usage
///
/// ```dart
/// // Check if delivery is complete
/// if (status.isCompleted) {
///   showDeliveryCompleteDialog();
/// }
///
/// // Check if delivery is in progress
/// if (status.isInProgress) {
///   showTrackingUI();
/// }
///
/// // Use in switch expression
/// final message = switch (status) {
///   DeliveryStatus.preparing => 'Your order is being prepared',
///   DeliveryStatus.pickedUp => 'Driver has picked up your order',
///   DeliveryStatus.onTheWay => 'Your order is on the way',
///   DeliveryStatus.arriving => 'Driver is almost there!',
///   DeliveryStatus.delivered => 'Your order has been delivered',
/// };
/// ```
enum DeliveryStatus {
  /// Order is being prepared at the origin location.
  ///
  /// This is typically the initial status when a delivery starts.
  preparing,

  /// Driver has picked up the order from the origin.
  ///
  /// The order has left the origin and is with the driver.
  pickedUp,

  /// Driver is en route to the destination.
  ///
  /// This is the main transit phase of the delivery.
  onTheWay,

  /// Driver is nearby and will arrive soon.
  ///
  /// Typically triggered when the driver is within a few minutes
  /// of the destination (e.g., 90% progress).
  arriving,

  /// Order has been delivered to the destination.
  ///
  /// This is the final status. Once reached, the delivery is complete.
  delivered;

  /// Returns `true` if the delivery has been completed.
  ///
  /// ```dart
  /// if (status.isCompleted) {
  ///   showRatingDialog();
  /// }
  /// ```
  bool get isCompleted => this == DeliveryStatus.delivered;

  /// Returns `true` if the delivery is actively in transit.
  ///
  /// This is `true` for [onTheWay] and [arriving] statuses.
  ///
  /// ```dart
  /// if (status.isInProgress) {
  ///   enableLiveTracking();
  /// }
  /// ```
  bool get isInProgress =>
      this == DeliveryStatus.onTheWay || this == DeliveryStatus.arriving;
}

/// Configuration for how a [DeliveryStatus] should be displayed in the UI.
///
/// Each status can have a custom label, color, and icon for display purposes.
///
/// ## Usage
///
/// ```dart
/// final customConfig = DeliveryStatusConfig(
///   label: 'Getting Ready',
///   color: Colors.amber,
///   icon: Icons.kitchen,
/// );
/// ```
class DeliveryStatusConfig {
  /// The human-readable label to display for this status.
  ///
  /// Example: "Preparing", "On The Way", "Delivered"
  final String label;

  /// The color associated with this status for UI elements.
  ///
  /// Used for status badges, progress indicators, and icons.
  final Color color;

  /// The icon to display for this status.
  ///
  /// Typically displayed in status badges or timeline indicators.
  final IconData icon;

  /// Creates a new [DeliveryStatusConfig] instance.
  const DeliveryStatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

/// Manages display configurations for all [DeliveryStatus] values.
///
/// Provides default configurations for all statuses and allows
/// custom overrides for specific statuses.
///
/// ## Usage
///
/// ```dart
/// // Use default configurations
/// final config = DeliveryStatusConfigs.defaultConfigFor(status);
///
/// // Create custom configurations
/// final customConfigs = DeliveryStatusConfigs(
///   configs: {
///     DeliveryStatus.preparing: DeliveryStatusConfig(
///       label: 'Getting Ready',
///       color: Colors.amber,
///       icon: Icons.kitchen,
///     ),
///     DeliveryStatus.onTheWay: DeliveryStatusConfig(
///       label: 'Coming Your Way',
///       color: Colors.green,
///       icon: Icons.motorcycle,
///     ),
///   },
/// );
///
/// // Get config (falls back to defaults if not specified)
/// final config = customConfigs.getConfig(DeliveryStatus.preparing);
/// ```
class DeliveryStatusConfigs {
  /// Map of custom configurations for each status.
  ///
  /// Statuses not in this map will use default configurations.
  final Map<DeliveryStatus, DeliveryStatusConfig> configs;

  /// Creates a new [DeliveryStatusConfigs] with custom configurations.
  ///
  /// Any status not included in [configs] will use the default configuration.
  const DeliveryStatusConfigs({required this.configs});

  /// Gets the configuration for a specific status.
  ///
  /// Returns the custom configuration if one was provided,
  /// otherwise returns the default configuration.
  DeliveryStatusConfig getConfig(DeliveryStatus status) {
    return configs[status] ?? _defaultConfigs[status]!;
  }

  /// Default configurations for all statuses.
  static const Map<DeliveryStatus, DeliveryStatusConfig> _defaultConfigs = {
    DeliveryStatus.preparing: DeliveryStatusConfig(
      label: 'Preparing',
      color: Colors.orange,
      icon: Icons.restaurant,
    ),
    DeliveryStatus.pickedUp: DeliveryStatusConfig(
      label: 'Picked Up',
      color: Colors.blue,
      icon: Icons.inventory_2,
    ),
    DeliveryStatus.onTheWay: DeliveryStatusConfig(
      label: 'On The Way',
      color: Colors.green,
      icon: Icons.delivery_dining,
    ),
    DeliveryStatus.arriving: DeliveryStatusConfig(
      label: 'Arriving',
      color: Colors.teal,
      icon: Icons.near_me,
    ),
    DeliveryStatus.delivered: DeliveryStatusConfig(
      label: 'Delivered',
      color: Colors.purple,
      icon: Icons.check_circle,
    ),
  };

  /// Gets the default configuration for a specific status.
  ///
  /// This is a convenience method for accessing default configurations
  /// without creating a [DeliveryStatusConfigs] instance.
  ///
  /// ```dart
  /// final config = DeliveryStatusConfigs.defaultConfigFor(
  ///   DeliveryStatus.onTheWay,
  /// );
  /// print(config.label); // "On The Way"
  /// ```
  static DeliveryStatusConfig defaultConfigFor(DeliveryStatus status) {
    return _defaultConfigs[status]!;
  }
}
