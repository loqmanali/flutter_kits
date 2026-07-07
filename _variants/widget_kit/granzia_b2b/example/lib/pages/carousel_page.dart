import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../gallery/demo_section.dart';
import '../gallery/gallery_scaffold.dart';

/// Documents the Carousel, its presets, and the standalone CarouselIndicator.
class CarouselPage extends StatelessWidget {
  const CarouselPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Carousel',
      intro: 'A Riverpod-powered carousel with preset configs, indicators, '
          'overlays and auto-scroll. Items can be images or any widget.',
      sections: [
        DemoSection(
          title: 'Banner preset',
          description: 'CarouselConfig.banner — a simple swipeable banner with '
              'a dot indicator.',
          demoBackground: false,
          // The Carousel sizes itself (visual.height + indicator); don't wrap it
          // in a tight SizedBox or the indicator overflows.
          demo: Carousel(
            config: CarouselConfig.banner,
            items: _colorSlides(),
          ),
          code: '''
Carousel(
  config: CarouselConfig.banner,
  items: [
    ImageCarouselItem.network('https://…'),
    WidgetCarouselItem(builder: (_) => MySlide()),
  ],
)''',
        ),
        DemoSection(
          title: 'Hero preset (auto-scroll)',
          description: 'CarouselConfig.hero — larger, auto-scrolling, with an '
              'overlay indicator.',
          demoBackground: false,
          demo: Carousel(
            config: CarouselConfig.hero,
            items: _colorSlides(),
          ),
          code: 'Carousel(config: CarouselConfig.hero, items: items)',
        ),
        const _StandaloneIndicatorDemo(),
      ],
    );
  }

  static List<CarouselItem> _colorSlides() {
    const colors = [
      Color(0xFFDC1213),
      Color(0xFF104C65),
      Color(0xFFF49B25),
      Color(0xFF2E7D32),
    ];
    return [
      for (var i = 0; i < colors.length; i++)
        WidgetCarouselItem(
          id: 'slide$i',
          builder: (_) => Container(
            color: colors[i],
            alignment: Alignment.center,
            child: Text(
              'Slide ${i + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ];
  }
}

class _StandaloneIndicatorDemo extends StatefulWidget {
  const _StandaloneIndicatorDemo();

  @override
  State<_StandaloneIndicatorDemo> createState() =>
      _StandaloneIndicatorDemoState();
}

class _StandaloneIndicatorDemoState extends State<_StandaloneIndicatorDemo> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'CarouselIndicator (standalone)',
      description: 'The dot indicator can be used on its own, driven by your '
          'own page state.',
      demo: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CarouselIndicator(currentPage: _page, pageCount: 5),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < 5; i++)
                ChoiceChip(
                  label: Text('${i + 1}'),
                  selected: _page == i,
                  onSelected: (_) => setState(() => _page = i),
                ),
            ],
          ),
        ],
      ),
      code: 'CarouselIndicator(currentPage: page, pageCount: 5)',
    );
  }
}
