# Animation Kit Architecture

This document describes the architecture of Animation Kit, a Flutter animation package designed for reusable, performant animations.

## Overview

Animation Kit follows Clean Architecture principles with clear separation between data, domain, and presentation layers. The package is designed to be modular, testable, and maintainable.

## Directory Structure

```
animation_kit/
├── core/                          # Core layer - enums, models, exceptions
│   ├── enums/                   # Animation-related enums
│   │   ├── animation_curve.dart
│   │   ├── animation_state.dart
│   │   ├── animation_type.dart
│   │   ├── stagger_direction.dart
│   │   └── transition_type.dart
│   ├── models/                   # Data models
│   │   ├── animation_config.dart
│   │   ├── animation_key.dart
│   │   ├── animation_sequence.dart
│   │   ├── animation_step.dart
│   │   ├── stagger_config.dart
│   │   └── transition_config.dart
│   ├── exceptions/               # Exception handling
│   │   └── animation_exception.dart
│   ├── controllers/              # Animation controllers
│   │   ├── animation_controller_factory.dart
│   │   └── custom_animation_controller.dart
│   └── mixins/                   # Core mixins
│       └── animated_mixin.dart
├── data/                          # Data layer - persistence
│   ├── datasources/             # Data sources
│   │   └── animation_local_datasource.dart
│   └── repositories/             # Repository implementations
│       └── animation_repository_impl.dart
├── domain/                         # Domain layer - business logic
│   ├── repositories/             # Repository interfaces
│   │   └── animation_repository.dart
│   └── usecases/                 # Business logic
│       ├── play_animation_usecase.dart
│       ├── stop_animation_usecase.dart
│       ├── pause_animation_usecase.dart
│       ├── reset_animation_usecase.dart
│       └── create_sequence_usecase.dart
├── presentation/                   # Presentation layer - UI
│   ├── widgets/                  # Reusable widgets
│   │   ├── transitions/          # Transition widgets
│   │   │   ├── fade_transition_widget.dart
│   │   │   ├── slide_transition_widget.dart
│   │   │   ├── scale_transition_widget.dart
│   │   │   ├── rotation_transition_widget.dart
│   │   │   └── custom_page_transition.dart
│   │   ├── micro_animations/     # Small, delightful animations
│   │   │   ├── pulse_widget.dart
│   │   │   ├── shake_widget.dart
│   │   │   ├── bounce_widget.dart
│   │   │   └── heartbeat_widget.dart
│   │   ├── stagger/              # Staggered list/grid widgets
│   │   │   ├── staggered_fade_in.dart
│   │   │   ├── staggered_list_view.dart
│   │   │   └── staggered_grid_view.dart
│   │   ├── burger_specific/      # Burger Republic animations
│   │   │   ├── burger_stack_animation.dart
│   │   │   ├── ingredient_drop_animation.dart
│   │   │   ├── delivery_ride_animation.dart
│   │   │   └── order_confetti.dart
│   │   ├── gesture/              # Gesture-triggered animations
│   │   │   ├── tap_animation.dart
│   │   │   ├── swipe_animation.dart
│   │   │   └── drag_animation.dart
│   │   └── lottie/               # Lottie integration
│   │       ├── lottie_animation_widget.dart
│   │       └── lottie_controller.dart
│   ├── providers/                # Riverpod providers
│   │   ├── animation_provider.dart
│   │   ├── animation_sequence_provider.dart
│   │   └── animation_config_provider.dart
│   └── mixins/                   # Presentation mixins
│       └── animation_mixin.dart
├── config/                         # Global configuration
│   ├── animation_config.dart
│   └── transition_config.dart
├── examples/                        # Example implementations
│   ├── basic_animations.dart
│   ├── staggered_lists.dart
│   ├── burger_animations.dart
│   ├── gesture_animations.dart
│   └── animation_sequences.dart
├── test/                           # Tests
│   ├── unit/
│   ├── widget/
│   └── integration/
└── animation_kit.dart              # Public API
```

## Layer Descriptions

### Core Layer

The core layer contains fundamental types and utilities used throughout the package.

#### Enums

- **AnimationCurve**: Easing curves for animations (linear, ease, bounce, elastic, etc.)
- **AnimationState**: States an animation can be in (idle, playing, paused, completed, dismissed)
- **AnimationType**: Types of animations (fade, slide, scale, rotation, pulse, shake, bounce, heartbeat)
- **StaggerDirection**: Directions for staggered animations (forward, reverse, fromCenter)
- **TransitionType**: Types of transitions (fadeIn, fadeOut, slideUp, slideDown, slideLeft, slideRight, scaleIn, scaleOut, rotateIn, rotateOut)

#### Models

- **AnimationConfig**: Configuration for single animations (duration, curve, type, repeat, callbacks)
- **AnimationKey**: Unique identifier for animation instances
- **AnimationSequence**: Sequence of animation steps
- **AnimationStep**: Single step in an animation sequence
- **StaggerConfig**: Configuration for staggered animations (direction, delay, duration, curve)
- **TransitionConfig**: Configuration for transition animations

#### Exceptions

