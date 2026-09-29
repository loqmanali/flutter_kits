/// confirm_kit
///
/// One confirmation widget for every "are you sure?" in an app: destructive
/// deletes, permission prompts, multi-way choices, async actions that must
/// finish before the dialog closes.
///
/// ```dart
/// final ok = await const ConfirmDialog(
///   title: 'Delete account?',
///   message: 'Your orders and addresses are removed permanently.',
///   intent: ConfirmIntent.destructive,
/// ).ask(context);
/// ```
///
/// Style it once for the whole app with a [ConfirmKitTheme] on `ThemeData`:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData.light().copyWith(
///     extensions: const [
///       ConfirmKitTheme(borderRadius: 20, actionBorderRadius: 12),
///     ],
///   ),
/// );
/// ```
library;

export 'src/confirm_action.dart';
export 'src/confirm_action_button.dart';
export 'src/confirm_dialog.dart';
export 'src/confirm_enums.dart';
export 'src/confirm_kit_theme.dart';
export 'src/confirm_strings.dart';
export 'src/show_confirm.dart';
