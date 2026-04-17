import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

enum SellerStripeReadinessStatus {
  notConnected,
  onboardingInProgress,
  verificationPending,
  ready,
}

final class SellerStripeStatusSnapshot {
  const SellerStripeStatusSnapshot({
    required this.accountId,
    required this.readiness,
    required this.detailsSubmitted,
    required this.chargesEnabled,
    required this.payoutsEnabled,
    required this.requirementsPending,
    required this.onboardingCompletedAt,
    required this.readyAt,
  });

  final String? accountId;
  final SellerStripeReadinessStatus readiness;
  final bool detailsSubmitted;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final bool requirementsPending;
  final DateTime? onboardingCompletedAt;
  final DateTime? readyAt;

  bool get isReady => readiness == SellerStripeReadinessStatus.ready;
}

final class SellerStripeOnboardingLink {
  const SellerStripeOnboardingLink({
    required this.url,
    required this.accountId,
  });

  final Uri url;
  final String? accountId;
}

enum SellerStripeOnboardingFailure {
  unauthenticated,
  notAllowed,
  network,
  unknown,
}

final class SellerStripeOnboardingServiceException implements Exception {
  const SellerStripeOnboardingServiceException(
    this.failure, {
    this.backendCode,
    this.backendMessage,
  });

  final SellerStripeOnboardingFailure failure;
  final String? backendCode;
  final String? backendMessage;
}

class SellerStripeOnboardingService {
  SellerStripeOnboardingService(this._supabaseClient);

  static const _requestTimeout = Duration(seconds: 12);
  static const _createLinkFunction = 'create_seller_stripe_account_or_link';
  static const _refreshStatusFunction = 'refresh_seller_stripe_status';

  final SupabaseClient _supabaseClient;

