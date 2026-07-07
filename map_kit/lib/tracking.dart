/// `map_kit/tracking` — delivery-tracking surface of the map_kit package.
///
/// ```dart
/// import 'package:map_kit/tracking.dart';
/// ```
///
/// Exposes:
/// - `DeliveryLocation`, `DeliveryRoute`, `DeliveryStatus`,
///   `DeliveryStatusConfig(s)`, `DeliveryTrackingState`
/// - `RoutingService` (interface) + `OsrmRoutingService` + `RouteResult`
/// - `deliveryTrackingProvider` and friends
/// - Ready-made widgets (`DeliveryMap`, `DeliveryInfoPanel`,
///   `DeliveryControls`, `DeliveryStatusCard`, `DeliveryLoading`)
library;

// Core (shared runtime config)
export 'src/core/map_kit_runtime.dart';

// Tracking sub-module
export 'src/tracking/models/models.dart';
export 'src/tracking/providers/providers.dart';
export 'src/tracking/services/services.dart';
export 'src/tracking/widgets/widgets.dart';
