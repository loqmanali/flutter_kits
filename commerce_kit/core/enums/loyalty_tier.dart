/// Represents loyalty program tiers.
enum LoyaltyTier {
  /// No tier / Not enrolled
  none,

  /// Bronze tier (entry level)
  bronze,

  /// Silver tier
  silver,

  /// Gold tier
  gold,

  /// Platinum tier
  platinum,

  /// Diamond tier (highest)
  diamond,

  /// VIP tier (special status)
  vip,
}

/// Extension methods for [LoyaltyTier].
extension LoyaltyTierExtension on LoyaltyTier {
  /// Returns true if user is enrolled in loyalty program
  bool get isEnrolled => this != LoyaltyTier.none;

  /// Returns true if this is a premium tier (gold and above)
  bool get isPremium =>
      this == LoyaltyTier.gold ||
      this == LoyaltyTier.platinum ||
      this == LoyaltyTier.diamond ||
      this == LoyaltyTier.vip;

  /// Returns the tier level (0-6)
  int get level {
    switch (this) {
      case LoyaltyTier.none:
        return 0;
      case LoyaltyTier.bronze:
        return 1;
      case LoyaltyTier.silver:
        return 2;
      case LoyaltyTier.gold:
        return 3;
      case LoyaltyTier.platinum:
        return 4;
      case LoyaltyTier.diamond:
        return 5;
      case LoyaltyTier.vip:
        return 6;
    }
  }

  /// Returns the next tier (or null if at max)
  LoyaltyTier? get nextTier {
    switch (this) {
      case LoyaltyTier.none:
        return LoyaltyTier.bronze;
      case LoyaltyTier.bronze:
        return LoyaltyTier.silver;
      case LoyaltyTier.silver:
        return LoyaltyTier.gold;
      case LoyaltyTier.gold:
        return LoyaltyTier.platinum;
      case LoyaltyTier.platinum:
        return LoyaltyTier.diamond;
      case LoyaltyTier.diamond:
        return LoyaltyTier.vip;
      case LoyaltyTier.vip:
        return null;
    }
  }

  /// Returns the points multiplier for this tier
  double get pointsMultiplier {
    switch (this) {
      case LoyaltyTier.none:
        return 1.0;
      case LoyaltyTier.bronze:
        return 1.0;
      case LoyaltyTier.silver:
        return 1.25;
      case LoyaltyTier.gold:
        return 1.5;
      case LoyaltyTier.platinum:
        return 1.75;
      case LoyaltyTier.diamond:
        return 2.0;
      case LoyaltyTier.vip:
        return 2.5;
    }
  }

  /// Returns a human-readable label
  String get label {
    switch (this) {
      case LoyaltyTier.none:
        return 'Not Enrolled';
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
      case LoyaltyTier.diamond:
        return 'Diamond';
      case LoyaltyTier.vip:
        return 'VIP';
    }
  }

  /// Returns a color hex code for this tier
  String get colorHex {
    switch (this) {
      case LoyaltyTier.none:
        return '#9E9E9E';
      case LoyaltyTier.bronze:
        return '#CD7F32';
      case LoyaltyTier.silver:
        return '#C0C0C0';
      case LoyaltyTier.gold:
        return '#FFD700';
      case LoyaltyTier.platinum:
        return '#E5E4E2';
      case LoyaltyTier.diamond:
        return '#B9F2FF';
      case LoyaltyTier.vip:
        return '#8B008B';
    }
  }
}
