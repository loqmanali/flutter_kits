import 'package:carousel_kit/carousel_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: _ExampleApp()));
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'carousel_kit example',
      home: _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final items = <CarouselItem>[
      const ImageCarouselItem.network('https://picsum.photos/id/1018/800/400'),
      const ImageCarouselItem.network('https://picsum.photos/id/1015/800/400'),
      const ImageCarouselItem.network('https://picsum.photos/id/1019/800/400'),
      WidgetCarouselItem(
        builder: (context) => Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          alignment: Alignment.center,
          child: const Text('Custom widget slide'),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('carousel_kit')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Banner preset'),
          ),
          const SizedBox(height: 8),
          Carousel(items: items, config: CarouselConfig.banner),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Hero preset'),
          ),
          const SizedBox(height: 8),
          Carousel(items: items, config: CarouselConfig.hero),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Cards preset'),
          ),
          const SizedBox(height: 8),
          Carousel(items: items, config: CarouselConfig.cards),
        ],
      ),
    );
  }
}
