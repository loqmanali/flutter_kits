import 'package:confirm_kit/confirm_kit.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

enum SaveChoice { save, discard, keep }

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'confirm_kit example',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF104C65),
        // App-wide defaults for every confirmation. Anything passed on a
        // single dialog still wins.
        extensions: const [
          ConfirmKitTheme(
            borderRadius: 20,
            actionBorderRadius: 12,
            destructiveColor: Color(0xFFD53B3B),
          ),
        ],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF104C65),
        extensions: const [
          ConfirmKitTheme(borderRadius: 20, actionBorderRadius: 12),
        ],
      ),
      home: const GalleryPage(),
    );
  }
}

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  /// Shows a confirmation and reports what it popped.
  Future<void> _run(
    BuildContext context,
    Future<Object?> Function() open,
  ) async {
    final result = await open();
    if (context.mounted) _report(context, result);
  }

  void _report(BuildContext context, Object? result) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text('result: $result')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('confirm_kit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Demo(
            'Plain confirm',
            'Default intent, confirm + cancel.',
            () => _run(
                context,
                () => const ConfirmDialog(
                      title: 'Apply changes?',
                      message:
                          'Your new delivery window will be used from now on.',
                    ).show(context)),
          ),
          _Demo(
            'Destructive',
            'Error-colored accent, "Delete" by default.',
            () => _run(
                context,
                () => const ConfirmDialog(
                      title: 'Delete account?',
                      message:
                          'Your orders, addresses and saved cards are removed permanently.',
                      intent: ConfirmIntent.destructive,
                    ).ask(context)),
          ),
          _Demo(
            'Acknowledge only',
            'A single button — no cancel.',
            () => _run(
                context,
                () => const ConfirmDialog(
                      title: 'Notifications are blocked',
                      message:
                          'Enable them from system settings to receive order updates.',
                      intent: ConfirmIntent.info,
                      showCancel: false,
                      confirmText: 'Open settings',
                    ).show(context)),
          ),
          _Demo(
            'Bottom sheet',
            'Same content, sheet surface.',
            () => _run(
                context,
                () => const ConfirmDialog(
                      title: 'Order placed',
                      message:
                          'We will notify you once the driver picks it up.',
                      intent: ConfirmIntent.success,
                      surface: ConfirmSurface.sheet,
                      showCancel: false,
                    ).show(context)),
          ),
          _Demo(
            'Custom icon, start aligned',
            'Any widget as the icon; Material-style alignment.',
            () => _run(
                context,
                () => const ConfirmDialog(
                      title: 'Leave the checkout?',
                      message: 'Items stay in your box for 24 hours.',
                      intent: ConfirmIntent.warning,
                      alignment: ConfirmAlignment.start,
                      iconBackground: false,
                      icon: Text('🧊', style: TextStyle(fontSize: 32)),
                      confirmText: 'Leave',
                      cancelText: 'Stay',
                    ).show(context)),
          ),
          _Demo(
            'No icon',
            'Text-only confirmation.',
            () => _run(
                context,
                () => const ConfirmDialog(
                      title: 'Switch to Arabic?',
                      showIcon: false,
                      confirmText: 'Switch',
                    ).show(context)),
          ),
          _Demo(
            'Async confirm',
            'Spinner in the button; dialog locked until the work settles.',
            () => _run(
                context,
                () => ConfirmDialog(
                      title: 'Cancel order #1042?',
                      message:
                          'The refund is issued to your original payment method.',
                      intent: ConfirmIntent.destructive,
                      dismissible: false,
                      confirmText: 'Cancel order',
                      cancelText: 'Keep it',
                      onConfirm: () =>
                          Future<void>.delayed(const Duration(seconds: 2)),
                    ).show(context)),
          ),
          _Demo(
            'Three-way choice',
            'Custom actions, custom result type, stacked layout.',
            () => _run(
              context,
              () => const ConfirmDialog<SaveChoice>(
                title: 'Unsaved changes',
                message: 'What should we do with your edits?',
                intent: ConfirmIntent.warning,
                actions: [
                  ConfirmAction(label: 'Save', result: SaveChoice.save),
                  ConfirmAction.destructive(
                      label: 'Discard',
                      result: SaveChoice.discard,
                      style: ConfirmActionStyle.tonal),
                  ConfirmAction.cancel(
                    label: 'Keep editing',
                    result: SaveChoice.keep,
                    style: ConfirmActionStyle.text,
                  ),
                ],
              ).show(context),
            ),
          ),
          _Demo(
            'Typed confirmation',
            'Custom content widget gating the confirm action.',
            () => _run(context, () => _askForTypedDelete(context)),
          ),
          const SizedBox(height: 24),
          Text('Embedded (bare surface)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ConfirmDialog(
              title: 'Enable location?',
              message: 'We use it to pick the nearest branch.',
              intent: ConfirmIntent.info,
              surface: ConfirmSurface.bare,
              confirmText: 'Enable',
              onConfirm: () => _report(context, 'enabled inline'),
              onCancel: () => _report(context, 'declined inline'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// A confirm button that only unlocks once the user types DELETE — shows
/// `content` + `ConfirmAction.enabled` working together.
Future<bool?> _askForTypedDelete(BuildContext context) {
  final typed = ValueNotifier<String>('');
  return showDialog<bool>(
    context: context,
    builder: (_) => ValueListenableBuilder<String>(
      valueListenable: typed,
      builder: (_, value, __) => ConfirmDialog<bool>(
        title: 'Delete workspace',
        message: 'Type DELETE to confirm. This cannot be undone.',
        intent: ConfirmIntent.destructive,
        content: TextField(
          autofocus: true,
          onChanged: (v) => typed.value = v,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'DELETE',
          ),
        ),
        actions: [
          const ConfirmAction.cancel(label: 'Cancel', result: false),
          ConfirmAction.destructive(
            label: 'Delete',
            result: true,
            enabled: value.trim() == 'DELETE',
          ),
        ],
      ),
    ),
  ).whenComplete(typed.dispose);
}

class _Demo extends StatelessWidget {
  const _Demo(this.title, this.subtitle, this.onTap);

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
