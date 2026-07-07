# Animation Kit

A comprehensive Flutter animation package that provides reusable animation widgets, providers, and utilities for building smooth, performant animations in your Flutter applications.

## Features

- **Pre-built Animation Widgets**: Ready-to-use widgets for common animations like fade, slide, scale, rotation, and more
- **Animation Providers**: Riverpod-based state management for animations
- **Staggered Animations**: Built-in support for list and grid staggered animations
- **Micro-animations**: Small, delightful animations for buttons, cards, and other UI elements
- **Burger-specific Animations**: Custom animations designed for Burger Republic app
- **Gesture Animations**: Animations triggered by user gestures (tap, swipe, drag)
- **Lottie Integration**: Support for Lottie animations
- **Custom Animation Builder**: Create complex multi-step animation sequences
- **Animation Configuration**: Global configuration for consistent animation behavior
- **Animation Persistence**: Save and restore animation state across app restarts

## Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  animation_kit:
    path: lib/packages/animation_kit
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize Animation Kit

```dart
import 'package:animation_kit/animation_kit.dart';

void main() {
  // Initialize animation configuration
  AnimationConfig.initialize(
    defaultDuration: Duration(milliseconds: 300),
    defaultCurve: AnimationCurve.easeInOut,
    animationsEnabled: true,
  );

  runApp(MyApp());
}
```

### 2. Use Pre-built Animation Widgets

```dart
// Fade animation
FadeTransitionWidget(
  config: AnimationConfig.fade(
    duration: Duration(milliseconds: 300),
  ),
  child: YourWidget(),
)

// Slide animation
SlideTransitionWidget(
  config: TransitionConfig.slide(
    type: TransitionType.slideRight,
    duration: Duration(milliseconds: 300),
  ),
  child: YourWidget(),
)

// Scale animation
ScaleTransitionWidget(
  config: AnimationConfig.scale(
    duration: Duration(milliseconds: 300),
  ),
  child: YourWidget(),
)
```

### 3. Use Micro-animations

```dart
// Pulse animation
PulseWidget(
  config: AnimationConfig.pulse(
    duration: Duration(seconds: 1),
    repeat: true,
  ),
  child: YourWidget(),
)

// Shake animation
ShakeWidget(
  config: AnimationConfig.shake(),
  child: YourWidget(),
)

// Heartbeat animation
HeartbeatWidget(
  config: AnimationConfig.heartbeat(),
  child: YourWidget(),
)
```

### 4. Use Staggered Animations

```dart
// Staggered list view
StaggeredListView(
  staggerConfig: StaggerConfig.forward(
    delay: Duration(milliseconds: 50),
    duration: Duration(milliseconds: 300),
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)

// Staggered grid view
StaggeredGridView(
  staggerConfig: StaggerConfig.fromCenter(),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(child: Text(items[index]));
  },
)
```

### 5. Use Animation Providers

```dart
// Watch animation state
final animationState = ref.watch(animationProvider(
  key: AnimationKey('my_animation'),
));

// Play animation
ref.read(animationProvider.notifier).playAnimation(
  AnimationConfig.fade(),
);

// Stop animation
ref.read(animationProvider.notifier).stopAnimation(
  AnimationKey('my_animation'),
);
```

## Architecture

Animation Kit follows a clean architecture with clear separation of concerns:

```
animation_kit/
├── core/               # Core enums, models, exceptions
├── data/               # Data sources and repositories
├── domain/              # Use cases and business logic
├── presentation/         # Widgets and providers
├── config/              # Global configuration
└── examples/            # Example implementations
```

### Core Layer

- **Enums**: Animation types, curves, states, transitions, stagger directions
- **Models**: Animation config, transition config, sequence, step, key
- **Exceptions**: Animation exception handling

### Data Layer

- **Datasources**: Local storage for animation state
- **Repositories**: Data access abstraction

### Domain Layer

- **Use Cases**: Business logic for animation operations
  - Play animation
  - Stop animation
  - Pause animation
  - Reset animation
  - Create sequence

### Presentation Layer

- **Widgets**: Reusable animation widgets
  - Transitions: Fade, slide, scale, rotation
  - Micro-animations: Pulse, shake, bounce, heartbeat
  - Staggered: List view, grid view
  - Burger-specific: Custom animations for Burger Republic
  - Gesture: Tap, swipe, drag
  - Lottie: Lottie animation support

