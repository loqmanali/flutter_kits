// template: confirm-dialog
// description: A yes/no confirmation sheet for destructive actions.
// kits: widget_kit
// output: lib/widgets/confirm.dart
import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

/// Asks the user to confirm a destructive action.
///
/// Returns true only if they explicitly confirmed — dismissing the dialog by
/// tapping outside or pressing back resolves to false, never null, so callers
/// can treat the result as a plain bool.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Delete',
  String cancelText = 'Cancel',
  Color? dangerColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AppWarningDialog(
      title: title,
      message: message,
      buttonText: confirmText,
      cancelText: cancelText,
      dangerColor: dangerColor,
      onPressed: () => Navigator.of(dialogContext).pop(true),
    ),
  );

  return result ?? false;
}

/// Example call site — delete the file after copying the function above.
class DeleteAccountTile extends StatelessWidget {
  const DeleteAccountTile({super.key, required this.onConfirmed});

  final Future<void> Function() onConfirmed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_outline_rounded),
      title: const Text('Delete account'),
      onTap: () async {
        final confirmed = await confirmAction(
          context,
          title: 'Delete account?',
          message: 'This permanently removes your data. It cannot be undone.',
        );
        if (!confirmed) return;

        await onConfirmed();
        // `context` may be gone after the await, so guard before using it.
        if (context.mounted) {
          UIHelper.showSnackBar(context, message: 'Account deleted');
        }
      },
    );
  }
}
