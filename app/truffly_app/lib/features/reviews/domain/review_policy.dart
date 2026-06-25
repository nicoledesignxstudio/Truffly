import 'package:truffly_app/features/orders/domain/order_detail.dart';
import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/reviews/domain/order_review.dart';

const reviewWindowDuration = Duration(hours: 48);

bool isManualReviewWindowOpenForOrder(
  OrderDetail order, {
  required OrderReview? review,
  DateTime? now,
}) {
  if (order.status != OrderStatus.completed) return false;
  if (review != null) return false;
  final completedAt = order.completedAt;
  if (completedAt == null) return false;
  final currentTime = now ?? DateTime.now().toUtc();
  return completedAt.toUtc().add(reviewWindowDuration).isAfter(currentTime);
}
