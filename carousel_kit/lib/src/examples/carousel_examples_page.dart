import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../carousel_module.dart';

/// A comprehensive examples page demonstrating all carousel types.
///
/// Each section shows a different carousel configuration with
/// explanations of when and why to use each type.
class CarouselExamplesPage extends StatelessWidget {
  const CarouselExamplesPage({super.key});

  static const routeName = '/carousel-examples';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel Module Examples'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionHeader(
            title: 'Banner Carousel',
            description: 'Standard banner for promotions and highlights',
          ),
          _BannerExample(),
          SizedBox(height: 32),
          _SectionHeader(
            title: 'Hero Carousel',
            description: 'Large featured content with auto-scroll',
          ),
          _HeroExample(),
          SizedBox(height: 32),
          _SectionHeader(
            title: 'Card Carousel',
            description: 'Shows peek of adjacent cards for browseable content',
          ),
          _CardsExample(),
          SizedBox(height: 32),
          _SectionHeader(
            title: 'Product Showcase',
            description: 'Horizontal product gallery with viewport preview',
          ),
          _ProductShowcaseExample(),
          SizedBox(height: 32),
          _SectionHeader(
            title: 'Full Screen Banner',
            description: 'Edge-to-edge full width carousel',
          ),
          _FullScreenExample(),
          SizedBox(height: 32),
          _SectionHeader(
            title: 'Thumbnail Gallery',
            description: 'Small horizontal list without indicators',
          ),
          _ThumbnailExample(),
          SizedBox(height: 32),
          _SectionHeader(
            title: 'Onboarding Carousel',
            description: 'Walkthrough screens with expanding indicators',
          ),
          _OnboardingExample(),
          SizedBox(height: 32),
          _SectionHeader(
            title: 'Indicator Effects',
            description: 'Different page indicator animations',
          ),
          _IndicatorEffectsExample(),
          SizedBox(height: 32),
          _SectionHeader(
            title: 'Custom Content Carousel',
            description: 'Using custom widgets as carousel items',
          ),
          _CustomContentExample(),
          SizedBox(height: 32),
          _SectionHeader(
            title: 'Controller Example',
            description: 'Programmatic control with external buttons',
          ),
          _ControllerExample(),
          SizedBox(height: 32),
          _SectionHeader(
            title: 'Provider Example',
            description: 'Riverpod state management integration',
          ),
          _ProviderExample(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String description;

  const _SectionHeader({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ========== Helper to get demo items ==========
List<CarouselItem> _getDemoItems() {
  return [
    const _DemoImageItem('assets/images/home_banner_1.png'),
    const _DemoImageItem('assets/images/home_banner_2.png'),
    const _DemoImageItem('assets/images/home_banner_3.png'),
  ];
}

/// Demo image item for examples.
class _DemoImageItem extends ImageCarouselItem {
  const _DemoImageItem(String super.imagePath) : super.asset();
}

/// ========== Banner Carousel Example ==========
///
/// Use this for:
/// - Home page promotional banners
/// - Featured announcements
/// - Marketing highlights
///
/// Characteristics:
/// - Medium height (180px)
/// - Standard dots indicator below
/// - Auto-scroll enabled (3 seconds)
/// - Full viewport width
class _BannerExample extends StatelessWidget {
  const _BannerExample();

  @override
  Widget build(BuildContext context) {
    return Carousel(
      items: _getDemoItems(),
      config: CarouselConfig.banner,
      onPageChanged: (index) {
        debugPrint('Banner: Page changed to $index');
      },
    );
  }
}

/// ========== Hero Carousel Example ==========
///
/// Use this for:
/// - Featured articles/stories
/// - Full-width hero sections
/// - Landing page highlights
///
/// Characteristics:
/// - Large height (250px)
/// - Overlay indicator (white dots)
/// - Slow auto-scroll (5 seconds)
/// - Rounded corners (20px)
class _HeroExample extends StatelessWidget {
  const _HeroExample();

  @override
  Widget build(BuildContext context) {
    return Carousel(
      items: _getDemoItems(),
      config: CarouselConfig.hero,
    );
  }
}

/// ========== Card Carousel Example ==========
///
/// Use this for:
/// - Product categories
/// - Browseable content cards
/// - Navigation cards
///
/// Characteristics:
/// - Medium height with card styling
/// - Shows peek of adjacent cards (85% viewport)
/// - Pill-shaped indicator
/// - No auto-scroll (user-controlled)
class _CardsExample extends StatelessWidget {
  const _CardsExample();

  @override
  Widget build(BuildContext context) {
    return const Carousel(
      items: [
        _DemoImageItem('assets/images/home_banner_1.png'),
        _DemoImageItem('assets/images/home_banner_2.png'),
        _DemoImageItem('assets/images/home_banner_3.png'),
        _DemoImageItem('assets/images/home_banner_4.png'),
      ],
      config: CarouselConfig.cards,
    );
  }
}

/// ========== Product Showcase Example ==========
///
/// Use this for:
/// - Product image galleries
/// - Portfolio showcases
/// - Item details with multiple views
///
/// Characteristics:
/// - 75% viewport fraction (shows adjacent items)
/// - Small dot indicators
/// - User-controlled navigation
class _ProductShowcaseExample extends StatelessWidget {
  const _ProductShowcaseExample();

  @override
  Widget build(BuildContext context) {
    return const Carousel(
      items: [
        _DemoImageItem('assets/images/home_banner_1.png'),
        _DemoImageItem('assets/images/home_banner_2.png'),
        _DemoImageItem('assets/images/home_banner_3.png'),
        _DemoImageItem('assets/images/home_banner_4.png'),
      ],
      config: CarouselConfig.productShowcase,
    );
  }
}

/// ========== Full Screen Banner Example ==========
///
/// Use this for:
/// - Edge-to-edge promotional banners
/// - Full-width immersive content
/// - Story-style carousels
///
/// Characteristics:
/// - No border radius
/// - Full viewport width
/// - Overlay indicator
/// - Auto-scroll enabled
class _FullScreenExample extends StatelessWidget {
  const _FullScreenExample();

  @override
  Widget build(BuildContext context) {
    return Carousel(
      items: _getDemoItems(),
      config: CarouselConfig.fullScreen,
    );
  }
}

/// ========== Thumbnail Gallery Example ==========
///
/// Use this for:
/// - Image thumbnails
/// - Quick navigation helpers
/// - Color/size selectors
///
/// Characteristics:
/// - Small height (120px)
/// - No indicators (clean look)
/// - No auto-scroll
/// - Horizontal list behavior
class _ThumbnailExample extends StatelessWidget {
  const _ThumbnailExample();

  @override
  Widget build(BuildContext context) {
    return const Carousel(
      items: [
        _DemoImageItem('assets/images/home_banner_1.png'),
        _DemoImageItem('assets/images/home_banner_2.png'),
        _DemoImageItem('assets/images/home_banner_3.png'),
        _DemoImageItem('assets/images/home_banner_4.png'),
        _DemoImageItem('assets/images/home_banner_ar.png'),
      ],
      config: CarouselConfig.thumbnail,
    );
  }
}

/// ========== Onboarding Carousel Example ==========
///
/// Use this for:
/// - App introduction/walkthrough
/// - Feature explanations
/// - Tutorial steps
///
/// Characteristics:
/// - Large height for content
/// - Expanding indicator effect
/// - No auto-scroll (user-paced)
/// - Often used with "Skip" and "Next" buttons
class _OnboardingExample extends StatelessWidget {
  const _OnboardingExample();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Carousel(
        items: [
          WidgetCarouselItem(
            builder: (_) => const _OnboardingSlide(
              title: 'Welcome',
              description: 'Discover amazing features',
              color: Color(0xFF6C63FF),
              icon: Icons.star,
            ),
          ),
          WidgetCarouselItem(
            builder: (_) => const _OnboardingSlide(
              title: 'Get Started',
              description: 'Create your account in seconds',
              color: Color(0xFF00C896),
              icon: Icons.person,
            ),
          ),
          WidgetCarouselItem(
            builder: (_) => const _OnboardingSlide(
              title: 'Explore',
              description: 'Find what you need easily',
              color: Color(0xFFFF6B6B),
              icon: Icons.search,
            ),
          ),
        ],
        config: CarouselConfig.onboarding,
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// ========== Indicator Effects Example ==========
///
/// Demonstrates all available indicator animation effects:
///
/// - Dot: Simple color change
/// - Worm: Active dot stretches between positions
/// - Expanding: Active dot grows wider
/// - Jumping: Active dot jumps vertically
/// - Scrolling: Dots scroll with content
/// - Swap: Active/inactive swap sizes
class _IndicatorEffectsExample extends StatelessWidget {
  const _IndicatorEffectsExample();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _EffectRow(
          label: 'Dot Effect',
          config: CarouselConfig.banner,
        ),
        SizedBox(height: 16),
        _EffectRow(
          label: 'Worm Effect',
          config: CarouselConfig(
            indicator: IndicatorConfig.worm,
          ),
        ),
        SizedBox(height: 16),
        _EffectRow(
          label: 'Expanding Effect',
          config: CarouselConfig.onboarding,
        ),
        SizedBox(height: 16),
        _EffectRow(
          label: 'Pill Indicator',
          config: CarouselConfig.cards,
        ),
      ],
    );
  }
}

class _EffectRow extends StatelessWidget {
  final String label;
  final CarouselConfig config;

  const _EffectRow({
    required this.label,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label),
        ),
        Expanded(
          child: Carousel(
            items: _getDemoItems(),
            config: config,
          ),
        ),
      ],
    );
  }
}

