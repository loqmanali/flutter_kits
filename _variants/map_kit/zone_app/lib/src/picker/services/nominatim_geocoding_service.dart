import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../core/map_kit_runtime.dart';
import '../models/models.dart';
import 'geocoding_service.dart';

/// Nominatim (OpenStreetMap) implementation of [GeocodingService].
///
/// Uses the free Nominatim API for geocoding and reverse geocoding.
/// Nominatim is powered by OpenStreetMap data.
///
/// ## Features
///
/// - Free to use (with usage policy compliance)
/// - No API key required
/// - Worldwide coverage
/// - Multiple languages supported
/// - Address search and reverse geocoding
///
/// ## Usage
///
/// ```dart
/// // Using default public server
/// final geocodingService = NominatimGeocodingService();
///
/// // Using custom server
/// final geocodingService = NominatimGeocodingService(
///   baseUrl: 'https://your-nominatim-server.com',
///   userAgent: 'YourApp/1.0',
/// );
///
/// // Search for locations
/// final results = await geocodingService.search('Cairo Tower');
///
/// // Reverse geocode coordinates
/// final address = await geocodingService.reverseGeocode(
///   LatLng(30.0444, 31.2357),
/// );
/// ```
///
/// ## Nominatim Usage Policy
///
/// When using the public Nominatim server:
/// - Maximum 1 request per second
/// - Provide a valid User-Agent identifying your application
/// - Cache results to reduce requests
/// - See: https://operations.osmfoundation.org/policies/nominatim/
///
/// ## Self-Hosting
///
/// For production use, consider hosting your own Nominatim server:
/// - Docker: https://github.com/mediagis/nominatim-docker
/// - See: https://nominatim.org/release-docs/latest/admin/Installation/
class NominatimGeocodingService implements GeocodingService {
  /// HTTP client for making API requests.
  final Dio _dio;

  /// Base URL of the Nominatim server.
  ///
  /// Default: `https://nominatim.openstreetmap.org`
  final String baseUrl;

  /// User-Agent header for API requests.
  ///
  /// Required by Nominatim usage policy.
  /// Should identify your application.
  final String userAgent;

  /// Creates a new [NominatimGeocodingService] instance.
  ///
  /// [dio] - Optional custom Dio instance
  /// [baseUrl] - Nominatim server URL
  /// [userAgent] - User-Agent header (required by usage policy)
  NominatimGeocodingService({
    Dio? dio,
    String? baseUrl,
    String? userAgent,
  })  : _dio = dio ?? MapKitRuntime.createDio(),
        baseUrl = baseUrl ?? MapKitRuntime.nominatimBaseUrl,
        userAgent = userAgent ?? MapKitRuntime.nominatimUserAgent;

