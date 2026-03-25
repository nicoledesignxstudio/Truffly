import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/profile/domain/seller_profile_detail.dart';
import 'package:truffly_app/features/profile/domain/seller_review_item.dart';
import 'package:truffly_app/features/truffle/data/truffle_image_url_resolver.dart';
import 'package:truffly_app/features/truffle/domain/truffle_list_item.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

enum SellerProfileFailure {
  network,
  notFound,
  unknown,
}

final class SellerProfileServiceException implements Exception {
  const SellerProfileServiceException(this.failure);

  final SellerProfileFailure failure;
}

final class SellerProfileService {
  SellerProfileService(this._supabaseClient)
      : _imageUrlResolver = TruffleImageUrlResolver(_supabaseClient);

  final SupabaseClient _supabaseClient;
  final TruffleImageUrlResolver _imageUrlResolver;

  Future<SellerProfileDetail> fetchSellerProfile(String sellerId) async {
    final normalizedSellerId = sellerId.trim();
    if (normalizedSellerId.isEmpty) {
      throw const SellerProfileServiceException(SellerProfileFailure.notFound);
    }

    try {
      final profileRow = await _supabaseClient
          .from('seller_public_profiles')
          .select()
          .eq('id', normalizedSellerId)
          .maybeSingle();

      if (profileRow == null) {
        throw const SellerProfileServiceException(SellerProfileFailure.notFound);
      }

      final reviews = await fetchSellerReviews(
        normalizedSellerId,
        limit: 3,
      );
      final truffles = await _fetchSellerActiveTruffles(normalizedSellerId);

      return SellerProfileDetail(
        id: profileRow['id'] as String,
        firstName: profileRow['first_name'] as String?,
        lastName: profileRow['last_name'] as String?,
        profileImageUrl: profileRow['profile_image_url'] as String?,
        region: profileRow['region'] as String?,
        bio: profileRow['bio'] as String?,
        ratingAverage: _toDouble(profileRow['seller_rating_avg']),
        reviewCount: profileRow['seller_review_count'] as int? ?? 0,
        completedOrdersCount: profileRow['completed_orders_count'] as int? ?? 0,
        latestReviews: reviews,
        activeTruffles: truffles,
      );
    } on SellerProfileServiceException {
      rethrow;
    } on SocketException {
      throw const SellerProfileServiceException(SellerProfileFailure.network);
    } on PostgrestException catch (_) {
      throw const SellerProfileServiceException(SellerProfileFailure.unknown);
    } catch (_) {
      throw const SellerProfileServiceException(SellerProfileFailure.unknown);
    }
  }

  Future<List<SellerReviewItem>> fetchSellerReviews(
    String sellerId, {
    int? limit,
  }) async {
    final normalizedSellerId = sellerId.trim();
    try {
      dynamic query = _supabaseClient
          .from('seller_public_reviews')
          .select()
          .eq('seller_id', normalizedSellerId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final rows = await query as List<dynamic>;
      return rows.cast<Map<String, dynamic>>().map(_mapReview).toList();
    } on SocketException {
      throw const SellerProfileServiceException(SellerProfileFailure.network);
    } on PostgrestException catch (_) {
      throw const SellerProfileServiceException(SellerProfileFailure.unknown);
    } catch (_) {
      throw const SellerProfileServiceException(SellerProfileFailure.unknown);
    }
  }

  Future<List<TruffleListItem>> _fetchSellerActiveTruffles(String sellerId) async {
    final rows = await _supabaseClient
        .from('seller_active_truffle_cards')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false) as List<dynamic>;

    final typedRows = rows.cast<Map<String, dynamic>>();
    final primaryImageUrls = await _imageUrlResolver.resolveOrderedUrls(
      typedRows.map((row) => row['primary_image_url'] as String?),
    );

    final items = <TruffleListItem>[];
    for (var index = 0; index < typedRows.length; index++) {
      final row = typedRows[index];
      items.add(
        TruffleListItem(
          id: row['id'] as String,
          type: TruffleType.fromDbValue(row['truffle_type'] as String),
          quality: TruffleQuality.fromDbValue(row['quality'] as String),
          weightGrams: row['weight_grams'] as int,
          priceTotal: _toDouble(row['price_total']),
          shippingPriceItaly: _toDouble(row['shipping_price_italy']),
          shippingPriceAbroad: _toDouble(row['shipping_price_abroad']),
          region: row['region'] as String,
          harvestDate: DateTime.parse(row['harvest_date'] as String),
          createdAt: DateTime.parse(row['created_at'] as String),
          expiresAt: DateTime.parse(row['expires_at'] as String),
          primaryImageUrl: primaryImageUrls[index],
        ),
      );
    }

    return items;
  }

  SellerReviewItem _mapReview(Map<String, dynamic> row) {
    return SellerReviewItem(
      id: row['id'] as String,
      rating: row['rating'] as int,
      comment: row['comment'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  double _toDouble(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }
}
