import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:otp_kit/otp_kit.dart';

import '../../../core/component_page.dart';
import '../../../core/demo_section.dart';
import '../snippets/programmatic_snippets.dart';

/// The Programmatic control documentation page.
class ProgrammaticSection extends ConsumerWidget {
  const ProgrammaticSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ComponentPage(
      title: 'Programmatic control',
      lead: 'The OTPController (a StateNotifier) is the single source of truth. '
          'Read state declaratively via selectors, drive the field imperatively '
          'via the notifier — fill it, error it, clear it, validate it.',
      params: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Drive from buttons',
            description: 'Fill, error, clear, and validate the field via the '
                'controller. The widget reflects every mutation instantly.',
            demo: const _ProgrammaticDemo(),
            code: kProgrammaticSnippet,
          ),
        ],
      ),
    );
  }
}

class _ProgrammaticDemo extends ConsumerStatefulWidget {
  const _ProgrammaticDemo();

  @override
  ConsumerState<_ProgrammaticDemo> createState() => _ProgrammaticDemoState();
}

class _ProgrammaticDemoState extends ConsumerState<_ProgrammaticDemo> {
  late final OTPConfig _config = OTPTheme.custom(context: context, length: 4);

  OTPController get _controller =>
      ref.read(otpControllerProvider(_config).notifier);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpControllerProvider(_config));
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OTPTextField(key: ValueKey(_config), config: _config),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _ActionChip(
              label: "setValue('1234')",
              onTap: () => _controller.setValue('1234'),
            ),
            _ActionChip(
              label: 'setError',
              onTap: () => _controller.setError('Server rejected this code'),
            ),
            _ActionChip(
              label: 'clearError',
              onTap: _controller.clearError,
            ),
            _ActionChip(
              label: 'clear',
              onTap: _controller.clear,
            ),
            _ActionChip(
              label: 'validate',
              onTap: () {
                final e = _controller.validate();
                if (e != null) _controller.setError(e);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OTPState',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              _KvRow(k: 'value', v: "'${state.value}'"),
              _KvRow(k: 'filledCount', v: '${state.filledCount}/${_config.length}'),
              _KvRow(k: 'isComplete', v: '${state.isComplete}'),
              _KvRow(k: 'hasError', v: '${state.hasError}'),
              _KvRow(k: 'progress', v: state.progress.toStringAsFixed(2)),
              if (state.errorMessage != null)
                _KvRow(
                  k: 'errorMessage',
                  v: "'${state.errorMessage!}'",
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}

class _KvRow extends StatelessWidget {
  const _KvRow({required this.k, required this.v});
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              k,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              v,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