  Future<SellerStripeStatusSnapshot> getCurrentSellerStripeStatus() async {
    final authUser = _supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw const SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.unauthenticated,
      );
    }

    try {
      final row = await _supabaseClient
          .from('users')
          .select(
            'stripe_account_id, stripe_details_submitted, stripe_charges_enabled, '
            'stripe_payouts_enabled, stripe_requirements_pending, '
            'stripe_onboarding_completed_at, stripe_ready_at',
          )
          .eq('id', authUser.id)
          .maybeSingle()
          .timeout(_requestTimeout);

      if (row == null) {
        throw const SellerStripeOnboardingServiceException(
          SellerStripeOnboardingFailure.notAllowed,
        );
      }

      return _mapSnapshotFromRow(row);
    } on SellerStripeOnboardingServiceException {
      rethrow;
    } on TimeoutException {
      throw const SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.network,
      );
    } on SocketException {
      throw const SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.network,
      );
    } on PostgrestException catch (_) {
      throw const SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.unknown,
      );
    } catch (_) {
      throw const SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.unknown,
      );
    }
  }

  Future<SellerStripeOnboardingLink> createOnboardingLink() async {
    try {
      final response = await _supabaseClient.functions
          .invoke(_createLinkFunction)
          .timeout(_requestTimeout);

      final data = _asMap(response.data);
      final urlString = _normalizedString(data['onboarding_url']);
      final uri = urlString == null ? null : Uri.tryParse(urlString);
      if (uri == null) {
        throw const SellerStripeOnboardingServiceException(
          SellerStripeOnboardingFailure.unknown,
        );
      }

      return SellerStripeOnboardingLink(
        url: uri,
        accountId: _normalizedString(data['stripe_account_id']),
      );
    } on SellerStripeOnboardingServiceException {
      rethrow;
    } on FunctionException catch (error) {
      throw _mapFunctionException(error);
    } on TimeoutException {
      throw const SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.network,
      );
    } on SocketException {
      throw const SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.network,
      );
    } catch (_) {
      throw const SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.unknown,
      );
    }
  }

  Future<SellerStripeStatusSnapshot> refreshSellerStripeStatus() async {
    try {
      final response = await _supabaseClient.functions
          .invoke(_refreshStatusFunction)
          .timeout(_requestTimeout);

      return _mapSnapshotFromRow(_asMap(response.data));
    } on SellerStripeOnboardingServiceException {
      rethrow;
    } on FunctionException catch (error) {
      throw _mapFunctionException(error);
    } on TimeoutException {
      throw const SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.network,
      );
    } on SocketException {
      throw const SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.network,
      );
    } catch (_) {
      throw const SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.unknown,
      );
    }
  }

  SellerStripeStatusSnapshot _mapSnapshotFromRow(Map<String, dynamic> row) {
    final accountId = _normalizedString(row['stripe_account_id']);
    final detailsSubmitted = row['stripe_details_submitted'] == true;
    final chargesEnabled = row['stripe_charges_enabled'] == true;
    final payoutsEnabled = row['stripe_payouts_enabled'] == true;
    final requirementsPending = row['stripe_requirements_pending'] != false;
    final readyAt = _parseIsoDate(row['stripe_ready_at']);

    return SellerStripeStatusSnapshot(
      accountId: accountId,
      readiness: _deriveReadiness(
        accountId: accountId,
        detailsSubmitted: detailsSubmitted,
        chargesEnabled: chargesEnabled,
        payoutsEnabled: payoutsEnabled,
        requirementsPending: requirementsPending,
        readyAt: readyAt,
      ),
      detailsSubmitted: detailsSubmitted,
      chargesEnabled: chargesEnabled,
      payoutsEnabled: payoutsEnabled,
      requirementsPending: requirementsPending,
      onboardingCompletedAt: _parseIsoDate(row['stripe_onboarding_completed_at']),
      readyAt: readyAt,
    );
  }

  SellerStripeReadinessStatus _deriveReadiness({
    required String? accountId,
    required bool detailsSubmitted,
    required bool chargesEnabled,
    required bool payoutsEnabled,
    required bool requirementsPending,
    required DateTime? readyAt,
  }) {
    if (accountId == null || accountId.isEmpty) {
      return SellerStripeReadinessStatus.notConnected;
    }

    if (!detailsSubmitted) {
      return SellerStripeReadinessStatus.onboardingInProgress;
    }

    if (payoutsEnabled &&
        !requirementsPending &&
        readyAt != null) {
      return SellerStripeReadinessStatus.ready;
    }

    return SellerStripeReadinessStatus.verificationPending;
  }

  SellerStripeOnboardingServiceException _mapFunctionException(
    FunctionException error,
  ) {
    final errorCode = _extractFunctionErrorCode(error.details);
    final backendMessage = _extractFunctionErrorMessage(error.details);

    if (error.status == 401) {
      return SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.unauthenticated,
        backendCode: errorCode,
        backendMessage: backendMessage,
      );
    }

    if (error.status == 403 || error.status == 404) {
      return SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.notAllowed,
        backendCode: errorCode,
        backendMessage: backendMessage,
      );
    }

    if (error.status == 408 || error.status == 429 || error.status >= 500) {
      return SellerStripeOnboardingServiceException(
        SellerStripeOnboardingFailure.network,
        backendCode: errorCode,
        backendMessage: backendMessage,
      );
    }

    return SellerStripeOnboardingServiceException(
      SellerStripeOnboardingFailure.unknown,
      backendCode: errorCode,
      backendMessage: backendMessage,
    );
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw const SellerStripeOnboardingServiceException(
      SellerStripeOnboardingFailure.unknown,
    );
  }

  String? _extractFunctionErrorCode(Object? details) {
    if (details is Map) {
      return _normalizedString(details['error']);
    }

    if (details is String && details.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(details);
        if (decoded is Map) {
          return _normalizedString(decoded['error']);
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  String? _extractFunctionErrorMessage(Object? details) {
    if (details is Map) {
      return _normalizedString(details['message']);
    }

    if (details is String && details.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(details);
        if (decoded is Map) {
          return _normalizedString(decoded['message']);
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  String? _normalizedString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  DateTime? _parseIsoDate(Object? value) {
    final normalized = _normalizedString(value);
    if (normalized == null) return null;
    return DateTime.tryParse(normalized);
  }
}
