import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/home/data/models/seasonal_highlight_response.dart';
import 'package:truffly_app/features/marketplace/data/marketplace_service.dart';
import 'package:truffly_app/features/marketplace/domain/truffle_listing_filters.dart';
import 'package:truffly_app/features/sellers/domain/seller_list_item.dart';
import 'package:truffly_app/features/truffle/domain/truffle_list_item.dart';

enum SeasonalHighlightFailure { network, unauthorized, unknown }

class SeasonalHighlightException implements Exception {
  const SeasonalHighlightException(this.failure);

  final SeasonalHighlightFailure failure;
}

class HomeRepository {
  const HomeRepository(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  Future<SeasonalHighlightResponse> fetchSeasonalHighlight({
    required String localeCode,
  }) async {
    final lang = normalizeLocaleCode(localeCode);

    try {
      final response = await _supabaseClient.rpc(
        'get_buyer_home_seasonal_highlight',
        params: {'lang': lang},
      );

      if (response is! Map<String, dynamic>) {
        throw const SeasonalHighlightException(
          SeasonalHighlightFailure.unknown,
        );
      }

      return SeasonalHighlightResponse.fromJson(response);
    } on SocketException {
      throw const SeasonalHighlightException(SeasonalHighlightFailure.network);
    } on PostgrestException catch (error) {
      final message = error.message.toLowerCase();
      final isUnauthorized =
          error.code == '42501' || message.contains('not allowed');
      throw SeasonalHighlightException(
        isUnauthorized
            ? SeasonalHighlightFailure.unauthorized
            : SeasonalHighlightFailure.unknown,
      );
    } on SeasonalHighlightException {
      rethrow;
    } catch (_) {
      throw const SeasonalHighlightException(SeasonalHighlightFailure.unknown);
    }
  }

  @visibleForTesting
  static String normalizeLocaleCode(String localeCode) {
    return localeCode.trim().toLowerCase() == 'en' ? 'en' : 'it';
  }

  Future<List<TruffleListItem>> fetchLatestTruffles({
    required String localeCode,
    int limit = 6,
  }) async {
    final marketplaceService = MarketplaceService(_supabaseClient);
    final items = await marketplaceService.fetchListingPage(
      localeCode: normalizeLocaleCode(localeCode),
      searchQuery: '',
      filters: TruffleListingFilters.defaults(),
      page: 0,
    );
    return items.take(limit).toList(growable: false);
  }

  Future<List<SellerListItem>> fetchTopSellers({int limit = 6}) async {
    try {
      final rows = await _supabaseClient
          .from('active_seller_cards')
          .select(
            'id, first_name, last_name, profile_image_url, region, '
            'seller_rating_avg, seller_review_count, completed_orders_count',
          )
          .order('seller_review_count', ascending: false)
          .order('seller_rating_avg', ascending: false)
          .order('completed_orders_count', ascending: false)
          .limit(limit) as List<dynamic>;

      return rows.cast<Map<String, dynamic>>().map(_mapSeller).toList(growable: false);
    } on SocketException {
      throw const SeasonalHighlightException(SeasonalHighlightFailure.network);
    } on PostgrestException {
      throw const SeasonalHighlightException(SeasonalHighlightFailure.unknown);
    } catch (_) {
      throw const SeasonalHighlightException(SeasonalHighlightFailure.unknown);
    }
  }

  Future<SellerHomeStats> fetchSellerHomeStats({required String sellerId}) async {
    try {
      final orders = await _supabaseClient
          .from('orders')
          .select('id')
          .eq('seller_id', sellerId)
          .inFilter('status', ['paid', 'shipped']) as List<dynamic>;

      final activeTruffles = await _supabaseClient
          .from('truffles')
          .select('id')
          .eq('seller_id', sellerId)
          .eq('status', 'active') as List<dynamic>;

      return SellerHomeStats(
        inProgressOrdersCount: orders.length,
        activeTrufflesCount: activeTruffles.length,
      );
    } on SocketException {
      throw const SeasonalHighlightException(SeasonalHighlightFailure.network);
    } on PostgrestException {
      throw const SeasonalHighlightException(SeasonalHighlightFailure.unknown);
    } catch (_) {
      throw const SeasonalHighlightException(SeasonalHighlightFailure.unknown);
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
      reviewCount: (row['seller_review_count'] as num?)?.toInt() ?? 0,
      completedOrdersCount: (row['completed_orders_count'] as num?)?.toInt() ?? 0,
    );
  }

  double _toDouble(Object value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }
}

final class SellerHomeStats {
  const SellerHomeStats({
    required this.inProgressOrdersCount,
    required this.activeTrufflesCount,
  });

  const SellerHomeStats.empty()
      : inProgressOrdersCount = 0,
        activeTrufflesCount = 0;

  final int inProgressOrdersCount;
  final int activeTrufflesCount;
}
