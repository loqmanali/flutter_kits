# showcase_kit

Coach-marks / product tour for Flutter. Wrap the widgets you want to explain,
list them as steps, and the kit dims the screen, cuts a hole over the current
target, pulses a ring around it and shows an info bubble with Skip / Prev /
Next.

## Highlights

- **One hook** — `useShowcaseTour(steps)` returns a controller with
  `start()` / `stop()`. The tour is tied to the calling widget: when it goes
  away, the overlay and the auto-play timer go with it.
- **No layout coupling** — `ShowcaseTarget` only attaches a `GlobalKey`; it
  adds no widget of its own, so it can wrap anything, anywhere.
- **Modal backdrop** — taps do not reach the app behind the spotlight, so the
  user cannot act on a screen that is still being explained.
- **Stays on screen** — the bubble flips above the target when there is no room
  below, and is clamped inside the safe area on every edge.
- **Auto-play** — optional, with a configurable delay per step.
- **Bring your own strings** — `TourLabels` takes the button copy, so a
  localised app passes its own translations.
- **Themed from the app** — the bubble uses the ambient `ColorScheme` and text
  theme; only the backdrop, cut-out radius/padding and ring colour are the
  kit's own (`TourTheme`).
- **Swappable UI** — the spotlight talks to the tour through
  `ISpotlightNavigator`, so a custom bubble can drive the same manager.

## Install

```yaml
dependencies:
  showcase_kit:
    git:
      url: https://github.com/loqmanali/flutter_kits.git
      path: showcase_kit
      ref: v1.2.0   # tag or commit SHA
```

```dart
import 'package:showcase_kit/showcase_kit.dart';
```

## Quick start

```dart
class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Keep the steps stable — the tour reads the list once.
    final steps = useMemoized(() => [
      ShowcaseStep(key: GlobalKey(), title: 'Search', body: 'Find an order'),
      ShowcaseStep(key: GlobalKey(), title: 'Cart', body: 'Review the basket'),
    ]);

    final tour = useShowcaseTour(
      steps,
      labels: TourLabels(
        skip: l10n.skip,
        previous: l10n.previous,
        next: l10n.next,
        done: l10n.done,
      ),
    );

    // Targets must be laid out before the first spotlight is measured.
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => tour.start());
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: ShowcaseTarget(
          showcaseKey: steps[0].key,
          child: const TextField(),
        ),
        actions: [
          ShowcaseTarget(
            showcaseKey: steps[1].key,
            child: IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
          ),
        ],
      ),
      body: const SizedBox(),
    );
  }
}
```

## API

```dart
ShowcaseController useShowcaseTour(
  List<ShowcaseStep> steps, {
  bool autoPlay = false,
  Duration autoPlayDelay = const Duration(seconds: 3),
  TourTheme theme = const TourTheme(),
  TourLabels labels = const TourLabels(),
})
```

| Type | What it is |
| --- | --- |
| `ShowcaseStep` | `key` (the one given to `ShowcaseTarget`) + `title` + `body`. |
| `ShowcaseTarget` | Wraps the widget to highlight and carries its key. |
| `ShowcaseController` | `start()`, `stop()`, `isRunning`. |
| `TourTheme` | `overlay`, `radius`, `padding`, `ring`. |
| `TourLabels` | `skip`, `previous`, `next`, `done`. |
| `TourConfig` | The three above, bundled — what `TourManager` takes. |
| `TourManager` | The tour itself. Use it directly only outside a hook widget, and call `dispose()`. |
| `ISpotlightNavigator` | `next` / `prev` / `skip` — the contract a custom spotlight UI drives. |

## Notes

- `start()` waits for the target to be laid out, retrying for up to 60 frames.
  A key that never mounts ends the tour instead of spinning forever.
- The ring animation repeats indefinitely, so `pumpAndSettle` never returns
  while a spotlight is on screen. In tests, pump fixed durations instead.
- `Prev` on the first step does nothing; `Next` on the last step ends the tour
  and its button reads `done`.
