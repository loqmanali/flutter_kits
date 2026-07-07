import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/otp_models.dart';
import '../providers/otp_controller.dart';
import '../validators/otp_validator.dart';

/// Cell-styled OTP input backed by a **single** hidden text field.
///
/// Earlier versions used one `TextField` per cell and choreographed focus
/// between them. That architecture is unreliable on mobile soft keyboards:
/// backspace on an empty field emits no event, programmatic focus hops can
/// flicker or dismiss the keyboard, and paste needs manual distribution.
/// One real field with painted cells eliminates the whole class of bugs:
///
///  - typing appends — the active cell is simply `value.length`, so input is
///    always sequential (you can never type into a later box first),
///  - backspace deletes the last digit natively — the active cell walks back,
///  - paste / SMS autofill arrive as one string and fill the cells directly.
///
/// The provider (`otpControllerProvider(config)`) remains the source of
/// truth, so external control still works: `notifier.clear()`,
/// `notifier.setValue(...)` and `notifier.setError(...)` all reflect into the
/// cells (an error also plays the shake animation).
///
/// ```dart
/// OTPTextField(
///   config: OTPConfig(length: 6),
///   onCompleted: (code) => verify(code),
/// )
/// ```
class OTPTextField extends ConsumerStatefulWidget {
  const OTPTextField({
    super.key,
    required this.config,
    this.onCompleted,
    this.onChanged,
    this.customValidationRules,
  });

  final OTPConfig config;

  /// Fired once when the last digit is entered (deduped when
  /// [OTPConfig.dedupeCompletion] is set). Not fired if a rule in
  /// [customValidationRules] rejects the value — that surfaces as the error
  /// state instead.
  final void Function(String)? onCompleted;

  final void Function(String)? onChanged;

  /// Optional rules checked when the code reaches full length. A failing rule
  /// sets the error state (shake + error border) instead of completing.
  final List<OTPValidationRule>? customValidationRules;

  @override
  ConsumerState<OTPTextField> createState() => _OTPTextFieldState();
}

