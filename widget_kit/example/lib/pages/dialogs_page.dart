import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../gallery/demo_section.dart';
import '../gallery/gallery_scaffold.dart';

/// Documents dialogs (warning, picker), the sheet header, and UIHelper's
/// overlay helpers (bottom sheet, toast).
class DialogsPage extends StatelessWidget {
  const DialogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Dialogs & Toasts',
      intro:
          'Modal surfaces and transient messages. Toasts require a '
          'ToastificationWrapper above the app (this gallery provides one).',
      sections: [
        DemoGroup(
          label: 'Dialogs',
          children: [
            DemoSection(
              title: 'AppWarningDialog',
              description:
                  'A confirm/cancel dialog for destructive or important '
                  'actions, with a danger accent.',
              demo: Builder(
                builder: (context) => AppButton(
                  label: 'Show warning',
                  style: AppButtonStyleType.outlined,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AppWarningDialog(
                      title: 'Delete item?',
                      message: 'This action cannot be undone.',
                      buttonText: 'Delete',
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                ),
              ),
              code: '''
showDialog(
  context: context,
  builder: (_) => AppWarningDialog(
    title: 'Delete item?',
    message: 'This action cannot be undone.',
    buttonText: 'Delete',
    onPressed: _delete,
  ),
)''',
            ),
            DemoSection(
              title: 'DialogPicker',
              description:
                  'A rounded dialog container that hosts any child — a '
                  'list, a form, a custom picker.',
              demo: Builder(
                builder: (context) => AppButton(
                  label: 'Show picker dialog',
                  style: AppButtonStyleType.outlined,
                  onPressed: () => UIHelper.showDialogPicker<void>(
                    context,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Pick an option'),
                          const SizedBox(height: 12),
                          for (final o in ['One', 'Two', 'Three'])
                            ListTile(
                              title: Text(o),
                              onTap: () => Navigator.pop(context),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              code: '''
UIHelper.showDialogPicker(
  context,
  child: MyCustomPickerBody(),
)''',
            ),
          ],
        ),
        DemoGroup(
          label: 'Bottom sheet',
          children: [
            DemoSection(
              title: 'UIHelper.showBottomSheet + SheetHeader',
              description:
                  'A modal bottom sheet, topped with the standard '
                  'SheetHeader (title + close button).',
              demo: Builder(
                builder: (context) => AppButton(
                  label: 'Open sheet',
                  onPressed: () => UIHelper.showBottomSheet<void>(
                    context,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SheetHeader(
                          title: 'Settings',
                          onClose: () => Navigator.pop(context),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('Your sheet content goes here.'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              code: '''
UIHelper.showBottomSheet(
  context,
  child: Column(children: [
    SheetHeader(title: 'Settings', onClose: () => Navigator.pop(context)),
    // …body…
  ]),
)''',
            ),
          ],
        ),
        DemoGroup(
          label: 'Toasts',
          children: [
            DemoSection(
              title: 'UIHelper.showToast',
              description:
                  'Transient, non-blocking messages. Pick a type for '
                  'the colour (success / error / warning / info).',
              demo: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  AppButton(
                    label: 'Success',
                    size: AdaptiveButtonSize.small,
                    onPressed: () => UIHelper.showToast(
                      title: 'Saved!',
                      type: ToastificationType.success,
                    ),
                  ),
                  AppButton(
                    label: 'Error',
                    size: AdaptiveButtonSize.small,
                    style: AppButtonStyleType.outlined,
                    onPressed: () => UIHelper.showToast(
                      title: 'Something failed',
                      type: ToastificationType.error,
                    ),
                  ),
                  AppButton(
                    label: 'Info',
                    size: AdaptiveButtonSize.small,
                    style: AppButtonStyleType.text,
                    onPressed: () => UIHelper.showToast(
                      title: 'Heads up',
                      type: ToastificationType.info,
                    ),
                  ),
                ],
              ),
              code: '''
UIHelper.showToast(
  title: 'Saved!',
  type: ToastificationType.success,
);''',
            ),
          ],
        ),
      ],
    );
  }
}
