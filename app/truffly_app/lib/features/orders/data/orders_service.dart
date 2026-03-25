import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/orders/domain/order_detail.dart';
import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/orders/domain/order_summary.dart';
import 'package:truffly_app/features/truffle/data/truffle_image_url_resolver.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

enum OrdersFailure {
  network,
  unauthenticated,
  forbidden,
  notFound,
  validation,
  unknown,
}

final class OrdersServiceException implements Exception {
  const OrdersServiceException(this.failure, {this.code});

  final OrdersFailure failure;
  final String? code;
}

final class OrdersService {
  OrdersService(this._supabaseClient)
    : _imageUrlResolver = TruffleImageUrlResolver(_supabaseClient);

  final SupabaseClient _supabaseClient;
  final TruffleImageUrlResolver _imageUrlResolver;

  Future<List<OrderSummary>> fetchCurrentUserOrders() async {
    try {
      final rows =
          await _supabaseClient
                  .from('current_user_order_details')
                  .select(
                    'id, truffle_id, truffle_type, quality, weight_grams, total_price, '
                    'status, created_at, tracking_code, primary_image_url, buyer_id, '
                    'buyer_full_name, seller_id, seller_full_name, seller_profile_image_url',
                  )
                  .order('created_at', ascending: false)
              as List<dynamic>;

      return _mapSummaries(rows.cast<Map<String, dynamic>>());
    } on SocketException {
      throw const OrdersServiceException(OrdersFailure.network);
    } on PostgrestException catch (error) {
      throw OrdersServiceException(
        _mapPostgrestFailure(error),
        code: error.code,
      );
    } catch (_) {
      throw const OrdersServiceException(OrdersFailure.unknown);
    }
  }

  Future<OrderDetail> fetchOrderDetail(String orderId) async {
    final normalizedOrderId = orderId.trim();
    if (normalizedOrderId.isEmpty) {
      throw const OrdersServiceException(OrdersFailure.notFound);
    }

    try {
      final row = await _supabaseClient
          .from('current_user_order_details')
          .select()
          .eq('id', normalizedOrderId)
          .maybeSingle();

      if (row == null) {
        throw const OrdersServiceException(OrdersFailure.notFound);
      }

      return _mapDetail(row);
    } on OrdersServiceException {
      rethrow;
    } on SocketException {
      throw const OrdersServiceException(OrdersFailure.network);
    } on PostgrestException catch (error) {
      throw OrdersServiceException(
        _mapPostgrestFailure(error),
        code: error.code,
      );
    } catch (_) {
      throw const OrdersServiceException(OrdersFailure.unknown);
    }
  }

  Future<void> confirmReceipt(String orderId) async {
    await _invokeMutation(
      action: 'confirm_receipt',
      payload: {'order_id': orderId},
    );
  }

  Future<void> markAsShipped(String orderId, String trackingCode) async {
    await _invokeMutation(
      action: 'mark_shipped',
      payload: {'order_id': orderId, 'tracking_code': trackingCode.trim()},
    );
  }

  Future<void> cancelOrder(String orderId) async {
    await _invokeMutation(
      action: 'cancel_order',
      payload: {'order_id': orderId},
    );
  }

