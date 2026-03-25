import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/sellers/domain/seller_list_item.dart';
import 'package:truffly_app/features/sellers/domain/seller_listing_filters.dart';
import 'package:truffly_app/features/sellers/domain/seller_listing_state.dart';

final class SellerListingServiceException implements Exception {
  const SellerListingServiceException(this.failure);

  final SellerListingFailure failure;
}

final class SellerListingService {
  SellerListingService(this._supabaseClient);

  static const pageSize = 20;

  final SupabaseClient _supabaseClient;

  Future<List<SellerListItem>> fetchListingPage({
    required String searchQuery,
    required SellerListingFilters filters,
    required int page,
  }) async {
    try {
      dynamic query = _supabaseClient.from('active_seller_cards').select();

      final normalizedQuery = searchQuery.trim();
      if (normalizedQuery.isNotEmpty) {
        final escapedQuery = _escapeLikeQuery(normalizedQuery);
        query = query.or(
          'first_name.ilike.%$escapedQuery%,'
          'last_name.ilike.%$escapedQuery%,'
          'full_name.ilike.%$escapedQuery%',
        );
      }

      if (filters.selectedRegion != null) {
        query = query.eq('region', filters.selectedRegion!);
      }

      if (filters.minimumRating != null) {
        query = query.gte('seller_rating_avg', filters.minimumRating!);
      }

      if (filters.minimumCompletedOrders != null) {
        query = query.gte(
          'completed_orders_count',
          filters.minimumCompletedOrders!,
        );
      }

      final from = page * pageSize;
      final to = from + pageSize - 1;
      final rows = await query
          .order('seller_rating_avg', ascending: false)
          .order('completed_orders_count', ascending: false)
          .order('created_at', ascending: false)
          .range(from, to) as List<dynamic>;

      return rows.cast<Map<String, dynamic>>().map(_mapSeller).toList();
    } on SocketException {
      throw const SellerListingServiceException(SellerListingFailure.network);
    } on PostgrestException catch (error) {
      if (error.message.toLowerCase().contains('fetch')) {
        throw const SellerListingServiceException(SellerListingFailure.network);
      }
      throw const SellerListingServiceException(SellerListingFailure.unknown);
    } catch (_) {
      throw const SellerListingServiceException(SellerListingFailure.unknown);
    }
  }

  SellerListItem _mapSeller(Map<String, dynamic> row) {
    return SellerListItem(
      id: row['id'] as String,
      firstName: row['first_name'] as String?,
      lastName: row['last_name'] as String?,
      profileImageUrl: row['profile_image_url'] as String?,
      region: row['region'] as String?,
      ratingAverage: _toDouble(row['seller_rating_avg']),
      reviewCount: row['seller_review_count'] as int? ?? 0,
      completedOrdersCount: row['completed_orders_count'] as int? ?? 0,
    );
  }

  String _escapeLikeQuery(String value) {
    return value.replaceAll(',', r'\,');
  }

  double _toDouble(Object value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }
}
