/// All user-visible strings used by the slot picker widgets.
///
/// Pass a custom instance to override any label.
class SlotPickerLabels {
  /// Prompt shown before a date is chosen. Also used as the bottom-sheet title.
  final String chooseDatePrompt;

  /// Heading above the time-slot grid.
  final String timeHeading;

  /// Message shown when a day has no available slots.
  final String noSlotsMessage;

  /// Message shown while slots for a day are loading (and an error occurred).
  final String errorMessage;

  /// Label for the confirm / "Next" button inside the bottom sheet.
  final String confirmButtonLabel;

  const SlotPickerLabels({
    this.chooseDatePrompt = 'Choose the best date & time',
    this.timeHeading = 'Time',
    this.noSlotsMessage = 'No available time slots for this day',
    this.errorMessage = 'Something went wrong. Please try again.',
    this.confirmButtonLabel = 'Next',
  });

  /// Arabic defaults.
  const SlotPickerLabels.arabic({
    this.chooseDatePrompt = 'اختر أفضل تاريخ ووقت',
    this.timeHeading = 'الوقت',
    this.noSlotsMessage = 'لا توجد فترات زمنية متاحة لهذا اليوم',
    this.errorMessage = 'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
    this.confirmButtonLabel = 'التالي',
  });
}
