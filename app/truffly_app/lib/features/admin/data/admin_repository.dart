import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/admin/data/admin_application_dto.dart';

enum AdminRepositoryFailure {
  unauthenticated,
  forbidden,
  notFound,
  network,
  validation,
  unknown,
}

final class AdminRepositoryException implements Exception {
  const AdminRepositoryException(this.failure, {this.code, this.cause});

  final AdminRepositoryFailure failure;
  final String? code;
  final Object? cause;
}

class AdminRepository {
  AdminRepository(this._supabaseClient);

  static const _listFunction = 'list_seller_applications';
  static const _documentsFunction = 'get_seller_application_documents';
  static const _approveFunction = 'approve_seller';
  static const _rejectFunction = 'reject_seller';
  static const _timeout = Duration(seconds: 20);

  final SupabaseClient _supabaseClient;

  Future<List<AdminSellerApplication>> listPendingApplications() async {
    final data = await _invoke(_listFunction, const {});
    final rawApplications = data['applications'];
    if (rawApplications is! List) return const [];
    return [
      for (final item in rawApplications)
        if (item is Map)
          AdminSellerApplication.fromJson(item.cast<String, dynamic>()),
    ];
  }

  Future<AdminSellerApplicationDocuments> getApplicationDocuments(
    String userId,
  ) async {
    final data = await _invoke(_documentsFunction, {'user_id': userId});
    final documents = AdminSellerApplicationDocuments.fromJson(data);
    if (!documents.isComplete) {
      throw const AdminRepositoryException(AdminRepositoryFailure.notFound);
    }
    return documents;
  }

  Future<void> approveSeller(String userId) async {
    await _invoke(_approveFunction, {'user_id': userId});
  }

  Future<void> rejectSeller(String userId, {String? reason}) async {
    await _invoke(_rejectFunction, {
      'user_id': userId,
      if ((reason ?? '').trim().isNotEmpty) 'reason': reason!.trim(),
    });
  }

  Future<Map<String, dynamic>> _invoke(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _supabaseClient.functions
          .invoke(functionName, body: body)
          .timeout(_timeout);

      final data = _asJsonMap(response.data);
      if (response.status < 200 || response.status >= 300) {
        throw AdminRepositoryException(
          _mapStatus(response.status),
          code: _errorCode(data),
        );
      }
      return data;
    } on AdminRepositoryException {
      rethrow;
    } on TimeoutException catch (error) {
      throw AdminRepositoryException(
        AdminRepositoryFailure.network,
        cause: error,
      );
    } on SocketException catch (error) {
      throw AdminRepositoryException(
        AdminRepositoryFailure.network,
        cause: error,
      );
    } on FunctionException catch (error) {
      throw AdminRepositoryException(
        _mapStatus(error.status),
        code: _errorCode(_asJsonMap(error.details)),
        cause: error,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[AdminRepository] $functionName failed: $error');
      }
      throw AdminRepositoryException(
        AdminRepositoryFailure.unknown,
        cause: error,
      );
    }
  }

  AdminRepositoryFailure _mapStatus(int status) {
    if (status == 401) return AdminRepositoryFailure.unauthenticated;
    if (status == 403) return AdminRepositoryFailure.forbidden;
    if (status == 404) return AdminRepositoryFailure.notFound;
    if (status == 400 || status == 409) {
      return AdminRepositoryFailure.validation;
    }
    if (status == 408 || status == 429 || status >= 500) {
      return AdminRepositoryFailure.network;
    }
    return AdminRepositoryFailure.unknown;
  }

  Map<String, dynamic> _asJsonMap(Object? value) {
    if (value is Map) return value.cast<String, dynamic>();
    return const {};
  }

  String? _errorCode(Map<String, dynamic> data) {
    final value = data['error'];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }
}
