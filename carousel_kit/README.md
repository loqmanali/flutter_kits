# carousel_kit

A fully-featured, project-agnostic carousel widget for Flutter with
Riverpod-powered state management. Drop into any project — no host-app
configuration required.

## What it gives you

- **Multiple item kinds** — images (asset or network) and arbitrary widgets.
- **Auto-scroll** with configurable interval, pause-on-interaction, reverse,
  and start-delay.
- **Indicators** — dots, pills, hidden, overlay; size/color/spacing
  customizable; six positions.
- **Layout presets** — `banner`, `hero`, `cards`, `cardPeek`, `fullBleed`,
  `horizontalList`, `onboarding`, …
- **Visual presets** — `small`, `large`, `card`, `fullWidth`, with
  height/border-radius/padding controls.
- **Per-item overlays** — title, subtitle, gradient, tap actions.
- **Riverpod providers** for current page, controller access, and
  programmatic navigation.
- **RTL aware**.

## Install

```yaml
dependencies:
  carousel_kit:
    path: ../packages/carousel_kit
```

```dart
import 'package:carousel_kit/carousel_kit.dart';
```

Make sure your app is wrapped in a `ProviderScope`:

```dart
runApp(const ProviderScope(child: MyApp()));
```

## Quick start

```dart
final items = [
  ImageCarouselItem.asset('assets/banner1.png'),
  ImageCarouselItem.network('https://picsum.photos/800/400'),
];

Carousel(items: items, config: CarouselConfig.banner);
```

That's the minimum. The widget handles paging, auto-scroll, and indicators.

## Configuration

A carousel is configured via a single immutable `CarouselConfig` made up of
four sub-configs:

```dart
CarouselConfig(
  visual:     VisualConfig(height: 220, borderRadius: 12),
  layout:     LayoutConfig(viewportFraction: 0.85),
  indicator:  IndicatorConfig(
    position: IndicatorPosition.belowOutside,
    activeColor: Colors.black,
  ),
  autoScroll: AutoScrollConfig(
    enabled: true,
    interval: Duration(seconds: 4),
    pauseOnInteraction: true,
  ),
);
```

### Presets

`CarouselConfig` ships with ready-made configurations:

| Preset                       | Use case                                 |
| ---------------------------- | ---------------------------------------- |
| `CarouselConfig.banner`      | Standard auto-scrolling banner.          |
| `CarouselConfig.hero`        | Large hero with overlay indicators.      |
| `CarouselConfig.cards`       | Card-peek carousel.                      |
| `CarouselConfig.productShowcase` | Product cards with small dots.       |
| `CarouselConfig.fullScreen`  | Full-bleed slow auto-scroll.             |
| `CarouselConfig.thumbnail`   | Thumbnails, no indicators.               |
| `CarouselConfig.onboarding`  | Onboarding screens.                      |

## Image items

```dart
ImageCarouselItem.asset(
  'assets/banner1.png',
  fit: BoxFit.cover,
  overlay: CarouselOverlay(title: 'Special offer', subtitle: 'Up to 50% off'),
  onTap: () => print('tapped'),
);

ImageCarouselItem.network(
  'https://example.com/image.jpg',
  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
);
```

## Widget items

```dart
WidgetCarouselItem(
  builder: (context) => const Card(
    child: Center(child: Text('Custom slide')),
  ),
);
```

## State and controller (Riverpod)

```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(carouselCurrentPageProvider);
    final controller = ref.read(carouselControllerProvider);

    return Column(
      children: [
        Carousel(items: items, config: CarouselConfig.hero),
        Text('Page: $currentPage'),
        ElevatedButton(
          onPressed: () => controller.next(),
          child: const Text('Next'),
        ),
      ],
    );
  }
}
```

## Layout presets

Several `LayoutConfig` presets are available:

```dart
LayoutConfig.cardPeek        // shows ~10% of neighbouring cards
LayoutConfig.fullBleed       // no padding/peek
LayoutConfig.horizontalList  // scroll like a horizontal list
```

## Notes

- The widget is a `ConsumerStatefulWidget`; it manages its own controller
  state internally — you only pass `items` and `config`.
- Auto-scroll pauses while the user is dragging the page (when
  `pauseOnInteraction` is true) and resumes shortly after.
- `IndicatorPosition.overlay` paints the indicators on top of the carousel
  itself, useful for hero banners.

See `example/` for a runnable demo.
