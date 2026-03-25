final class SellerListItem {
  const SellerListItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profileImageUrl,
    required this.region,
    required this.ratingAverage,
    required this.reviewCount,
    required this.completedOrdersCount,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String? region;
  final double ratingAverage;
  final int reviewCount;
  final int completedOrdersCount;

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

  bool get hasReviews => reviewCount > 0;
}
