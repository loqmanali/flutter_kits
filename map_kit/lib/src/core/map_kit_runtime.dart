import 'package:dio/dio.dart';

/// Process-wide runtime configuration shared by every sub-module of map_kit
/// (the location picker and the delivery-tracking layer).
///
/// Configure once near the top of `main()` if you want to override the
/// defaults — otherwise the kit ships sensible defaults (public OSRM and
/// Nominatim servers, a fresh `Dio` per service).
///
/// ```dart
/// MapKitRuntime.use(
///   dioFactory: () => Dio()..interceptors.add(MyLogger()),
///   nominatimBaseUrl: 'https://nominatim.example.com',
///   nominatimUserAgent: 'MyApp/1.0',
///   osrmBaseUrl: 'https://router.example.com',
///   osrmProfile: 'driving',
///   defaultMapCenter: LatLng(30.0444, 31.2357),
/// );
/// ```
class MapKitRuntime {
  MapKitRuntime._();

  static Dio Function()? _dioFactory;

  static String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static String _nominatimUserAgent = 'MapKitApp/1.0';

  static String _osrmBaseUrl = 'https://router.project-osrm.org';
  static String _osrmProfile = 'driving';
  static String _osrmUserAgent = 'MapKitApp/1.0';

  /// Override defaults. Pass only the fields you want to change.
  static void use({
    Dio Function()? dioFactory,
    String? nominatimBaseUrl,
    String? nominatimUserAgent,
    String? osrmBaseUrl,
    String? osrmProfile,
    String? osrmUserAgent,
  }) {
    if (dioFactory != null) _dioFactory = dioFactory;
    if (nominatimBaseUrl != null) _nominatimBaseUrl = nominatimBaseUrl;
    if (nominatimUserAgent != null) _nominatimUserAgent = nominatimUserAgent;
    if (osrmBaseUrl != null) _osrmBaseUrl = osrmBaseUrl;
    if (osrmProfile != null) _osrmProfile = osrmProfile;
    if (osrmUserAgent != null) _osrmUserAgent = osrmUserAgent;
  }

  /// Returns a `Dio` instance — host-supplied [_dioFactory] or a fresh one.
  static Dio createDio() => _dioFactory?.call() ?? Dio();

  static String get nominatimBaseUrl => _nominatimBaseUrl;
  static String get nominatimUserAgent => _nominatimUserAgent;
  static String get osrmBaseUrl => _osrmBaseUrl;
  static String get osrmProfile => _osrmProfile;
  static String get osrmUserAgent => _osrmUserAgent;
}
