import 'package:flutter/material.dart';
import 'package:otp_kit/otp_kit.dart';

import '../../../core/component_page.dart';
import '../../../core/demo_section.dart';
import '../snippets/themes_snippets.dart';

/// The Themes documentation page — every OTPTheme preset, live.
class ThemesSection extends StatelessWidget {
  const ThemesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Themes',
      lead: 'Every OTPTheme preset is a static factory reading '
          'Theme.of(context).colorScheme — so your OTP adapts to the app palette '
          'for free. Pick one, or compose your own with copyWith.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'All presets',
            description: 'Ten named presets plus adaptive (picks dark/light '
                'from the current theme). Each below is a live OTPTextField.',
            demo: _PresetsGrid(),
            code: kThemesIntroSnippet,
          ),
          const SizedBox(height: 32),
          DemoSection(
            title: 'Custom via copyWith',
            description: 'Start from adaptive, then override anything. Here: '
                'violet accent, larger cells, bold digits, success glow.',
            demo: OTPTextField(
              config: OTPTheme.adaptive(context).copyWith(
                length: 6,
                activeColor: const Color(0xFF7C3AED),
                successColor: const Color(0xFF15803D),
                borderRadius: 14,
                size: 56,
                spacing: 12,
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                enableShadow: true,
                shadowElevation: 3,
              ),
            ),
            code: kThemeCustomSnippet,
          ),
        ],
      ),
    );
  }
}

class _PresetsGrid extends StatelessWidget {
  final _presets = <_Preset>[
    _Preset('defaultLight', (c) => OTPTheme.defaultLight(c)),
    _Preset('defaultDark', (c) => OTPTheme.defaultDark(c)),
    _Preset('minimal', (c) => OTPTheme.minimal(c)),
    _Preset('rounded', (c) => OTPTheme.rounded(c)),
    _Preset('modern', (c) => OTPTheme.modern(c)),
    _Preset('compact', (c) => OTPTheme.compact(c)),
    _Preset('large', (c) => OTPTheme.large(c)),
    _Preset('secure', (c) => OTPTheme.secure(c)),
    _Preset('premium', (c) => OTPTheme.premium(c)),
    _Preset('underline', (c) => OTPTheme.underline(c)),
    _Preset('adaptive', (c) => OTPTheme.adaptive(c)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final entry in _presets) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'OTPTheme.${entry.name}(context)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OTPTextField(config: entry.builder(context)),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _Preset {
  const _Preset(this.name, this.builder);
  final String name;
  final OTPConfig Function(BuildContext) builder;
}
