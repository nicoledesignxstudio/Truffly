final class OrderReview {
  const OrderReview({
    required this.id,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.isAuto,
    required this.autoCreatedAt,
  });

  final String id;
  final String orderId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final bool isAuto;
  final DateTime? autoCreatedAt;
}
