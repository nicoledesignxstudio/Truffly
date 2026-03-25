final class TruffleSellerPreview {
  const TruffleSellerPreview({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profileImageUrl,
    required this.ratingAverage,
    required this.reviewCount,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final double ratingAverage;
  final int reviewCount;

  String get fullName {
    final parts = [firstName?.trim(), lastName?.trim()]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'Truffly seller';
    }
    return parts.join(' ');
  }

  String get initials {
    final parts = fullName.split(RegExp(r'\s+'));
    final letters = parts
        .where((value) => value.isNotEmpty)
        .take(2)
        .map((value) => value.substring(0, 1).toUpperCase())
        .join();
    return letters.isEmpty ? 'T' : letters;
  }
}
