final class SellerReviewItem {
  const SellerReviewItem({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.isAuto,
    required this.reviewerName,
  });

  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final bool isAuto;
  final String? reviewerName;

  bool get hasComment => comment != null && comment!.trim().isNotEmpty;
}
