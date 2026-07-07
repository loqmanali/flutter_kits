import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../gallery/demo_section.dart';
import '../gallery/gallery_scaffold.dart';

/// Documents [AppTextFormField], [IntlPhoneField] and the date-of-birth picker.
class InputsPage extends StatelessWidget {
  const InputsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Inputs',
      intro:
          'Form inputs that pick up colours, radii and fonts from '
          'WidgetKitTheme, with per-field overrides.',
      sections: const [
        DemoSection(
          title: 'AppTextFormField',
          description:
              'A themed TextFormField wrapper with label, hint and '
              'built-in validation display.',
          demo: SizedBox(
            width: 320,
            child: AppTextFormField(
              labelText: 'Email',
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          code: '''
AppTextFormField(
  labelText: 'Email',
  hintText: 'you@example.com',
  keyboardType: TextInputType.emailAddress,
)''',
        ),
        _ValidatedField(),
        _PhoneFieldDemo(),
        _DobPickerDemo(),
      ],
    );
  }
}

class _ValidatedField extends StatefulWidget {
  const _ValidatedField();

  @override
  State<_ValidatedField> createState() => _ValidatedFieldState();
}

class _ValidatedFieldState extends State<_ValidatedField> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'With validation',
      description:
          'Pass a validator; it runs on user interaction and shows the error '
          'inline. Submit to force-validate.',
      demo: SizedBox(
        width: 320,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextFormField(
                labelText: 'Username',
                validator: (v) => (v == null || v.length < 3)
                    ? 'At least 3 characters'
                    : null,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Submit',
                onPressed: () => _formKey.currentState?.validate(),
              ),
            ],
          ),
        ),
      ),
      code: '''
AppTextFormField(
  labelText: 'Username',
  validator: (v) =>
      (v == null || v.length < 3) ? 'At least 3 characters' : null,
)''',
    );
  }
}

class _PhoneFieldDemo extends StatefulWidget {
  const _PhoneFieldDemo();

  @override
  State<_PhoneFieldDemo> createState() => _PhoneFieldDemoState();
}

class _PhoneFieldDemoState extends State<_PhoneFieldDemo> {
  String _complete = '';

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'IntlPhoneField',
      description:
          'International phone input with a country picker and a typed '
          'PhoneNumber callback. Tap the flag to change country.',
      demo: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntlPhoneField(
              initialCountryCode: 'EG',
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              onChanged: (phone) =>
                  setState(() => _complete = phone.completeNumber),
            ),
            const SizedBox(height: 8),
            Text('Complete: $_complete'),
          ],
        ),
      ),
      code: '''
IntlPhoneField(
  initialCountryCode: 'EG',
  onChanged: (phone) => print(phone.completeNumber),
)''',
    );
  }
}

class _DobPickerDemo extends StatefulWidget {
  const _DobPickerDemo();

  @override
  State<_DobPickerDemo> createState() => _DobPickerDemoState();
}

class _DobPickerDemoState extends State<_DobPickerDemo> {
  DateTime? _picked;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Date-of-birth picker',
      description:
          'showDobPicker opens a scroll-wheel bottom sheet and returns '
          'the chosen DateTime (defaults to 18 years ago).',
      demo: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _picked == null
                ? 'No date selected'
                : '${_picked!.year}-${_picked!.month}-${_picked!.day}',
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Pick date of birth',
            icon: const Icon(Icons.cake_outlined),
            onPressed: () async {
              final result = await showDobPicker(context);
              if (mounted) setState(() => _picked = result);
            },
          ),
        ],
      ),
      code: '''
final dob = await showDobPicker(
  context,
  locale: 'en', // or 'ar'
);''',
    );
  }
}
