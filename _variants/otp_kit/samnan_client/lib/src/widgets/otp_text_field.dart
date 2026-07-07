import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/otp_models.dart';
import '../providers/otp_controller.dart';
import '../validators/otp_validator.dart';

/// Cell-based OTP input with focus management, paste support, animations,
/// error shake, RTL, and SMS auto-fill hints.
///
/// Wire it up like:
/// ```dart
/// OTPTextField(
///   config: OTPConfig(length: 4),
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
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  final List<OTPValidationRule>? customValidationRules;

  @override
  ConsumerState<OTPTextField> createState() => _OTPTextFieldState();
}

class _OTPTextFieldState extends ConsumerState<OTPTextField>
    with TickerProviderStateMixin {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _keyListenerNodes;

  AnimationController? _animationController;
  AnimationController? _shakeController;
  List<Animation<double>> _scaleAnimations = const [];
  Animation<double>? _shakeAnimation;

  /// Last value forwarded via `onCompleted`. Only used when
  /// `config.dedupeCompletion == true` to suppress duplicate submissions
  /// when the user backspaces and re-types the same digits.
  String? _lastCompletedValue;

  @override
  void initState() {
    super.initState();
    _initializeFocusNodes();
    _initializeControllers();
    _initializeAnimations();
    _autoFocusFirstField();
  }

  void _initializeFocusNodes() {
    _focusNodes = List.generate(
      widget.config.length,
      (index) => FocusNode(debugLabel: 'OTPDigit_$index')
        ..addListener(() => _onFocusChange(index)),
    );
    _keyListenerNodes = List.generate(
      widget.config.length,
      (index) => FocusNode(skipTraversal: true, debugLabel: 'OTPKey_$index'),
    );
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.config.length,
      (_) => TextEditingController(),
    );
  }

  void _initializeAnimations() {
    if (!widget.config.enableAnimations) return;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.config.animationDuration),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController!, curve: Curves.elasticOut),
    );

    _scaleAnimations = List.generate(
      widget.config.length,
      (index) => TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.1)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 30.0,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 70.0,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _animationController!,
          curve: Interval(
            index / widget.config.length,
            (index + 1) / widget.config.length,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }

  void _autoFocusFirstField() {
    if (!widget.config.autoFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_focusNodes.isNotEmpty) _focusNodes[0].requestFocus();
    });
  }

  void _onFocusChange(int index) {
    if (!mounted) return;
    final controller = ref.read(otpControllerProvider(widget.config).notifier);
    controller.setFocused(_focusNodes[index].hasFocus, index);
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final node in _keyListenerNodes) {
      node.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    _animationController?.dispose();
    _shakeController?.dispose();
    super.dispose();
  }

  void _onTextChanged(String value, int index) {
    final controller = ref.read(otpControllerProvider(widget.config).notifier);

    // Paste / SMS autofill: a multi-character insert lands here.
    if (value.length > 1) {
      controller.setValue(value);
      _syncControllersFromState();
      final state = ref.read(otpControllerProvider(widget.config));
      if (state.isComplete) _handleCompletion(state.value);
      widget.onChanged?.call(state.value);
      return;
    }

    if (value.isNotEmpty) {
      controller.updateDigit(index, value);

      if (_animationController != null) {
        _animationController!.forward().then((_) {
          if (mounted) _animationController!.reverse();
        });
      }

      if (index < widget.config.length - 1) {
        // Defer focus change so the keyboard doesn't fight the text update.
        Future.microtask(() {
          if (mounted) _focusNodes[index + 1].requestFocus();
        });
      } else {
        _focusNodes[index].unfocus();
        final state = ref.read(otpControllerProvider(widget.config));
        if (state.isComplete) _handleCompletion(state.value);
      }
    } else {
      // Empty: user cleared this cell (e.g. via inputFormatter rejection).
      controller.clearDigit(index);
    }

    final state = ref.read(otpControllerProvider(widget.config));
    widget.onChanged?.call(state.value);
  }

  void _handleCompletion(String value) {
    if (widget.config.dedupeCompletion) {
      if (_lastCompletedValue == value) return;
      _lastCompletedValue = value;
    }
    if (widget.config.autoDismissKeyboard) {
      FocusScope.of(context).unfocus();
    }
    widget.onCompleted?.call(value);
  }

  void _handleKeyEvent(KeyEvent event, int index) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
        ref
            .read(otpControllerProvider(widget.config).notifier)
            .clearDigit(index - 1);
      } else if (_controllers[index].text.isNotEmpty) {
        _controllers[index].clear();
        ref
            .read(otpControllerProvider(widget.config).notifier)
            .clearDigit(index);
      }
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && index > 0) {
      _focusNodes[index - 1].requestFocus();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        index < widget.config.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _handlePaste() async {
    final notifier = ref.read(otpControllerProvider(widget.config).notifier);
    await notifier.handlePaste();
    _syncControllersFromState();

    final state = ref.read(otpControllerProvider(widget.config));
    if (state.isComplete) _handleCompletion(state.value);
  }

  void _syncControllersFromState() {
    final state = ref.read(otpControllerProvider(widget.config));
    for (int i = 0; i < state.digits.length && i < _controllers.length; i++) {
      final desired = state.digits[i];
      if (_controllers[i].text != desired) {
        _controllers[i].value = TextEditingValue(
          text: desired,
          selection: TextSelection.collapsed(offset: desired.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpControllerProvider(widget.config));

    ref.listen<OTPState>(
      otpControllerProvider(widget.config),
      (previous, next) {
        // Reset the dedupe guard whenever the value is wiped, so the user
        // can re-submit the same code after explicitly clearing.
        if (next.value.isEmpty && (previous?.value.isNotEmpty ?? false)) {
          _lastCompletedValue = null;
        }
        if (next.hasError &&
            (previous?.hasError == false) &&
            _shakeController != null) {
          _shakeController!.forward().then((_) {
            if (mounted) _shakeController!.reverse();
          });
        }
      },
    );

    return Directionality(
      textDirection:
          widget.config.isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GestureDetector(
        onLongPress: widget.config.enablePaste ? _handlePaste : null,
        child: AutofillGroup(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalSpacing =
                  widget.config.spacing * (widget.config.length - 1);
              final totalPadding = widget.config.fieldPadding.horizontal *
                  widget.config.length;
              final availableWidth =
                  constraints.maxWidth - totalSpacing - totalPadding;
              final fieldSize = math.max(
                20.0,
                math.min(
                    availableWidth / widget.config.length, widget.config.size),
              );

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  widget.config.length * 2 - 1,
                  (index) {
                    if (index.isOdd) {
                      return SizedBox(width: widget.config.spacing);
                    }
                    return _buildDigitField(index ~/ 2, state, fieldSize);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDigitField(int index, OTPState state, double fieldSize) {
    final input = _buildInputContainer(index, state, fieldSize);
    if (_animationController == null || _shakeAnimation == null) {
      return Padding(padding: widget.config.fieldPadding, child: input);
    }
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimations[index], _shakeAnimation!]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            state.hasError
                ? _shakeAnimation!.value * (index.isEven ? 1 : -1)
                : 0,
            0,
          ),
          child: Padding(
            padding: widget.config.fieldPadding,
            child: Transform.scale(
              scale: 1.0 + (0.1 * _scaleAnimations[index].value),
              child: child,
            ),
          ),
        );
      },
      child: input,
    );
  }

  Widget _buildInputContainer(int index, OTPState state, double fieldSize) {
    final theme = Theme.of(context);
    final isFocused = state.focusedIndex == index;

    final Color borderColor;
    if (state.hasError) {
      borderColor = widget.config.errorColor ?? theme.colorScheme.error;
    } else if (isFocused) {
      borderColor = widget.config.activeColor ?? theme.colorScheme.primary;
    } else {
      borderColor = widget.config.inactiveColor ?? theme.colorScheme.outline;
    }

    final isFirstCell = index == 0;

    return SizedBox(
      width: fieldSize,
      height: fieldSize,
      child: KeyboardListener(
        focusNode: _keyListenerNodes[index],
        onKeyEvent: (event) => _handleKeyEvent(event, index),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: widget.config.inputType.keyboardType,
          obscureText: widget.config.obscureText,
          obscuringCharacter: widget.config.obscureCharacter,
          // We let the input formatter handle paste-then-distribute; the
          // `maxLength`/`MaxLengthEnforcement` pair would truncate a multi-
          // char paste to 1 before our distribution branch fires.
          maxLength: widget.config.length,
          maxLengthEnforcement: MaxLengthEnforcement.none,
          // Only the first cell carries the SMS autofill hint; the platform
          // forwards the full code there and the multi-character branch in
          // [_onTextChanged] distributes it across cells.
          autofillHints: isFirstCell ? const [AutofillHints.oneTimeCode] : null,
          style: widget.config.textStyle?.copyWith(
                color: widget.config.textColor ?? theme.colorScheme.onSurface,
              ) ??
              TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.config.textColor ?? theme.colorScheme.onSurface,
              ),
          decoration: InputDecoration(
            counterText: '',
            fillColor: widget.config.backgroundColor ?? Colors.transparent,
            filled: widget.config.backgroundColor != null,
            border: _outline(borderColor),
            enabledBorder: _outline(borderColor),
            focusedBorder: _outline(
              widget.config.activeColor ?? theme.colorScheme.primary,
            ),
            errorBorder: _outline(
              widget.config.errorColor ?? theme.colorScheme.error,
            ),
            disabledBorder: _outline(
              widget.config.inactiveColor ?? theme.colorScheme.outline,
            ),
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            // Allow paste up to `length` chars; the multi-char branch in
            // [_onTextChanged] handles distribution.
            LengthLimitingTextInputFormatter(widget.config.length),
            _OTPInputFormatter(widget.config.inputType),
          ],
          onChanged: (value) => _onTextChanged(value, index),
        ),
      ),
    );
  }

  OutlineInputBorder _outline(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
        borderSide: BorderSide(color: color, width: widget.config.borderWidth),
      );
}

/// Allows characters that pass the configured input-type predicate. Empty
/// values pass through (they represent deletions).
class _OTPInputFormatter extends TextInputFormatter {
  _OTPInputFormatter(this.inputType);

  final OTPInputType inputType;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    // Multi-char paste / autofill: filter to allowed chars only.
    if (newValue.text.length > 1) {
      final filtered = newValue.text
          .split('')
          .where((c) => inputType.isValidCharacter(c))
          .join();
      if (filtered == newValue.text) return newValue;
      return TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }
    if (!inputType.isValidCharacter(newValue.text)) return oldValue;
    return newValue;
  }
}
