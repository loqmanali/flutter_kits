import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../gallery/demo_section.dart';
import '../gallery/gallery_scaffold.dart';

/// Documents ContextMenu — triggers, submenus and disabled rows.
class ContextMenuPage extends StatelessWidget {
  const ContextMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Context Menu',
      intro: 'Wrap any widget; open a floating, screen-aware menu on tap or '
          'long-press. Supports nested submenus and disabled rows.',
      sections: const [
        _TapMenuDemo(),
        _LongPressMenuDemo(),
        _SubmenuDemo(),
      ],
    );
  }
}

Widget _target(String label, IconData icon) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );

class _TapMenuDemo extends StatefulWidget {
  const _TapMenuDemo();

  @override
  State<_TapMenuDemo> createState() => _TapMenuDemoState();
}

class _TapMenuDemoState extends State<_TapMenuDemo> {
  String _last = '—';

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Tap to open',
      description: 'The default trigger is a tap. Each MenuItem has a title, an '
          'optional icon, and an onTap. A disabled item is greyed out.',
      demo: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ContextMenu(
            items: [
              MenuItem(
                title: 'Copy',
                icon: Icons.copy,
                onTap: () => setState(() => _last = 'Copy'),
              ),
              MenuItem(
                title: 'Share',
                icon: Icons.share,
                onTap: () => setState(() => _last = 'Share'),
              ),
              MenuItem(
                title: 'Delete',
                icon: Icons.delete,
                enabled: false,
                onTap: () {},
              ),
            ],
            child: _target('Tap me', Icons.touch_app),
          ),
          const SizedBox(height: 10),
          Text('Last action: $_last'),
        ],
      ),
      code: '''
ContextMenu(
  items: [
    MenuItem(title: 'Copy', icon: Icons.copy, onTap: doCopy),
    MenuItem(title: 'Delete', icon: Icons.delete, enabled: false, onTap: () {}),
  ],
  child: const Icon(Icons.more_vert),
)''',
    );
  }
}

class _LongPressMenuDemo extends StatelessWidget {
  const _LongPressMenuDemo();

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Long-press trigger',
      description: 'Set trigger: MenuTrigger.longPress for a press-and-hold '
          'gesture (common on list rows and images).',
      demo: ContextMenu(
        trigger: MenuTrigger.longPress,
        items: [
          MenuItem(title: 'Pin', icon: Icons.push_pin, onTap: () {}),
          MenuItem(title: 'Archive', icon: Icons.archive, onTap: () {}),
        ],
        child: _target('Long-press me', Icons.timer),
      ),
      code: '''
ContextMenu(
  trigger: MenuTrigger.longPress,
  items: [...],
  child: myRow,
)''',
    );
  }
}

class _SubmenuDemo extends StatelessWidget {
  const _SubmenuDemo();

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Nested submenus',
      description: 'Give a MenuItem subItems to render it as a submenu trigger '
          'with a chevron.',
      demo: ContextMenu(
        items: [
          MenuItem(title: 'New', icon: Icons.add, onTap: () {}),
          MenuItem(
            title: 'Move to',
            icon: Icons.drive_file_move,
            onTap: () {},
            subItems: [
              MenuItem(title: 'Inbox', onTap: () {}),
              MenuItem(title: 'Archive', onTap: () {}),
              MenuItem(title: 'Trash', onTap: () {}),
            ],
          ),
        ],
        child: _target('Open menu', Icons.account_tree),
      ),
      code: '''
MenuItem(
  title: 'Move to',
  onTap: () {},
  subItems: [
    MenuItem(title: 'Inbox', onTap: ...),
    MenuItem(title: 'Trash', onTap: ...),
  ],
)''',
    );
  }
}
