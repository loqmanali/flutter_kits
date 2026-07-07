import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../gallery/demo_section.dart';
import '../gallery/gallery_scaffold.dart';

/// Documents empty/error states, loading indicators and shimmer placeholders.
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Feedback',
      intro: 'States for empty data, errors, in-flight loading, and skeleton '
          'placeholders while content loads.',
      sections: [
        DemoGroup(
          label: 'States',
          children: [
            DemoSection(
              title: 'EmptyStateWidget',
              description: 'Shown when a list or screen has no content. Optional '
                  'action button to guide the user forward.',
              demo: EmptyStateWidget(
                icon: Icons.inbox_outlined,
                title: 'No messages',
                subtitle: 'Your inbox is empty.',
                actionLabel: 'Refresh',
                onAction: () {},
              ),
              code: '''
EmptyStateWidget(
  icon: Icons.inbox_outlined,
  title: 'No messages',
  subtitle: 'Your inbox is empty.',
  actionLabel: 'Refresh',
  onAction: () {},
)''',
            ),
            DemoSection(
              title: 'ErrorStateWidget',
              description: 'A retry-able error panel with a default title and a '
                  'customisable message and retry label.',
              demo: ErrorStateWidget(
                message: 'Could not reach the server.',
                onRetry: () {},
              ),
              code: '''
ErrorStateWidget(
  message: 'Could not reach the server.',
  onRetry: _reload,
)''',
            ),
          ],
        ),
        DemoGroup(
          label: 'Loading',
          children: [
            const DemoSection(
              title: 'LoadingIndicator',
              description: 'A unified spinner with 30+ styles, including an '
                  'adaptive (platform-aware) type.',
              demo: Wrap(
                spacing: 28,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _LabelledLoader('adaptive', LoadingIndicatorType.adaptive),
                  _LabelledLoader('circular', LoadingIndicatorType.circular),
                  _LabelledLoader('wave', LoadingIndicatorType.wave),
                  _LabelledLoader(
                      'fadingCircle', LoadingIndicatorType.fadingCircle),
                  _LabelledLoader('pulse', LoadingIndicatorType.pulse),
                  _LabelledLoader('ring', LoadingIndicatorType.ring),
                ],
              ),
              code: '''
LoadingIndicator(
  type: LoadingIndicatorType.adaptive,
  color: Colors.blue,
  size: 32,
)''',
            ),
          ],
        ),
        DemoGroup(
          label: 'Shimmer skeletons',
          children: [
            DemoSection(
              title: 'ShimmerLayouts presets',
              description: 'Ready-made skeleton placeholders that animate while '
                  'real content loads.',
              demoBackground: false,
              demo: Column(
                children: [
                  ShimmerLayouts.card(),
                  const SizedBox(height: 12),
                  ShimmerLayouts.listItem(),
                ],
              ),
              code: '''
ShimmerLayouts.card()
ShimmerLayouts.listItem()
ShimmerLayouts.banner(height: 180)''',
            ),
            DemoSection(
              title: 'ShimmerShape + FlexibleShimmerLoading',
              description: 'Compose custom skeletons from primitive shapes, '
                  'wrapped in the shimmer animation.',
              demo: FlexibleShimmerLoading(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ShimmerShape.circle(radius: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerShape.text(width: 140),
                        SizedBox(height: 8),
                        ShimmerShape.text(width: 90),
                      ],
                    ),
                  ],
                ),
              ),
              code: '''
FlexibleShimmerLoading(
  child: Row(children: [
    ShimmerShape.circle(radius: 24),
    ShimmerShape.text(width: 140),
  ]),
)''',
            ),
          ],
        ),
      ],
    );
  }
}

class _LabelledLoader extends StatelessWidget {
  const _LabelledLoader(this.label, this.type);
  final String label;
  final LoadingIndicatorType type;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 36,
          width: 36,
          child: Center(
            child: LoadingIndicator(type: type, size: 30),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
