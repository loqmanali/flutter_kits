import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/models.dart';
import '../services/services.dart';

/// Configuration for the location picker.
///
/// Provides initial values and customization options.
///
/// ## Usage
///
/// ```dart
/// final config = LocationPickerConfig(
///   initialCenter: LatLng(30.0444, 31.2357),
///   initialZoom: 15.0,
///   searchCountry: 'eg',
///   searchLanguage: 'en',
///   geocodingService: NominatimGeocodingService(),
/// );
/// ```
class LocationPickerConfig {
  /// Initial center position for the map.
  final LatLng initialCenter;

  /// Initial zoom level for the map.
  final double initialZoom;

  /// Initial location to pre-select (optional).
  final LocationAddress? initialLocation;

  /// Country code to limit search results (e.g., 'eg', 'us').
  final String? searchCountry;

  /// Language for search results and addresses.
  final String? searchLanguage;

  /// Maximum number of search results.
  final int searchLimit;

  /// Debounce duration for search input.
  final Duration searchDebounce;

  /// The geocoding service to use.
  final GeocodingService geocodingService;

  /// Whether to auto-reverse-geocode when selecting on map.
  final bool autoReverseGeocode;

  /// Creates a new [LocationPickerConfig] instance.
  const LocationPickerConfig({
    this.initialCenter = const LatLng(30.0444, 31.2357),
    this.initialZoom = 14.0,
    this.initialLocation,
    this.searchCountry,
    this.searchLanguage,
    this.searchLimit = 10,
    this.searchDebounce = const Duration(milliseconds: 500),
    required this.geocodingService,
    this.autoReverseGeocode = true,
  });
}

/// Notifier for managing location picker state.
///
/// Handles all location picker operations including:
/// - Map position updates
/// - Location selection
/// - Address search
/// - Reverse geocoding
///
/// ## Usage
///
/// ```dart
/// // Configure the picker
/// await ref.read(locationPickerProvider.notifier).configure(config);
///
/// // Select a location on the map
/// ref.read(locationPickerProvider.notifier).selectOnMap(LatLng(...));
///
/// // Search for a location
/// ref.read(locationPickerProvider.notifier).search('Cairo Tower');
///
/// // Select from search results
/// ref.read(locationPickerProvider.notifier).selectSearchResult(result);
///
/// // Confirm selection
/// final location = ref.read(locationPickerProvider.notifier).confirmSelection();
/// ```
class LocationPickerNotifier extends Notifier<LocationPickerState> {
  LocationPickerConfig? _config;
  Timer? _searchDebounceTimer;

  @override
  LocationPickerState build() {
    ref.onDispose(() {
      _searchDebounceTimer?.cancel();
    });

    return LocationPickerState.initial();
  }

  /// Configures the location picker with the given settings.
  Future<void> configure(LocationPickerConfig config) async {
    _config = config;
    _searchDebounceTimer?.cancel();

    state = LocationPickerState.initial(
      center: config.initialCenter,
      zoom: config.initialZoom,
      initialLocation: config.initialLocation,
    );
  }

  /// Updates the map center position.
  void updateMapCenter(LatLng center) {
    state = state.copyWith(mapCenter: center);
  }

  /// Updates the map zoom level.
  void updateMapZoom(double zoom) {
    state = state.copyWith(mapZoom: zoom);
  }

  /// Updates both map center and zoom.
  void updateMapPosition(LatLng center, double zoom) {
    state = state.copyWith(mapCenter: center, mapZoom: zoom);
  }

  /// Selects a location by tapping on the map.
  ///
  /// If [autoReverseGeocode] is enabled in config, automatically
  /// fetches the address for the selected coordinates.
  Future<void> selectOnMap(LatLng position) async {
    // Create initial location from coordinates
    final location = LocationAddress.fromLatLng(position);

    state = state.copyWith(
      selectedLocation: location,
      mapCenter: position,
      mode: LocationPickerMode.preview,
      isLoadingAddress: _config?.autoReverseGeocode ?? true,
      clearError: true,
    );

    // Auto reverse geocode if enabled
    if (_config?.autoReverseGeocode ?? true) {
      await _reverseGeocode(position);
    }
  }

