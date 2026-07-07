import 'package:latlong2/latlong.dart';

import '../models/models.dart';

/// Result of a routing request from a [RoutingService].
///
/// Contains all the information returned by a routing API, including
/// the route polyline points, total distance, and estimated duration.
///
/// ## Usage
///
/// ```dart
/// final result = await routingService.getRoute(start, end);
/// if (result != null) {
///   print('Distance: ${result.distanceKm} km');
///   print('Duration: ${result.duration.inMinutes} minutes');
///   print('Points: ${result.points.length}');
///
///   // Convert to DeliveryRoute for use with the tracking module
///   final route = result.toDeliveryRoute();
/// }
/// ```
class RouteResult {
  /// List of geographic coordinates that form the route polyline.
  ///
  /// These points are decoded from the routing API's encoded polyline
  /// and represent the actual path along roads.
  final List<LatLng> points;

  /// Total route distance in meters.
  ///
  /// This is the raw value from the routing API.
  /// Use [distanceKm] for the value in kilometers.
  final double distanceMeters;

  /// Estimated travel duration in seconds.
  ///
  /// This is the raw value from the routing API.
  /// Use [duration] for a [Duration] object.
  final double durationSeconds;

  /// Creates a new [RouteResult] instance.
  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  /// Total route distance in kilometers.
  ///
  /// Convenience getter that converts [distanceMeters] to kilometers.
  double get distanceKm => distanceMeters / 1000;

  /// Estimated travel duration as a [Duration] object.
  ///
  /// Convenience getter that converts [durationSeconds] to a [Duration].
  Duration get duration => Duration(seconds: durationSeconds.round());

  /// Converts this [RouteResult] to a [DeliveryRoute].
  ///
  /// This is useful for integrating routing results with the
  /// delivery tracking state.
  ///
  /// ```dart
  /// final routeResult = await routingService.getRoute(start, end);
  /// final deliveryRoute = routeResult?.toDeliveryRoute();
  /// ```
  DeliveryRoute toDeliveryRoute() {
    return DeliveryRoute(
      points: points,
      distanceKm: distanceKm,
      estimatedTime: duration,
    );
  }
}

/// Abstract interface for routing service implementations.
///
/// Implement this interface to support different routing providers
/// (OSRM, Google Directions, Mapbox, etc.).
///
/// ## Built-in Implementations
///
/// - [OsrmRoutingService]: Uses OSRM (Open Source Routing Machine)
///
/// ## Custom Implementation Example
///
/// ```dart
/// class GoogleMapsRoutingService implements RoutingService {
///   final String apiKey;
///
///   GoogleMapsRoutingService({required this.apiKey});
///
///   @override
///   Future<RouteResult?> getRoute(LatLng start, LatLng end) async {
///     // Make API call to Google Directions
///     final response = await _callGoogleDirectionsApi(start, end);
///
///     // Parse response and return RouteResult
///     return RouteResult(
///       points: _decodePolyline(response.polyline),
///       distanceMeters: response.distance,
///       durationSeconds: response.duration,
///     );
///   }
///
///   @override
///   Future<RouteResult?> getRouteWithWaypoints(List<LatLng> waypoints) async {
///     // Implementation with waypoints support
///   }
/// }
/// ```
///
/// ## Usage with Riverpod
///
/// Override the routing service provider to use a custom implementation:
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     routingServiceProvider.overrideWithValue(
///       GoogleMapsRoutingService(apiKey: 'your-api-key'),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
abstract class RoutingService {
  /// Fetches a route between two geographic points.
  ///
  /// Returns a [RouteResult] containing the route polyline, distance,
  /// and estimated duration. Returns `null` if the route cannot be
  /// calculated (e.g., network error, invalid coordinates).
  ///
  /// [start] - The starting point coordinates
  /// [end] - The ending point coordinates
  ///
  /// ```dart
  /// final result = await routingService.getRoute(
  ///   LatLng(30.0444, 31.2357),  // Cairo
  ///   LatLng(30.0644, 31.2557),  // Destination
  /// );
  /// ```
  Future<RouteResult?> getRoute(LatLng start, LatLng end);

  /// Fetches a route through multiple waypoints.
  ///
  /// The route will pass through all waypoints in the order provided.
  /// Returns `null` if fewer than 2 waypoints are provided or if
  /// the route cannot be calculated.
  ///
  /// [waypoints] - List of coordinates to route through (minimum 2)
  ///
  /// ```dart
  /// final result = await routingService.getRouteWithWaypoints([
  ///   LatLng(30.0444, 31.2357),  // Start
  ///   LatLng(30.0544, 31.2457),  // Stop 1
  ///   LatLng(30.0644, 31.2557),  // End
  /// ]);
  /// ```
  Future<RouteResult?> getRouteWithWaypoints(List<LatLng> waypoints);
}
