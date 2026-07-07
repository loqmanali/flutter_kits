# map_kit

One package, two cohesive surfaces — location picking and delivery
tracking — that share the same map stack (`flutter_map` + `latlong2`),
the same HTTP client (`dio`), and the same runtime configuration.

The two modules were two separate folders in the original project
(`location_picker` and `delivery_tracking`). They duplicated their
pubspec deps and HTTP setup. `map_kit` merges them into a single package
without changing public class names, so adopting it is a drop-in.

## What's inside

| Surface | Barrel | Highlights |
|---|---|---|
| Location picker | `package:map_kit/picker.dart` | `LocationPickerMap`, `LocationSearchBar`, `LocationPreviewCard`, `CurrentLocationButton`, `SearchResultsList`, `GeocodingService`, `NominatimGeocodingService` |
| Delivery tracking | `package:map_kit/tracking.dart` | `DeliveryMap`, `DeliveryInfoPanel`, `DeliveryControls`, `DeliveryStatusCard`, `RoutingService`, `OsrmRoutingService` |
| Everything | `package:map_kit/map_kit.dart` | Re-exports both |

## Install

```yaml
dependencies:
  map_kit:
    path: ../packages/map_kit
```

Wrap your app in a `ProviderScope` (Riverpod). That's the only setup
required to start using the widgets.

## Configure once (optional)

If you self-host Nominatim / OSRM, or want a `Dio` instance with custom
interceptors / logging, point the runtime at it in `main()`:

```dart
import 'package:map_kit/map_kit.dart';

void main() {
  MapKitRuntime.use(
    // HTTP
    dioFactory: () => Dio()..interceptors.add(MyLoggingInterceptor()),

    // Nominatim (forward + reverse geocoding)
    nominatimBaseUrl:   'https://nominatim.your-domain.com',
    nominatimUserAgent: 'MyApp/1.0',

    // OSRM (route polyline + distance + ETA)
    osrmBaseUrl: 'https://router.your-domain.com',
    osrmProfile: 'driving', // or 'walking', 'cycling'
  );

  runApp(const ProviderScope(child: MyApp()));
}
```

Both `NominatimGeocodingService()` and `OsrmRoutingService()` read from
the runtime; constructor arguments still take precedence when you want
per-instance overrides.

## Location picker — quick start

```dart
import 'package:map_kit/picker.dart';

class PickLocationPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationPickerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a location')),
      body: Column(
        children: [
          const LocationSearchBar(),
          Expanded(child: LocationPickerMap()),
          if (state.hasSelection)
            LocationPreviewCard(
              location: state.selectedLocation!,
              onConfirm: () => Navigator.pop(context, state.selectedLocation),
            ),
        ],
      ),
    );
  }
}
```

## Delivery tracking — quick start

```dart
import 'package:map_kit/tracking.dart';

class TrackOrderPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryTrackingProvider);

    return Scaffold(
      body: Stack(
        children: [
          DeliveryMap(state: state),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: DeliveryInfoPanel(state: state),
          ),
        ],
      ),
    );
  }
}
```

Initialise the tracking state from somewhere in your app (typically when
opening the screen):

```dart
final origin = DeliveryLocation(
  latitude: 30.0444, longitude: 31.2357, label: 'Pizza Palace',
);
final destination = DeliveryLocation(
  latitude: 30.0644, longitude: 31.2557, label: 'John Doe',
);

ref.read(deliveryTrackingProvider.notifier).start(
  origin: origin,
  destination: destination,
);
```

## Plugging in a different geocoding / routing provider

Both services are behind interfaces, so you can swap in Google
Geocoding, Mapbox, or whatever:

```dart
class MyGeocoder implements GeocodingService {
  @override
  Future<List<SearchResult>> search(String query, {...}) async { ... }
  @override
  Future<LocationAddress?> reverseGeocode(LatLng position, {...}) async { ... }
  @override
  Future<List<SearchResult>> searchNearby(String query, {...}) async { ... }
}

ProviderScope(
  overrides: [
    geocodingServiceProvider.overrideWithValue(MyGeocoder()),
  ],
  child: MyApp(),
);
```

Same pattern for `routingServiceProvider`.

## DRY: what the merge saved

- One `pubspec.yaml` instead of two with duplicated `flutter_map` /
  `latlong2` / `dio` constraints.
- One `MapKitRuntime` instead of two parallel sets of
  `baseUrl` / `userAgent` constructor args.
- One `dioFactory` is shared by `NominatimGeocodingService` and
  `OsrmRoutingService`, so HTTP logging / auth / proxy config configured
  for one is picked up by the other.
- The `LatLng`-based geometry types (`LocationAddress.latLng`,
  `DeliveryLocation.latLng`) live in the same package, so consumers
  don't have to import two unrelated packages to express "a point on a
  map".

## Notes

- The pre-existing `LocationAddress` and `DeliveryLocation` types are
  kept as-is — they have different semantics (`LocationAddress` carries
  geocoding metadata; `DeliveryLocation` carries a label + optional
  icon) and merging them would just push complexity onto callers. The
  shared part — `latitude`, `longitude`, the `LatLng` conversion — is
  already DRY in practice because both expose the same `latLng` getter.
- The original modules' `example/` and `examples/` folders are kept in
  source for reference but excluded from the analyzer (they referenced
  the old host-app paths).
- The kit is fully project-agnostic — no `package:<app>/...`
  imports, no host-app coupling. The only configuration surface is
  `MapKitRuntime.use(...)`.
