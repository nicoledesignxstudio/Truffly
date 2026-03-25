final class ShippingAddress {
  const ShippingAddress({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.countryCode,
    required this.phone,
    required this.isDefault,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String fullName;
  final String street;
  final String city;
  final String postalCode;
  final String countryCode;
  final String phone;
  final bool isDefault;
  final DateTime createdAt;

  String get cityLine => '$postalCode $city'.trim();

  ShippingAddress copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? street,
    String? city,
    String? postalCode,
    String? countryCode,
    String? phone,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShippingAddress &&
            other.id == id &&
            other.userId == userId &&
            other.fullName == fullName &&
            other.street == street &&
            other.city == city &&
            other.postalCode == postalCode &&
            other.countryCode == countryCode &&
            other.phone == phone &&
            other.isDefault == isDefault &&
            other.createdAt == createdAt);
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    fullName,
    street,
    city,
    postalCode,
    countryCode,
    phone,
    isDefault,
    createdAt,
  );
}
