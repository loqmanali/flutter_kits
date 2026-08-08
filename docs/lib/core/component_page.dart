import 'package:flutter/material.dart';

import 'api_table.dart';

/// A standard page shell: title, lead paragraph, optional API reference,
/// then the page body (typically a column of [DemoGroup]s / [DemoSection]s).
class ComponentPage extends StatelessWidget {
  const ComponentPage({
    super.key,
    required this.title,
    required this.lead,
    this.params = const [],
    required this.child,
  });

  final String title;
  final String lead;

  /// Constructor params rendered as an API table under the lead.
  final List<ApiParam> params;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 36, 40, 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 32,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                lead,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              if (params.isNotEmpty) ...[
                const SizedBox(height: 28),
                ApiTable(params: params),
              ],
              const SizedBox(height: 36),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
