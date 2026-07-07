import 'package:flutter/material.dart';
import '../../theme/slot_picker_theme.dart';

class MessageStateWidget extends StatelessWidget {
  final String message;
  final SlotPickerTheme theme;

  const MessageStateWidget({
    super.key,
    required this.message,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 140),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: theme.emptyStateFillColor.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.grey400.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_outlined, color: theme.grey400, size: 28),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                theme.emptyStateMessageStyle ??
                TextStyle(color: theme.grey500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
