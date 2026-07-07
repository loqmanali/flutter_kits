import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Represents a delivery route with polyline points and metadata.
///
/// This immutable class contains all the information needed to display
/// a route on a map and show distance/time information to users.
///
/// ## Usage
///
/// ```dart
/// // Create a route from OSRM response
/// final route = DeliveryRoute(
///   points: [
///     LatLng(30.0444, 31.2357),
///     LatLng(30.0500, 31.2400),
///     LatLng(30.0644, 31.2557),
///   ],
///   distanceKm: 3.5,
///   estimatedTime: Duration(minutes: 12),
///   color: Colors.blue,
///   strokeWidth: 4.0,
/// );
///
/// // Use with flutter_map PolylineLayer
/// PolylineLayer(
///   polylines: [
///     Polyline(
///       points: route.points,
///       color: route.color,
///       strokeWidth: route.strokeWidth,
///     ),
///   ],
/// )
/// ```
///
/// ## Properties
///
/// - [points]: List of [LatLng] coordinates that form the route polyline
/// - [distanceKm]: Total route distance in kilometers
/// - [estimatedTime]: Estimated travel duration
/// - [color]: Color for rendering the polyline on the map
/// - [strokeWidth]: Width of the polyline stroke
///
/// ## Note
///
/// The [points] list should contain at least 2 points for a valid route.
/// Routes are typically obtained from routing services like OSRM.
@immutable
class DeliveryRoute {
  /// List of geographic coordinates that form the route polyline.
  ///
  /// These points are typically decoded from an encoded polyline string
  /// returned by routing APIs like OSRM or Google Directions.
  ///
  /// The list should contain at least 2 points (start and end).
  final List<LatLng> points;

  /// Total route distance in kilometers.
  ///
  /// This value is typically provided by the routing service and represents
  /// the actual road distance, not the straight-line distance.
  final double distanceKm;

  /// Estimated travel time for this route.
  ///
  /// This duration is calculated by the routing service based on:
  /// - Road types and speed limits
  /// - Historical traffic data (if available)
  /// - Vehicle type (car, bicycle, walking)
  final Duration estimatedTime;

  /// Color used to render the polyline on the map.
  ///
  /// Defaults to [Colors.blue]. Consider using different colors for:
  /// - Active route segments
  /// - Completed portions
  /// - Alternative routes
  final Color color;

  /// Width of the polyline stroke in logical pixels.
  ///
  /// Defaults to 4.0. Adjust based on map zoom level and visual preference.
  final double strokeWidth;

  /// Creates a new [DeliveryRoute] instance.
  ///
  /// [points], [distanceKm], and [estimatedTime] are required.
  /// [color] defaults to [Colors.blue] and [strokeWidth] defaults to 4.0.
  const DeliveryRoute({
    required this.points,
    required this.distanceKm,
    required this.estimatedTime,
    this.color = Colors.blue,
    this.strokeWidth = 4.0,
  });

  /// Returns `true` if the route has no points.
  bool get isEmpty => points.isEmpty;

  /// Returns `true` if the route has at least one point.
  bool get isNotEmpty => points.isNotEmpty;

  /// Creates a copy of this [DeliveryRoute] with the given fields replaced.
  ///
  /// ```dart
  /// final updatedRoute = route.copyWith(
  ///   color: Colors.red,
  ///   strokeWidth: 6.0,
  /// );
  /// ```
  DeliveryRoute copyWith({
    List<LatLng>? points,
    double? distanceKm,
    Duration? estimatedTime,
    Color? color,
    double? strokeWidth,
  }) {
    return DeliveryRoute(
      points: points ?? this.points,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryRoute &&
        listEquals(other.points, points) &&
        other.distanceKm == distanceKm &&
        other.estimatedTime == estimatedTime &&
        other.color == color &&
        other.strokeWidth == strokeWidth;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(points),
      distanceKm,
      estimatedTime,
      color,
      strokeWidth,
    );
  }
}
