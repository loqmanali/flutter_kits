import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:otp_kit/otp_kit.dart';

import '../../../core/api_table.dart';
import '../../../core/component_page.dart';
import '../../../core/demo_section.dart';
import '../snippets/validation_snippets.dart';

/// The Validation documentation page.
class ValidationSection extends ConsumerWidget {
  const ValidationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ComponentPage(
      title: 'Validation',
      lead: 'Two layers: built-in length/type checks via OTPController.validate(), '
          'and composable OTPValidationRule classes you pass to the widget. Every '
          'error string flows through OTPValidatorMessages for localization.',
      params: const [
        ApiParam(
          name: '',
          type: 'OTPValidationRule',
          note: 'abstract — implement validate(String) → String?',
        ),
        ApiParam(name: 'minimumUnique', type: 'int', required: true),
        ApiParam(name: 'errorMessage', type: 'String?'),
        ApiParam(name: 'pattern', type: 'RegExp', required: true),
        ApiParam(name: 'minLength', type: 'int', required: true),
        ApiParam(name: 'maxLength', type: 'int', required: true),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Built-in checks',
            description: 'OTPController.validate() enforces the configured '
                'length and inputType. Type an incomplete or wrong-type code, '
                'then hit Verify.',
            demo: _BuiltInValidateDemo(),
            code: kValidationBuiltInSnippet,
          ),
          const SizedBox(height: 32),
          DemoSection(
            title: 'Custom rules',
            description: 'Compose any number of OTPValidationRule classes. The '
                'widget runs them on completion and surfaces the first failure.',
            demo: const _RulesOverview(),
            code: kValidationRulesSnippet,
          ),
          const SizedBox(height: 32),
          DemoSection(
            title: 'Localized messages',
            description: 'Set OTPValidatorMessages.instance once at startup to '
                'translate every error string. The {length} placeholder is '
                'supported in wrongLength.',
            demo: const _MessagesPreview(),
            code: kValidationMessagesSnippet,
          ),
        ],
      ),
    );
  }
}

class _BuiltInValidateDemo extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BuiltInValidateDemo> createState() =>
      _BuiltInValidateDemoState();
}

class _BuiltInValidateDemoState extends ConsumerState<_BuiltInValidateDemo> {
  late final OTPConfig _config =
      OTPTheme.custom(context: context, length: 4);
  String? _message;

  void _verify() {
    final controller = ref.read(otpControllerProvider(_config).notifier);
    final error = controller.validate();
    setState(() {
      if (error != null) {
        controller.setError(error);
        _message = error;
      } else {
        _message = '✓ Looks valid — proceed.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OTPTextField(key: ValueKey(_config), config: _config),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _verify,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Verify'),
        ),
        if (_message != null) ...[
          const SizedBox(height: 10),
          Text(
            _message!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _message!.startsWith('✓')
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _RulesOverview extends StatelessWidget {
  const _RulesOverview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const rules = [
      ('MinimumUniqueDigitsRule', 'Reject codes with too few unique digits.'),
      ('NoSequentialPatternRule', 'Block 1234, 4567, etc.'),
      ('NoRepeatedDigitsRule', 'Block 1111, 2222, etc.'),
      ('PatternMatchRule', 'Require a custom RegExp.'),
      ('LengthRangeRule', 'Enforce a min/max length window.'),
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
          for (final r in rules) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.bolt_rounded, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.$1,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          r.$2,
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

class _MessagesPreview extends StatelessWidget {
  const _MessagesPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const fields = [
      ('required', "'OTP is required'"),
      ('wrongLength', "'OTP must be {length} digits'"),
      ('notNumeric', "'OTP must contain only numbers'"),
      ('sequential', "'OTP cannot be sequential numbers'"),
      ('repeated', "'OTP cannot be all the same digit'"),
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
          Text(
            'OTPValidatorMessages',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          for (final f in fields)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Text(
                    f.$1,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
