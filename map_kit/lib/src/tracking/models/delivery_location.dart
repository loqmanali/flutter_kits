import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Represents a geographic location point in the delivery process.
///
/// This immutable class encapsulates all information about a specific location,
/// whether it's the origin (restaurant/warehouse), destination (customer), or
/// the current driver position.
///
/// ## Usage
///
/// ```dart
/// // Create a restaurant location
/// final restaurant = DeliveryLocation(
///   latitude: 30.0444,
///   longitude: 31.2357,
///   label: 'Pizza Palace',
///   address: '123 Main Street, Cairo',
///   iconAsset: 'assets/icons/restaurant.png',
/// );
///
/// // Create a customer location
/// final customer = DeliveryLocation(
///   latitude: 30.0644,
///   longitude: 31.2557,
///   label: 'John Doe',
///   address: '456 Oak Avenue, Cairo',
/// );
///
/// // Access LatLng for flutter_map
/// final mapPoint = restaurant.latLng;
/// ```
///
/// ## Properties
///
/// - [latitude]: The geographic latitude coordinate (-90 to 90)
/// - [longitude]: The geographic longitude coordinate (-180 to 180)
/// - [label]: A human-readable name for this location (e.g., "Pizza Palace")
/// - [address]: Optional full address string for display
/// - [iconAsset]: Optional path to a custom icon asset for map markers
///
/// ## Note
///
/// This class is immutable and uses value equality. Two [DeliveryLocation]
/// instances with the same values are considered equal.
@immutable
class DeliveryLocation {
  /// The geographic latitude coordinate.
  ///
  /// Valid range: -90.0 to 90.0
  /// Positive values indicate North, negative values indicate South.
  final double latitude;

  /// The geographic longitude coordinate.
  ///
  /// Valid range: -180.0 to 180.0
  /// Positive values indicate East, negative values indicate West.
  final double longitude;

  /// A human-readable name for this location.
  ///
  /// Examples: "Pizza Palace", "John's Home", "Driver Ahmed"
  final String label;

  /// Optional full address string for display purposes.
  ///
  /// Example: "123 Main Street, Downtown, Cairo, Egypt"
  final String? address;

  /// Optional path to a custom icon asset for map markers.
  ///
  /// Example: "assets/icons/restaurant.png"
  final String? iconAsset;

  /// Creates a new [DeliveryLocation] instance.
  ///
  /// [latitude] and [longitude] are required geographic coordinates.
  /// [label] is required for identification and display.
  /// [address] and [iconAsset] are optional additional metadata.
  const DeliveryLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
    this.address,
    this.iconAsset,
  });

  /// Converts this location to a [LatLng] object for use with flutter_map.
  ///
  /// This is a convenience getter that creates a new [LatLng] instance
  /// from the latitude and longitude values.
  ///
  /// ```dart
  /// final location = DeliveryLocation(
  ///   latitude: 30.0444,
  ///   longitude: 31.2357,
  ///   label: 'Test',
  /// );
  ///
  /// // Use with flutter_map
  /// Marker(point: location.latLng, ...)
  /// ```
  LatLng get latLng => LatLng(latitude, longitude);

  /// Creates a copy of this [DeliveryLocation] with the given fields replaced.
  ///
  /// ```dart
  /// final updated = location.copyWith(
  ///   label: 'New Name',
  ///   address: 'New Address',
  /// );
  /// ```
  DeliveryLocation copyWith({
    double? latitude,
    double? longitude,
    String? label,
    String? address,
    String? iconAsset,
  }) {
    return DeliveryLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      label: label ?? this.label,
      address: address ?? this.address,
      iconAsset: iconAsset ?? this.iconAsset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.label == label &&
        other.address == address &&
        other.iconAsset == iconAsset;
  }

  @override
  int get hashCode {
    return Object.hash(latitude, longitude, label, address, iconAsset);
  }

  @override
  String toString() =>
      'DeliveryLocation(label: $label, lat: $latitude, lng: $longitude)';
}
