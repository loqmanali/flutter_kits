/// deep_link_kit
///
/// Project-agnostic deep-link toolkit for Flutter.
///
/// - Parses custom-scheme (`myapp://...`) and universal links
///   (`https://example.com/...`) into structured [LinkData].
/// - Exposes a stream of incoming links via [DeepLinkService], handling both
///   hot-start (links received while the app is running) and cold-start
///   (the link that launched the app).
/// - No hardcoded scheme or host — configure once via
///   [DeepLinkKitRuntime.use].
/// - No coupling to a specific router (`go_router`, `auto_route`, etc.) —
///   the kit emits parsed data; navigation stays in the host app.
///
/// Quick start:
/// ```dart
/// import 'package:deep_link_kit/deep_link_kit.dart';
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   DeepLinkKitRuntime.use(
///     customSchemes: const ['myapp'],
///     universalLinkHosts: const ['example.com', 'www.example.com'],
///   );
///
///   final service = DeepLinkService();
///   await service.init();
///   service.linkStream.listen((link) {
///     // route based on link.type / link.rawType / link.id / link.parameters
///   });
///
///   runApp(MyApp());
/// }
/// ```
library;

export 'src/adapters/deep_link_kit_runtime.dart';
export 'src/handlers/route_parser.dart';
export 'src/models/link_data.dart';
export 'src/services/deep_link_service.dart';
