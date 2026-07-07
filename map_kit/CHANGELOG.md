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
