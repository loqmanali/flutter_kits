## 1.1.3

* Fix: auto-scroll no longer freezes after the user swipes or taps the
  carousel. The pan recognizer now handles `onPanCancel` (fired when the inner
  PageView wins the horizontal drag) and clears the drag state, so the
  auto-scroll timer keeps advancing. Previously `isDragging` got stuck true and
  `pauseOnInteraction: false` could not work around it.

## 1.0.0

* Initial release as a standalone, project-agnostic package extracted from
  `lib/core/carousel_module`. No source-level changes versus the original
  module — just packaged for reuse.
* Single dependency: `flutter_riverpod`. No host-app coupling.
