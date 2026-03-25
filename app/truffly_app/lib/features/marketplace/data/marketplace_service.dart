import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/marketplace/domain/truffle_listing_filters.dart';
import 'package:truffly_app/features/marketplace/domain/truffle_search_matcher.dart';
import 'package:truffly_app/features/marketplace/domain/truffle_listing_state.dart';
import 'package:truffly_app/features/truffle/data/truffle_image_url_resolver.dart';
import 'package:truffly_app/features/truffle/domain/truffle_list_item.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

final class MarketplaceServiceException implements Exception {
  const MarketplaceServiceException(this.failure);

  final TruffleListingFailure failure;
}

final class MarketplaceService {
  MarketplaceService(this._supabaseClient)
      : _imageUrlResolver = TruffleImageUrlResolver(_supabaseClient);

  static const pageSize = 20;

  final SupabaseClient _supabaseClient;
  final TruffleImageUrlResolver _imageUrlResolver;

  Future<List<TruffleListItem>> fetchTrufflesByIds(List<String> truffleIds) async {
    final normalizedIds = truffleIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (normalizedIds.isEmpty) {
      return const [];
    }

    try {
      final rows = await _supabaseClient
          .from('active_truffle_cards')
          .select()
          .inFilter('id', normalizedIds)
          .order('created_at', ascending: false) as List<dynamic>;

      return _mapRowsToItems(rows.cast<Map<String, dynamic>>());
    } on SocketException {
      throw const MarketplaceServiceException(TruffleListingFailure.network);
    } on PostgrestException catch (error) {
      if (error.message.toLowerCase().contains('fetch')) {
        throw const MarketplaceServiceException(TruffleListingFailure.network);
      }
      throw const MarketplaceServiceException(TruffleListingFailure.unknown);
    } catch (_) {
      throw const MarketplaceServiceException(TruffleListingFailure.unknown);
    }
  }

  Future<List<TruffleListItem>> fetchListingPage({
    required String localeCode,
    required String searchQuery,
    required TruffleListingFilters filters,
    required int page,
  }) async {
    try {
      final matchingTypes = _resolveMatchingTypes(
        localeCode: localeCode,
        searchQuery: searchQuery,
      );

      if (searchQuery.trim().isNotEmpty && matchingTypes.isEmpty) {
        return const [];
      }

      if (filters.selectedType != null &&
          matchingTypes.isNotEmpty &&
          !matchingTypes.contains(filters.selectedType)) {
        return const [];
      }

      dynamic query = _supabaseClient.from('active_truffle_cards').select();

      final selectedTypes = [
        if (filters.selectedType != null)
          filters.selectedType!
        else
          ...matchingTypes,
      ];

      if (selectedTypes.isNotEmpty) {
        query = query.inFilter(
          'truffle_type',
          selectedTypes.map((type) => type.dbValue).toList(),
        );
      }

      if (filters.qualities.isNotEmpty) {
        query = query.inFilter(
          'quality',
          filters.qualities.map((quality) => quality.dbValue).toList(),
        );
      }

      if (filters.regions.isNotEmpty) {
        query = query.inFilter('region', filters.regions.toList());
      }

      if (filters.minPrice > TruffleListingFilterBounds.minPriceEuro) {
        query = query.gte('price_total', filters.minPrice);
      }

      if (filters.maxPrice < TruffleListingFilterBounds.maxPriceEuro) {
        query = query.lte('price_total', filters.maxPrice);
      }

      if (filters.minWeight > TruffleListingFilterBounds.minWeightGrams) {
        query = query.gte('weight_grams', filters.minWeight.round());
      }

      if (filters.maxWeight < TruffleListingFilterBounds.maxWeightGrams) {
        query = query.lte('weight_grams', filters.maxWeight.round());
      }

      final harvestStartDate = _harvestStartDate(filters.harvestDatePreset);
      if (harvestStartDate != null) {
        query = query.gte('harvest_date', harvestStartDate.toIso8601String());
      }

      final from = page * pageSize;
      final to = from + pageSize - 1;
      final rows = await query
          .order('created_at', ascending: false)
          .range(from, to) as List<dynamic>;

      return _mapRowsToItems(rows.cast<Map<String, dynamic>>());
    } on SocketException {
      throw const MarketplaceServiceException(TruffleListingFailure.network);
    } on PostgrestException catch (error) {
      if (error.message.toLowerCase().contains('fetch')) {
        throw const MarketplaceServiceException(TruffleListingFailure.network);
      }
      throw const MarketplaceServiceException(TruffleListingFailure.unknown);
    } catch (_) {
      throw const MarketplaceServiceException(TruffleListingFailure.unknown);
    }
  }

  List<TruffleType> _resolveMatchingTypes({
    required String localeCode,
    required String searchQuery,
  }) {
    return resolveSearchMatchingTypes(
      localeCode: localeCode,
      searchQuery: searchQuery,
    );
  }

  DateTime? _harvestStartDate(HarvestDatePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return switch (preset) {
      HarvestDatePreset.all => null,
      HarvestDatePreset.today => today,
      HarvestDatePreset.last2Days => today.subtract(const Duration(days: 1)),
      HarvestDatePreset.last3Days => today.subtract(const Duration(days: 2)),
      HarvestDatePreset.last5Days => today.subtract(const Duration(days: 4)),
    };
  }

  double _toDouble(Object value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }

  Future<List<TruffleListItem>> _mapRowsToItems(
    List<Map<String, dynamic>> rows,
  ) async {
    final primaryImageUrls = await _imageUrlResolver.resolveOrderedUrls(
      rows.map((row) => row['primary_image_url'] as String?),
    );

    final items = <TruffleListItem>[];
    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
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
}
