import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/truffle/data/truffle_image_url_resolver.dart';
import 'package:truffly_app/features/truffle/domain/truffle_detail.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
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
    try {
      final row = await _supabaseClient
          .from('truffles')
          .select(
            'id, truffle_type, quality, weight_grams, price_total, price_per_kg, '
            'shipping_price_italy, shipping_price_abroad, region, harvest_date, '
            'created_at, expires_at',
          )
          .eq('id', truffleId)
          .eq('status', 'active')
          .maybeSingle();

      if (row == null) {
        throw const TruffleServiceException(TruffleDetailFailure.notFound);
      }

      final imageRows = await _supabaseClient
          .from('truffle_images')
          .select('image_url, order_index')
          .eq('truffle_id', truffleId)
          .order('order_index', ascending: true) as List<dynamic>;

      final resolvedImageUrls = _imageUrlResolver.resolveOrderedUrls(
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
      );
    } on TruffleServiceException {
      rethrow;
    } on SocketException {
      throw const TruffleServiceException(TruffleDetailFailure.network);
    } catch (_) {
      throw const TruffleServiceException(TruffleDetailFailure.unknown);
    }
  }

  double _toDouble(Object value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }
}
