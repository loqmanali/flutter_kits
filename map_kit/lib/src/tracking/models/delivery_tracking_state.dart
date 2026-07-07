import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'delivery_location.dart';
import 'delivery_route.dart';
import 'delivery_status.dart';

/// Immutable state for delivery tracking
@immutable
class DeliveryTrackingState {
  final DeliveryLocation origin;
  final DeliveryLocation destination;
  final DeliveryLocation? driverLocation;
  final DeliveryRoute? fullRoute;
  final DeliveryRoute? remainingRoute;
  final DeliveryStatus status;
  final double progress;
  final bool isLoading;
  final String? errorMessage;
  final bool isPaused;

  const DeliveryTrackingState({
    required this.origin,
    required this.destination,
    this.driverLocation,
    this.fullRoute,
    this.remainingRoute,
    this.status = DeliveryStatus.preparing,
    this.progress = 0.0,
    this.isLoading = false,
    this.errorMessage,
    this.isPaused = false,
  });

  /// Current distance remaining in km
  double get remainingDistanceKm => remainingRoute?.distanceKm ?? 0.0;

  /// Current ETA
  Duration get remainingTime => remainingRoute?.estimatedTime ?? Duration.zero;

  /// Total distance of the route
  double get totalDistanceKm => fullRoute?.distanceKm ?? 0.0;

  /// Total estimated time
  Duration get totalTime => fullRoute?.estimatedTime ?? Duration.zero;

  /// Progress as percentage (0-100)
  int get progressPercent => (progress * 100).round().clamp(0, 100);

  /// Whether delivery is complete
  bool get isCompleted => status == DeliveryStatus.delivered;

  /// Current route points to display
  List<LatLng> get displayRoutePoints => remainingRoute?.points ?? [];

  DeliveryTrackingState copyWith({
    DeliveryLocation? origin,
    DeliveryLocation? destination,
    DeliveryLocation? driverLocation,
    DeliveryRoute? fullRoute,
    DeliveryRoute? remainingRoute,
    DeliveryStatus? status,
    double? progress,
    bool? isLoading,
    String? errorMessage,
    bool? isPaused,
    bool clearError = false,
    bool clearDriverLocation = false,
  }) {
    return DeliveryTrackingState(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      driverLocation:
          clearDriverLocation ? null : (driverLocation ?? this.driverLocation),
      fullRoute: fullRoute ?? this.fullRoute,
      remainingRoute: remainingRoute ?? this.remainingRoute,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryTrackingState &&
        other.origin == origin &&
        other.destination == destination &&
        other.driverLocation == driverLocation &&
        other.fullRoute == fullRoute &&
        other.remainingRoute == remainingRoute &&
        other.status == status &&
        other.progress == progress &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.isPaused == isPaused;
  }

  @override
  int get hashCode {
    return Object.hash(
      origin,
      destination,
      driverLocation,
      fullRoute,
      remainingRoute,
      status,
      progress,
      isLoading,
      errorMessage,
      isPaused,
    );
  }
}
