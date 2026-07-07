import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../models/models.dart';
import '../providers/providers.dart';

/// Configuration for map appearance.
///
/// Customize tile provider, zoom levels, and other map settings.
class LocationPickerMapConfig {
  /// URL template for map tiles.
  final String tileUrlTemplate;

  /// Subdomains for tile URL.
  final List<String> subdomains;

  /// Minimum zoom level.
  final double minZoom;

  /// Maximum zoom level.
  final double maxZoom;

  /// Whether to show attribution.
  final bool showAttribution;

  /// Attribution text.
  final String attributionText;

  /// Creates a new [LocationPickerMapConfig].
  const LocationPickerMapConfig({
    this.tileUrlTemplate =
        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
    this.subdomains = const ['a', 'b', 'c', 'd'],
    this.minZoom = 3.0,
    this.maxZoom = 19.0,
    this.showAttribution = true,
    this.attributionText = 'OpenStreetMap contributors',
  });
}

/// The main map widget for location picking.
///
/// Displays an interactive map where users can:
/// - Pan and zoom to explore
/// - Tap to select a location
/// - See a marker at the selected location
///
/// ## Usage
///
/// ```dart
/// LocationPickerMap(
///   controller: _mapController,
///   config: LocationPickerMapConfig(
///     tileUrlTemplate: 'https://...',
///   ),
///   onTap: (position) {
///     ref.read(locationPickerProvider.notifier).selectOnMap(position);
///   },
///   markerBuilder: (context, location) {
///     return MyCustomMarker(location: location);
///   },
/// )
/// ```
class LocationPickerMap extends ConsumerWidget {
  /// Optional external map controller.
  final MapController? controller;

  /// Map configuration.
  final LocationPickerMapConfig config;

  /// Called when the map is tapped.
  final void Function(LatLng position)? onTap;

  /// Called when the map position changes.
  final void Function(LatLng center, double zoom)? onPositionChanged;

  /// Custom builder for the selection marker.
  final Widget Function(BuildContext, LocationAddress)? markerBuilder;

  /// Custom marker widget (used if markerBuilder is null).
  final Widget? marker;

  /// Whether to show a center crosshair instead of a marker.
  final bool showCenterCrosshair;

  /// Custom crosshair widget.
  final Widget? crosshairWidget;

  /// Creates a new [LocationPickerMap].
  const LocationPickerMap({
    super.key,
    this.controller,
    this.config = const LocationPickerMapConfig(),
    this.onTap,
    this.onPositionChanged,
    this.markerBuilder,
    this.marker,
    this.showCenterCrosshair = false,
    this.crosshairWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationPickerProvider);

    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: state.mapCenter,
            initialZoom: state.mapZoom,
            minZoom: config.minZoom,
            maxZoom: config.maxZoom,
            onTap: (tapPosition, point) {
              if (onTap != null) {
                onTap!(point);
              } else {
                ref.read(locationPickerProvider.notifier).selectOnMap(point);
              }
            },
            onPositionChanged: (position, hasGesture) {
              if (hasGesture &&
                  onPositionChanged != null &&
                  position.center != null) {
                onPositionChanged!(
                  position.center!,
                  position.zoom ?? state.mapZoom,
                );
              }
            },
          ),
          children: [
            // Tile layer
            TileLayer(
              urlTemplate: config.tileUrlTemplate,
              subdomains: config.subdomains,
              userAgentPackageName: 'com.location.picker',
              retinaMode: true,
              tileProvider: CancellableNetworkTileProvider(),
            ),

            // Selection marker
            if (state.hasSelection && !showCenterCrosshair)
              MarkerLayer(
                markers: [
                  Marker(
                    point: state.selectedLocation!.latLng,
                    width: 50,
                    height: 50,
                    child: markerBuilder != null
                        ? markerBuilder!(context, state.selectedLocation!)
                        : marker ?? _defaultMarker(context),
                  ),
                ],
              ),

            // Attribution
            if (config.showAttribution)
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    config.attributionText,
                    textStyle: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
          ],
        ),

        // Center crosshair (if enabled)
        if (showCenterCrosshair)
          Center(
            child: crosshairWidget ?? _defaultCrosshair(context),
          ),
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
        CustomPaint(
          size: const Size(12, 8),
          painter: _MarkerPointerPainter(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _defaultCrosshair(BuildContext context) {
    return IgnorePointer(
      child: Column(
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
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
          CustomPaint(
            size: const Size(12, 8),
            painter: _MarkerPointerPainter(
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 40), // Offset to point to center
        ],
      ),
    );
  }
}

/// Custom painter for marker pointer triangle.
class _MarkerPointerPainter extends CustomPainter {
  final Color color;

  _MarkerPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