- **AnimationException**: Base exception with error types (startFailed, stopFailed, pauseFailed, resetFailed, invalidConfig, animationNotFound, controllerError)

#### Controllers

- **AnimationControllerFactory**: Factory for creating animation controllers
- **CustomAnimationController**: Custom animation controller with additional features

#### Mixins

- **AnimatedMixin**: Mixin providing animation functionality to widgets

### Data Layer

The data layer handles persistence of animation state.

#### Datasources

- **AnimationLocalDatasource**: Local storage using SharedPreferences for animation state persistence

#### Repositories

- **AnimationRepositoryImpl**: Implementation of animation repository using local datasource

### Domain Layer

The domain layer contains business logic and use cases.

#### Repositories

- **AnimationRepository**: Interface defining animation data operations

#### Use Cases

- **PlayAnimationUseCase**: Business logic for starting animations
- **StopAnimationUseCase**: Business logic for stopping animations
- **PauseAnimationUseCase**: Business logic for pausing animations
- **ResetAnimationUseCase**: Business logic for resetting animations
- **CreateSequenceUseCase**: Business logic for creating animation sequences

### Presentation Layer

The presentation layer contains widgets and providers for UI.

#### Widgets

**Transitions:**

- **FadeTransitionWidget**: Fade in/out transition
- **SlideTransitionWidget**: Slide transition
- **ScaleTransitionWidget**: Scale transition
- **RotationTransitionWidget**: Rotation transition
- **CustomPageTransition**: Custom page route transition

**Micro-animations:**

- **PulseWidget**: Pulsing animation
- **ShakeWidget**: Shake animation
- **BounceWidget**: Bounce animation
- **HeartbeatWidget**: Heartbeat animation

**Staggered:**

- **StaggeredFadeIn**: Staggered fade-in widget
- **StaggeredListView**: List view with staggered animations
- **StaggeredGridView**: Grid view with staggered animations

**Burger-specific:**

- **BurgerStackAnimation**: Stack burger ingredients with animation
- **IngredientDropAnimation**: Drop ingredients with physics
- **DeliveryRideAnimation**: Animate delivery vehicle
- **OrderConfetti**: Celebrate order completion

**Gesture:**

- **TapAnimation**: Animation triggered by tap
- **SwipeAnimation**: Animation triggered by swipe
- **DragAnimation**: Animation triggered by drag

**Lottie:**

- **LottieAnimationWidget**: Lottie animation widget
- **LottieController**: Controller for Lottie animations

#### Providers

- **AnimationProvider**: Riverpod provider for animation state
- **AnimationSequenceProvider**: Riverpod provider for animation sequences
- **AnimationConfigProvider**: Riverpod provider for animation configuration

#### Mixins

- **AnimationMixin**: Mixin providing animation functionality to presentation layer

### Config Layer

The config layer provides global configuration for animations.

- **AnimationConfig**: Global animation settings (duration, curve, auto-play, enabled)
- **TransitionConfig**: Global transition settings (duration, curve, type, auto-play, enabled)

## Data Flow

```
┌─────────────┐
│   Widget    │
└──────┬──────┘
       │
       ▼
┌──────────────┐
│   Provider   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Use Case   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Repository   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Datasource │
└─────────────┘
```

## Key Design Patterns

### 1. Clean Architecture

- Separation of concerns between data, domain, and presentation layers
- Dependency inversion: domain layer depends on abstractions, not implementations
- Single responsibility: each class has one clear purpose

### 2. Repository Pattern

- Abstracts data access behind repository interfaces
- Allows easy switching of data sources
- Centralizes data access logic

### 3. Use Case Pattern

- Encapsulates business logic in use case classes
- Provides clear API for animation operations
- Makes testing easier

### 4. Provider Pattern (Riverpod)

- Manages animation state using Riverpod providers
- Enables reactive UI updates
- Simplifies state management

### 5. Factory Pattern

- **AnimationControllerFactory**: Creates appropriate animation controllers
- Centralizes controller creation logic
- Enables easy extension with new controller types

### 6. Configuration Pattern

- Singleton configuration classes
- Global settings for consistent behavior
- Runtime configuration updates

## Testing Strategy

### Unit Tests

- Test use cases with mocked repositories
- Test models and enums
- Test configuration logic

### Widget Tests

- Test animation widgets with golden tests
- Test provider state changes
- Test user interactions

### Integration Tests

- Test full animation flows
- Test persistence across app restarts
- Test complex animation sequences

## Performance Considerations

1. **Animation Duration**: Keep animations between 200-500ms for optimal UX
2. **Repaint Boundaries**: Use to limit repaints during animations
3. **Controller Caching**: Reuse controllers when possible
4. **Off-screen Animations**: Pause animations when widget is off-screen
5. **AnimatedBuilder**: Prefer over rebuilding for custom animations

## Future Enhancements

- [ ] Add more animation types (spring, physics-based)
- [ ] Support for Rive animations
- [ ] Animation timeline editor
- [ ] Animation presets and templates
- [ ] Performance monitoring tools
- [ ] Animation debugging tools
- [ ] More gesture-based animations
- [ ] 3D animation support
