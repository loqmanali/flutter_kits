/// carousel_kit
///
/// A fully-featured, project-agnostic carousel widget for Flutter with
/// Riverpod-powered state management.
///
/// Features:
/// - Multiple item kinds (images, custom widgets)
/// - Configurable auto-scroll with pause-on-interaction
/// - Multiple indicator styles
/// - Preset [CarouselConfig] for common layouts (banner, hero, stories…)
/// - Optional overlays per item
/// - Riverpod integration for state and controller access
///
/// Quick start:
/// ```dart
/// import 'package:carousel_kit/carousel_kit.dart';
///
/// final items = [
///   ImageCarouselItem.asset('assets/banner1.png'),
///   ImageCarouselItem.network('https://example.com/image.jpg'),
/// ];
///
/// Carousel(items: items, config: CarouselConfig.banner)
/// ```
library;

// Config
export 'src/config/auto_scroll_config.dart';
export 'src/config/carousel_config.dart';
export 'src/config/indicator_config.dart';
export 'src/config/layout_config.dart';
export 'src/config/visual_config.dart';

// Models
// (`carousel_item.dart` already defines ImageCarouselItem and WidgetCarouselItem;
// the standalone `image_carousel_item.dart`/`widget_carousel_item.dart` files
// are duplicates kept in src/ for compatibility but not re-exported here.)
export 'src/models/carousel_item.dart';
export 'src/models/carousel_overlay.dart';
export 'src/models/carousel_state.dart';

// Providers
export 'src/providers/carousel_controller_provider.dart';
export 'src/providers/carousel_state_provider.dart';

// Widgets
export 'src/widgets/carousel.dart';
export 'src/widgets/carousel_indicator.dart';
