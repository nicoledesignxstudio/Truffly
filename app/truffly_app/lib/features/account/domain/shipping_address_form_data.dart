import 'package:truffly_app/features/account/domain/shipping_address.dart';

final class ShippingAddressFormData {
  const ShippingAddressFormData({
    this.id,
    required this.fullName,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.countryCode,
    required this.phone,
    required this.isDefault,
  });

  final String? id;
  final String fullName;
  final String street;
  final String city;
  final String postalCode;
  final String countryCode;
  final String phone;
  final bool isDefault;

  factory ShippingAddressFormData.empty() {
    return const ShippingAddressFormData(
      fullName: '',
      street: '',
      city: '',
      postalCode: '',
      countryCode: '',
      phone: '',
      isDefault: false,
    );
  }

  factory ShippingAddressFormData.fromAddress(ShippingAddress address) {
    return ShippingAddressFormData(
      id: address.id,
      fullName: address.fullName,
      street: address.street,
      city: address.city,
      postalCode: address.postalCode,
      countryCode: address.countryCode,
      phone: address.phone,
      isDefault: address.isDefault,
    );
  }

  bool get isEditing => id != null;

  ShippingAddressFormData normalized() {
    return ShippingAddressFormData(
      id: id,
      fullName: fullName.trim(),
      street: street.trim(),
      city: city.trim(),
      postalCode: postalCode.trim(),
      countryCode: countryCode.trim().toUpperCase(),
      phone: phone.trim(),
      isDefault: isDefault,
    );
  }

  bool hasChangesComparedTo(ShippingAddressFormData other) {
    final normalizedCurrent = normalized();
    final normalizedOther = other.normalized();

    return normalizedCurrent.id != normalizedOther.id ||
        normalizedCurrent.fullName != normalizedOther.fullName ||
        normalizedCurrent.street != normalizedOther.street ||
        normalizedCurrent.city != normalizedOther.city ||
        normalizedCurrent.postalCode != normalizedOther.postalCode ||
        normalizedCurrent.countryCode != normalizedOther.countryCode ||
        normalizedCurrent.phone != normalizedOther.phone ||
        normalizedCurrent.isDefault != normalizedOther.isDefault;
  }

  ShippingAddressFormData copyWith({
    Object? id = _sentinel,
    String? fullName,
    String? street,
    String? city,
    String? postalCode,
    String? countryCode,
    String? phone,
    bool? isDefault,
  }) {
    return ShippingAddressFormData(
      id: identical(id, _sentinel) ? this.id : id as String?,
      fullName: fullName ?? this.fullName,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShippingAddressFormData &&
            other.id == id &&
            other.fullName == fullName &&
            other.street == street &&
            other.city == city &&
            other.postalCode == postalCode &&
            other.countryCode == countryCode &&
            other.phone == phone &&
            other.isDefault == isDefault);
  }

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    street,
    city,
    postalCode,
    countryCode,
    phone,
    isDefault,
  );
}

const _sentinel = Object();
