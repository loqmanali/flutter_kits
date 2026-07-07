import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';

import '../../core/map_kit_runtime.dart';
import 'routing_service.dart';

/// OSRM (Open Source Routing Machine) implementation of [RoutingService].
///
/// Uses OSRM to calculate routes along actual roads. By default, uses the
/// public OSRM demo server, but can be configured to use a self-hosted server.
///
/// ## Features
///
/// - Real road routing (not straight lines)
/// - Distance calculation based on actual road network
/// - Duration estimates based on speed limits and road types
/// - Support for multiple travel profiles (driving, walking, cycling)
/// - Automatic polyline decoding
///
/// ## Usage
///
/// ```dart
/// // Using default public server
/// final routingService = OsrmRoutingService();
///
/// // Using custom server
/// final routingService = OsrmRoutingService(
///   baseUrl: 'https://your-osrm-server.com',
///   profile: 'car',  // or 'foot', 'bike'
/// );
///
/// // Get route
/// final result = await routingService.getRoute(
///   LatLng(30.0444, 31.2357),  // Start
///   LatLng(30.0644, 31.2557),  // End
/// );
///
/// if (result != null) {
///   print('Distance: ${result.distanceKm} km');
///   print('Duration: ${result.duration.inMinutes} minutes');
/// }
/// ```
///
/// ## OSRM API
///
/// This service calls the OSRM Route API:
/// ```
/// GET {baseUrl}/route/v1/{profile}/{coordinates}
/// ```
///
/// Where:
/// - `{profile}` is the travel mode (driving, walking, cycling)
/// - `{coordinates}` are semicolon-separated lon,lat pairs
///
/// ## Important Notes
///
/// ### Coordinate Order
/// OSRM uses **longitude,latitude** order (opposite of lat,lng).
/// This service handles the conversion automatically.
///
/// ### Rate Limits
/// The public demo server (router.project-osrm.org) has rate limits:
/// - Maximum 1 request per second
/// - No guarantees on uptime or latency
/// - For production, host your own OSRM server
///
/// ### Self-Hosting
/// For production use, consider hosting your own OSRM server:
/// - Docker: `docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-routed --algorithm mld /data/map.osrm`
/// - See: https://github.com/Project-OSRM/osrm-backend
class OsrmRoutingService implements RoutingService {
  /// HTTP client for making API requests.
  final Dio _dio;

  /// Base URL of the OSRM server.
  ///
  /// Default: `https://router.project-osrm.org` (public demo server)
  ///
  /// For production, use your own OSRM server:
  /// ```dart
  /// OsrmRoutingService(baseUrl: 'https://your-server.com')
  /// ```
  final String baseUrl;

  /// Travel profile for routing.
  ///
  /// Available profiles on the demo server:
  /// - `driving` (default) - Car routing
  /// - `walking` - Pedestrian routing (if enabled on server)
  /// - `cycling` - Bicycle routing (if enabled on server)
  ///
  /// Custom OSRM servers may have different profiles configured.
  final String profile;

  /// Creates a new [OsrmRoutingService] instance.
  ///
  /// [dio] - Optional custom Dio instance for HTTP requests.
  ///         Useful for adding interceptors, custom headers, etc.
  ///
  /// [baseUrl] - OSRM server URL. Defaults to the public demo server.
  ///
  /// [profile] - Travel profile. Defaults to 'driving'.
  ///
  /// ```dart
  /// // Basic usage
  /// final service = OsrmRoutingService();
  ///
  /// // Custom configuration
  /// final service = OsrmRoutingService(
  ///   baseUrl: 'https://your-osrm-server.com',
  ///   profile: 'car',
  ///   dio: Dio()..interceptors.add(LogInterceptor()),
  /// );
  /// ```
  OsrmRoutingService({
    Dio? dio,
    String? baseUrl,
    String? profile,
  })  : _dio = dio ?? MapKitRuntime.createDio(),
        baseUrl = baseUrl ?? MapKitRuntime.osrmBaseUrl,
        profile = profile ?? MapKitRuntime.osrmProfile;

  /// Fetches a route between two geographic points.
  ///
  /// Makes a request to the OSRM Route API and returns the result
  /// as a [RouteResult] with decoded polyline points.
  ///
  /// Returns `null` if:
  /// - Network error occurs
  /// - OSRM returns an error
  /// - No route could be found
  ///
  /// ```dart
  /// final result = await service.getRoute(
  ///   LatLng(30.0444, 31.2357),
  ///   LatLng(30.0644, 31.2557),
  /// );
  /// ```
  @override
  Future<RouteResult?> getRoute(LatLng start, LatLng end) async {
    return _fetchRoute([start, end]);
  }

  /// Fetches a route through multiple waypoints.
  ///
  /// The route will pass through all waypoints in order.
  /// Requires at least 2 waypoints.
  ///
  /// ```dart
  /// final result = await service.getRouteWithWaypoints([
  ///   LatLng(30.0444, 31.2357),  // Start
  ///   LatLng(30.0544, 31.2457),  // Stop 1
  ///   LatLng(30.0644, 31.2557),  // End
  /// ]);
  /// ```
  @override
  Future<RouteResult?> getRouteWithWaypoints(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;
    return _fetchRoute(waypoints);
  }

  /// Internal method to fetch route from OSRM API.
  ///
  /// Handles:
  /// 1. Converting coordinates to OSRM format (lon,lat)
  /// 2. Making the HTTP request
  /// 3. Parsing the response
  /// 4. Decoding the polyline
  /// 5. Error handling
  Future<RouteResult?> _fetchRoute(List<LatLng> waypoints) async {
    try {
      // OSRM expects coordinates in lon,lat format (opposite of LatLng)
      final coordinates =
          waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');

      final response = await _dio.get(
        '$baseUrl/route/v1/$profile/$coordinates',
        queryParameters: {
          'overview': 'full', // Get full polyline geometry
          'geometries': 'polyline', // Use Google polyline encoding
        },
        options: Options(
          headers: {'User-Agent': 'DeliveryTrackingApp/1.0'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // OSRM returns 'Ok' on success
        if (data['code'] == 'Ok' && data['routes'] is List) {
          final routes = data['routes'] as List;
          if (routes.isNotEmpty) {
            final route = routes[0] as Map<String, dynamic>;

            // Decode the encoded polyline string
            final geometry = route['geometry'] as String;
            final polylinePoints = PolylinePoints();
            final decodedPoints = polylinePoints.decodePolyline(geometry);

            // Convert to LatLng list for flutter_map
            final points = decodedPoints
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();

            return RouteResult(
              points: points,
              distanceMeters: (route['distance'] as num).toDouble(),
              durationSeconds: (route['duration'] as num).toDouble(),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching route from OSRM: $e');
    }

    return null;
  }
}