  /// Performs reverse geocoding for the given position.
  Future<void> _reverseGeocode(LatLng position) async {
    if (_config == null) return;

    try {
      final address = await _config!.geocodingService.reverseGeocode(
        position,
        language: _config!.searchLanguage,
      );

      if (address != null) {
        state = state.copyWith(
          selectedLocation: address,
          isLoadingAddress: false,
        );
      } else {
        state = state.copyWith(isLoadingAddress: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingAddress: false,
        errorMessage: 'Failed to get address: $e',
      );
    }
  }

  /// Manually triggers reverse geocoding for current selection.
  Future<void> reverseGeocodeCurrentSelection() async {
    final location = state.selectedLocation;
    if (location == null) return;

    state = state.copyWith(isLoadingAddress: true, clearError: true);
    await _reverseGeocode(location.latLng);
  }

  /// Enters search mode.
  void enterSearchMode() {
    state = state.copyWith(
      mode: LocationPickerMode.search,
      clearError: true,
    );
  }

  /// Exits search mode and returns to map mode.
  void exitSearchMode() {
    state = state.copyWith(
      mode: LocationPickerMode.map,
      searchQuery: '',
      clearSearchResults: true,
      clearError: true,
    );
  }

  /// Updates the search query with debouncing.
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);

    _searchDebounceTimer?.cancel();

    if (query.isEmpty) {
      state = state.copyWith(clearSearchResults: true);
      return;
    }

    _searchDebounceTimer = Timer(
      _config?.searchDebounce ?? const Duration(milliseconds: 500),
      () => _performSearch(query),
    );
  }

  /// Performs search immediately without debouncing.
  Future<void> searchNow(String query) async {
    _searchDebounceTimer?.cancel();
    state = state.copyWith(searchQuery: query);
    await _performSearch(query);
  }

  /// Internal search implementation.
  Future<void> _performSearch(String query) async {
    if (_config == null || query.isEmpty) return;

    state = state.copyWith(isSearching: true, clearError: true);

    try {
      final results = await _config!.geocodingService.search(
        query,
        country: _config!.searchCountry,
        language: _config!.searchLanguage,
        limit: _config!.searchLimit,
      );

      state = state.copyWith(
        searchResults: results,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: 'Search failed: $e',
      );
    }
  }

  /// Selects a location from search results.
  void selectSearchResult(SearchResult result) {
    state = state.copyWith(
      selectedLocation: result.location,
      mapCenter: result.location.latLng,
      mapZoom: 16.0, // Zoom in when selecting
      mode: LocationPickerMode.preview,
      searchQuery: '',
      clearSearchResults: true,
      clearError: true,
    );
  }

  /// Clears the current selection.
  void clearSelection() {
    state = state.copyWith(
      clearSelection: true,
      mode: LocationPickerMode.map,
      clearError: true,
    );
  }

  /// Enters confirm mode (ready to confirm selection).
  void enterConfirmMode() {
    if (state.hasSelection) {
      state = state.copyWith(isConfirmMode: true);
    }
  }

  /// Confirms and returns the selected location.
  ///
  /// Returns `null` if no location is selected.
  LocationAddress? confirmSelection() {
    return state.selectedLocation;
  }

  /// Resets the picker to initial state.
  void reset() {
    _searchDebounceTimer?.cancel();

    if (_config != null) {
      state = LocationPickerState.initial(
        center: _config!.initialCenter,
        zoom: _config!.initialZoom,
        initialLocation: _config!.initialLocation,
      );
    } else {
      state = LocationPickerState.initial();
    }
  }

  /// Clears any error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Sets a custom error message.
  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  /// Moves map to a specific location without selecting it.
  void goToLocation(LatLng position, {double? zoom}) {
    state = state.copyWith(
      mapCenter: position,
      mapZoom: zoom ?? state.mapZoom,
    );
  }

  /// Moves map to show current selection.
  void goToSelection() {
    if (state.hasSelection) {
      state = state.copyWith(
        mapCenter: state.selectedLocation!.latLng,
        mapZoom: 16.0,
      );
    }
  }
}

/// Main provider for location picker state.
///
/// ## Usage
///
/// ```dart
/// // Watch state
/// final state = ref.watch(locationPickerProvider);
///
/// // Access notifier
/// final notifier = ref.read(locationPickerProvider.notifier);
///
/// // Configure
/// await notifier.configure(LocationPickerConfig(...));
///
/// // Select on map
/// notifier.selectOnMap(LatLng(30.0, 31.0));
///
/// // Search
/// notifier.updateSearchQuery('Cairo');
///
/// // Get selection
/// final location = notifier.confirmSelection();
/// ```
final locationPickerProvider =
    NotifierProvider<LocationPickerNotifier, LocationPickerState>(
  LocationPickerNotifier.new,
);

/// Provider for the geocoding service.
///
/// Can be overridden to use a different geocoding provider.
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     geocodingServiceProvider.overrideWithValue(
///       MyCustomGeocodingService(),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return NominatimGeocodingService();
});
