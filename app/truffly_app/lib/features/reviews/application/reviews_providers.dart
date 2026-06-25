import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/reviews/data/reviews_service.dart';
import 'package:truffly_app/features/reviews/domain/order_review.dart';

final reviewsServiceProvider = Provider<ReviewsService>((ref) {
  return ReviewsService(ref.read(supabaseClientProvider));
});

final orderReviewProvider = FutureProvider.family<OrderReview?, String>((
  ref,
  orderId,
) {
  return ref.read(reviewsServiceProvider).fetchOrderReview(orderId);
});

final reviewSubmissionProvider =
    NotifierProvider<ReviewSubmissionNotifier, Set<String>>(
      ReviewSubmissionNotifier.new,
    );

final class ReviewSubmissionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  Future<void> submitReview({
    required String orderId,
    required int rating,
    required String? comment,
  }) async {
    if (state.contains(orderId)) return;
    state = {...state, orderId};
    try {
      await ref
          .read(reviewsServiceProvider)
          .submitReview(orderId: orderId, rating: rating, comment: comment);
    } finally {
      final next = Set<String>.from(state)..remove(orderId);
      state = next;
    }
  }
}
