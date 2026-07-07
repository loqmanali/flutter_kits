import 'package:latlong2/latlong.dart';

import '../models/models.dart';

/// Abstract interface for geocoding service implementations.
///
/// Implement this interface to support different geocoding providers
/// (Nominatim, Google Geocoding, Mapbox, etc.).
///
/// ## Built-in Implementations
///
/// - [NominatimGeocodingService]: Uses OpenStreetMap Nominatim (free)
///
/// ## Geocoding Operations
///
/// - **Forward Geocoding**: Convert address text to coordinates
/// - **Reverse Geocoding**: Convert coordinates to address
///
/// ## Custom Implementation Example
///
/// ```dart
/// class GoogleGeocodingService implements GeocodingService {
///   final String apiKey;
///
///   GoogleGeocodingService({required this.apiKey});
///
///   @override
///   Future<List<SearchResult>> search(String query, {String? country}) async {
///     // Make API call to Google Geocoding
///     final response = await _callGoogleApi(query, country);
///     return _parseResults(response);
///   }
///
///   @override
///   Future<LocationAddress?> reverseGeocode(LatLng position) async {
///     // Convert coordinates to address
///     final response = await _callGoogleReverseApi(position);
///     return _parseAddress(response);
///   }
/// }
/// ```
///
/// ## Usage with Riverpod
///
/// Override the geocoding service provider:
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     geocodingServiceProvider.overrideWithValue(
///       GoogleGeocodingService(apiKey: 'your-api-key'),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
abstract class GeocodingService {
  /// Searches for locations matching the query string.
  ///
  /// Returns a list of [SearchResult] objects sorted by relevance.
  /// Returns an empty list if no results are found.
  ///
  /// [query] - The search text (address, place name, etc.)
  /// [country] - Optional country code to limit results (e.g., 'eg', 'us')
  /// [language] - Optional language for results (e.g., 'en', 'ar')
  /// [limit] - Maximum number of results to return
  ///
  /// ```dart
  /// final results = await geocodingService.search(
  ///   'Cairo Tower',
  ///   country: 'eg',
  ///   language: 'en',
  ///   limit: 5,
  /// );
  /// ```
  Future<List<SearchResult>> search(
    String query, {
    String? country,
    String? language,
    int limit = 10,
  });

  /// Converts geographic coordinates to an address.
  ///
  /// Returns a [LocationAddress] with address details, or `null` if
  /// the coordinates couldn't be geocoded.
  ///
  /// [position] - The geographic coordinates to geocode
  /// [language] - Optional language for the address (e.g., 'en', 'ar')
  ///
  /// ```dart
  /// final address = await geocodingService.reverseGeocode(
  ///   LatLng(30.0444, 31.2357),
  ///   language: 'en',
  /// );
  ///
  /// if (address != null) {
  ///   print(address.formattedAddress);
  /// }
  /// ```
  Future<LocationAddress?> reverseGeocode(
    LatLng position, {
    String? language,
  });

  /// Searches for locations near a specific point.
  ///
  /// Useful for finding nearby places of interest.
  ///
  /// [query] - The search text
  /// [near] - The center point to search around
  /// [radiusKm] - Search radius in kilometers
  Future<List<SearchResult>> searchNearby(
    String query, {
    required LatLng near,
    double radiusKm = 10.0,
    String? language,
    int limit = 10,
  });
}
