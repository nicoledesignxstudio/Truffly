import 'package:truffly_app/features/profile/domain/seller_review_item.dart';
import 'package:truffly_app/features/truffle/domain/truffle_list_item.dart';

final class SellerProfileDetail {
  const SellerProfileDetail({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profileImageUrl,
    required this.region,
    required this.bio,
    required this.ratingAverage,
    required this.reviewCount,
    required this.completedOrdersCount,
    required this.latestReviews,
    required this.activeTruffles,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String? region;
  final String? bio;
  final double ratingAverage;
  final int reviewCount;
  final int completedOrdersCount;
  final List<SellerReviewItem> latestReviews;
  final List<TruffleListItem> activeTruffles;

  String get fullName {
    final parts = [firstName?.trim(), lastName?.trim()]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'Truffly seller';
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
