import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'location_address.dart';
import 'search_result.dart';

/// The current mode of the location picker.
enum LocationPickerMode {
  /// User is browsing/selecting on the map.
  map,

  /// User is searching for a location.
  search,

  /// Showing preview of selected location.
  preview,
}

/// Immutable state for the location picker.
///
/// Contains all information about the current state of location selection,
/// including the selected location, search results, and UI state.
///
/// ## Usage
///
/// ```dart
/// // Access state via Riverpod
/// final state = ref.watch(locationPickerProvider);
///
/// // Check if a location is selected
/// if (state.hasSelection) {
///   print('Selected: ${state.selectedLocation!.formattedAddress}');
/// }
///
/// // Check search state
/// if (state.isSearching) {
///   showLoadingIndicator();
/// } else if (state.searchResults.isNotEmpty) {
///   showSearchResults(state.searchResults);
/// }
/// ```
@immutable
class LocationPickerState {
  /// The currently selected location (if any).
  final LocationAddress? selectedLocation;

  /// Current map center position.
  final LatLng mapCenter;

  /// Current map zoom level.
  final double mapZoom;

  /// Current mode of the picker.
  final LocationPickerMode mode;

  /// Current search query text.
  final String searchQuery;

  /// Search results from the geocoding service.
  final List<SearchResult> searchResults;

  /// Whether a search is currently in progress.
  final bool isSearching;

  /// Whether reverse geocoding is in progress for the selected point.
  final bool isLoadingAddress;

  /// Error message (if any).
  final String? errorMessage;

  /// Whether the picker is in "confirm" mode (ready to confirm selection).
  final bool isConfirmMode;

  /// Creates a new [LocationPickerState] instance.
  const LocationPickerState({
    this.selectedLocation,
    required this.mapCenter,
    this.mapZoom = 14.0,
    this.mode = LocationPickerMode.map,
    this.searchQuery = '',
    this.searchResults = const [],
    this.isSearching = false,
    this.isLoadingAddress = false,
    this.errorMessage,
    this.isConfirmMode = false,
  });

  /// Creates the initial state with a given center position.
  factory LocationPickerState.initial({
    LatLng? center,
    double zoom = 14.0,
    LocationAddress? initialLocation,
  }) {
    return LocationPickerState(
      mapCenter: center ?? const LatLng(30.0444, 31.2357), // Default: Cairo
      mapZoom: zoom,
      selectedLocation: initialLocation,
    );
  }

  /// Whether a location has been selected.
  bool get hasSelection => selectedLocation != null;

  /// Whether the search field has text.
  bool get hasSearchQuery => searchQuery.isNotEmpty;

  /// Whether there are search results to display.
  bool get hasSearchResults => searchResults.isNotEmpty;

  /// Whether in search mode (showing search UI).
  bool get isInSearchMode => mode == LocationPickerMode.search;

  /// Whether in map mode (browsing map).
  bool get isInMapMode => mode == LocationPickerMode.map;

  /// Whether in preview mode (showing selected location details).
  bool get isInPreviewMode => mode == LocationPickerMode.preview;

  /// Whether any loading operation is in progress.
  bool get isLoading => isSearching || isLoadingAddress;

  /// Whether there's an error to display.
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Creates a copy with the given fields replaced.
  LocationPickerState copyWith({
    LocationAddress? selectedLocation,
    LatLng? mapCenter,
    double? mapZoom,
    LocationPickerMode? mode,
    String? searchQuery,
    List<SearchResult>? searchResults,
    bool? isSearching,
    bool? isLoadingAddress,
    String? errorMessage,
    bool? isConfirmMode,
    bool clearSelection = false,
    bool clearError = false,
    bool clearSearchResults = false,
  }) {
    return LocationPickerState(
      selectedLocation:
          clearSelection ? null : (selectedLocation ?? this.selectedLocation),
      mapCenter: mapCenter ?? this.mapCenter,
      mapZoom: mapZoom ?? this.mapZoom,
      mode: mode ?? this.mode,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults:
          clearSearchResults ? const [] : (searchResults ?? this.searchResults),
      isSearching: isSearching ?? this.isSearching,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isConfirmMode: isConfirmMode ?? this.isConfirmMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationPickerState &&
        other.selectedLocation == selectedLocation &&
        other.mapCenter == mapCenter &&
        other.mapZoom == mapZoom &&
        other.mode == mode &&
        other.searchQuery == searchQuery &&
        listEquals(other.searchResults, searchResults) &&
        other.isSearching == isSearching &&
        other.isLoadingAddress == isLoadingAddress &&
        other.errorMessage == errorMessage &&
        other.isConfirmMode == isConfirmMode;
  }

  @override
  int get hashCode {
    return Object.hash(
      selectedLocation,
      mapCenter,
      mapZoom,
      mode,
      searchQuery,
      Object.hashAll(searchResults),
      isSearching,
      isLoadingAddress,
      errorMessage,
      isConfirmMode,
    );
  }
}
