# Changelog

## 0.1.0

- Initial release: `ToastHost`, `ToastController`, `ToastKitTheme`, five
  built-in layouts (`flat`, `filled`, `outlined`, `minimal`, `banner`).
- The auto-dismiss timer starts only once a toast has actually painted
  (`ToastController.markShown`, reported from a post-frame callback), so a
  toast occluded before its first frame is never dismissed early nor left
  stuck.
- Dedupe window, per-placement queueing, pause/resume on press-and-hold,
  swipe/tap/close/action dismissal, sticky toasts.
- RTL by construction, accessible navigation and reduced-motion support.
- Debug/profile-only DevTools service extensions
  (`ext.toast_kit.show`/`dismissAll`/`state`) and `dart:developer` lifecycle
  logging.
- `@Preview` gallery for every layout × tone plus RTL, dark, large-text and
  stacked-toast cases.
