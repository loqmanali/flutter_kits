import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/models.dart';
import '../services/services.dart';

/// Status threshold definition
class StatusThreshold {
  final double progress;
  final DeliveryStatus status;

  const StatusThreshold(this.progress, this.status);
}

/// Configuration for delivery tracking
class DeliveryTrackingConfig {
  final DeliveryLocation origin;
  final DeliveryLocation destination;
  final RoutingService routingService;
  final Duration updateInterval;
  final double progressIncrement;
  final List<StatusThreshold> statusThresholds;

  static const List<StatusThreshold> defaultThresholds = [
    StatusThreshold(0.0, DeliveryStatus.preparing),
    StatusThreshold(0.2, DeliveryStatus.pickedUp),
    StatusThreshold(0.3, DeliveryStatus.onTheWay),
    StatusThreshold(0.9, DeliveryStatus.arriving),
    StatusThreshold(1.0, DeliveryStatus.delivered),
  ];

  const DeliveryTrackingConfig({
    required this.origin,
    required this.destination,
    required this.routingService,
    this.updateInterval = const Duration(seconds: 1),
    this.progressIncrement = 0.02,
    this.statusThresholds = defaultThresholds,
  });
}

/// Notifier for managing delivery tracking state
class DeliveryTrackingNotifier extends Notifier<DeliveryTrackingState> {
  Timer? _simulationTimer;
  DeliveryTrackingConfig? _config;
  double _totalDistanceKm = 0.0;
  Duration _totalDuration = Duration.zero;

  @override
  DeliveryTrackingState build() {
    ref.onDispose(() {
      _simulationTimer?.cancel();
    });

    // Return initial empty state - will be initialized with configure()
    return const DeliveryTrackingState(
      origin: DeliveryLocation(
        latitude: 0,
        longitude: 0,
        label: '',
      ),
      destination: DeliveryLocation(
        latitude: 0,
        longitude: 0,
        label: '',
      ),
      isLoading: true,
    );
  }

  /// Initialize tracking with configuration
  Future<void> configure(DeliveryTrackingConfig config) async {
    _config = config;
    _simulationTimer?.cancel();

    state = DeliveryTrackingState(
      origin: config.origin,
      destination: config.destination,
      isLoading: true,
      driverLocation: config.origin,
    );

    await _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    if (_config == null) return;

    try {
      final routeResult = await _config!.routingService.getRoute(
        _config!.origin.latLng,
        _config!.destination.latLng,
      );

      if (routeResult != null && routeResult.points.isNotEmpty) {
        final route = routeResult.toDeliveryRoute();
        _totalDistanceKm = route.distanceKm;
        _totalDuration = route.estimatedTime;

        state = state.copyWith(
          fullRoute: route,
          remainingRoute: route,
          isLoading: false,
          clearError: true,
        );
      } else {
        // Fallback to straight line
        final fallbackRoute = _createFallbackRoute();
        _totalDistanceKm = fallbackRoute.distanceKm;
        _totalDuration = fallbackRoute.estimatedTime;

        state = state.copyWith(
          fullRoute: fallbackRoute,
          remainingRoute: fallbackRoute,
          isLoading: false,
          errorMessage: 'Could not fetch route, using straight line',
        );
      }
    } catch (e) {
      final fallbackRoute = _createFallbackRoute();
      _totalDistanceKm = fallbackRoute.distanceKm;
      _totalDuration = fallbackRoute.estimatedTime;

      state = state.copyWith(
        fullRoute: fallbackRoute,
        remainingRoute: fallbackRoute,
        isLoading: false,
        errorMessage: 'Error fetching route: $e',
      );
    }
  }

  DeliveryRoute _createFallbackRoute() {
    if (_config == null) {
      return const DeliveryRoute(
        points: [],
        distanceKm: 0,
        estimatedTime: Duration.zero,
      );
    }

    const distance = Distance();
    final distanceKm = distance.as(
      LengthUnit.Kilometer,
      _config!.origin.latLng,
      _config!.destination.latLng,
    );

    return DeliveryRoute(
      points: [_config!.origin.latLng, _config!.destination.latLng],
      distanceKm: distanceKm,
      estimatedTime: Duration(minutes: (distanceKm / 0.5).round()),
    );
  }

  /// Start the delivery simulation
  void startSimulation() {
    if (_config == null || state.isLoading) return;

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(_config!.updateInterval, (_) {
      if (state.isPaused || state.isCompleted) return;
      _updateProgress();
    });
  }