class _OTPTextFieldState extends ConsumerState<OTPTextField>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode;

  AnimationController? _pulseController;
  AnimationController? _shakeController;
  AnimationController? _caretController;

  /// Cell currently playing the digit-entry pulse.
  int _pulsedIndex = -1;

  /// Last value forwarded via `onCompleted`. Only used when
  /// `config.dedupeCompletion == true`; reset when the field is cleared.
  String? _lastCompletedValue;

  OTPConfig get _config => widget.config;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'OTPField')
      ..addListener(_onFocusChanged);

    if (_config.enableAnimations) {
      _pulseController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _config.animationDuration),
      )..addListener(_repaint);
      _shakeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      )..addListener(_repaint);
    }
    if (_config.showCursor) {
      _caretController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true);
    }

    // The hidden field always starts empty. The provider is family-keyed by
    // config and can outlive a previous mount that used an equal config (route
    // transitions, hot reload, an external listener holding it alive). If we
    // let stale digits sit in the field, the next keystroke appends to them and
    // can instantly "complete" a bogus code — the "invalid after one digit"
    // bug. Clearing the controller in initState is safe (it's not a provider);
    // the provider itself is reset post-frame, where modifying it is allowed.
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(otpControllerProvider(_config));
      if (state.value.isNotEmpty || state.hasError) {
        ref.read(otpControllerProvider(_config).notifier).clear();
      }
      if (_config.autoFocus) _focusField();
    });
  }

  void _repaint() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    _pulseController?.dispose();
    _shakeController?.dispose();
    _caretController?.dispose();
    super.dispose();
  }

  /// The cell that receives the next digit.
  int get _activeIndex => math.min(_controller.text.length, _config.length - 1);

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {});
    ref
        .read(otpControllerProvider(_config).notifier)
        .setFocused(_focusNode.hasFocus, _activeIndex);
  }

  void _focusField() {
    if (_focusNode.hasFocus) {
      // Focus is still ours but the user dismissed the keyboard (iOS swipe
      // down) — requestFocus would be a no-op, so re-summon it explicitly.
      SystemChannels.textInput.invokeMethod('TextInput.show');
    } else {
      _focusNode.requestFocus();
    }
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  void _onTextChanged(String raw) {
    // The formatters already restrict charset and length; sanitize
    // defensively (IME edge cases) and keep the caret pinned to the end.
    var value = OTPValidator.sanitize(raw, _config.inputType);
    if (value.length > _config.length) {
      value = value.substring(0, _config.length);
    }
    if (value != raw) {
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    final previous = ref.read(otpControllerProvider(_config)).value;
    ref.read(otpControllerProvider(_config).notifier).syncValue(value);

    if (value.length > previous.length) {
      if (_config.enableHapticFeedback) HapticFeedback.lightImpact();
      _pulse(value.length - 1);
    }

    // Completion is driven from here — real user input — not from the state
    // listener. Firing on the listener risks auto-submitting a value that the
    // user didn't just type (e.g. leftover state on mount), which is exactly
    // the "invalid code after one digit" bug.
    if (value.length == _config.length) {
      _handleCompletion(value);
    } else if (value.isEmpty) {
      // Fully cleared → re-arm completion for the same code (see dedupe).
      _lastCompletedValue = null;
    }
    setState(() {});
  }

  void _pulse(int index) {
    final controller = _pulseController;
    if (controller == null) return;
    _pulsedIndex = index;
    controller.forward(from: 0);
  }

  Future<void> _paste() =>
      ref.read(otpControllerProvider(_config).notifier).handlePaste();

  /// Reflects state that changed *outside* the hidden field — programmatic
  /// `setValue`/`clear`/`setError` and `handlePaste` — back into the cells.
  ///
  /// Typing already updates everything synchronously in [_onTextChanged];
  /// when the state and controller are already in sync (the common case) this
  /// does nothing. Completion is only fired here for an *external* fill, so a
  /// keystroke can't double-fire it.
  void _handleStateChange(OTPState? previous, OTPState next) {
    final external = next.value != _controller.text;

    if (external) {
      _controller.value = TextEditingValue(
        text: next.value,
        selection: TextSelection.collapsed(offset: next.value.length),
      );
      _repaint();
    }

    if (previous?.value != next.value) {
      widget.onChanged?.call(next.value);
      if (next.value.isEmpty) _lastCompletedValue = null;
    }

    if (next.hasError && previous?.hasError != true) {
      _shakeController?.forward(from: 0);
    }

    // Only an external fill (paste / setValue) completes here; typed input
    // completes in [_onTextChanged].
    if (external && next.isComplete && previous?.isComplete != true) {
      _handleCompletion(next.value);
    }
  }

  void _handleCompletion(String value) {
    final rules = widget.customValidationRules;
    if (rules != null && rules.isNotEmpty) {
      final error = OTPValidator.validate(value, _config, customRules: rules);
      if (error != null) {
        ref.read(otpControllerProvider(_config).notifier).setError(error);
        return;
      }
    }

    if (_config.dedupeCompletion) {
      if (_lastCompletedValue == value) return;
      _lastCompletedValue = value;
    }
    if (_config.autoDismissKeyboard) _focusNode.unfocus();
    widget.onCompleted?.call(value);
  }

  List<TextInputFormatter> get _formatters => [
    switch (_config.inputType) {
      OTPInputType.numeric => FilteringTextInputFormatter.digitsOnly,
      OTPInputType.alphabetic => FilteringTextInputFormatter.allow(
        RegExp('[a-zA-Z]'),
      ),
      OTPInputType.alphanumeric => FilteringTextInputFormatter.allow(
        RegExp('[a-zA-Z0-9]'),
      ),
      OTPInputType.any => FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
    },
    LengthLimitingTextInputFormatter(_config.length),
  ];

  /// Horizontal wiggle for the error shake; returns to 0 at both ends so the
  /// row never rests off-center.
  double get _shakeDx {
    final controller = _shakeController;
    if (controller == null) return 0;
    final t = controller.value;
    if (t == 0 || t == 1) return 0;
    return math.sin(t * math.pi * 3) * 6 * (1 - t);
  }

  double _pulseScale(int index) {
    final controller = _pulseController;
    if (controller == null || index != _pulsedIndex) return 1;
    return 1 + 0.08 * math.sin(math.pi * controller.value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpControllerProvider(_config));
    ref.listen<OTPState>(otpControllerProvider(_config), _handleStateChange);

    return Semantics(
      textField: true,
      label: 'One-time code',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _focusField,
        onLongPress: _config.enablePaste ? _paste : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(_shakeDx, 0),
              child: Directionality(
                textDirection: _config.isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalSpacing =
                        _config.spacing * (_config.length - 1);
                    final totalPadding =
                        _config.fieldPadding.horizontal * _config.length;
                    final available =
                        constraints.maxWidth - totalSpacing - totalPadding;
                    final fieldSize = math.max(
                      20.0,
                      math.min(available / _config.length, _config.size),
                    );

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_config.length * 2 - 1, (i) {
                        if (i.isOdd) {
                          return SizedBox(width: _config.spacing);
                        }
                        final index = i ~/ 2;
                        final isActive =
                            _focusNode.hasFocus && index == _activeIndex;
                        return Padding(
                          padding: _config.fieldPadding,
                          child: Transform.scale(
                            scale: _pulseScale(index),
                            child: _OtpCell(
                              config: _config,
                              character: index < state.value.length
                                  ? state.value[index]
                                  : '',
                              size: fieldSize,
                              isActive: isActive,
                              hasError: state.hasError,
                              caret: isActive ? _caretController : null,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
            // The real input: invisible and not hit-testable. All pointer
            // handling happens on the surrounding GestureDetector; the field
            // only owns keyboard input and OS autofill.
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: AutofillGroup(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: _config.inputType.keyboardType,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                      enableSuggestions: false,
                      enableInteractiveSelection: false,
                      showCursor: false,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: _formatters,
                      style: const TextStyle(
                        color: Colors.transparent,
                        fontSize: 1,
                        height: 1,
                      ),
                      // No decoration at all — `InputBorder.none` alone is not
                      // enough, because an app-level InputDecorationTheme can
                      // still paint enabled/focused borders (a stray hairline
                      // across the cells).
                      decoration: null,
                      cursorColor: Colors.transparent,
                      onChanged: _onTextChanged,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One painted cell: border reflects error/active/inactive, content is the
/// digit (or the obscure character), or a blinking caret when active and
/// [OTPConfig.showCursor] is on.
class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.config,
    required this.character,
    required this.size,
    required this.isActive,
    required this.hasError,
    this.caret,
  });

  final OTPConfig config;
  final String character;
  final double size;
  final bool isActive;
  final bool hasError;
  final Animation<double>? caret;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Color borderColor;
    if (hasError) {
      borderColor = config.errorColor ?? scheme.error;
    } else if (isActive) {
      borderColor = config.activeColor ?? scheme.primary;
    } else {
      borderColor = config.inactiveColor ?? scheme.outline;
    }

    final textStyle =
        (config.textStyle ??
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            .copyWith(color: config.textColor ?? scheme.onSurface);

    Widget? child;
    if (character.isNotEmpty) {
      child = Text(
        config.obscureText ? config.obscureCharacter : character,
        style: textStyle,
      );
    } else if (isActive && caret != null) {
      child = FadeTransition(
        opacity: caret!,
        child: Container(
          width: 2,
          height: (textStyle.fontSize ?? 18) * 1.2,
          color: config.activeColor ?? scheme.primary,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: config.backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(config.borderRadius),
        border: Border.all(color: borderColor, width: config.borderWidth),
        boxShadow: config.enableShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: config.shadowElevation * 2,
                  offset: Offset(0, config.shadowElevation / 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