/// ========== Custom Content Carousel Example ==========
///
/// Use this for:
/// - Mixed content types
/// - Custom layouts per slide
/// - Dynamic content from API
///
/// This example shows how to create custom carousel items
/// with any widget content.
class _CustomContentExample extends StatelessWidget {
  const _CustomContentExample();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Carousel(
        items: [
          WidgetCarouselItem(
            builder: (_) => const _CustomSlide(
              title: 'Special Offer',
              subtitle: '50% OFF',
              color: Color(0xFFFF6B6B),
              textAlign: TextAlign.left,
            ),
          ),
          WidgetCarouselItem(
            builder: (_) => const _CustomSlide(
              title: 'New Collection',
              subtitle: 'Shop Now',
              color: Color(0xFF4ECDC4),
              textAlign: TextAlign.center,
            ),
          ),
          WidgetCarouselItem(
            builder: (_) => const _CustomSlide(
              title: 'Free Delivery',
              subtitle: 'On Orders Over \$50',
              color: Color(0xFF6C63FF),
              textAlign: TextAlign.right,
            ),
          ),
        ],
        config: CarouselConfig.banner,
      ),
    );
  }
}

class _CustomSlide extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final TextAlign textAlign;

  const _CustomSlide({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: textAlign == TextAlign.left
              ? CrossAxisAlignment.start
              : textAlign == TextAlign.right
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: textAlign,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: textAlign,
            ),
          ],
        ),
      ),
    );
  }
}

