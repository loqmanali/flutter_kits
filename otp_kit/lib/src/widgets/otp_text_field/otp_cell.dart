part of '../otp_text_field.dart';

// One painted cell of the code.
/// One painted cell: border reflects error/active/inactive, content is the
/// digit (or the obscure character), or a blinking caret when active and
/// [OTPConfig.showCursor] is on.
class _OtpCell extends StatelessWidget {
  const _OtpCell({
    super.key,
    required this.config,
    required this.character,
    required this.width,
    required this.height,
    required this.isActive,
    required this.hasError,
    this.isSuccess = false,
    this.caret,
  });

  final OTPConfig config;
  final String character;
  final double width;
  final double height;
  final bool isActive;
  final bool hasError;
  final bool isSuccess;
  final Animation<double>? caret;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Color borderColor;
    if (hasError) {
      borderColor = config.errorColor ?? scheme.error;
    } else if (isSuccess && config.successColor != null) {
      borderColor = config.successColor!;
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
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: config.backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(config.borderRadius),
        border: Border.all(color: borderColor, width: config.borderWidth),
        boxShadow: config.enableShadow
            ? [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .shadow
                      .withValues(alpha: 0.08),
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
