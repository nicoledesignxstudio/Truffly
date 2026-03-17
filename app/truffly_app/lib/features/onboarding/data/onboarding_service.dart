import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/domain/auth_failure.dart';
import 'package:truffly_app/features/onboarding/data/models/complete_buyer_onboarding_input.dart';
import 'package:truffly_app/features/onboarding/data/models/notification_permission_result.dart';
import 'package:truffly_app/features/onboarding/data/models/submit_seller_onboarding_input.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_draft.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_state.dart';

abstract interface class OnboardingService {
  Future<void> completeBuyerOnboarding(CompleteBuyerOnboardingInput input);

  Future<void> submitSellerOnboarding(SubmitSellerOnboardingInput input);

  Future<NotificationPermissionResult> requestNotificationPermission();
}

final class OnboardingSubmissionException implements Exception {
  const OnboardingSubmissionException(this.failure);

  final OnboardingSubmissionFailure failure;
}

final class UnimplementedOnboardingService implements OnboardingService {
  const UnimplementedOnboardingService();

  @override
  Future<void> completeBuyerOnboarding(CompleteBuyerOnboardingInput input) {
    throw const OnboardingSubmissionException(
      OnboardingSubmissionFailure.unimplemented,
    );
  }

  @override
  Future<NotificationPermissionResult> requestNotificationPermission() {
    return _fallbackNotificationPermissionResult();
  }

  @override
  Future<void> submitSellerOnboarding(SubmitSellerOnboardingInput input) {
    throw const OnboardingSubmissionException(
      OnboardingSubmissionFailure.unimplemented,
    );
  }
}

final class AppOnboardingService implements OnboardingService {
  AppOnboardingService({
    required SupabaseClient supabaseClient,
    required ProfileService profileService,
    required Future<AuthResult<AuthUnit>> Function() refreshAuthState,
  }) : _supabaseClient = supabaseClient,
       _profileService = profileService,
       _refreshAuthState = refreshAuthState;

  static const _submitSellerApplicationFunction = 'submit_seller_application';

  final SupabaseClient _supabaseClient;
  final ProfileService _profileService;
  final Future<AuthResult<AuthUnit>> Function() _refreshAuthState;

  @override
  Future<void> completeBuyerOnboarding(CompleteBuyerOnboardingInput input) async {
    final persistenceResult = await _profileService.completeBuyerOnboarding(
      firstName: input.firstName,
      lastName: input.lastName,
      countryCode: input.countryCode,
      region: input.region,
    );

    if (persistenceResult is AuthFailureResult<AuthUnit>) {
      throw OnboardingSubmissionException(
        _mapAuthFailureToSubmissionFailure(persistenceResult.failure),
      );
    }

    final refreshResult = await _refreshAuthState();
    if (refreshResult is AuthFailureResult<AuthUnit>) {
      throw OnboardingSubmissionException(
        _mapAuthFailureToSubmissionFailure(refreshResult.failure),
      );
    }
  }

  @override
  Future<NotificationPermissionResult> requestNotificationPermission() {
    return _fallbackNotificationPermissionResult();
  }

  @override
  Future<void> submitSellerOnboarding(SubmitSellerOnboardingInput input) async {
    try {
      final payload = await _buildSubmitSellerApplicationPayload(input);

      final response = await _supabaseClient.functions.invoke(
        _submitSellerApplicationFunction,
        body: payload,
      );

      if (!_isSuccessfulSellerSubmitResponse(response.data)) {
        throw const OnboardingSubmissionException(
          OnboardingSubmissionFailure.unknown,
        );
      }

      final refreshResult = await _refreshAuthState();
      if (refreshResult is AuthFailureResult<AuthUnit>) {
        throw OnboardingSubmissionException(
          _mapAuthFailureToSubmissionFailure(refreshResult.failure),
        );
      }
    } on OnboardingSubmissionException {
      rethrow;
    } on FunctionException catch (error) {
      throw OnboardingSubmissionException(
        _mapFunctionExceptionToSubmissionFailure(error),
      );
    } on TimeoutException {
      throw const OnboardingSubmissionException(
        OnboardingSubmissionFailure.network,
      );
    } on SocketException {
      throw const OnboardingSubmissionException(
        OnboardingSubmissionFailure.network,
      );
    } on HttpException {
      throw const OnboardingSubmissionException(
        OnboardingSubmissionFailure.network,
      );
    } on FileSystemException {
      throw const OnboardingSubmissionException(
        OnboardingSubmissionFailure.documentUpload,
      );
    } catch (_) {
      throw const OnboardingSubmissionException(
        OnboardingSubmissionFailure.unknown,
      );
    }
  }

