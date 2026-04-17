import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_image_draft.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_submission_failure.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_submission_input.dart';
import 'package:truffly_app/features/truffle/domain/seller_publish_access.dart';

final class PublishTruffleServiceException implements Exception {
  const PublishTruffleServiceException(this.failure);

  final PublishTruffleSubmissionFailure failure;
}

final class PublishTruffleService {
  PublishTruffleService(this._supabaseClient);

  static const _requestTimeout = Duration(seconds: 12);
  static const _publishTruffleFunction = 'publish_truffle';
  static const _truffleImagesStagingBucket = 'truffle_images_staging';
  static const _stagingPrefix = 'staging';

  final SupabaseClient _supabaseClient;

  Future<SellerPublishAccess> getCurrentSellerPublishAccess() async {
    final authUser = _supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.unauthenticated,
      );
    }

    try {
      final row = await _supabaseClient
          .from('users')
          .select(
            'role, seller_status, stripe_account_id, stripe_details_submitted, '
            'stripe_charges_enabled, stripe_payouts_enabled, '
            'stripe_requirements_pending, stripe_ready_at, region',
          )
          .eq('id', authUser.id)
          .maybeSingle()
          .timeout(_requestTimeout);

      if (row == null) {
        throw const PublishTruffleServiceException(
          PublishTruffleSubmissionFailure.notAllowed,
        );
      }

      return SellerPublishAccess(
        role: (row['role'] as String? ?? '').trim().toLowerCase(),
        sellerStatus: (row['seller_status'] as String? ?? '').trim().toLowerCase(),
        stripeAccountId: row['stripe_account_id'] as String?,
        stripeDetailsSubmitted: row['stripe_details_submitted'] == true,
        stripeChargesEnabled: row['stripe_charges_enabled'] == true,
        stripePayoutsEnabled: row['stripe_payouts_enabled'] == true,
        stripeRequirementsPending: row['stripe_requirements_pending'] != false,
        stripeReadyAt: _parseIsoDate(row['stripe_ready_at']),
        region: row['region'] as String?,
      );
    } on PublishTruffleServiceException {
      rethrow;
    } on TimeoutException {
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.network,
      );
    } on SocketException {
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.network,
      );
    } on PostgrestException catch (error) {
      throw PublishTruffleServiceException(_mapPostgrestFailure(error));
    } catch (_) {
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.unknown,
      );
    }
  }

  Future<void> publishTruffle(
    PublishTruffleSubmissionInput input, {
    required String publishRequestId,
  }) async {
    _validateInputShape(input);

    final authUser = _supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.unauthenticated,
      );
    }

    List<_StagedPublishImage> stagedImages = const [];
    var functionInvocationStarted = false;

    try {
      stagedImages = await _uploadImagesToStaging(
        images: input.images,
        userId: authUser.id,
      );

      final payload = _buildPublishPayload(
        input: input,
        publishRequestId: publishRequestId,
        stagedImages: stagedImages,
      );

      functionInvocationStarted = true;
      final response = await _supabaseClient.functions
          .invoke(
            _publishTruffleFunction,
            body: payload,
          )
          .timeout(_requestTimeout);

      if (!_isSuccessfulPublishResponse(response.data)) {
        throw const PublishTruffleServiceException(
          PublishTruffleSubmissionFailure.unknown,
        );
      }
    } on PublishTruffleServiceException {
      if (!functionInvocationStarted) {
        await _cleanupStagingUploads(stagedImages);
      }
      rethrow;
    } on FunctionException catch (error) {
      if (!functionInvocationStarted) {
        await _cleanupStagingUploads(stagedImages);
      }
      throw PublishTruffleServiceException(
        _mapFunctionExceptionToSubmissionFailure(error),
      );
    } on TimeoutException {
      if (!functionInvocationStarted) {
        await _cleanupStagingUploads(stagedImages);
      }
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.network,
      );
    } on SocketException {
      if (!functionInvocationStarted) {
        await _cleanupStagingUploads(stagedImages);
      }
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.network,
      );
    } on StorageException {
      await _cleanupStagingUploads(stagedImages);
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.imageUpload,
      );
    } on FileSystemException {
      await _cleanupStagingUploads(stagedImages);
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.invalidImage,
      );
    } on PostgrestException catch (error) {
      if (!functionInvocationStarted) {
        await _cleanupStagingUploads(stagedImages);
      }
      throw PublishTruffleServiceException(_mapPostgrestFailure(error));
    } catch (_) {
      if (!functionInvocationStarted) {
        await _cleanupStagingUploads(stagedImages);
      }
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.unknown,
      );
    }
  }

  void _validateInputShape(PublishTruffleSubmissionInput input) {
    if (input.images.isEmpty || input.images.length > 3) {
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.validation,
      );
    }

    if (input.weightGrams <= 0 ||
        input.priceTotal <= 0 ||
        input.shippingPriceItaly < 0 ||
        input.shippingPriceAbroad < 0) {
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.validation,
      );
    }

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedHarvestDate = DateTime(
      input.harvestDate.year,
      input.harvestDate.month,
      input.harvestDate.day,
    );
    if (normalizedHarvestDate.isAfter(normalizedToday)) {
      throw const PublishTruffleServiceException(
        PublishTruffleSubmissionFailure.validation,
      );
    }
  }

  Map<String, dynamic> _buildPublishPayload({
    required PublishTruffleSubmissionInput input,
    required String publishRequestId,
    required List<_StagedPublishImage> stagedImages,
  }) {
    return {
      'publish_request_id': publishRequestId,
      'truffle_type': input.truffleType.dbValue,
      'quality': input.quality.dbValue,
      'weight_grams': input.weightGrams,
      'price_total': input.priceTotal,
      'shipping_price_italy': input.shippingPriceItaly,
      'shipping_price_abroad': input.shippingPriceAbroad,
      'region': input.region,
      'harvest_date': _formatDateOnly(input.harvestDate),
      'images': [
        for (final image in stagedImages)
          {
            'staging_path': image.stagingPath,
          },
      ],
    };
  }

  Future<List<_StagedPublishImage>> _uploadImagesToStaging({
    required List<PublishTruffleImageDraft> images,
    required String userId,
  }) async {
    final stagedImages = <_StagedPublishImage>[];
    final storage = _supabaseClient.storage.from(_truffleImagesStagingBucket);

    for (var index = 0; index < images.length; index++) {
      final image = images[index];
      final file = File(image.localPath);
      if (!await file.exists()) {
        throw const PublishTruffleServiceException(
          PublishTruffleSubmissionFailure.invalidImage,
        );
      }

      final stagingPath = _buildStagingPath(
        userId: userId,
        imageIndex: index,
        fileName: image.fileName,
      );

      await storage.upload(
        stagingPath,
        file,
        fileOptions: FileOptions(
          contentType: image.contentType,
          upsert: false,
        ),
      );

      stagedImages.add(
        _StagedPublishImage(
          stagingPath: stagingPath,
        ),
      );
    }

    return stagedImages;
  }

  Future<void> _cleanupStagingUploads(List<_StagedPublishImage> stagedImages) async {
    if (stagedImages.isEmpty) return;

    try {
      await _supabaseClient.storage.from(_truffleImagesStagingBucket).remove([
        for (final image in stagedImages) image.stagingPath,
      ]);
    } catch (_) {
      // Cleanup is best-effort because the server-side flow is the source of truth.
    }
  }

  String _buildStagingPath({
    required String userId,
    required int imageIndex,
    required String fileName,
  }) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final normalizedName = _normalizedStorageFileName(fileName);
    return '$_stagingPrefix/$userId/${timestamp}_${imageIndex}_$normalizedName';
  }

  String _normalizedStorageFileName(String fileName) {
    final sanitized = fileName
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    if (sanitized.isEmpty) {
      return 'publish_image';
    }

    return sanitized;
  }

  PublishTruffleSubmissionFailure _mapPostgrestFailure(PostgrestException error) {
    final message = error.message.toLowerCase();

    if (message.contains('fetch') || message.contains('network')) {
      return PublishTruffleSubmissionFailure.network;
    }

    if (message.contains('row-level security') ||
        message.contains('permission denied') ||
        error.code == '42501') {
      return PublishTruffleSubmissionFailure.notAllowed;
    }

    if (error.code == '23514' ||
        error.code == '22P02' ||
        message.contains('check constraint')) {
      return PublishTruffleSubmissionFailure.validation;
    }

    return PublishTruffleSubmissionFailure.unknown;
  }

  PublishTruffleSubmissionFailure _mapFunctionExceptionToSubmissionFailure(
    FunctionException error,
  ) {
    final errorCode = _extractFunctionErrorCode(error.details);

    if (_isInvalidImageErrorCode(errorCode)) {
      return PublishTruffleSubmissionFailure.invalidImage;
    }

    if (errorCode == 'publish_image_upload_failed' ||
        errorCode == 'publish_image_cleanup_failed') {
      return PublishTruffleSubmissionFailure.imageUpload;
    }

    if (errorCode == 'publish_request_in_progress') {
      return PublishTruffleSubmissionFailure.inProgress;
    }

    if (_isValidationErrorCode(errorCode)) {
      return PublishTruffleSubmissionFailure.validation;
    }

    if (_isNotAllowedErrorCode(errorCode)) {
      return PublishTruffleSubmissionFailure.notAllowed;
    }

    if (errorCode == 'seller_stripe_verification_unavailable') {
      return PublishTruffleSubmissionFailure.network;
    }

    if (error.status == 400 || error.status == 409 || error.status == 422) {
      return PublishTruffleSubmissionFailure.validation;
    }

    if (error.status == 401 || error.status == 403 || error.status == 404) {
      return PublishTruffleSubmissionFailure.notAllowed;
    }

    if (error.status >= 500) {
      return PublishTruffleSubmissionFailure.unknown;
    }

    return PublishTruffleSubmissionFailure.unknown;
  }

  bool _isSuccessfulPublishResponse(Object? data) {
    if (data is! Map) return false;

    return data['success'] == true &&
        data['status'] == 'active' &&
        data['truffle_id'] is String &&
        (data['truffle_id'] as String).trim().isNotEmpty;
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

  bool _isValidationErrorCode(String? errorCode) {
    return switch (errorCode) {
      'invalid_json_body' ||
      'invalid_payload' ||
      'missing_publish_request_id' ||
      'invalid_truffle_type' ||
      'invalid_quality' ||
      'invalid_weight_grams' ||
      'invalid_price_total' ||
      'invalid_shipping_price_italy' ||
      'invalid_shipping_price_abroad' ||
      'missing_region' ||
      'invalid_region' ||
      'missing_harvest_date' ||
      'invalid_harvest_date' ||
      'harvest_date_in_future' ||
      'missing_images' ||
      'too_many_images' ||
      'publish_request_payload_mismatch' ||
      'publish_validation_failed' => true,
      _ => false,
    };
  }

  bool _isInvalidImageErrorCode(String? errorCode) {
    return switch (errorCode) {
      'invalid_image_payload' ||
      'invalid_image_encoding' ||
      'invalid_image_type' ||
      'invalid_image_size' => true,
      _ => false,
    };
  }

  bool _isNotAllowedErrorCode(String? errorCode) {
    return switch (errorCode) {
      'method_not_allowed' ||
      'unauthorized' ||
      'user_not_found' ||
      'inactive_account' ||
      'seller_not_allowed' => true,
      _ => false,
    };
  }

  String _formatDateOnly(DateTime value) {
    final normalized = DateTime(value.year, value.month, value.day);
    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTime? _parseIsoDate(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return DateTime.tryParse(trimmed);
  }
}

final class _StagedPublishImage {
  const _StagedPublishImage({
    required this.stagingPath,
  });

  final String stagingPath;
}
