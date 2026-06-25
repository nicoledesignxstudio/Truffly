import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/reviews/domain/order_review.dart';

final class ReviewsServiceException implements Exception {
  const ReviewsServiceException(this.code, this.message);

  final String code;
  final String message;
}

class ReviewsService {
  ReviewsService(this._supabaseClient);

  static const _submitReviewFunction = 'create_review';

  final SupabaseClient _supabaseClient;

  Future<OrderReview?> fetchOrderReview(String orderId) async {
    final normalizedOrderId = orderId.trim();
    if (normalizedOrderId.isEmpty) return null;

    try {
      final row = await _supabaseClient
          .from('reviews')
          .select(
            'id, order_id, rating, comment, created_at, is_auto, auto_created_at',
          )
          .eq('order_id', normalizedOrderId)
          .maybeSingle();

      if (row == null) return null;
      return _mapReview(row);
    } on PostgrestException catch (error) {
      throw ReviewsServiceException(
        error.code ?? 'reviews_fetch_failed',
        error.message,
      );
    } on SocketException {
      throw const ReviewsServiceException('network', 'Unable to load reviews.');
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[ReviewsService] fetch failed: $error');
      }
      throw const ReviewsServiceException(
        'reviews_fetch_failed',
        'Unable to load reviews.',
      );
    }
  }

  Future<void> submitReview({
    required String orderId,
    required int rating,
    required String? comment,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        _submitReviewFunction,
        body: {
          'order_id': orderId.trim(),
          'rating': rating,
          'comment': comment?.trim().isEmpty == true ? null : comment?.trim(),
        },
      );

      if (response.status < 200 || response.status >= 300) {
        final code = response.data is Map<String, dynamic>
            ? response.data['error'] as String?
            : null;
        throw ReviewsServiceException(
          code ?? 'review_submit_failed',
          'Review submission failed.',
        );
      }
    } on FunctionException catch (error) {
      final code = error.details is Map<String, dynamic>
          ? error.details['error'] as String?
          : null;
      throw ReviewsServiceException(
        code ?? 'review_submit_failed',
        'Review submission failed.',
      );
    } on SocketException {
      throw const ReviewsServiceException(
        'network',
        'Review submission failed.',
      );
    }
  }

  OrderReview _mapReview(Map<String, dynamic> row) {
    return OrderReview(
      id: row['id'] as String,
      orderId: row['order_id'] as String,
      rating: (row['rating'] as num).toInt(),
      comment: (row['comment'] as String?)?.trim(),
      createdAt: DateTime.parse(row['created_at'] as String),
      isAuto: row['is_auto'] == true,
      autoCreatedAt: _parseDate(row['auto_created_at']),
    );
  }

  DateTime? _parseDate(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