  /// Stop the simulation
  void stopSimulation() {
    _simulationTimer?.cancel();
  }

  /// Pause the delivery tracking
  void pause() {
    state = state.copyWith(isPaused: true);
  }

  /// Resume the delivery tracking
  void resume() {
    state = state.copyWith(isPaused: false);
  }

  /// Toggle pause/resume
  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  /// Reset to initial state
  Future<void> reset() async {
    _simulationTimer?.cancel();
    if (_config != null) {
      await configure(_config!);
    }
  }

  /// Manually update driver location (for real tracking)
  void updateDriverLocation(DeliveryLocation location) {
    state = state.copyWith(driverLocation: location);
    _updateRemainingRoute();
  }

  /// Manually update progress (for real tracking)
  void updateProgress(double progress) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final newStatus = _getStatusForProgress(clampedProgress);

    state = state.copyWith(
      progress: clampedProgress,
      status: newStatus,
    );

    _updateDriverPositionFromProgress();
    _updateRemainingRoute();
  }

  /// Manually set delivery status
  void setStatus(DeliveryStatus status) {
    state = state.copyWith(status: status);
  }

  void _updateProgress() {
    if (_config == null) return;

    final newProgress =
        (state.progress + _config!.progressIncrement).clamp(0.0, 1.0);
    final newStatus = _getStatusForProgress(newProgress);

    state = state.copyWith(
      progress: newProgress,
      status: newStatus,
    );

    _updateDriverPositionFromProgress();
    _updateRemainingRoute();

    if (state.isCompleted) {
      _simulationTimer?.cancel();
    }
  }

  DeliveryStatus _getStatusForProgress(double progress) {
    if (_config == null) return DeliveryStatus.preparing;

    DeliveryStatus result = DeliveryStatus.preparing;
    for (final threshold in _config!.statusThresholds) {
      if (progress >= threshold.progress) {
        result = threshold.status;
      }
    }
    return result;
  }

  void _updateDriverPositionFromProgress() {
    final fullRoute = state.fullRoute;
    if (fullRoute == null || fullRoute.points.length < 2) return;

    final totalPoints = fullRoute.points.length;
    final currentIndex = (state.progress * (totalPoints - 1)).floor();
    final segmentProgress = (state.progress * (totalPoints - 1)) - currentIndex;

    if (currentIndex < totalPoints - 1) {
      final startPoint = fullRoute.points[currentIndex];
      final endPoint = fullRoute.points[currentIndex + 1];

      final newLat = startPoint.latitude +
          (endPoint.latitude - startPoint.latitude) * segmentProgress;
      final newLng = startPoint.longitude +
          (endPoint.longitude - startPoint.longitude) * segmentProgress;

      state = state.copyWith(
        driverLocation: DeliveryLocation(
          latitude: newLat,
          longitude: newLng,
          label: state.driverLocation?.label ?? 'Driver',
          address: state.driverLocation?.address,
        ),
      );
    }
  }

  void _updateRemainingRoute() {
    final fullRoute = state.fullRoute;
    final driverLocation = state.driverLocation;

    if (fullRoute == null || driverLocation == null) return;

    final totalPoints = fullRoute.points.length;
    final currentIndex = (state.progress * (totalPoints - 1)).floor();

    if (currentIndex < totalPoints - 1) {
      final remainingPoints = fullRoute.points.sublist(currentIndex + 1);
      if (remainingPoints.isNotEmpty) {
        final remainingProgress = 1.0 - state.progress;
        final remainingDistance = _totalDistanceKm * remainingProgress;
        final remainingTime = Duration(
          seconds: (_totalDuration.inSeconds * remainingProgress).round(),
        );

        state = state.copyWith(
          remainingRoute: DeliveryRoute(
            points: [driverLocation.latLng, ...remainingPoints],
            distanceKm: remainingDistance,
            estimatedTime: remainingTime,
            color: fullRoute.color,
            strokeWidth: fullRoute.strokeWidth,
          ),
        );
      }
    }
  }
}

/// Provider for delivery tracking
final deliveryTrackingProvider =
    NotifierProvider<DeliveryTrackingNotifier, DeliveryTrackingState>(
  DeliveryTrackingNotifier.new,
);

/// Provider for routing service - can be overridden
final routingServiceProvider = Provider<RoutingService>((ref) {
  return OsrmRoutingService();
});
