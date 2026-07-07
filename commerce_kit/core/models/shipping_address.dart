import 'package:equatable/equatable.dart';

/// Represents a shipping/delivery address.
class ShippingAddress extends Equatable {
  /// Unique identifier for this address.
  final String? id;

  /// Address label (e.g., "Home", "Work").
  final String? label;

  /// Full name of recipient.
  final String fullName;

  /// Phone number.
  final String phone;

  /// Alternative phone number.
  final String? alternativePhone;

  /// Email address.
  final String? email;

  /// Address line 1 (street address).
  final String addressLine1;

  /// Address line 2 (apartment, suite, etc.).
  final String? addressLine2;

  /// City.
  final String city;

  /// State/Province/Region.
  final String? state;

  /// Postal/ZIP code.
  final String? postalCode;

  /// Country.
  final String country;

  /// Country code (ISO 3166-1 alpha-2).
  final String? countryCode;

  /// Latitude for map display.
  final double? latitude;

  /// Longitude for map display.
  final double? longitude;

  /// Building/apartment number.
  final String? building;

  /// Floor number.
  final String? floor;

  /// Apartment/unit number.
  final String? apartment;

  /// Landmark for easier delivery.
  final String? landmark;

  /// Special delivery instructions.
  final String? deliveryInstructions;

  /// Whether this is the default address.
  final bool isDefault;

  /// Whether this address is verified.
  final bool isVerified;

  /// Address type (home, work, other).
  final AddressType type;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  /// Creates a [ShippingAddress].
  const ShippingAddress({
    this.id,
    this.label,
    required this.fullName,
    required this.phone,
    this.alternativePhone,
    this.email,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    this.postalCode,
    required this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
    this.building,
    this.floor,
    this.apartment,
    this.landmark,
    this.deliveryInstructions,
    this.isDefault = false,
    this.isVerified = false,
    this.type = AddressType.home,
    this.metadata = const {},
  });

  /// Creates a [ShippingAddress] from JSON.
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] as String?,
      label: json['label'] as String?,
      fullName: json['full_name'] ?? json['fullName'] ?? json['name'] as String,
      phone: json['phone'] ?? json['phoneNumber'] as String,
      alternativePhone: json['alternative_phone'] ??
          json['alternativePhone'] ??
          json['altPhone'] as String?,
      email: json['email'] as String?,
      addressLine1: json['address_line_1'] ??
          json['addressLine1'] ??
          json['address'] ??
          json['street'] as String,
      addressLine2: json['address_line_2'] ??
          json['addressLine2'] ??
          json['address2'] as String?,
      city: json['city'] as String,
      state: json['state'] ?? json['province'] ?? json['region'] as String?,
      postalCode: json['postal_code'] ??
          json['postalCode'] ??
          json['zip'] ??
          json['zipCode'] as String?,
      country: json['country'] as String,
      countryCode: json['country_code'] ?? json['countryCode'] as String?,
      latitude: (json['latitude'] ?? json['lat'] as num?)?.toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? json['lon'] as num?)
          ?.toDouble(),
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] ?? json['unit'] as String?,
      landmark: json['landmark'] as String?,
      deliveryInstructions: json['delivery_instructions'] ??
          json['deliveryInstructions'] ??
          json['instructions'] as String?,
      isDefault: json['is_default'] ?? json['isDefault'] as bool? ?? false,
      isVerified: json['is_verified'] ?? json['isVerified'] as bool? ?? false,
      type: json['type'] != null
          ? AddressType.values.firstWhere(
              (e) => e.name == json['type'],
              orElse: () => AddressType.home,
            )
          : AddressType.home,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'full_name': fullName,
        'phone': phone,
        'alternative_phone': alternativePhone,
        'email': email,
        'address_line_1': addressLine1,
        'address_line_2': addressLine2,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'country_code': countryCode,
        'latitude': latitude,
        'longitude': longitude,
        'building': building,
        'floor': floor,
        'apartment': apartment,
        'landmark': landmark,
        'delivery_instructions': deliveryInstructions,
        'is_default': isDefault,
        'is_verified': isVerified,
        'type': type.name,
        'metadata': metadata,
      };

  /// Returns the full address as a single string.
  String get fullAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      if (building != null && building!.isNotEmpty) 'Building $building',
      if (floor != null && floor!.isNotEmpty) 'Floor $floor',
      if (apartment != null && apartment!.isNotEmpty) 'Apt $apartment',
      city,
      if (state != null && state!.isNotEmpty) state!,
      if (postalCode != null && postalCode!.isNotEmpty) postalCode!,
      country,
    ];
    return parts.join(', ');
  }

  /// Returns a short address (street + city).
  String get shortAddress => '$addressLine1, $city';

  /// Returns true if this address has coordinates.
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Creates a copy with updated values.
  ShippingAddress copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? alternativePhone,
    String? email,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? countryCode,
    double? latitude,
    double? longitude,
    String? building,
    String? floor,
    String? apartment,
    String? landmark,
    String? deliveryInstructions,
    bool? isDefault,
    bool? isVerified,
    AddressType? type,
    Map<String, dynamic>? metadata,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      email: email ?? this.email,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        label,
        fullName,
        phone,
        alternativePhone,
        email,
        addressLine1,
        addressLine2,
        city,
        state,
        postalCode,
        country,
        countryCode,
        latitude,
        longitude,
        building,
        floor,
        apartment,
        landmark,
        deliveryInstructions,
        isDefault,
        isVerified,
        type,
        metadata,
      ];
}

/// Address type enum.
enum AddressType {
  home,
  work,
  office,
  other,
}

/// Extension methods for [AddressType].
extension AddressTypeExtension on AddressType {
  String get label {
    switch (this) {
      case AddressType.home:
        return 'Home';
      case AddressType.work:
        return 'Work';
      case AddressType.office:
        return 'Office';
      case AddressType.other:
        return 'Other';
    }
  }

  String get iconName {
    switch (this) {
      case AddressType.home:
        return 'home';
      case AddressType.work:
        return 'work';
      case AddressType.office:
        return 'business';
      case AddressType.other:
        return 'location_on';
    }
  }
}
