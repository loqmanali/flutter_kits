import 'package:flutter/material.dart';
import 'package:selection_kit/selection_kit.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'selection_kit example',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const SelectionKitTheme(
        data: SelectionKitThemeData(
          borderRadius: 12,
          contentPadding: EdgeInsets.all(16),
        ),
        child: ExamplePage(),
      ),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  String? _radioValue = 'family';
  Set<String> _channels = {'email'};
  bool _agreed = false;
  String? _horizontalValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('selection_kit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Radio group', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AppRadioGroup<String>(
              label: 'Booking type',
              isRequired: true,
              groupValue: _radioValue,
              onChanged: (v) => setState(() => _radioValue = v),
              helperText: 'Choose one option',
              options: const [
                SelectionOption(
                  value: 'single',
                  title: 'Single',
                  icon: Icon(Icons.person),
                ),
                SelectionOption(
                  value: 'family',
                  title: 'Family or Friends',
                  subtitle: 'Up to 5 passengers',
                  icon: Icon(Icons.group),
                ),
                SelectionOption(
                  value: 'business',
                  title: 'Business',
                  subtitle: 'Corporate bookings',
                  icon: Icon(Icons.business),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Text(
              'Checkbox group (min 1, max 2)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            AppCheckboxGroup<String>(
              label: 'Notification channels',
              groupValues: _channels,
              minSelections: 1,
              maxSelections: 2,
              onChanged: (v) => setState(() => _channels = v),
              helperText: 'Pick at least one, up to two',
              options: const [
                SelectionOption(
                  value: 'email',
                  title: 'Email',
                  icon: Icon(Icons.email),
                ),
                SelectionOption(
                  value: 'sms',
                  title: 'SMS',
                  icon: Icon(Icons.sms),
                ),
                SelectionOption(
                  value: 'push',
                  title: 'Push',
                  icon: Icon(Icons.notifications),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Text(
              'Horizontal radio with custom indicator',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            AppRadioGroup<String>(
              direction: Axis.horizontal,
              groupValue: _horizontalValue,
              onChanged: (v) => setState(() => _horizontalValue = v),
              indicatorBuilder: (selected, enabled) => Icon(
                selected ? Icons.star : Icons.star_border,
                color: enabled ? Colors.amber : Colors.grey,
              ),
              options: const [
                SelectionOption(value: 'small', title: 'Small'),
                SelectionOption(value: 'medium', title: 'Medium'),
                SelectionOption(value: 'large', title: 'Large'),
              ],
            ),
            const SizedBox(height: 32),

            Text(
              'Single checkbox',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            AppCheckbox<bool>(
              value: true,
              selected: _agreed,
              title: 'I agree to the terms and conditions',
              onChanged: (v) => setState(() => _agreed = v == true),
            ),
            const SizedBox(height: 32),

            Text(
              'Radio with separator',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            AppRadioGroup<String>(
              groupValue: _radioValue,
              onChanged: (v) => setState(() => _radioValue = v),
              separator: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              options: const [
                SelectionOption(value: 'a', title: 'Option A'),
                SelectionOption(value: 'b', title: 'Option B'),
                SelectionOption(value: 'c', title: 'Option C'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
