import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_item.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_status.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';
import 'package:truffly_app/features/truffle/data/truffle_image_url_resolver.dart';

enum SellerManagedTruffleFailure {
  network,
  unauthenticated,
  forbidden,
  unknown,
}

final class SellerManagedTruffleServiceException implements Exception {
  const SellerManagedTruffleServiceException(this.failure);

  final SellerManagedTruffleFailure failure;
}

final class SellerManagedTruffleDeleteException implements Exception {
  const SellerManagedTruffleDeleteException(this.failure, {this.code});

  final SellerManagedTruffleFailure failure;
  final String? code;
}

final class SellerManagedTruffleService {
  SellerManagedTruffleService(this._supabaseClient)
      : _imageUrlResolver = TruffleImageUrlResolver(_supabaseClient);

  static const _deleteFunctionName = 'delete_truffle';
  static const _requestTimeout = Duration(seconds: 12);

  final SupabaseClient _supabaseClient;
  final TruffleImageUrlResolver _imageUrlResolver;

  Future<List<SellerManagedTruffleItem>> fetchCurrentSellerTruffles() async {
    try {
      final rows = await _supabaseClient
          .from('seller_owned_truffle_cards')
          .select()
          .order('created_at', ascending: false)
          .timeout(_requestTimeout) as List<dynamic>;

      final typedRows = rows.cast<Map<String, dynamic>>();
      final imageUrls = await _imageUrlResolver.resolveOrderedUrls(
        typedRows.map((row) => row['primary_image_url'] as String?),
      );

      final items = <SellerManagedTruffleItem>[];
      for (var index = 0; index < typedRows.length; index++) {
        final row = typedRows[index];
        final rawStatus = row['status'] as String? ?? '';
        items.add(
          SellerManagedTruffleItem(
            id: row['id'] as String,
            status: SellerManagedTruffleStatus.fromDbValue(rawStatus),
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
            primaryImageUrl: imageUrls[index],
          ),
        );
      }

      return items;
    } on TimeoutException {
      throw const SellerManagedTruffleServiceException(
        SellerManagedTruffleFailure.network,
      );
    } on SocketException {
      throw const SellerManagedTruffleServiceException(
        SellerManagedTruffleFailure.network,
      );
    } on FormatException {
      throw const SellerManagedTruffleServiceException(
        SellerManagedTruffleFailure.unknown,
      );
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw const SellerManagedTruffleServiceException(
          SellerManagedTruffleFailure.forbidden,
        );
      }

      if (error.message.toLowerCase().contains('fetch')) {
        throw const SellerManagedTruffleServiceException(
          SellerManagedTruffleFailure.network,
        );
      }

      throw const SellerManagedTruffleServiceException(
        SellerManagedTruffleFailure.unknown,
      );
    } catch (_) {
      throw const SellerManagedTruffleServiceException(
        SellerManagedTruffleFailure.unknown,
      );
    }
  }

  Future<void> deleteTruffle(String truffleId) async {
    final normalizedId = truffleId.trim();
    if (normalizedId.isEmpty) {
      throw const SellerManagedTruffleDeleteException(
        SellerManagedTruffleFailure.unknown,
      );
    }

    try {
      final response = await _supabaseClient.functions
          .invoke(
            _deleteFunctionName,
            body: {'truffle_id': normalizedId},
          )
          .timeout(_requestTimeout);

      final payload = _normalizeFunctionPayload(response.data);
      if (payload case {'success': true}) {
        return;
      }

      throw const SellerManagedTruffleDeleteException(
        SellerManagedTruffleFailure.unknown,
      );
    } on TimeoutException {
      throw const SellerManagedTruffleDeleteException(
        SellerManagedTruffleFailure.network,
      );
    } on SocketException {
      throw const SellerManagedTruffleDeleteException(
        SellerManagedTruffleFailure.network,
      );
    } on FunctionException catch (error) {
      final code = _extractErrorCode(error.details);
      final failure = switch (error.status) {
        401 => SellerManagedTruffleFailure.unauthenticated,
        403 || 404 || 409 => SellerManagedTruffleFailure.forbidden,
        _ => SellerManagedTruffleFailure.unknown,
      };

      throw SellerManagedTruffleDeleteException(failure, code: code);
    } catch (_) {
      throw const SellerManagedTruffleDeleteException(
        SellerManagedTruffleFailure.unknown,
      );
    }
  }

  double _toDouble(Object value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }

  String? _extractErrorCode(Object? details) {
    if (details is Map) {
      final error = details['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }
    }
    return null;
  }

  Map<String, dynamic>? _normalizeFunctionPayload(Object? raw) {
    if (raw is Map) {
      return raw.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;

      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    }

    return null;
  }
}