/// ========== Advanced: Controller Example ==========
///
/// Shows how to use CarouselController for programmatic control.
/// This is useful when you need external buttons to control the carousel.
class _ControllerExample extends ConsumerStatefulWidget {
  const _ControllerExample();

  @override
  ConsumerState<_ControllerExample> createState() => _ControllerExampleState();
}

class _ControllerExampleState extends ConsumerState<_ControllerExample> {
  late CarouselController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CarouselController(
      items: const [
        _DemoImageItem('assets/images/home_banner_1.png'),
        _DemoImageItem('assets/images/home_banner_2.png'),
        _DemoImageItem('assets/images/home_banner_3.png'),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return ControlledCarousel(
                controller: _controller,
                items: const [
                  _DemoImageItem('assets/images/home_banner_1.png'),
                  _DemoImageItem('assets/images/home_banner_2.png'),
                  _DemoImageItem('assets/images/home_banner_3.png'),
                ],
                config: CarouselConfig.banner,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _controller.previous(),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => _controller.next(),
              icon: const Icon(Icons.arrow_forward),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {
                _controller.isPaused
                    ? _controller.resume()
                    : _controller.pause();
                setState(() {});
              },
              icon: Icon(
                _controller.isPaused ? Icons.play_arrow : Icons.pause,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ========== Provider-Based Example ==========
///
/// Shows how to use Riverpod providers for state management.
/// This is useful when multiple widgets need to access carousel state.
class _ProviderExample extends ConsumerWidget {
  const _ProviderExample();

  static const items = [
    _DemoImageItem('assets/images/home_banner_1.png'),
    _DemoImageItem('assets/images/home_banner_2.png'),
    _DemoImageItem('assets/images/home_banner_3.png'),
  ];

  static const int _itemCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the carousel index
    final currentIndex = ref.watch(carouselIndexProvider);

    return Column(
      children: [
        Carousel(
          items: items,
          config: CarouselConfig.banner,
          onPageChanged: (index) {
            // Update the provider state when page changes
            ref.read(carouselIndexProvider.notifier).setIndex(index);
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Page: ${currentIndex + 1} / $_itemCount',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                final notifier = ref.read(carouselIndexProvider.notifier);
                if (currentIndex > 0) {
                  notifier.setIndex(currentIndex - 1);
                } else {
                  notifier.setIndex(_itemCount - 1);
                }
              },
              icon: const Icon(Icons.arrow_back),
              iconSize: 20,
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                final notifier = ref.read(carouselIndexProvider.notifier);
                if (currentIndex < _itemCount - 1) {
                  notifier.setIndex(currentIndex + 1);
                } else {
                  notifier.setIndex(0);
                }
              },
              icon: const Icon(Icons.arrow_forward),
              iconSize: 20,
            ),
          ],
        ),
      ],
    );
  }
}
