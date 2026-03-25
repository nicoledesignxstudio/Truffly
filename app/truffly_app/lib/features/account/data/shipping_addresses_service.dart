import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/account/domain/shipping_address.dart';
import 'package:truffly_app/features/account/domain/shipping_address_form_data.dart';

enum ShippingAddressesFailure {
  network,
  unauthorized,
  notFound,
  validation,
  unknown,
}

class ShippingAddressesException implements Exception {
  const ShippingAddressesException(
    this.failure, {
    this.code,
  });

  final ShippingAddressesFailure failure;
  final String? code;
}

class ShippingAddressesService {
  const ShippingAddressesService(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  static const _timeout = Duration(seconds: 12);

  Future<List<ShippingAddress>> fetchAddresses() async {
    try {
      final response = await _supabaseClient
          .from('shipping_addresses')
          .select(
            'id, user_id, full_name, street, city, postal_code, '
            'country_code, phone, is_default, created_at',
          )
          .order('is_default', ascending: false)
          .order('created_at', ascending: true)
          .timeout(_timeout) as List<dynamic>;

      return response
          .cast<Map<String, dynamic>>()
          .map(_mapAddress)
          .toList(growable: false);
    } on SocketException {
      throw const ShippingAddressesException(ShippingAddressesFailure.network);
    } on TimeoutException {
      throw const ShippingAddressesException(ShippingAddressesFailure.network);
    } on PostgrestException catch (error) {
      throw _mapPostgrestException(error);
    } catch (_) {
      throw const ShippingAddressesException(ShippingAddressesFailure.unknown);
    }
  }

  Future<ShippingAddress> fetchAddressById(String addressId) async {
    try {
      final response = await _supabaseClient
          .from('shipping_addresses')
          .select(
            'id, user_id, full_name, street, city, postal_code, '
            'country_code, phone, is_default, created_at',
          )
          .eq('id', addressId)
          .single()
          .timeout(_timeout);

      return _mapAddress(response);
    } on SocketException {
      throw const ShippingAddressesException(ShippingAddressesFailure.network);
    } on TimeoutException {
      throw const ShippingAddressesException(ShippingAddressesFailure.network);
    } on PostgrestException catch (error) {
      throw _mapPostgrestException(error);
    } catch (_) {
      throw const ShippingAddressesException(ShippingAddressesFailure.unknown);
    }
  }

  Future<ShippingAddress> saveAddress(ShippingAddressFormData form) async {
    final normalized = form.normalized();

    try {
      final response = await _supabaseClient.rpc(
        'save_shipping_address',
        params: {
          'p_address_id': normalized.id,
          'p_full_name': normalized.fullName,
          'p_street': normalized.street,
          'p_city': normalized.city,
          'p_postal_code': normalized.postalCode,
          'p_country_code': normalized.countryCode,
          'p_phone': normalized.phone,
          'p_is_default': normalized.isDefault,
        },
      ).timeout(_timeout);

      if (response case Map<String, dynamic> row) {
        return _mapAddress(row);
      }

      if (response case List<dynamic> rows
          when rows.isNotEmpty && rows.first is Map<String, dynamic>) {
        return _mapAddress(rows.first as Map<String, dynamic>);
      }

      throw const ShippingAddressesException(ShippingAddressesFailure.unknown);
    } on SocketException {
      throw const ShippingAddressesException(ShippingAddressesFailure.network);
    } on TimeoutException {
      throw const ShippingAddressesException(ShippingAddressesFailure.network);
    } on PostgrestException catch (error) {
      throw _mapPostgrestException(error);
    } catch (error) {
      if (error is ShippingAddressesException) rethrow;
      throw const ShippingAddressesException(ShippingAddressesFailure.unknown);
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _supabaseClient
          .rpc(
            'delete_shipping_address',
            params: {'p_address_id': addressId},
          )
          .timeout(_timeout);
    } on SocketException {
      throw const ShippingAddressesException(ShippingAddressesFailure.network);
    } on TimeoutException {
      throw const ShippingAddressesException(ShippingAddressesFailure.network);
    } on PostgrestException catch (error) {
      throw _mapPostgrestException(error);
    } catch (error) {
      if (error is ShippingAddressesException) rethrow;
      throw const ShippingAddressesException(ShippingAddressesFailure.unknown);
    }
  }

  ShippingAddress _mapAddress(Map<String, dynamic> row) {
    return ShippingAddress(
      id: (row['id'] as String? ?? '').trim(),
      userId: (row['user_id'] as String? ?? '').trim(),
      fullName: (row['full_name'] as String? ?? '').trim(),
      street: (row['street'] as String? ?? '').trim(),
      city: (row['city'] as String? ?? '').trim(),
      postalCode: (row['postal_code'] as String? ?? '').trim(),
      countryCode: (row['country_code'] as String? ?? '').trim().toUpperCase(),
      phone: (row['phone'] as String? ?? '').trim(),
      isDefault: row['is_default'] as bool? ?? false,
      createdAt:
          DateTime.tryParse((row['created_at'] as String? ?? '').trim()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  ShippingAddressesException _mapPostgrestException(PostgrestException error) {
    final code = error.code?.trim();
    final message = error.message.trim().toLowerCase();
    final customCode = _extractCustomCode(error);

    if (code == '42501' || message.contains('not allowed')) {
      return const ShippingAddressesException(
        ShippingAddressesFailure.unauthorized,
      );
    }

    if (code == 'PGRST116' ||
        message.contains('not found') ||
        customCode == 'shipping_address_not_found') {
      return ShippingAddressesException(
        ShippingAddressesFailure.notFound,
        code: customCode ?? code,
      );
    }

    if (_isValidationCode(customCode)) {
      return ShippingAddressesException(
        ShippingAddressesFailure.validation,
        code: customCode,
      );
    }

    debugPrint('Shipping addresses PostgrestException: ${error.code} ${error.message}');
    return ShippingAddressesException(
      ShippingAddressesFailure.unknown,
      code: customCode ?? code,
    );
  }

  bool _isValidationCode(String? code) {
    return switch (code) {
      'shipping_address_not_found' ||
      'shipping_address_full_name_required' ||
      'shipping_address_street_required' ||
      'shipping_address_city_required' ||
      'shipping_address_postal_code_required' ||
      'shipping_address_country_code_invalid' ||
      'shipping_address_phone_required' => true,
      _ => false,
    };
  }

  String? _extractCustomCode(PostgrestException error) {
    final message = error.message.trim();
    if (_isValidationCode(message) || message == 'shipping_address_not_found') {
      return message;
    }

    final details = switch (error.details) {
      final String value => value.trim(),
      _ => null,
    };
    if (details != null &&
        (_isValidationCode(details) || details == 'shipping_address_not_found')) {
      return details;
    }

    return null;
  }
}
