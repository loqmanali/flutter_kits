import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../location_picker.dart';

/// Example demonstrating basic usage of the Location Picker module.
///
/// This example shows how to:
/// - Configure the location picker
/// - Display map, search bar, and preview card
/// - Handle location selection
///
/// ## Usage
///
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => const LocationPickerBasicExample(),
///   ),
/// );
/// ```
class LocationPickerBasicExample extends ConsumerStatefulWidget {
  /// Initial location to center the map on.
  final LatLng? initialCenter;

  /// Pre-selected location (optional).
  final LocationAddress? initialLocation;

  /// Creates a new [LocationPickerBasicExample].
  const LocationPickerBasicExample({
    super.key,
    this.initialCenter,
    this.initialLocation,
  });

  @override
  ConsumerState<LocationPickerBasicExample> createState() =>
      _LocationPickerBasicExampleState();
}

class _LocationPickerBasicExampleState
    extends ConsumerState<LocationPickerBasicExample> {
  final MapController _mapController = MapController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePicker();
  }

  Future<void> _initializePicker() async {
    Future(() async {
      await ref.read(locationPickerProvider.notifier).configure(
            LocationPickerConfig(
              initialCenter:
                  widget.initialCenter ?? const LatLng(30.0444, 31.2357),
              initialLocation: widget.initialLocation,
              searchCountry: 'eg', // Limit search to Egypt
              searchLanguage: 'en',
              geocodingService: NominatimGeocodingService(),
            ),
          );

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(locationPickerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          LocationPickerMap(
            controller: _mapController,
            config: const LocationPickerMapConfig(
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
          ),

          // Search bar (top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Back button and search bar
                Row(
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Search bar
                    const Expanded(
                      child: LocationSearchBar(),
                    ),
                  ],
                ),

                // Search results
                if (state.isInSearchMode && state.hasSearchResults)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: SearchResultsList(
                      onResultSelected: (result) {
                        // Animate map to selected location
                        _mapController.move(result.location.latLng, 16.0);
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Current location button
          Positioned(
            right: 16,
            bottom: state.hasSelection ? 220 : 100,
            child: CurrentLocationButton(
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                );
              },
            ),
          ),

          // Preview card (bottom)
          if (state.hasSelection)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LocationPreviewCard(
                onConfirm: (location) {
                  Navigator.pop(context, location);
                },
                onChangePressed: () {
                  ref.read(locationPickerProvider.notifier).clearSelection();
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Example showing the location picker as a full-screen page.
///
/// Returns the selected [LocationAddress] when confirmed.
///
/// ## Usage
///
/// ```dart
/// final location = await Navigator.push<LocationAddress>(
///   context,
///   MaterialPageRoute(
///     builder: (_) => const LocationPickerPage(),
///   ),
/// );
///
/// if (location != null) {
///   print('Selected: ${location.displayName}');
/// }
/// ```
class LocationPickerPage extends StatelessWidget {
  /// Title shown in the app bar.
  final String title;

  /// Initial center position.
  final LatLng? initialCenter;

  /// Creates a new [LocationPickerPage].
  const LocationPickerPage({
    super.key,
    this.title = 'Select Location',
    this.initialCenter,
  });

  @override
  Widget build(BuildContext context) {
    return LocationPickerBasicExample(
      initialCenter: initialCenter,
    );
  }
}

/// Example showing how to display a location on a read-only map.
///
/// This is useful for showing delivery addresses, store locations, etc.
///
/// ## Usage
///
/// ```dart
/// LocationViewExample(
///   location: LocationAddress(
///     latitude: 30.0444,
///     longitude: 31.2357,
///     displayName: 'Cairo Tower',
///   ),
///   height: 200,
/// )
/// ```
class LocationViewExample extends StatelessWidget {
  /// The location to display.
  final LocationAddress location;

  /// Height of the map view.
  final double height;

  /// Whether to show the address card below the map.
  final bool showAddressCard;

  /// Custom marker widget.
  final Widget? marker;

  /// Creates a new [LocationViewExample].
  const LocationViewExample({
    super.key,
    required this.location,
    this.height = 200,
    this.showAddressCard = true,
    this.marker,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Map view
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: location.latLng,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none, // Read-only map
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location.latLng,
                      width: 50,
                      height: 50,
                      child: marker ?? _defaultMarker(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Address card
        if (showAddressCard) ...[
          const SizedBox(height: 12),
          _buildAddressCard(context),
        ],
      ],
    );
  }

  Widget _defaultMarker(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: theme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.displayName ?? 'Selected Location',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Example demonstrating how to use location picker with custom styling.
///
/// Shows how to customize colors, icons, and behavior.
class LocationPickerCustomExample extends ConsumerStatefulWidget {
  /// Primary color for the picker.
  final Color primaryColor;

  /// Creates a new [LocationPickerCustomExample].
  const LocationPickerCustomExample({
    super.key,
    this.primaryColor = Colors.deepOrange,
  });

  @override
  ConsumerState<LocationPickerCustomExample> createState() =>
      _LocationPickerCustomExampleState();
}

class _LocationPickerCustomExampleState
    extends ConsumerState<LocationPickerCustomExample> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePicker();
  }

  Future<void> _initializePicker() async {
    Future(() async {
      await ref.read(locationPickerProvider.notifier).configure(
            LocationPickerConfig(
              geocodingService: NominatimGeocodingService(
                userAgent: 'MyCustomApp/1.0',
              ),
            ),
          );

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(locationPickerProvider);

    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: widget.primaryColor,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: widget.primaryColor,
            ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Delivery Location'),
          backgroundColor: widget.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: LocationSearchBar(
                config: LocationSearchBarConfig(
                  hintText: 'Where should we deliver?',
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ),

            // Search results or map
            Expanded(
              child: state.isInSearchMode && state.hasSearchResults
                  ? const SearchResultsList(
                      config: SearchResultsListConfig(
                        emptyMessage: 'No addresses found',
                      ),
                    )
                  : LocationPickerMap(
                      showCenterCrosshair: true,
                      crosshairWidget: _buildCustomCrosshair(),
                    ),
            ),

            // Preview card
            if (state.hasSelection)
              LocationPreviewCard(
                config: LocationPreviewCardConfig(
                  confirmButtonText: 'Deliver Here',
                  confirmButtonColor: widget.primaryColor,
                ),
                onConfirm: (location) {
                  Navigator.pop(context, location);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCrosshair() {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.delivery_dining,
              color: Colors.white,
              size: 28,
            ),
          ),
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: widget.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: widget.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Comprehensive screen that combines all location picker examples.
///
/// This screen provides easy navigation to all available location picker
/// examples and demonstrates different use cases and configurations.
class LocationPickerExamplesScreen extends StatelessWidget {
  /// Creates a new [LocationPickerExamplesScreen].
  const LocationPickerExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Picker Examples'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Basic Examples'),
          const SizedBox(height: 8),
          _buildExampleCard(
            context,
            title: 'Basic Location Picker',
            description:
                'Simple location picker with map, search, and preview card',
            icon: Icons.location_on,
            onTap: () => _navigateToExample(
              context,
              const LocationPickerBasicExample(),
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleCard(
            context,
            title: 'Full Screen Page',
            description: 'Location picker as a full-screen page with app bar',
            icon: Icons.fullscreen,
            onTap: () => _navigateToExample(
              context,
              const LocationPickerPage(),
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleCard(
            context,
            title: 'Location View',
            description: 'Read-only map view for displaying selected locations',
            icon: Icons.visibility,
            onTap: () => _navigateToExample(
              context,
              const LocationViewExample(
                location: LocationAddress(
                  latitude: 30.0444,
                  longitude: 31.2357,
                  displayName: 'Cairo Tower, Egypt',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Advanced Examples'),
          const SizedBox(height: 8),
          _buildExampleCard(
            context,
            title: 'Custom Styled Picker',
            description:
                'Location picker with custom colors and delivery theme',
            icon: Icons.palette,
            color: Colors.deepOrange,
            onTap: () => _navigateToExample(
              context,
              const LocationPickerCustomExample(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Demo Scenarios'),
          const SizedBox(height: 8),
          _buildExampleCard(
            context,
            title: 'Restaurant Location',
            description: 'Find and select restaurant delivery location',
            icon: Icons.restaurant,
            color: Colors.red,
            onTap: () => _navigateToExample(
              context,
              const LocationPickerCustomExample(
                primaryColor: Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleCard(
            context,
            title: 'Store Location',
            description: 'Select store or pickup location',
            icon: Icons.store,
            color: Colors.green,
            onTap: () => _navigateToExample(
              context,
              const LocationPickerCustomExample(
                primaryColor: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleCard(
            context,
            title: 'Home Delivery',
            description: 'Set home delivery address',
            icon: Icons.home,
            color: Colors.blue,
            onTap: () => _navigateToExample(
              context,
              const LocationPickerCustomExample(
                primaryColor: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Test Locations'),
          const SizedBox(height: 8),
          _buildExampleCard(
            context,
            title: 'Cairo, Egypt',
            description: 'Test with Cairo coordinates',
            icon: Icons.location_city,
            onTap: () => _navigateToExample(
              context,
              const LocationPickerBasicExample(
                initialCenter: LatLng(30.0444, 31.2357),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleCard(
            context,
            title: 'Alexandria, Egypt',
            description: 'Test with Alexandria coordinates',
            icon: Icons.beach_access,
            onTap: () => _navigateToExample(
              context,
              const LocationPickerBasicExample(
                initialCenter: LatLng(31.2001, 29.9187),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleCard(
            context,
            title: 'Pre-selected Location',
            description: 'Test with pre-selected location',
            icon: Icons.check_circle,
            onTap: () => _navigateToExample(
              context,
              const LocationPickerBasicExample(
                initialLocation: LocationAddress(
                  latitude: 30.0444,
                  longitude: 31.2357,
                  displayName: 'Cairo Tower, Cairo, Egypt',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final cardColor = color ?? Theme.of(context).primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: cardColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).disabledColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToExample(BuildContext context, Widget example) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => example),
    );
  }
}
