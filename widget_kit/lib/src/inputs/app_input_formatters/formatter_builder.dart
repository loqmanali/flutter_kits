part of '../app_input_formatters.dart';

// Fluent builder + the inline error message widget.
class AppFormatterBuilder {
  AppFormatterBuilder._();

  /// Create custom formatter with your own pattern
  static List<TextInputFormatter> custom({
    required RegExp allowedPattern,
    RegExp? deniedPattern,
    required String errorMessage,
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
  }) {
    return [
      SmartInputFormatter(
        allowedPattern: allowedPattern,
        deniedPattern: deniedPattern,
        errorMessage: errorMessage,
        onError: onError,
        callbacks: callbacks,
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🧩 Helper Widget & Extensions
// ─────────────────────────────────────────────────────────────────────────────

/// Widget to display formatter error messages below input
class FormatterErrorMessage extends StatelessWidget {
  const FormatterErrorMessage({
    super.key,
    this.message,
    this.visible = false,
  });

  final String? message;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible || message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4),
      child: Text(
        message!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
      ),
    );
  }
}

/// Extension to get error message from formatters list
extension InputFormattersExtension on List<TextInputFormatter>? {
  String? getFirstErrorMessage() {
    if (this == null || this!.isEmpty) return null;

    for (final formatter in this!) {
      if (formatter is SmartInputFormatter) {
        return formatter.errorMessage;
      }
    }
    return null;
  }
}
