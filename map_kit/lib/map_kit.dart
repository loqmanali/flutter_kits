/// map_kit
///
/// A unified, project-agnostic map toolkit for Flutter. Two cohesive
/// sub-modules share one dependency set, one runtime configuration, and
/// the same map stack (`flutter_map` + `latlong2` + `dio`):
///
/// - **`map_kit/picker.dart`** — interactive map + search + reverse
///   geocoding (Nominatim by default).
/// - **`map_kit/tracking.dart`** — live driver position + OSRM routing +
///   delivery status / progress.
///
/// You can `import 'package:map_kit/map_kit.dart';` to get everything, or
/// import just the surface you need (the smaller barrels above) to keep
/// your build cleaner.
///
/// ## Configure once in `main()`
///
/// ```dart
/// MapKitRuntime.use(
///   nominatimBaseUrl: 'https://nominatim.your-domain.com',
///   nominatimUserAgent: 'MyApp/1.0',
///   osrmBaseUrl: 'https://router.your-domain.com',
///   osrmProfile: 'driving',
/// );
/// ```
///
/// Both `NominatimGeocodingService()` and `OsrmRoutingService()` then read
/// from the runtime — no need to pass URLs through every layer.
library;

// Shared core
export 'src/core/map_kit_runtime.dart';

// Picker sub-module
export 'src/picker/models/models.dart';
export 'src/picker/providers/providers.dart';
export 'src/picker/services/services.dart';
export 'src/picker/widgets/widgets.dart';

// Tracking sub-module
export 'src/tracking/models/models.dart';
export 'src/tracking/providers/providers.dart';
export 'src/tracking/services/services.dart';
export 'src/tracking/widgets/widgets.dart';
