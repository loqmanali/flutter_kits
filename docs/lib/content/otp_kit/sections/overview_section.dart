import 'package:flutter/material.dart';

import '../../../core/code_block.dart';
import '../../../core/demo_section.dart';
import '../../../core/preview_tabs.dart';
import '../snippets/programmatic_snippets.dart';
import 'package:otp_kit/otp_kit.dart';

/// The otp_kit landing/overview page body.
class OtpKitOverview extends StatelessWidget {
  const OtpKitOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero.
              Text(
                'otp_kit',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 44),
              ),
              const SizedBox(height: 14),
              Text(
                'A high-performance, hand-rolled OTP input: single-hidden-field '
                'architecture, Riverpod state, validation, resend cooldown, '
                'theming, animations, RTL, and paste/SMS autofill — no codegen.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 28),
              // Live preview right in the hero.
              PreviewTabs(
                demo: const _HeroOtp(),
                code: kOverviewQuickStartSnippet,
                previewPadding: const EdgeInsets.symmetric(
                  vertical: 36,
                  horizontal: 24,
                ),
              ),
              const SizedBox(height: 48),
              // Install.
              Text(
                'Install',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Pin a git ref and bump deliberately. Override with a path dep '
                'while developing locally.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 14),
              const CodeBlock(kOverviewInstallSnippet, language: 'yaml'),
              const SizedBox(height: 48),
              // What's inside.
              Text('What you get', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              const _FeatureGrid(),
              const SizedBox(height: 48),
              // Architecture note.
              DemoSection(
                title: 'Single import, ProviderScope required',
                description: 'otp_kit is built on hooks_riverpod. Wrap your app '
                    '(or at least the subtree hosting the field) in a '
                    'ProviderScope. Everything ships from one barrel import.',
                demo: const _IconRow(),
                code: "import 'package:otp_kit/otp_kit.dart';\n\n"
                    '// Widgets: OTPTextField, OTPResendButton\n'
                    '// Theme:  OTPTheme (11 presets + custom builder)\n'
                    '// Config: OTPConfig, ResendCooldownConfig, OTPInputType\n'
                    '// State:  OTPState, ResendState + OTPController\n'
                    '// Rules:  MinimumUniqueDigitsRule, NoSequentialPatternRule, ...',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroOtp extends StatelessWidget {
  const _HeroOtp();

  @override
  Widget build(BuildContext context) {
    return OTPTextField(
      config: OTPTheme.adaptive(context),
      onCompleted: (code) => debugPrint('Hero completed: $code'),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _Chip(icon: Icons.pin_rounded, label: 'OTPTextField'),
        _Chip(icon: Icons.timer_outlined, label: 'OTPResendButton'),
        _Chip(icon: Icons.palette_outlined, label: '11 themes'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const _items = <_Feature>[
    _Feature(
      icon: Icons.speed_rounded,
      title: 'Single hidden field',
      body: 'One TextField drives painted cells — no per-cell focus juggling.',
    ),
    _Feature(
      icon: Icons.rule_rounded,
      title: 'Composable validation',
      body: 'Built-in length/type checks + pluggable OTPValidationRule classes.',
    ),
    _Feature(
      icon: Icons.timer_outlined,
      title: 'Resend cooldown',
      body: 'Wall-clock timer, attempt escalation, persists across restarts.',
    ),
    _Feature(
      icon: Icons.palette_outlined,
      title: '11 theme presets',
      body: 'From minimal to premium; or build your own with OTPTheme.custom.',
    ),
    _Feature(
      icon: Icons.sms_rounded,
      title: 'SMS autofill + paste',
      body: 'AutofillHints.oneTimeCode, long-press paste, Arabic-Indic digits.',
    ),
    _Feature(
      icon: Icons.translate_rounded,
      title: 'RTL & i18n ready',
      body: 'isRTL flag + OTPValidatorMessages singleton for localized errors.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        for (final f in _items)
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(f.icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(height: 10),
                Text(
                  f.title,
                  style: theme.textTheme.titleSmall?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  f.body,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Feature {
  const _Feature({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}
