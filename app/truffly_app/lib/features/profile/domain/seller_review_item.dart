final class SellerReviewItem {
  const SellerReviewItem({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  bool get hasComment => comment != null && comment!.trim().isNotEmpty;
}
