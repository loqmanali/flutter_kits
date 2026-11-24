import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:otp_kit/otp_kit.dart';

import '../../../core/api_table.dart';
import '../../../core/component_page.dart';
import '../../../core/demo_section.dart';
import '../snippets/resend_snippets.dart';

/// The OTPResendButton documentation page.
class ResendButtonSection extends ConsumerWidget {
  const ResendButtonSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ComponentPage(
      title: 'OTPResendButton',
      lead: 'A self-contained countdown + resend button. It formats the '
          'remaining time (mm:ss under an hour, hh:mm:ss above), disables the '
          'button while ticking, escalates to a long cooldown after maxAttempts, '
          'and persists state across app restarts — all scoped by namespace.',
      params: const [
        ApiParam(name: 'config', type: 'ResendCooldownConfig', required: true),
        ApiParam(name: 'labels', type: 'ResendButtonLabels', required: true),
        ApiParam(name: 'onResend', type: 'VoidCallback', required: true),
        ApiParam(name: 'buttonBuilder', type: 'Widget Function(...)', required: true),
        ApiParam(name: 'timerStyle', type: 'TextStyle?'),
        ApiParam(name: 'spacing', type: 'double', defaultValue: '8.0'),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Basic resend',
            description: 'A 60-second initial countdown. Tap Resend when it '
                'becomes available — the kit records the attempt and restarts '
                'the timer.',
            demo: const _ResendDemo(),
            code: kResendBasicSnippet,
          ),
          const SizedBox(height: 32),
          DemoSection(
            title: 'Escalation',
            description: 'After maxAttempts quick resends, the kit switches to '
                'a long cooldown (5 min by default). State persists across '
                'restarts via SharedPreferences, keyed by namespace.',
            demo: const _EscalationPreview(),
            code: kResendConfigSnippet,
          ),
        ],
      ),
    );
  }
}

class _ResendDemo extends ConsumerStatefulWidget {
  const _ResendDemo();

  @override
  ConsumerState<_ResendDemo> createState() => _ResendDemoState();
}

class _ResendDemoState extends ConsumerState<_ResendDemo> {
  final _config = const ResendCooldownConfig(
    namespace: 'docs_demo',
    initialCountdownSeconds: 30,
    maxAttempts: 3,
  );
  int _sends = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OTPResendButton(
          config: _config,
          labels: ResendButtonLabels(
            resend: 'Resend code',
            shortCooldown: (t) => 'Resend in $t',
            longCooldown: (t) => 'Try again in $t',
          ),
          onResend: () {
            // In a real app: call your API here. Returns whether the resend
            // was accepted; the kit handles the next countdown either way.
            ref.read(resendCooldownProvider(_config).notifier).recordResend();
            setState(() => _sends++);
          },
          buttonBuilder: (context, {required label, required onPressed}) {
            return FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(label),
            );
          },
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(resendCooldownProvider(_config));
            return Text(
              'sends: $_sends · remaining: ${state.canResend ? "idle" : "ticking"}',
              style: Theme.of(context).textTheme.bodySmall,
            );
          },
        ),
      ],
    );
  }
}

class _EscalationPreview extends StatelessWidget {
  const _EscalationPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const phases = <(String, String)>[
      ('Idle', 'Tap Resend → starts initial 60s countdown.'),
      ('Short cooldown', '60s ticking. Format: mm:ss.'),
      ('After maxAttempts', 'Switches to long cooldown: 5 min. Format: hh:mm:ss.'),
      ('Persistence', 'Survives app restart via SharedPreferences, scoped by namespace.'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final p in phases) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.$1,
                          style: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
                        ),
                        Text(
                          p.$2,
                          style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
