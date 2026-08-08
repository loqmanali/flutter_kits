import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:otp_kit/otp_kit.dart';

import '../../../core/api_table.dart';
import '../../../core/component_page.dart';
import '../../../core/demo_section.dart';
import '../snippets/otp_text_field_snippets.dart';

/// The OTPTextField documentation page.
class OtpTextFieldSection extends ConsumerWidget {
  const OtpTextFieldSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ComponentPage(
      title: 'OTPTextField',
      lead: 'The core input. A single hidden TextField paints [length] cells, '
          'handles focus, paste, autofill, animations, and reports completion. '
          'Configure everything via OTPConfig — most easily through OTPTheme.',
      params: const [
        ApiParam(name: 'config', type: 'OTPConfig', required: true),
        ApiParam(name: 'onCompleted', type: 'void Function(String)?'),
        ApiParam(name: 'onChanged', type: 'void Function(String)?'),
        ApiParam(
          name: 'customValidationRules',
          type: 'List<OTPValidationRule>?',
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Basic 4-digit',
            description: 'The default: four numeric cells, autofocus on, paste '
                'enabled, adaptive to the current theme.',
            demo: OTPTextField(
              config: OTPTheme.adaptive(context),
              onCompleted: (c) => debugPrint('basic: $c'),
            ),
            code: kOtpBasicSnippet,
          ),
          const SizedBox(height: 32),
          DemoSection(
            title: '6-digit code',
            description: 'Bump the length — the row lays out automatically.',
            demo: OTPTextField(
              config: OTPTheme.custom(context: context, length: 6),
            ),
            code: kOtpLength6Snippet,
          ),
          const SizedBox(height: 32),
          DemoSection(
            title: 'Input types',
            description: 'Numeric (default), alphabetic, alphanumeric, or any. '
                'Each picks the right keyboard and validates accordingly.',
            demo: const _InputTypesRow(),
            code: kOtpInputTypesSnippet,
          ),
          const SizedBox(height: 32),
          DemoSection(
            title: 'Obscured',
            description: 'Mask entered digits with an obscureCharacter — ideal '
                'for PINs. Cells still show the active fill.',
            demo: OTPTextField(
              config: OTPTheme.custom(
                context: context,
                obscureText: true,
                length: 4,
              ),
            ),
            code: kOtpObscuredSnippet,
          ),
          const SizedBox(height: 32),
          DemoSection(
            title: 'Expand',
            description: 'Set expand: true and the cells stretch into rectangles '
                'that fill the available width — great for full-bleed layouts.',
            demo: OTPTextField(
              config: OTPTheme.adaptive(context).copyWith(
                length: 4,
                expand: true,
              ),
            ),
            code: kOtpExpandSnippet,
          ),
          const SizedBox(height: 32),
          DemoSection(
            title: 'Right-to-left',
            description: 'Set isRTL: true and cells lay out and fill from right '
                'to left — independent of the host locale.',
            demo: OTPTextField(
              config: OTPTheme.custom(context: context, isRTL: true),
            ),
            code: kOtpRtlSnippet,
          ),
          const SizedBox(height: 32),
          DemoSection(
            title: 'Custom colours',
            description: 'Start from a preset and override any of the 30 '
                'OTPConfig fields via copyWith — colours, geometry, typography, '
                'motion.',
            demo: OTPTextField(
              config: OTPTheme.adaptive(context).copyWith(
                length: 5,
                activeColor: const Color(0xFF16A34A),
                inactiveColor: const Color(0xFFD1D5DB),
                successColor: const Color(0xFF15803D),
                backgroundColor: const Color(0xFFF0FDF4),
                borderRadius: 12,
                borderWidth: 2,
                size: 56,
              ),
            ),
            code: kOtpCustomColorsSnippet,
          ),
          const SizedBox(height: 32),
          DemoSection(
            title: 'Error state',
            description: 'Tap a button to call setError on the controller — '
                'cells turn red and shake. Tap again to clear.',
            demo: _ErrorDemo(),
            code: kOtpErrorSnippet,
          ),
        ],
      ),
    );
  }
}

class _InputTypesRow extends StatelessWidget {
  const _InputTypesRow();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LabelledOtp(
          label: 'numeric',
          type: OTPInputType.numeric,
        ),
        SizedBox(height: 16),
        _LabelledOtp(label: 'alphabetic', type: OTPInputType.alphabetic),
        SizedBox(height: 16),
        _LabelledOtp(
          label: 'alphanumeric',
          type: OTPInputType.alphanumeric,
        ),
      ],
    );
  }
}

class _LabelledOtp extends StatelessWidget {
  const _LabelledOtp({required this.label, required this.type});
  final String label;
  final OTPInputType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        OTPTextField(
          config: OTPTheme.custom(context: context, length: 4, inputType: type),
        ),
      ],
    );
  }
}

class _ErrorDemo extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ErrorDemo> createState() => _ErrorDemoState();
}

class _ErrorDemoState extends ConsumerState<_ErrorDemo> {
  late final OTPConfig _config = OTPTheme.custom(context: context, length: 4);
  bool _hasError = false;

  void _toggle() {
    final controller =
        ref.read(otpControllerProvider(_config).notifier);
    if (_hasError) {
      controller.clearError();
    } else {
      controller.setError('The code you entered is incorrect.');
    }
    setState(() => _hasError = !_hasError);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OTPTextField(
          key: ValueKey(_config),
          config: _config,
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: _toggle,
          icon: Icon(_hasError ? Icons.clear_rounded : Icons.error_outline),
          label: Text(_hasError ? 'Clear error' : 'Trigger error'),
        ),
        const SizedBox(height: 6),
        Text(
          'Hint: type any 4 digits first, then trigger.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
