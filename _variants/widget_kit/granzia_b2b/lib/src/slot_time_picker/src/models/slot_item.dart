/// A single bookable time slot.
///
/// Implement this in your app and pass your instances to the picker widgets.
class SlotItem {
  /// Unique identifier for this slot. Used to track selection state.
  final int id;

  /// The calendar date this slot belongs to (time portion is ignored).
  final DateTime date;

  /// Human-readable time string, e.g. `"09:00 AM"` or `"14:30"`.
  final String time;

  /// Whether this slot has already been booked by someone else.
  final bool isBooked;

  /// Optional extra payload — store any domain-specific data here.
  final Object? extra;

  const SlotItem({
    required this.id,
    required this.date,
    required this.time,
    this.isBooked = false,
    this.extra,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlotItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
