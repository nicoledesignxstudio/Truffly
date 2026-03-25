final class AccountDetailsFormData {
  const AccountDetailsFormData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.region,
    required this.bio,
    required this.profileImageUrl,
    required this.isSeller,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String? region;
  final String? bio;
  final String? profileImageUrl;
  final bool isSeller;

  bool get requiresRegion => normalizedCountryCode == 'IT';

  String get normalizedCountryCode => countryCode.trim().toUpperCase();

  AccountDetailsFormData normalized() {
    final normalizedCountry = normalizedCountryCode;
    final normalizedRegion = normalizedCountry == 'IT' ? _normalizeOptional(region) : null;

    return AccountDetailsFormData(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim().toLowerCase(),
      countryCode: normalizedCountry,
      region: normalizedRegion,
      bio: isSeller ? _normalizeOptional(bio) : null,
      profileImageUrl: isSeller ? _normalizeOptional(profileImageUrl) : null,
      isSeller: isSeller,
    );
  }

  bool hasChangesComparedTo(AccountDetailsFormData other) {
    final current = normalized();
    final baseline = other.normalized();

    return current.firstName != baseline.firstName ||
        current.lastName != baseline.lastName ||
        current.email != baseline.email ||
        current.countryCode != baseline.countryCode ||
        current.region != baseline.region ||
        current.bio != baseline.bio ||
        current.profileImageUrl != baseline.profileImageUrl;
  }

  AccountDetailsFormData copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? countryCode,
    Object? region = _sentinel,
    Object? bio = _sentinel,
    Object? profileImageUrl = _sentinel,
    bool? isSeller,
  }) {
    return AccountDetailsFormData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      region: identical(region, _sentinel) ? this.region : region as String?,
      bio: identical(bio, _sentinel) ? this.bio : bio as String?,
      profileImageUrl: identical(profileImageUrl, _sentinel)
          ? this.profileImageUrl
          : profileImageUrl as String?,
      isSeller: isSeller ?? this.isSeller,
    );
  }

  static String? _normalizeOptional(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AccountDetailsFormData &&
            other.firstName == firstName &&
            other.lastName == lastName &&
            other.email == email &&
            other.countryCode == countryCode &&
            other.region == region &&
            other.bio == bio &&
            other.profileImageUrl == profileImageUrl &&
            other.isSeller == isSeller;
  }

  @override
  int get hashCode => Object.hash(
    firstName,
    lastName,
    email,
    countryCode,
    region,
    bio,
    profileImageUrl,
    isSeller,
  );
}

const _sentinel = Object();
