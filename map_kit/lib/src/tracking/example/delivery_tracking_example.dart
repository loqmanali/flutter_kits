// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../delivery_tracking.dart';

/// ============================================================================
/// DELIVERY TRACKING MODULE - USAGE EXAMPLE
/// ============================================================================
///
/// This file demonstrates how to use the delivery tracking module.
/// All the dummy data here is for demonstration purposes only.
///
/// ## How to use in your project:
///
/// 1. Import the module:
///    `import 'package:your_app/core/delivery_tracking/delivery_tracking.dart';`
///
/// 2. Wrap your app with ProviderScope (if not already done):
///    ```dart
///    runApp(ProviderScope(child: MyApp()));
///    ```
///
/// 3. Configure and use the widgets as shown in this example.
///

// =============================================================================
// EXAMPLE 1: Basic Usage
// =============================================================================

/// Basic example showing the simplest way to use delivery tracking
class BasicDeliveryTrackingExample extends ConsumerStatefulWidget {
  /// Your origin location (restaurant, warehouse, etc.)
  final DeliveryLocation origin;

  /// Your destination location (customer address)
  final DeliveryLocation destination;

  /// Optional: Driver name to display
  final String? driverName;

  const BasicDeliveryTrackingExample({
    super.key,
    required this.origin,
    required this.destination,
    this.driverName,
  });

  @override
  ConsumerState<BasicDeliveryTrackingExample> createState() =>
      _BasicDeliveryTrackingExampleState();
}

class _BasicDeliveryTrackingExampleState
    extends ConsumerState<BasicDeliveryTrackingExample> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTracking();
    });
  }

  Future<void> _initializeTracking() async {
    // Configure the tracking with your data
    await ref.read(deliveryTrackingProvider.notifier).configure(
          DeliveryTrackingConfig(
            origin: widget.origin,
            destination: widget.destination,
            routingService: OsrmRoutingService(),
          ),
        );

    // Start the simulation (remove this for real tracking)
    ref.read(deliveryTrackingProvider.notifier).startSimulation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Tracking'),
        actions: const [
          DeliveryControls(), // Built-in pause/reset controls
        ],
      ),
      body: const Column(
        children: [
          DeliveryStatusCard(), // Shows status and progress
          Expanded(
            child: DeliveryLoadingIndicator(
              loadingText: 'Loading route...',
              child: DeliveryMap(), // The map with route
            ),
          ),
          DeliveryInfoPanel(
            title: 'Delivery Details',
          ), // Distance and ETA
        ],
      ),
    );
  }
}

// =============================================================================
// EXAMPLE 2: Custom Styled Delivery Tracking
// =============================================================================

/// Example with custom styling and markers
class CustomStyledDeliveryTracking extends ConsumerStatefulWidget {
  final DeliveryLocation origin;
  final DeliveryLocation destination;