  OnboardingSubmissionFailure _mapAuthFailureToSubmissionFailure(
    AuthFailure failure,
  ) {
    return switch (failure) {
      NetworkErrorFailure() || TimeoutFailure() => OnboardingSubmissionFailure.network,
      InvalidCredentialsFailure() ||
      EmailNotVerifiedFailure() ||
      EmailAlreadyUsedFailure() ||
      ResetLinkInvalidFailure() => OnboardingSubmissionFailure.validation,
      UserProfileMissingFailure() ||
      UnauthenticatedFailure() ||
      UnknownAuthFailure() => OnboardingSubmissionFailure.unknown,
    };
  }

  Future<Map<String, dynamic>> _buildSubmitSellerApplicationPayload(
    SubmitSellerOnboardingInput input,
  ) async {
    return {
      'first_name': input.firstName,
      'last_name': input.lastName,
      'country_code': input.countryCode,
      'region': input.region,
      'tesserino_number': input.tesserinoNumber,
      'identity_document': await _readDocumentPayload(input.identityDocument),
      'tesserino_document': await _readDocumentPayload(input.tesserinoDocument),
    };
  }

  Future<Map<String, String>> _readDocumentPayload(
    OnboardingLocalDocument inputDocument,
  ) async {
    final file = File(inputDocument.localPath);
    if (!await file.exists()) {
      throw const OnboardingSubmissionException(
        OnboardingSubmissionFailure.documentUpload,
      );
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const OnboardingSubmissionException(
        OnboardingSubmissionFailure.documentUpload,
      );
    }

    return {
      'file_name': inputDocument.fileName,
      'content_base64': base64Encode(bytes),
      'content_type': _contentTypeForFileName(inputDocument.fileName),
    };
  }

  OnboardingSubmissionFailure _mapFunctionExceptionToSubmissionFailure(
    FunctionException error,
  ) {
    final errorCode = _extractFunctionErrorCode(error.details);

    if (_isSellerValidationErrorCode(errorCode)) {
      return OnboardingSubmissionFailure.validation;
    }

    if (error.status == 400 || error.status == 409 || error.status == 422) {
      return OnboardingSubmissionFailure.validation;
    }

    if (error.status == 401 || error.status == 403 || error.status == 404) {
      return OnboardingSubmissionFailure.unknown;
    }

    if (error.status >= 500) {
      return OnboardingSubmissionFailure.server;
    }

    return OnboardingSubmissionFailure.unknown;
  }

  String _contentTypeForFileName(String fileName) {
    final normalized = fileName.toLowerCase();
    if (normalized.endsWith('.pdf')) {
      return 'application/pdf';
    }
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }
    if (normalized.endsWith('.jpg') || normalized.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    return 'application/octet-stream';
  }

  bool _isSuccessfulSellerSubmitResponse(Object? data) {
    if (data is! Map) return false;

    final success = data['success'];
    final sellerStatus = data['seller_status'];
    final onboardingCompleted = data['onboarding_completed'];
    final countryCode = data['country_code'];

    return success == true &&
        sellerStatus == 'pending' &&
        onboardingCompleted == true &&
        countryCode == 'IT';
  }

  String? _extractFunctionErrorCode(Object? details) {
    if (details is Map) {
      final error = details['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }
    }

    if (details is String && details.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(details);
        if (decoded is Map) {
          final error = decoded['error'];
          if (error is String && error.trim().isNotEmpty) {
            return error.trim();
          }
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  bool _isSellerValidationErrorCode(String? errorCode) {
    return switch (errorCode) {
      'invalid_json_body' ||
      'invalid_payload' ||
      'missing_first_name' ||
      'missing_last_name' ||
      'invalid_country_code' ||
      'missing_region' ||
      'missing_tesserino_number' ||
      'invalid_identity_document' ||
      'invalid_tesserino_document' ||
      'invalid_document_encoding' ||
      'duplicate_tesserino_number' ||
      'invalid_region' ||
      'onboarding_already_completed' ||
      'seller_application_not_allowed' => true,
      _ => false,
    };
  }
}

Future<NotificationPermissionResult> _fallbackNotificationPermissionResult() {
  // TODO: replace with a real platform permission implementation.
  // For now, return a non-throwing result so the notifications step keeps
  // working and remains explicitly user-driven.
  return Future.value(NotificationPermissionResult.denied);
}
