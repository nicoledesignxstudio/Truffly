import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/truffle/data/truffle_image_url_resolver.dart';
import 'package:truffly_app/features/truffle/domain/truffle_detail.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_seller_preview.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

enum TruffleDetailFailure {
  network,
  notFound,
  unknown,
}

final class TruffleServiceException implements Exception {
  const TruffleServiceException(this.failure);

  final TruffleDetailFailure failure;
}

final class TruffleService {
  TruffleService(this._supabaseClient)
      : _imageUrlResolver = TruffleImageUrlResolver(_supabaseClient);

  final SupabaseClient _supabaseClient;
  final TruffleImageUrlResolver _imageUrlResolver;

  Future<TruffleDetail> fetchDetail(String truffleId) async {
    final normalizedTruffleId = truffleId.trim();
    if (normalizedTruffleId.isEmpty) {
      throw const TruffleServiceException(TruffleDetailFailure.notFound);
    }

    try {
      _debugLog('fetchDetail truffleId=$normalizedTruffleId');

      final row = await _supabaseClient
          .from('active_truffle_details')
          .select(
            'id, seller_id, truffle_type, quality, weight_grams, price_total, '
            'price_per_kg, shipping_price_italy, shipping_price_abroad, region, '
            'harvest_date, created_at, expires_at, seller_first_name, '
            'seller_last_name, seller_profile_image_url, seller_review_count, '
            'seller_rating_avg',
          )
          .eq('id', normalizedTruffleId)
          .maybeSingle();

      if (row == null) {
        _debugLog('detail row not found for truffleId=$normalizedTruffleId');
        throw const TruffleServiceException(TruffleDetailFailure.notFound);
      }

      final imageRows = await _supabaseClient
          .from('truffle_images')
          .select('image_url, order_index')
          .eq('truffle_id', normalizedTruffleId)
          .order('order_index', ascending: true) as List<dynamic>;

      _debugLog(
        'detail loaded for truffleId=$normalizedTruffleId '
        'imageCount=${imageRows.length}',
      );

      final resolvedImageUrls = await _imageUrlResolver.resolveOrderedUrls(
        imageRows
            .cast<Map<String, dynamic>>()
            .map((imageRow) => imageRow['image_url'] as String?),
      );
      final imageUrls = resolvedImageUrls.whereType<String>().toList(growable: false);

      return TruffleDetail(
        id: row['id'] as String,
        type: TruffleType.fromDbValue(row['truffle_type'] as String),
        quality: TruffleQuality.fromDbValue(row['quality'] as String),
        weightGrams: row['weight_grams'] as int,
        priceTotal: _toDouble(row['price_total']),
        pricePerKg: _toDouble(row['price_per_kg']),
        shippingPriceItaly: _toDouble(row['shipping_price_italy']),
        shippingPriceAbroad: _toDouble(row['shipping_price_abroad']),
        region: row['region'] as String,
        harvestDate: DateTime.parse(row['harvest_date'] as String),
        createdAt: DateTime.parse(row['created_at'] as String),
        expiresAt: DateTime.parse(row['expires_at'] as String),
        imageUrls: imageUrls,
        seller: TruffleSellerPreview(
          id: row['seller_id'] as String,
          firstName: row['seller_first_name'] as String?,
          lastName: row['seller_last_name'] as String?,
          profileImageUrl: row['seller_profile_image_url'] as String?,
          reviewCount: row['seller_review_count'] as int? ?? 0,
          ratingAverage: _toDouble(row['seller_rating_avg']),
        ),
      );
    } on TruffleServiceException {
      rethrow;
    } on PostgrestException catch (error) {
      if (error.code == 'PGRST205') {
        _debugLog(
          'active_truffle_details is missing from the PostgREST schema cache. '
          'Apply the latest migration and refresh the local Supabase stack.',
        );
      }
      _debugLog(
        'PostgrestException on truffle detail '
        'code=${error.code} message=${error.message} '
        'details=${error.details} hint=${error.hint}',
      );
      throw const TruffleServiceException(TruffleDetailFailure.unknown);
    } on SocketException {
      _debugLog('SocketException on truffle detail');
      throw const TruffleServiceException(TruffleDetailFailure.network);
    } on FormatException catch (error) {
      _debugLog('FormatException on truffle detail message=${error.message}');
      throw const TruffleServiceException(TruffleDetailFailure.unknown);
    } catch (error) {
      _debugLog('Unknown truffle detail error type=${error.runtimeType}');
      throw const TruffleServiceException(TruffleDetailFailure.unknown);
    }
  }

  double _toDouble(Object value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[TruffleService] $message');
    }
  }
}