- **Providers**: Riverpod state management
  - Animation provider
  - Animation sequence provider
  - Animation config provider

### Config Layer

- **AnimationConfig**: Global animation settings
- **TransitionConfig**: Global transition settings

## Animation Types

| Type        | Description                      |
| ----------- | -------------------------------- |
| `fade`      | Fade in/out animation            |
| `slide`     | Slide animation in any direction |
| `scale`     | Scale up/down animation          |
| `rotation`  | Rotate animation                 |
| `pulse`     | Pulsing animation (repeating)    |
| `shake`     | Shake animation                  |
| `bounce`    | Bounce animation                 |
| `heartbeat` | Heartbeat animation (repeating)  |

## Animation Curves

| Curve          | Description        |
| -------------- | ------------------ |
| `linear`       | Linear easing      |
| `easeIn`       | Ease in            |
| `easeOut`      | Ease out           |
| `easeInOut`    | Ease in and out    |
| `bounceIn`     | Bounce in          |
| `bounceOut`    | Bounce out         |
| `bounceInOut`  | Bounce in and out  |
| `elasticIn`    | Elastic in         |
| `elasticOut`   | Elastic out        |
| `elasticInOut` | Elastic in and out |

## Stagger Directions

| Direction    | Description                       |
| ------------ | --------------------------------- |
| `forward`    | Animate items from first to last  |
| `reverse`    | Animate items from last to first  |
| `fromCenter` | Animate items from center outward |

## Burger-specific Animations

Animation Kit includes custom animations designed specifically for the Burger Republic app:

- **Burger Stack Animation**: Stack burger ingredients with animation
- **Ingredient Drop Animation**: Drop ingredients with physics-based animation
- **Delivery Ride Animation**: Animate delivery vehicle movement
- **Order Confetti**: Celebrate order completion with confetti

## Examples

See the `examples/` directory for complete examples:

- `basic_animations.dart`: Basic animation usage
- `staggered_lists.dart`: Staggered list and grid examples
- `burger_animations.dart`: Burger-specific animations
- `gesture_animations.dart`: Gesture-triggered animations
- `animation_sequences.dart`: Multi-step animation sequences

## Configuration

### Global Animation Settings

```dart
AnimationConfig.initialize(
  defaultDuration: Duration(milliseconds: 300),
  defaultCurve: AnimationCurve.easeInOut,
  defaultAutoPlay: true,
  animationsEnabled: true,
);

// Update settings at runtime
AnimationConfig.instance.updateDefaultDuration(Duration(milliseconds: 500));
AnimationConfig.instance.setAnimationsEnabled(false);
```

### Global Transition Settings

```dart
TransitionConfig.initialize(
  defaultDuration: Duration(milliseconds: 300),
  defaultCurve: AnimationCurve.easeInOut,
  defaultType: TransitionType.fadeIn,
  transitionsEnabled: true,
);

// Update settings at runtime
TransitionConfig.instance.updateDefaultType(TransitionType.slideRight);
```

## Best Practices

1. **Use appropriate durations**: Keep animations between 200-500ms for optimal UX
2. **Choose the right curve**: Use `easeInOut` for general animations, `bounceOut` for playful effects
3. **Disable animations for accessibility**: Respect user's reduced motion preferences
4. **Use staggered animations for lists**: Makes list transitions feel more natural
5. **Combine animations**: Use animation sequences for complex effects
6. **Test on lower-end devices**: Ensure animations perform well on all devices

## Performance Tips

1. **Avoid complex animations in scrollable lists**: Use simple animations or staggered lists instead
2. **Use `RepaintBoundary`**: Wrap animated widgets to limit repaints
3. **Cache animation controllers**: Reuse controllers when possible
4. **Disable animations when not visible**: Pause animations when widget is off-screen
5. **Use `AnimatedBuilder`**: For custom animations, prefer `AnimatedBuilder` over rebuilding

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Follow the existing code style
2. Add documentation to all public APIs
3. Include examples for new widgets
4. Write tests for new features
5. Update this README for significant changes

## License

This package is part of the Burger Republic project.

## Support

For issues, questions, or suggestions, please contact the development team.
