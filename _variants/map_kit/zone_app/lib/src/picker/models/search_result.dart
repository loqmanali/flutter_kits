import 'package:flutter/foundation.dart';

import 'location_address.dart';

/// Represents a search result from a geocoding service.
///
/// Contains the location information along with search-specific
/// metadata like relevance score and result type.
///
/// ## Usage
///
/// ```dart
/// // From Nominatim API response
/// final result = SearchResult(
///   location: LocationAddress(
///     latitude: 30.0444,
///     longitude: 31.2357,
///     displayName: 'Cairo Tower, Zamalek, Cairo, Egypt',
///     city: 'Cairo',
///     country: 'Egypt',
///   ),
///   type: 'tourism',
///   category: 'attraction',
///   importance: 0.85,
/// );
///
/// // Display in search results list
/// ListTile(
///   title: Text(result.title),
///   subtitle: Text(result.subtitle),
///   onTap: () => selectLocation(result.location),
/// )
/// ```
@immutable
class SearchResult {
  /// The location information for this search result.
  final LocationAddress location;

  /// The type of place (e.g., 'highway', 'building', 'amenity').
  ///
  /// From OpenStreetMap type classification.
  final String? type;

  /// The category of the place (e.g., 'restaurant', 'hotel', 'road').
  ///
  /// More specific than [type].
  final String? category;

  /// Relevance score from the geocoding service (0.0 to 1.0).
  ///
  /// Higher values indicate more relevant results.
  final double? importance;

  /// Bounding box for this location [south, north, west, east].
  ///
  /// Useful for zooming the map to show the full extent.
  final List<double>? boundingBox;

  /// Creates a new [SearchResult] instance.
  const SearchResult({
    required this.location,
    this.type,
    this.category,
    this.importance,
    this.boundingBox,
  });

  /// Primary display title for the search result.
  ///
  /// Returns the street name, city, or full display name.
  String get title {
    if (location.street != null && location.street!.isNotEmpty) {
      return location.street!;
    }
    if (location.city != null && location.city!.isNotEmpty) {
      return location.city!;
    }
    if (location.displayName != null) {
      // Take first part of display name
      final parts = location.displayName!.split(',');
      return parts.first.trim();
    }
    return location.shortAddress;
  }

  /// Secondary display text (typically the broader location).
  String get subtitle {
    final parts = <String>[];

    if (location.city != null &&
        location.city!.isNotEmpty &&
        location.city != title) {
      parts.add(location.city!);
    }
    if (location.state != null && location.state!.isNotEmpty) {
      parts.add(location.state!);
    }
    if (location.country != null && location.country!.isNotEmpty) {
      parts.add(location.country!);
    }

    return parts.join(', ');
  }

  /// Full display name combining title and subtitle.
  String get fullDisplayName {
    if (subtitle.isNotEmpty) {
      return '$title, $subtitle';
    }
    return title;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResult &&
        other.location == location &&
        other.type == type &&
        other.category == category &&
        other.importance == importance;
  }

  @override
  int get hashCode => Object.hash(location, type, category, importance);

  @override
  String toString() => 'SearchResult($title)';
}
