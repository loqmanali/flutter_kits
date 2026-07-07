import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../gallery/demo_section.dart';
import '../gallery/gallery_scaffold.dart';

/// Documents CustomStarRating, RefreshTrigger and TravelingBorderWidget.
class EffectsPage extends StatelessWidget {
  const EffectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Effects',
      intro:
          'Interactive and animated flourishes: a star rating, a custom '
          'pull-to-refresh, and an animated traveling border.',
      sections: const [
        _StarRatingDemo(),
        DemoSection(
          title: 'TravelingBorderWidget',
          description:
              'An animated gradient border that travels around the '
              'child — great for highlighting a focused element.',
          demo: TravelingBorderWidget(
            borderColor: Color(0xFFDC1213),
            borderRadius: 16,
            child: SizedBox(
              width: 160,
              height: 90,
              child: Center(child: Text('Highlighted')),
            ),
          ),
          code: '''
TravelingBorderWidget(
  borderColor: Color(0xFFDC1213),
  borderRadius: 16,
  child: MyCard(),
)''',
        ),
        _RefreshTriggerDemo(),
      ],
    );
  }
}

class _StarRatingDemo extends StatefulWidget {
  const _StarRatingDemo();

  @override
  State<_StarRatingDemo> createState() => _StarRatingDemoState();
}

class _StarRatingDemoState extends State<_StarRatingDemo> {
  double _rating = 3;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'CustomStarRating',
      description:
          'Tap (or drag for half-stars) to rate. Set readOnly to use '
          'it purely as a display.',
      demo: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomStarRating(
            initialRating: _rating,
            iconSize: 36,
            onRatingChanged: (r) => setState(() => _rating = r),
          ),
          const SizedBox(height: 8),
          Text('Rating: $_rating'),
          const SizedBox(height: 16),
          const Text('Read-only:'),
          const CustomStarRating(initialRating: 4, readOnly: true),
        ],
      ),
      code: '''
CustomStarRating(
  initialRating: 3,
  allowHalfRating: true,
  onRatingChanged: (r) => setState(() => rating = r),
)''',
    );
  }
}

class _RefreshTriggerDemo extends StatefulWidget {
  const _RefreshTriggerDemo();

  @override
  State<_RefreshTriggerDemo> createState() => _RefreshTriggerDemoState();
}

class _RefreshTriggerDemoState extends State<_RefreshTriggerDemo> {
  int _refreshes = 0;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'RefreshTrigger',
      description:
          'A customisable pull-to-refresh. Pull the list down to fire '
          'onRefresh.',
      demo: SizedBox(
        height: 220,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: RefreshTrigger(
            onRefresh: () async {
              await Future<void>.delayed(const Duration(seconds: 1));
              if (mounted) setState(() => _refreshes++);
            },
            child: ListView(
              children: [
                ListTile(title: Text('Pull me down · refreshed $_refreshes×')),
                for (var i = 1; i <= 8; i++) ListTile(title: Text('Row $i')),
              ],
            ),
          ),
        ),
      ),
      code: '''
RefreshTrigger(
  onRefresh: () async => await reload(),
  child: ListView(children: [...]),
)''',
    );
  }
}
