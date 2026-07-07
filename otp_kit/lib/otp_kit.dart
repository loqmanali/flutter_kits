/// otp_kit — a comprehensive, high-performance OTP input solution for Flutter.
///
/// Provides an OTP input system with hand-written Riverpod state management,
/// validation, theming, animations, RTL support, paste handling, and a
/// resend-cooldown timer.
///
/// ```dart
/// import 'package:otp_kit/otp_kit.dart';
///
/// OTPTextField(
///   config: OTPTheme.defaultLight(context),
///   onCompleted: (otp) => print('OTP entered: $otp'),
/// );
/// ```
library;

// Models
export 'src/models/otp_models.dart';
export 'src/models/resend_state.dart';
// Providers
export 'src/providers/otp_controller.dart';
export 'src/providers/resend_cooldown_notifier.dart';
// Services
export 'src/services/resend_cooldown_service.dart';
// Theme
export 'src/theme/otp_theme.dart';
// Utils
export 'src/utils/otp_utils.dart';
// Validators
export 'src/validators/otp_validator.dart';
// Widgets
export 'src/widgets/widgets.dart';
