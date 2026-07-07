/// `map_kit/picker` — location-picker surface of the map_kit package.
///
/// ```dart
/// import 'package:map_kit/picker.dart';
/// ```
///
/// Exposes:
/// - `LocationAddress`, `SearchResult`, `LocationPickerState`,
///   `LocationPickerMode`
/// - `GeocodingService` (interface) + `NominatimGeocodingService`
/// - `locationPickerProvider` and friends
/// - Ready-made widgets (`LocationPickerMap`, `LocationSearchBar`, …)
library;

// Core (shared runtime config)
export 'src/core/map_kit_runtime.dart';

// Picker sub-module
export 'src/picker/models/models.dart';
export 'src/picker/providers/providers.dart';
export 'src/picker/services/services.dart';
export 'src/picker/widgets/widgets.dart';
