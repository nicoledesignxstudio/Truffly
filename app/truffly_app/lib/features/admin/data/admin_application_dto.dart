final class AdminSellerApplication {
  const AdminSellerApplication({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.region,
    required this.sellerStatus,
    required this.tesserinoNumber,
    required this.uploadedAt,
  });

  factory AdminSellerApplication.fromJson(Map<String, dynamic> json) {
    return AdminSellerApplication(
      userId: _string(json['user_id']) ?? _string(json['id']) ?? '',
      firstName: _firstString(json, ['first_name', 'firstname']),
      lastName: _firstString(json, ['last_name', 'lastname']),
      email: _firstString(json, ['email', 'user_email', 'account_email']),
      region: _firstString(json, ['region']),
      sellerStatus: _string(json['seller_status']) ?? 'pending',
      tesserinoNumber: _firstString(json, [
        'tesserino_number',
        'tesserino',
        'license_number',
        'truffle_license_number',
      ]),
      uploadedAt: DateTime.tryParse(_string(json['uploaded_at']) ?? ''),
    );
  }

  final String userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? region;
  final String sellerStatus;
  final String? tesserinoNumber;
  final DateTime? uploadedAt;

  String get displayName {
    final name = [
      if ((firstName ?? '').trim().isNotEmpty) firstName!.trim(),
      if ((lastName ?? '').trim().isNotEmpty) lastName!.trim(),
    ].join(' ');
    if (name.trim().isNotEmpty) return name.trim();
    if ((email ?? '').trim().isNotEmpty) return email!.trim();
    return 'Seller';
  }
}

final class AdminSellerApplicationDocuments {
  const AdminSellerApplicationDocuments({
    required this.identityDocumentUrl,
    required this.tesserinoDocumentUrl,
    required this.expiresIn,
  });

  factory AdminSellerApplicationDocuments.fromJson(Map<String, dynamic> json) {
    return AdminSellerApplicationDocuments(
      identityDocumentUrl: _string(json['identity_document_url']) ?? '',
      tesserinoDocumentUrl: _string(json['tesserino_document_url']) ?? '',
      expiresIn: json['expires_in'] is int ? json['expires_in'] as int : 0,
    );
  }

  final String identityDocumentUrl;
  final String tesserinoDocumentUrl;
  final int expiresIn;

  bool get isComplete =>
      identityDocumentUrl.trim().isNotEmpty &&
      tesserinoDocumentUrl.trim().isNotEmpty;
}

String? _string(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _firstString(
  Map<String, dynamic> json,
  List<String> keys, {
  bool recursive = true,
}) {
  for (final key in keys) {
    final value = _string(json[key]);
    if (value != null) return value;
  }
  if (!recursive) return null;
  for (final value in json.values) {
    final nested = _stringFromValue(value, keys);
    if (nested != null) return nested;
  }
  return null;
}

String? _stringFromValue(Object? value, List<String> keys) {
  if (value is Map) {
    final map = value.cast<String, dynamic>();
    final direct = _firstString(map, keys, recursive: false);
    if (direct != null) return direct;
    for (final nested in map.values) {
      final found = _stringFromValue(nested, keys);
      if (found != null) return found;
    }
  } else if (value is List) {
    for (final item in value) {
      final found = _stringFromValue(item, keys);
      if (found != null) return found;
    }
  }
  return null;
}
