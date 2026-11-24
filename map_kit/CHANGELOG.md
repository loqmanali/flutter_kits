## 2.0.0

**BREAKING.** Flutter 3.50 / Dart 3.14 migration (monorepo release 2.1.0).

- Migrated from the deprecated `package:flutter/material.dart` / `cupertino.dart` to `package:material_ui` / `package:cupertino_ui`. Requires Flutter >= 3.47 / Dart >= 3.13; extensions and themes are now material_ui `ThemeData` types.
- Dependencies: `flutter_map ^8.3.2`, `flutter_map_cancellable_tile_provider ^3.1.1`, `latlong2 ^0.10.1`, `flutter_polyline_points ^3.1.0`, `material_ui ^1.11.1`.
- flutter_polyline_points 3: `PolylinePoints.decodePolyline` is static; flutter_map 8: `position.zoom` is non-null.

## 1.0.0

* Initial release. Merges two independent modules from the original
  project — `lib/core/location_picker` and `lib/core/delivery_tracking` —
  into a single, project-agnostic package with shared dependencies and a
  single `MapKitRuntime` for HTTP / Nominatim / OSRM configuration.
* No public class renames: every `LocationAddress`, `SearchResult`,
  `LocationPickerState`, `DeliveryLocation`, `DeliveryRoute`,
  `DeliveryStatus`, `DeliveryTrackingState`, etc. carries over unchanged.
* `NominatimGeocodingService` and `OsrmRoutingService` now read their
  base URL / user agent / profile from `MapKitRuntime` when constructor
  arguments are omitted. Passing the arguments explicitly still works.
* `dioFactory` on `MapKitRuntime` lets both services share one HTTP
  client setup (interceptors, logging, etc.).
* The original `example/` / `examples/` folders are kept in source for
  reference but excluded from the analyzer.
