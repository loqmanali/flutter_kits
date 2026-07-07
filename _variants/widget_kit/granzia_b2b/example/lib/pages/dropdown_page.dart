import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../gallery/demo_section.dart';
import '../gallery/gallery_scaffold.dart';

/// Documents CustomDropdownMenu and all its entry types.
class DropdownPage extends StatelessWidget {
  const DropdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Dropdown Menu',
      intro: 'A trigger-anchored overlay menu supporting plain items, section '
          'labels, separators, checkboxes and radios.',
      sections: const [
        _BasicDropdown(),
        _RichDropdown(),
      ],
    );
  }
}

class _BasicDropdown extends StatefulWidget {
  const _BasicDropdown();

  @override
  State<_BasicDropdown> createState() => _BasicDropdownState();
}

class _BasicDropdownState extends State<_BasicDropdown> {
  String _selected = 'Profile';

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Items, icons & shortcuts',
      description: 'Tap the trigger to open. Each CustomDropdownItem can carry '
          'an icon, a shortcut hint, and an onTap.',
      demo: CustomDropdownMenu(
        trigger: FilledButton.tonalIcon(
          onPressed: null,
          icon: const Icon(Icons.menu),
          label: Text(_selected),
        ),
        items: [
          CustomDropdownItem(
            text: 'Profile',
            icon: Icons.person,
            onTap: () => setState(() => _selected = 'Profile'),
          ),
          CustomDropdownItem(
            text: 'Settings',
            icon: Icons.settings,
            shortcut: '⌘,',
            onTap: () => setState(() => _selected = 'Settings'),
          ),
          CustomDropdownSeparator(),
          CustomDropdownItem(
            text: 'Sign out',
            icon: Icons.logout,
            onTap: () => setState(() => _selected = 'Sign out'),
          ),
        ],
      ),
      code: '''
CustomDropdownMenu(
  trigger: const Text('Menu'),
  items: [
    CustomDropdownItem(text: 'Profile', icon: Icons.person, onTap: ...),
    CustomDropdownSeparator(),
    CustomDropdownItem(text: 'Sign out', icon: Icons.logout, onTap: ...),
  ],
)''',
    );
  }
}

class _RichDropdown extends StatefulWidget {
  const _RichDropdown();

  @override
  State<_RichDropdown> createState() => _RichDropdownState();
}

class _RichDropdownState extends State<_RichDropdown> {
  bool _notifications = true;
  String _theme = 'system';

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Labels, checkboxes & radios',
      description: 'Group entries under a CustomDropdownLabel, and use checkbox '
          'and radio entries for stateful options.',
      demo: CustomDropdownMenu(
        trigger: const Chip(
          avatar: Icon(Icons.tune, size: 18),
          label: Text('Preferences'),
        ),
        items: [
          CustomDropdownLabel(text: 'General'),
          CustomDropdownCheckbox(
            text: 'Notifications',
            checked: _notifications,
            onChanged: (v) => setState(() => _notifications = v ?? false),
          ),
          CustomDropdownSeparator(),
          CustomDropdownLabel(text: 'Theme'),
          for (final t in ['system', 'light', 'dark'])
            CustomDropdownRadio(
              text: t,
              value: t,
              groupValue: _theme,
              onChanged: (v) => setState(() => _theme = v),
            ),
        ],
      ),
      code: '''
CustomDropdownMenu(
  trigger: const Text('Preferences'),
  items: [
    CustomDropdownLabel(text: 'General'),
    CustomDropdownCheckbox(text: 'Notifications', checked: on, onChanged: ...),
    CustomDropdownLabel(text: 'Theme'),
    CustomDropdownRadio(text: 'dark', value: 'dark', groupValue: sel, onChanged: ...),
  ],
)''',
    );
  }
}
