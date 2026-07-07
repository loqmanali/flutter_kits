import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Represents a complete address with geographic coordinates.
///
/// This immutable class contains all information about a selected or
/// searched location, including coordinates, formatted address, and
/// individual address components.
///
/// ## Usage
///
/// ```dart
/// // Create from coordinates and address
/// final location = LocationAddress(
///   latitude: 30.0444,
///   longitude: 31.2357,
///   displayName: 'Cairo Tower, Zamalek, Cairo, Egypt',
///   street: 'Gezira Street',
///   city: 'Cairo',
///   country: 'Egypt',
///   postalCode: '11511',
/// );
///
/// // Access LatLng for flutter_map
/// final point = location.latLng;
///
/// // Get formatted address
/// print(location.formattedAddress);
/// ```
///
/// ## Properties
///
/// - [latitude], [longitude]: Geographic coordinates
/// - [displayName]: Full formatted address from geocoding service
/// - [street], [city], [state], [country], [postalCode]: Address components
/// - [placeId]: Unique identifier from the geocoding service
@immutable
class LocationAddress {
  /// The geographic latitude coordinate (-90 to 90).
  final double latitude;

  /// The geographic longitude coordinate (-180 to 180).
  final double longitude;

  /// Full formatted address string from the geocoding service.
  ///
  /// Example: "Cairo Tower, Gezira Street, Zamalek, Cairo, Egypt"
  final String? displayName;

  /// Street name and number.
  ///
  /// Example: "123 Gezira Street"
  final String? street;

  /// City or locality name.
  ///
  /// Example: "Cairo"
  final String? city;

  /// State, province, or region name.
  ///
  /// Example: "Cairo Governorate"
  final String? state;

  /// Country name.
  ///
  /// Example: "Egypt"
  final String? country;

  /// Postal or ZIP code.
  ///
  /// Example: "11511"
  final String? postalCode;

  /// Unique identifier from the geocoding service.
  ///
  /// Useful for caching or referencing specific places.
  final String? placeId;

  /// Creates a new [LocationAddress] instance.
  const LocationAddress({
    required this.latitude,
    required this.longitude,
    this.displayName,
    this.street,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.placeId,
  });

  /// Creates a [LocationAddress] from coordinates only.
  ///
  /// Useful when you have coordinates but haven't geocoded yet.
  ///
  /// ```dart
  /// final location = LocationAddress.fromCoordinates(30.0444, 31.2357);
  /// ```
  factory LocationAddress.fromCoordinates(double latitude, double longitude) {
    return LocationAddress(
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Creates a [LocationAddress] from a [LatLng] object.
  ///
  /// ```dart
  /// final latLng = LatLng(30.0444, 31.2357);
  /// final location = LocationAddress.fromLatLng(latLng);
  /// ```
  factory LocationAddress.fromLatLng(LatLng latLng) {
    return LocationAddress(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
  }

  /// Converts to a [LatLng] object for use with flutter_map.
  LatLng get latLng => LatLng(latitude, longitude);

  /// Returns a formatted address string.
  ///
  /// If [displayName] is available, returns it.
  /// Otherwise, constructs an address from available components.
  /// Falls back to coordinates if no address info is available.
  String get formattedAddress {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }

    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Returns a short address (city, country) or coordinates.
  String get shortAddress {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (country != null && country!.isNotEmpty) parts.add(country!);

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  /// Whether this location has address information (not just coordinates).
  bool get hasAddress =>
      displayName != null ||
      street != null ||
      city != null ||
      country != null;

  /// Creates a copy with the given fields replaced.
  LocationAddress copyWith({
    double? latitude,
    double? longitude,
    String? displayName,
    String? street,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? placeId,
  }) {
    return LocationAddress(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      displayName: displayName ?? this.displayName,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      placeId: placeId ?? this.placeId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationAddress &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.displayName == displayName &&
        other.street == street &&
        other.city == city &&
        other.state == state &&
        other.country == country &&
        other.postalCode == postalCode &&
        other.placeId == placeId;
  }

  @override
  int get hashCode {
    return Object.hash(
      latitude,
      longitude,
      displayName,
      street,
      city,
      state,
      country,
      postalCode,
      placeId,
    );
  }

  @override
  String toString() => 'LocationAddress($formattedAddress)';
}
