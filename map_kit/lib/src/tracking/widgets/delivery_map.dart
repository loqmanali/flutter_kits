import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/models.dart';
import '../providers/providers.dart';

/// Configuration for map appearance
class DeliveryMapConfig {
  final String tileUrlTemplate;
  final List<String> subdomains;
  final double initialZoom;
  final double minZoom;
  final double maxZoom;
  final bool showAttribution;
  final String attributionText;

  const DeliveryMapConfig({
    // this.tileUrlTemplate =
    //     'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
    // this.subdomains = const ['a', 'b', 'c', 'd'],
    this.tileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.subdomains = const ['a', 'b', 'c'],
    this.initialZoom = 14.0,
    this.minZoom = 10.0,
    this.maxZoom = 18.0,
    this.showAttribution = true,
    this.attributionText = '© OpenStreetMap contributors',
  });
}

/// Builder for custom markers
typedef MarkerBuilder = Widget Function(
  BuildContext context,
  DeliveryLocation location,
  MarkerType type,
);

/// Types of markers on the map
enum MarkerType { origin, destination, driver }

/// The main delivery tracking map widget
class DeliveryMap extends ConsumerWidget {
  final MapController? controller;
  final DeliveryMapConfig config;
  final MarkerBuilder? markerBuilder;
  final Widget? originMarker;
  final Widget? destinationMarker;
  final Widget? driverMarker;
  final void Function(LatLng position)? onTap;
  final void Function(DeliveryLocation location, MarkerType type)? onMarkerTap;

  const DeliveryMap({
    super.key,
    this.controller,
    this.config = const DeliveryMapConfig(),
    this.markerBuilder,
    this.originMarker,
    this.destinationMarker,
    this.driverMarker,
    this.onTap,
    this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryTrackingProvider);

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: state.origin.latLng,
        initialZoom: config.initialZoom,
        minZoom: config.minZoom,
        maxZoom: config.maxZoom,
        onTap: onTap != null ? (_, point) => onTap!(point) : null,
      ),
      children: [
        // Tile layer with error handling
        TileLayer(
          urlTemplate: config.tileUrlTemplate,
          // subdomains: config.subdomains,
          userAgentPackageName: 'com.delivery.tracking',
          retinaMode: false,
          // Add error handling for debugging
          errorTileCallback: (tile, error, stackTrace) {
            debugPrint('Map tile error: ${tile.toString()}, Error: $error');
          },
          // Use standard network provider with timeout
          tileProvider: CancellableNetworkTileProvider(
            headers: {
              'User-Agent': 'com.delivery.tracking',
            },
          ),
        ),

        // Route polyline
        if (state.remainingRoute != null && state.remainingRoute!.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: state.remainingRoute!.points,
                color: state.remainingRoute!.color,
                strokeWidth: state.remainingRoute!.strokeWidth,
              ),
            ],
          ),

        // Markers
        MarkerLayer(
          markers: _buildMarkers(context, state),
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
    );
  }

  List<Marker> _buildMarkers(
    BuildContext context,
    DeliveryTrackingState state,
  ) {
    final markers = <Marker>[];

    // Origin marker
    markers.add(
      _createMarker(
        context,
        state.origin,
        MarkerType.origin,
        originMarker ??
            _defaultMarker(
              const Icon(Icons.restaurant, color: Colors.red, size: 30),
            ),
      ),
    );

    // Destination marker
    markers.add(
      _createMarker(
        context,
        state.destination,
        MarkerType.destination,
        destinationMarker ??
            _defaultMarker(
              const Icon(Icons.home, color: Colors.green, size: 30),
            ),
      ),
    );

    // Driver marker
    if (state.driverLocation != null) {
      markers.add(
        _createMarker(
          context,
          state.driverLocation!,
          MarkerType.driver,
          driverMarker ??
              _defaultMarker(
                const Icon(Icons.delivery_dining, color: Colors.blue, size: 30),
              ),
        ),
      );
    }

    return markers;
  }

  Marker _createMarker(
    BuildContext context,
    DeliveryLocation location,
    MarkerType type,
    Widget child,
  ) {
    final markerWidget =
        markerBuilder != null ? markerBuilder!(context, location, type) : child;

    return Marker(
      point: location.latLng,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: onMarkerTap != null ? () => onMarkerTap!(location, type) : null,
        child: markerWidget,
      ),
    );
  }

  Widget _defaultMarker(Widget icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: icon,
    );
  }
}
