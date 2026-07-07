/// Animation Kit
///
/// A comprehensive animation package for Flutter applications.
/// This package provides reusable animation widgets, state management,
/// and utilities for common animation patterns.
///
/// ## Features
///
/// - **Transition Widgets**: Slide, fade, scale, rotation transitions
/// - **Micro Animations**: Pulse, shake, bounce, heartbeat effects
/// - **Lottie Integration**: Lottie animation widget with controller
/// - **Gesture Animations**: Swipe, drag, tap animations
/// - **Stagger Animations**: Staggered list/grid views
/// - **Burger Specific**: Burger stack, ingredient drop, confetti, delivery ride
/// - **Animation Sequences**: Multi-step animations
/// - **State Management**: Riverpod providers for animation state
/// - **Clean Architecture**: Following clean architecture patterns
///
/// ## Quick Start
///
/// ```dart
/// import 'package:animation_kit/animation_kit.dart';
///
/// // Basic fade transition
/// FadeTransitionWidget(
///   child: YourWidget(),
///   duration: Duration(milliseconds: 300),
///   curve: Curves.easeInOut,
/// )
///
/// // Pulse animation
/// PulseWidget(
///   child: Icon(Icons.favorite),
///   duration: Duration(seconds: 1),
/// )
/// ```
///
/// ## Documentation
///
/// See [README.md] for detailed documentation and examples.
/// See [ARCHITECTURE.md] for architecture details.

library;

// Config exports
export 'config/animation_config.dart';
export 'config/transition_config.dart' hide TransitionConfig;
// Core exports - enums
export 'core/enums/animation_curve.dart';
export 'core/enums/animation_state.dart';
export 'core/enums/animation_type.dart';
export 'core/enums/stagger_direction.dart';
export 'core/enums/transition_type.dart';
// Core exports - exceptions
export 'core/exceptions/animation_exception.dart';
// Core exports - models
export 'core/models/animation_config.dart';
export 'core/models/animation_key.dart';
export 'core/models/animation_sequence.dart';
export 'core/models/animation_step.dart';
export 'core/models/stagger_config.dart';
export 'core/models/transition_config.dart';
// Domain exports
export 'domain/repositories/animation_repository.dart';
export 'domain/usecases/pause_animation_usecase.dart';
export 'domain/usecases/play_animation_usecase.dart';
export 'domain/usecases/reset_animation_usecase.dart';
export 'domain/usecases/stop_animation_usecase.dart';
// Presentation mixins
export 'presentation/mixins/animation_mixin.dart';
// Burger specific
export 'presentation/widgets/burger_specific/burger_stack_animation.dart';
export 'presentation/widgets/burger_specific/delivery_ride_animation.dart';
export 'presentation/widgets/burger_specific/ingredient_drop_animation.dart';
export 'presentation/widgets/burger_specific/order_confetti.dart';
// Gesture animations
export 'presentation/widgets/gesture/drag_animation.dart';
export 'presentation/widgets/gesture/swipe_animation.dart';
export 'presentation/widgets/gesture/tap_animation.dart';
// Lottie
export 'presentation/widgets/lottie/lottie_animation_widget.dart';
export 'presentation/widgets/lottie/lottie_controller.dart';
// Micro animations
export 'presentation/widgets/micro_animations/bounce_widget.dart';
export 'presentation/widgets/micro_animations/heartbeat_widget.dart';
export 'presentation/widgets/micro_animations/pulse_widget.dart';
export 'presentation/widgets/micro_animations/shake_widget.dart';
// Stagger animations
export 'presentation/widgets/stagger/staggered_fade_in.dart';
export 'presentation/widgets/stagger/staggered_grid_view.dart';
export 'presentation/widgets/stagger/staggered_list_view.dart';
// Transition widgets
export 'presentation/widgets/transitions/custom_page_transition.dart';
export 'presentation/widgets/transitions/fade_transition_widget.dart';
export 'presentation/widgets/transitions/rotation_transition_widget.dart';
export 'presentation/widgets/transitions/scale_transition_widget.dart';
export 'presentation/widgets/transitions/slide_transition_widget.dart';
