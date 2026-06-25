import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AccountDeletionService {
  Future<AccountDeletionResult> deleteCurrentAccount();
}

final class AccountDeletionResult {
  const AccountDeletionResult({
    required this.status,
    required this.requestId,
  });

  final AccountDeletionOutcome status;
  final String requestId;
}

enum AccountDeletionOutcome {
  deleted,
  deactivated,
}

final class AccountDeletionServiceException implements Exception {
  const AccountDeletionServiceException(this.failure, {this.cause});

  final AccountDeletionFailure failure;
  final Object? cause;
}

enum AccountDeletionFailure {
  unauthenticated,
  inactiveAccount,
  requestFailed,
  network,
  unknown,
}

final class SupabaseAccountDeletionService implements AccountDeletionService {
  SupabaseAccountDeletionService(this._supabaseClient);

  static const String _functionName = 'delete_account';
  static const Duration _requestTimeout = Duration(seconds: 20);

  final SupabaseClient _supabaseClient;

  @override
  Future<AccountDeletionResult> deleteCurrentAccount() async {
    final authUser = _supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw const AccountDeletionServiceException(
        AccountDeletionFailure.unauthenticated,
      );
    }

    final requestId = _buildRequestId(authUser.id);

    try {
      final response = await _supabaseClient.functions
          .invoke(
            _functionName,
            body: const {},
            headers: {'x-request-id': requestId},
          )
          .timeout(_requestTimeout);

      final data = response.data;
      final status = _parseOutcome(data);
      if (status == null) {
        throw const AccountDeletionServiceException(
          AccountDeletionFailure.unknown,
        );
      }

      return AccountDeletionResult(status: status, requestId: requestId);
    } on TimeoutException catch (error) {
      throw AccountDeletionServiceException(
        AccountDeletionFailure.network,
        cause: error,
      );
    } on SocketException catch (error) {
      throw AccountDeletionServiceException(
        AccountDeletionFailure.network,
        cause: error,
      );
    } on FunctionException catch (error) {
      throw AccountDeletionServiceException(
        _mapFunctionFailure(error),
        cause: error,
      );
    } catch (error) {
      throw AccountDeletionServiceException(
        AccountDeletionFailure.unknown,
        cause: error,
      );
    }
  }

  AccountDeletionOutcome? _parseOutcome(Object? data) {
    if (data is! Map) return null;

    final status = data['status'];
    if (status is! String) return null;

    return switch (status.trim().toLowerCase()) {
      'deleted' => AccountDeletionOutcome.deleted,
      'deactivated' => AccountDeletionOutcome.deactivated,
      _ => null,
    };
  }

  AccountDeletionFailure _mapFunctionFailure(FunctionException error) {
    if (error.status == 401) return AccountDeletionFailure.unauthenticated;
    if (error.status == 403) return AccountDeletionFailure.inactiveAccount;
    if (error.status == 409) return AccountDeletionFailure.requestFailed;
    if (error.status >= 500) return AccountDeletionFailure.unknown;
    return AccountDeletionFailure.requestFailed;
  }

  String _buildRequestId(String userId) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return 'delete-account-$userId-$timestamp';
  }
}
