/// toast_kit
///
/// A project-agnostic toast/notification kit: queued, deduped, theme-able,
/// with an auto-dismiss timer that only ever starts once a toast has
/// actually painted — so one occluded by a native modal is never burned
/// unseen, and is never stuck either.
///
/// ```dart
/// final toastKey = GlobalKey<ToastHostState>();
///
/// MaterialApp(
///   builder: (context, child) => ToastHost(key: toastKey, child: child!),
///   home: const HomeScreen(),
/// );
///
/// ToastHost.of(context).show(
///   const ToastRequest(title: 'Saved', tone: ToastTone.success),
/// );
/// ```
///
/// Style it once for the whole app with a [ToastKitTheme] on `ThemeData`:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData.light().copyWith(
///     extensions: const [ToastKitTheme(defaultLayoutKey: 'filled')],
///   ),
/// );
/// ```
library;

export 'src/application/toast_controller.dart';
export 'src/application/toast_entry.dart';
export 'src/application/toast_handle.dart';
export 'src/application/toast_lifecycle_state.dart';
export 'src/domain/toast_action.dart';
export 'src/domain/toast_clock.dart';
export 'src/domain/toast_close_button_policy.dart';
export 'src/domain/toast_dismiss_reason.dart';
export 'src/domain/toast_placement.dart';
export 'src/domain/toast_policy.dart';
export 'src/domain/toast_request.dart';
export 'src/domain/toast_tone.dart';
export 'src/presentation/layouts/banner_toast_layout.dart';
export 'src/presentation/layouts/filled_toast_layout.dart';
export 'src/presentation/layouts/flat_toast_layout.dart';
export 'src/presentation/layouts/minimal_toast_layout.dart';
export 'src/presentation/layouts/outlined_toast_layout.dart';
export 'src/presentation/toast_card.dart';
export 'src/presentation/toast_host.dart';
export 'src/presentation/toast_item_widget.dart';
export 'src/presentation/toast_kit_theme.dart';
export 'src/presentation/toast_layout.dart';
export 'src/presentation/toast_strings.dart';