  Future<void> _invokeMutation({
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'update_order_status',
        body: {'action': action, ...payload},
      );

      if (response.status < 200 || response.status >= 300) {
        final data = response.data;
        final code = data is Map<String, dynamic>
            ? data['error'] as String?
            : null;
        throw OrdersServiceException(
          _mapFunctionFailure(response.status),
          code: code,
        );
      }
    } on OrdersServiceException {
      rethrow;
    } on FunctionException catch (error) {
      final details = error.details;
      String? code;
      final status = error.status;
      if (details is Map<String, dynamic>) {
        code = details['error'] as String?;
      }
      throw OrdersServiceException(_mapFunctionFailure(status), code: code);
    } on SocketException {
      throw const OrdersServiceException(OrdersFailure.network);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[OrdersService] mutation failure: $error');
      }
      throw const OrdersServiceException(OrdersFailure.unknown);
    }
  }

  OrdersFailure _mapPostgrestFailure(PostgrestException error) {
    final message = error.message.toLowerCase();
    if (error.code == 'PGRST116') return OrdersFailure.notFound;
    if (error.code == '42501' || message.contains('permission')) {
      return OrdersFailure.forbidden;
    }
    if (message.contains('jwt') || message.contains('auth')) {
      return OrdersFailure.unauthenticated;
    }
    return OrdersFailure.unknown;
  }

  OrdersFailure _mapFunctionFailure(int status) {
    return switch (status) {
      400 => OrdersFailure.validation,
      401 => OrdersFailure.unauthenticated,
      403 => OrdersFailure.forbidden,
      404 => OrdersFailure.notFound,
      _ => OrdersFailure.unknown,
    };
  }

  Future<OrderDetail> _mapDetail(Map<String, dynamic> row) async {
    final resolvedImageUrl = (await _imageUrlResolver.resolveOrderedUrls([
      row['primary_image_url'] as String?,
    ])).first;

    return OrderDetail(
      id: row['id'] as String,
      truffleId: row['truffle_id'] as String,
      type: TruffleType.fromDbValue(row['truffle_type'] as String),
      quality: TruffleQuality.fromDbValue(row['quality'] as String),
      weightGrams: row['weight_grams'] as int,
      totalPrice: _toDouble(row['total_price']),
      commissionAmount: _toDouble(row['commission_amount']),
      sellerAmount: _toDouble(row['seller_amount']),
      status: OrderStatus.fromDbValue(row['status'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      trackingCode: row['tracking_code'] as String?,
      primaryImageUrl: resolvedImageUrl,
      buyerId: row['buyer_id'] as String,
      buyerName: _normalizedPartyName(
        row['buyer_full_name'] as String?,
        fallback: 'Buyer',
      ),
      sellerId: row['seller_id'] as String,
      sellerName: _normalizedPartyName(
        row['seller_full_name'] as String?,
        fallback: 'Seller',
      ),
      sellerProfileImageUrl: row['seller_profile_image_url'] as String?,
      shippingFullName: row['shipping_full_name'] as String? ?? '',
      shippingStreet: row['shipping_street'] as String? ?? '',
      shippingCity: row['shipping_city'] as String? ?? '',
      shippingPostalCode: row['shipping_postal_code'] as String? ?? '',
      shippingCountryCode: row['shipping_country_code'] as String? ?? '',
      shippingPhone: row['shipping_phone'] as String? ?? '',
    );
  }

  double _toDouble(Object value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }

  Future<List<OrderSummary>> _mapSummaries(
    List<Map<String, dynamic>> rows,
  ) async {
    final resolvedImageUrls = await _imageUrlResolver.resolveOrderedUrls(
      rows.map((row) => row['primary_image_url'] as String?),
    );

    return [
      for (var index = 0; index < rows.length; index++)
        _mapSummary(rows[index], primaryImageUrl: resolvedImageUrls[index]),
    ];
  }

  OrderSummary _mapSummary(
    Map<String, dynamic> row, {
    String? primaryImageUrl,
  }) {
    return OrderSummary(
      id: row['id'] as String,
      truffleId: row['truffle_id'] as String,
      type: TruffleType.fromDbValue(row['truffle_type'] as String),
      quality: TruffleQuality.fromDbValue(row['quality'] as String),
      weightGrams: row['weight_grams'] as int,
      totalPrice: _toDouble(row['total_price']),
      status: OrderStatus.fromDbValue(row['status'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      trackingCode: row['tracking_code'] as String?,
      primaryImageUrl: primaryImageUrl ?? (row['primary_image_url'] as String?),
      buyerId: row['buyer_id'] as String,
      buyerName: _normalizedPartyName(
        row['buyer_full_name'] as String?,
        fallback: 'Buyer',
      ),
      sellerId: row['seller_id'] as String,
      sellerName: _normalizedPartyName(
        row['seller_full_name'] as String?,
        fallback: 'Seller',
      ),
      sellerProfileImageUrl: row['seller_profile_image_url'] as String?,
    );
  }

  String _normalizedPartyName(String? rawValue, {required String fallback}) {
    final trimmed = rawValue?.trim() ?? '';
    if (trimmed.isEmpty) return fallback;
    return trimmed;
  }
}