  @override
  Future<List<SearchResult>> search(
    String query, {
    String? country,
    String? language,
    int limit = 10,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        '$baseUrl/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': limit.toString(),
          if (country != null) 'countrycodes': country,
          if (language != null) 'accept-language': language,
        },
        options: Options(
          headers: {'User-Agent': userAgent},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => _parseSearchResult(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error searching with Nominatim: $e');
    }

    return [];
  }

  @override
  Future<LocationAddress?> reverseGeocode(
    LatLng position, {
    String? language,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/reverse',
        queryParameters: {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
          'format': 'json',
          'addressdetails': '1',
          if (language != null) 'accept-language': language,
        },
        options: Options(
          headers: {'User-Agent': userAgent},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Check for error response
        if (data.containsKey('error')) {
          debugPrint('Nominatim error: ${data['error']}');
          return null;
        }

        return _parseLocationAddress(data, position);
      }
    } catch (e) {
      debugPrint('Error reverse geocoding with Nominatim: $e');
    }

    return null;
  }

  @override
  Future<List<SearchResult>> searchNearby(
    String query, {
    required LatLng near,
    double radiusKm = 10.0,
    String? language,
    int limit = 10,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      // Calculate bounding box from radius
      // Approximate: 1 degree latitude ≈ 111 km
      final latDelta = radiusKm / 111.0;
      final lonDelta = radiusKm / (111.0 * near.latitude.abs().cos());

      final viewbox =
          '${near.longitude - lonDelta},${near.latitude - latDelta},'
          '${near.longitude + lonDelta},${near.latitude + latDelta}';

      final response = await _dio.get(
        '$baseUrl/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': limit.toString(),
          'viewbox': viewbox,
          'bounded': '1',
          if (language != null) 'accept-language': language,
        },
        options: Options(
          headers: {'User-Agent': userAgent},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => _parseSearchResult(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error searching nearby with Nominatim: $e');
    }

    return [];
  }

  /// Parses a Nominatim search result JSON into a [SearchResult].
  SearchResult _parseSearchResult(Map<String, dynamic> json) {
    final lat = double.tryParse(json['lat']?.toString() ?? '') ?? 0.0;
    final lon = double.tryParse(json['lon']?.toString() ?? '') ?? 0.0;

    final address = json['address'] as Map<String, dynamic>?;

    List<double>? boundingBox;
    if (json['boundingbox'] is List) {
      boundingBox = (json['boundingbox'] as List)
          .map((e) => double.tryParse(e.toString()) ?? 0.0)
          .toList();
    }

    return SearchResult(
      location: LocationAddress(
        latitude: lat,
        longitude: lon,
        displayName: json['display_name'] as String?,
        street: _extractStreet(address),
        city: _extractCity(address),
        state: address?['state'] as String?,
        country: address?['country'] as String?,
        postalCode: address?['postcode'] as String?,
        placeId: json['place_id']?.toString(),
      ),
      type: json['type'] as String?,
      category: json['class'] as String?,
      importance: (json['importance'] as num?)?.toDouble(),
      boundingBox: boundingBox,
    );
  }

  /// Parses a Nominatim reverse geocoding response into a [LocationAddress].
  LocationAddress _parseLocationAddress(
    Map<String, dynamic> json,
    LatLng position,
  ) {
    final address = json['address'] as Map<String, dynamic>?;

    return LocationAddress(
      latitude: position.latitude,
      longitude: position.longitude,
      displayName: json['display_name'] as String?,
      street: _extractStreet(address),
      city: _extractCity(address),
      state: address?['state'] as String?,
      country: address?['country'] as String?,
      postalCode: address?['postcode'] as String?,
      placeId: json['place_id']?.toString(),
    );
  }

  /// Extracts street information from Nominatim address object.
  String? _extractStreet(Map<String, dynamic>? address) {
    if (address == null) return null;

    // Try different street-related fields
    final streetFields = [
      'road',
      'street',
      'pedestrian',
      'footway',
      'cycleway',
      'path',
      'house_number',
    ];

    final parts = <String>[];

    // Get house number first
    if (address['house_number'] != null) {
      parts.add(address['house_number'] as String);
    }

    // Then get street name
    for (final field in streetFields) {
      if (field != 'house_number' && address[field] != null) {
        parts.add(address[field] as String);
        break;
      }
    }

    return parts.isNotEmpty ? parts.join(' ') : null;
  }

  /// Extracts city information from Nominatim address object.
  String? _extractCity(Map<String, dynamic>? address) {
    if (address == null) return null;

    // Try different city-related fields (Nominatim varies by region)
    final cityFields = [
      'city',
      'town',
      'village',
      'municipality',
      'city_district',
      'suburb',
      'neighbourhood',
    ];

    for (final field in cityFields) {
      if (address[field] != null) {
        return address[field] as String;
      }
    }

    return null;
  }
}

/// Extension on double for cos calculation
extension _DoubleExtension on double {
  double cos() => _cos(this);
}

double _cos(double radians) {
  return radians.abs() < 0.0001 ? 1.0 : _cosImpl(radians);
}

double _cosImpl(double x) {
  // Simple cos approximation for bounding box calculation
  // Convert degrees to radians
  final rad = x * 3.14159265359 / 180.0;
  // Taylor series approximation
  return 1 -
      (rad * rad) / 2 +
      (rad * rad * rad * rad) / 24 -
      (rad * rad * rad * rad * rad * rad) / 720;
}
