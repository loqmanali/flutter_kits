/// Represents the type of shipping/delivery method.
enum ShippingType {
  /// Standard delivery
  standard,

  /// Express/fast delivery
  express,

  /// Same day delivery
  sameDay,

  /// Next day delivery
  nextDay,

  /// Scheduled delivery (customer picks time)
  scheduled,

  /// Store pickup
  pickup,

  /// Curbside pickup
  curbside,

  /// Locker pickup
  locker,

  /// Drive-through
  driveThrough,

  /// Dine-in (for restaurants)
  dineIn,

  /// Free shipping
  free,
}

/// Extension methods for [ShippingType].
extension ShippingTypeExtension on ShippingType {
  /// Returns true if this is a delivery option
  bool get isDelivery =>
      this == ShippingType.standard ||
      this == ShippingType.express ||
      this == ShippingType.sameDay ||
      this == ShippingType.nextDay ||
      this == ShippingType.scheduled ||
      this == ShippingType.free;

  /// Returns true if this is a pickup option
  bool get isPickup =>
      this == ShippingType.pickup ||
      this == ShippingType.curbside ||
      this == ShippingType.locker ||
      this == ShippingType.driveThrough;

  /// Returns true if this is an in-store option
  bool get isInStore =>
      this == ShippingType.pickup ||
      this == ShippingType.curbside ||
      this == ShippingType.dineIn;

  /// Returns true if this is a fast/premium option
  bool get isPremium =>
      this == ShippingType.express ||
      this == ShippingType.sameDay ||
      this == ShippingType.nextDay;

  /// Returns true if customer needs to specify time
  bool get requiresTimeSlot => this == ShippingType.scheduled;

  /// Returns a human-readable label
  String get label {
    switch (this) {
      case ShippingType.standard:
        return 'Standard Delivery';
      case ShippingType.express:
        return 'Express Delivery';
      case ShippingType.sameDay:
        return 'Same Day Delivery';
      case ShippingType.nextDay:
        return 'Next Day Delivery';
      case ShippingType.scheduled:
        return 'Scheduled Delivery';
      case ShippingType.pickup:
        return 'Store Pickup';
      case ShippingType.curbside:
        return 'Curbside Pickup';
      case ShippingType.locker:
        return 'Locker Pickup';
      case ShippingType.driveThrough:
        return 'Drive-Through';
      case ShippingType.dineIn:
        return 'Dine In';
      case ShippingType.free:
        return 'Free Delivery';
    }
  }

  /// Returns an icon name for this shipping type
  String get iconName {
    switch (this) {
      case ShippingType.standard:
        return 'local_shipping';
      case ShippingType.express:
        return 'rocket_launch';
      case ShippingType.sameDay:
        return 'bolt';
      case ShippingType.nextDay:
        return 'schedule';
      case ShippingType.scheduled:
        return 'event';
      case ShippingType.pickup:
        return 'store';
      case ShippingType.curbside:
        return 'directions_car';
      case ShippingType.locker:
        return 'lock';
      case ShippingType.driveThrough:
        return 'drive_eta';
      case ShippingType.dineIn:
        return 'restaurant';
      case ShippingType.free:
        return 'local_offer';
    }
  }
}