  const CustomStyledDeliveryTracking({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  ConsumerState<CustomStyledDeliveryTracking> createState() =>
      _CustomStyledDeliveryTrackingState();
}

class _CustomStyledDeliveryTrackingState
    extends ConsumerState<CustomStyledDeliveryTracking> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTracking();
    });
  }

  Future<void> _initializeTracking() async {
    await ref.read(deliveryTrackingProvider.notifier).configure(
          DeliveryTrackingConfig(
            origin: widget.origin,
            destination: widget.destination,
            routingService: OsrmRoutingService(),
            // Custom progress increment (slower simulation)
            progressIncrement: 0.01,
            // Custom status thresholds
            statusThresholds: const [
              StatusThreshold(0.0, DeliveryStatus.preparing),
              StatusThreshold(0.1, DeliveryStatus.pickedUp),
              StatusThreshold(0.2, DeliveryStatus.onTheWay),
              StatusThreshold(0.8, DeliveryStatus.arriving),
              StatusThreshold(1.0, DeliveryStatus.delivered),
            ],
          ),
        );

    ref.read(deliveryTrackingProvider.notifier).startSimulation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Custom styled map
          DeliveryMap(
            controller: _mapController,
            config: const DeliveryMapConfig(
              initialZoom: 15.0,
            ),
            // Custom markers
            originMarker: _buildCustomMarker(Colors.red, Icons.store),
            destinationMarker: _buildCustomMarker(Colors.green, Icons.home),
            driverMarker: _buildCustomMarker(Colors.blue, Icons.motorcycle),
            onMarkerTap: (location, type) {
              _showLocationDetails(context, location, type);
            },
          ),

          // Custom status card overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: DeliveryStatusCard(
              config: DeliveryStatusCardConfig(
                backgroundColor: Colors.white.withValues(alpha: 0.95),
                borderRadius: 16.0,
              ),
            ),
          ),

          // Custom info panel overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DeliveryInfoPanel(
              config: const DeliveryInfoPanelConfig(
                padding: EdgeInsets.all(20),
              ),
              title: 'Order #12345',
              formatDuration: (duration) {
                if (duration.inMinutes < 1) return 'Arriving now!';
                return '${duration.inMinutes} min away';
              },
            ),
          ),

          // Floating action button for controls
          Positioned(
            bottom: 140,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'center',
                  onPressed: () => _centerOnDriver(),
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                const DeliveryPauseButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomMarker(Color color, IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  void _centerOnDriver() {
    final state = ref.read(deliveryTrackingProvider);
    if (state.driverLocation != null) {
      _mapController.move(state.driverLocation!.latLng, 16);
    }
  }

  void _showLocationDetails(
    BuildContext context,
    DeliveryLocation location,
    MarkerType type,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (location.address != null) ...[
              const SizedBox(height: 8),
              Text(location.address!),
            ],
            const SizedBox(height: 8),
            Text(
              'Lat: ${location.latitude.toStringAsFixed(6)}, '
              'Lng: ${location.longitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EXAMPLE 3: Real-Time Tracking (No Simulation)
// =============================================================================

/// Example showing how to use with real GPS data
class RealTimeDeliveryTracking extends ConsumerStatefulWidget {
  final DeliveryLocation origin;
  final DeliveryLocation destination;

  /// Stream of driver location updates from your backend
  final Stream<DeliveryLocation> driverLocationStream;

  /// Stream of delivery progress updates from your backend
  final Stream<double> progressStream;

  const RealTimeDeliveryTracking({
    super.key,
    required this.origin,
    required this.destination,
    required this.driverLocationStream,
    required this.progressStream,
  });

  @override
  ConsumerState<RealTimeDeliveryTracking> createState() =>
      _RealTimeDeliveryTrackingState();
}

class _RealTimeDeliveryTrackingState
    extends ConsumerState<RealTimeDeliveryTracking> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTracking();
      _listenToUpdates();
    });
  }

  Future<void> _initializeTracking() async {
    await ref.read(deliveryTrackingProvider.notifier).configure(
          DeliveryTrackingConfig(
            origin: widget.origin,
            destination: widget.destination,
            routingService: OsrmRoutingService(),
          ),
        );
    // Note: We don't call startSimulation() for real tracking
  }

  void _listenToUpdates() {
    // Listen to driver location updates
    widget.driverLocationStream.listen((location) {
      ref
          .read(deliveryTrackingProvider.notifier)
          .updateDriverLocation(location);
    });

    // Listen to progress updates
    widget.progressStream.listen((progress) {
      ref.read(deliveryTrackingProvider.notifier).updateProgress(progress);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Tracking')),
      body: const Column(
        children: [
          DeliveryStatusCard(),
          Expanded(
            child: DeliveryLoadingIndicator(
              loadingText: 'Loading route...',
              child: DeliveryMap(),
            ),
          ),
          DeliveryInfoPanel(),
        ],
      ),
    );
  }
}

// =============================================================================
// EXAMPLE 4: Completely Custom UI
// =============================================================================

/// Example showing how to build completely custom UI
class CompletelyCustomDeliveryUI extends ConsumerWidget {
  final DeliveryLocation origin;
  final DeliveryLocation destination;

  const CompletelyCustomDeliveryUI({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access state directly for complete control
    final state = ref.watch(deliveryTrackingProvider);
    final notifier = ref.read(deliveryTrackingProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          // Your completely custom status widget
          Container(
            padding: const EdgeInsets.all(20),
            color: _getStatusColor(state.status),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusText(state.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.progressPercent}% complete',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${state.remainingTime.inMinutes} min',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // The map
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const DeliveryMap(),
          ),

          // Custom bottom controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From: ${state.origin.label}'),
                      Text('To: ${state.destination.label}'),
                      Text(
                        'Distance: ${state.remainingDistanceKm.toStringAsFixed(1)} km',
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: state.isCompleted ? null : notifier.togglePause,
                  child: Text(state.isPaused ? 'Resume' : 'Pause'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DeliveryStatus status) {
    return switch (status) {
      DeliveryStatus.preparing => Colors.orange,
      DeliveryStatus.pickedUp => Colors.blue,
      DeliveryStatus.onTheWay => Colors.green,
      DeliveryStatus.arriving => Colors.teal,
      DeliveryStatus.delivered => Colors.purple,
    };
  }

  String _getStatusText(DeliveryStatus status) {
    return switch (status) {
      DeliveryStatus.preparing => 'Preparing your order',
      DeliveryStatus.pickedUp => 'Order picked up',
      DeliveryStatus.onTheWay => 'On the way',
      DeliveryStatus.arriving => 'Almost there!',
      DeliveryStatus.delivered => 'Delivered!',
    };
  }
}

// =============================================================================
// DEMO: How to run this example
// =============================================================================

/// Demo app entry point - shows how to set up the example
void main() {
  runApp(
    const ProviderScope(
      child: DeliveryTrackingDemoApp(),
    ),
  );
}

class DeliveryTrackingDemoApp extends StatelessWidget {
  const DeliveryTrackingDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Tracking Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  // Sample dummy data for demonstration
  static const _demoOrigin = DeliveryLocation(
    latitude: 30.0444,
    longitude: 31.2357,
    label: 'Burger Republic',
    address: '123 Main St, Downtown Cairo',
  );

  static const _demoDestination = DeliveryLocation(
    latitude: 30.0644,
    longitude: 31.2557,
    label: 'Customer Home',
    address: '456 Oak Ave, Cairo',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Tracking Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleCard(
            context,
            'Basic Usage',
            'Simple implementation with default styling',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BasicDeliveryTrackingExample(
                  origin: _demoOrigin,
                  destination: _demoDestination,
                ),
              ),
            ),
          ),
          _buildExampleCard(
            context,
            'Custom Styled',
            'Custom markers, map tiles, and overlays',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CustomStyledDeliveryTracking(
                  origin: _demoOrigin,
                  destination: _demoDestination,
                ),
              ),
            ),
          ),
          _buildExampleCard(
            context,
            'Completely Custom UI',
            'Build your own UI with the state',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CompletelyCustomDeliveryUI(
                  origin: _demoOrigin,
                  destination: _demoDestination,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
