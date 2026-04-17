import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/features/truffle/application/publish_truffle_providers.dart';
import 'package:truffly_app/features/truffle/data/publish_truffle_service.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_image_draft.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_state.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_submission_failure.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_submission_input.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_validation_failure.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

final publishTruffleNotifierProvider =
    AutoDisposeNotifierProvider<PublishTruffleNotifier, PublishTruffleState>(
  PublishTruffleNotifier.new,
);

final class PublishTruffleNotifier extends AutoDisposeNotifier<PublishTruffleState> {
  static final Random _random = Random.secure();

  @override
  PublishTruffleState build() {
    final initialState = PublishTruffleState.initial();
    return initialState.copyWith(
      validationFailures: _validate(initialState),
    );
  }

  void initialize({String? defaultRegion}) {
    if (defaultRegion == null || defaultRegion.trim().isEmpty) return;
    if (state.region == defaultRegion) return;

    _setState(
      state.copyWith(
        region: defaultRegion,
      ),
    );
  }

  void addImages(List<PublishTruffleImageDraft> images) {
    if (images.isEmpty) return;

    final nextImages = <PublishTruffleImageDraft>[...state.images];
    final knownPaths = nextImages.map((image) => image.localPath).toSet();

    for (final image in images) {
      if (nextImages.length >= PublishTruffleState.maxImages) break;
      if (knownPaths.add(image.localPath)) {
        nextImages.add(image);
      }
    }

    _setState(state.copyWith(images: nextImages));
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= state.images.length) return;
    final nextImages = [...state.images]..removeAt(index);
    _setState(state.copyWith(images: nextImages));
  }

  void updateQuality(TruffleQuality? quality) {
    _setState(state.copyWith(quality: quality));
  }

  void updateTruffleType(TruffleType? truffleType) {
    _setState(state.copyWith(truffleType: truffleType));
  }

  void updateWeightInput(String value) {
    _setState(state.copyWith(weightInput: value));
  }

  void updatePriceInput(String value) {
    _setState(state.copyWith(priceInput: value));
  }

  void updateShippingItalyInput(String value) {
    _setState(state.copyWith(shippingItalyInput: value));
  }

  void updateShippingAbroadInput(String value) {
    _setState(state.copyWith(shippingAbroadInput: value));
  }

  void updateRegion(String? region) {
    _setState(state.copyWith(region: region));
  }

  void updateHarvestDate(DateTime? harvestDate) {
    _setState(state.copyWith(harvestDate: harvestDate));
  }

  bool revealValidationErrors() {
    final validationFailures = _validate(state);
    state = state.copyWith(
      validationFailures: validationFailures,
      showValidationErrors: true,
      submitFailure: null,
      publishRequestId: null,
    );
    return validationFailures.isEmpty;
  }

  Future<bool> submit() async {
    final validationFailures = _validate(state);
    if (validationFailures.isNotEmpty) {
      state = state.copyWith(
        validationFailures: validationFailures,
        showValidationErrors: true,
        submitFailure: null,
        publishRequestId: null,
      );
      return false;
    }

    final input = _buildSubmissionInput(state);
    if (input == null) {
      state = state.copyWith(
        validationFailures: validationFailures,
        showValidationErrors: true,
        submitFailure: PublishTruffleSubmissionFailure.validation,
        publishRequestId: null,
      );
      return false;
    }

    final publishRequestId = state.publishRequestId ?? _generatePublishRequestId();
    state = state.copyWith(
      isSubmitting: true,
      validationFailures: validationFailures,
      showValidationErrors: true,
      submitFailure: null,
      publishRequestId: publishRequestId,
    );

    try {
      await ref.read(publishTruffleServiceProvider).publishTruffle(
            input,
            publishRequestId: publishRequestId,
          );
      state = state.copyWith(
        isSubmitting: false,
        showValidationErrors: false,
        submitFailure: null,
        publishRequestId: null,
      );
      return true;
    } on PublishTruffleServiceException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        submitFailure: error.failure,
        publishRequestId:
            _shouldPreservePublishRequestId(error.failure) ? publishRequestId : null,
      );
      return false;
    }
  }

  void clearSubmitFailure() {
    if (state.submitFailure == null) return;
    state = state.copyWith(submitFailure: null);
  }

  void _setState(PublishTruffleState nextState) {
    state = nextState.copyWith(
      publishRequestId: null,
      validationFailures: _validate(nextState),
      showValidationErrors: state.showValidationErrors,
      submitFailure: null,
    );
  }

  bool _shouldPreservePublishRequestId(
    PublishTruffleSubmissionFailure failure,
  ) {
    return failure == PublishTruffleSubmissionFailure.network ||
        failure == PublishTruffleSubmissionFailure.inProgress;
  }

  String _generatePublishRequestId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    String hexByte(int value) => value.toRadixString(16).padLeft(2, '0');
    final hex = bytes.map(hexByte).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }

  List<PublishTruffleValidationFailure> _validate(PublishTruffleState snapshot) {
    final failures = <PublishTruffleValidationFailure>[];

    if (snapshot.images.isEmpty) {
      failures.add(PublishTruffleValidationFailure.imagesRequired);
    } else if (snapshot.images.length > PublishTruffleState.maxImages) {
      failures.add(PublishTruffleValidationFailure.imagesTooMany);
    }

    if (snapshot.quality == null) {
      failures.add(PublishTruffleValidationFailure.qualityRequired);
    }

    if (snapshot.truffleType == null) {
      failures.add(PublishTruffleValidationFailure.typeRequired);
    }

    _validatePositiveInt(
      value: snapshot.weightInput,
      requiredFailure: PublishTruffleValidationFailure.weightRequired,
      invalidFailure: PublishTruffleValidationFailure.weightInvalid,
      failures: failures,
    );

    _validatePositiveDouble(
      value: snapshot.priceInput,
      requiredFailure: PublishTruffleValidationFailure.totalPriceRequired,
      invalidFailure: PublishTruffleValidationFailure.totalPriceInvalid,
      failures: failures,
    );

    _validateNonNegativeDouble(
      value: snapshot.shippingItalyInput,
      requiredFailure: PublishTruffleValidationFailure.shippingItalyRequired,
      invalidFailure: PublishTruffleValidationFailure.shippingItalyInvalid,
      failures: failures,
    );

    _validateNonNegativeDouble(
      value: snapshot.shippingAbroadInput,
      requiredFailure: PublishTruffleValidationFailure.shippingAbroadRequired,
      invalidFailure: PublishTruffleValidationFailure.shippingAbroadInvalid,
      failures: failures,
    );

    final region = snapshot.region?.trim();
    if (region == null || region.isEmpty) {
      failures.add(PublishTruffleValidationFailure.regionRequired);
    }

    final harvestDate = snapshot.harvestDate;
    if (harvestDate == null) {
      failures.add(PublishTruffleValidationFailure.harvestDateRequired);
    } else {
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final normalizedHarvestDate = DateTime(
        harvestDate.year,
        harvestDate.month,
        harvestDate.day,
      );
      if (normalizedHarvestDate.isAfter(normalizedToday)) {
        failures.add(PublishTruffleValidationFailure.harvestDateFuture);
      }
    }

    return failures;
  }

  PublishTruffleSubmissionInput? _buildSubmissionInput(
    PublishTruffleState snapshot,
  ) {
    final weight = _parsePositiveInt(snapshot.weightInput);
    final priceTotal = _parsePositiveDouble(snapshot.priceInput);
    final shippingItaly = _parseNonNegativeDouble(snapshot.shippingItalyInput);
    final shippingAbroad = _parseNonNegativeDouble(snapshot.shippingAbroadInput);
    final region = snapshot.region?.trim();

    if (snapshot.truffleType == null ||
        snapshot.quality == null ||
        weight == null ||
        priceTotal == null ||
        shippingItaly == null ||
        shippingAbroad == null ||
        region == null ||
        region.isEmpty ||
        snapshot.harvestDate == null ||
        snapshot.images.isEmpty ||
        snapshot.images.length > PublishTruffleState.maxImages) {
      return null;
    }

    return PublishTruffleSubmissionInput(
      truffleType: snapshot.truffleType!,
      quality: snapshot.quality!,
      weightGrams: weight,
      priceTotal: priceTotal,
      shippingPriceItaly: shippingItaly,
      shippingPriceAbroad: shippingAbroad,
      region: region,
      harvestDate: snapshot.harvestDate!,
      images: snapshot.images,
    );
  }

  void _validatePositiveInt({
    required String value,
    required PublishTruffleValidationFailure requiredFailure,
    required PublishTruffleValidationFailure invalidFailure,
    required List<PublishTruffleValidationFailure> failures,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      failures.add(requiredFailure);
      return;
    }

    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      failures.add(invalidFailure);
    }
  }

  void _validatePositiveDouble({
    required String value,
    required PublishTruffleValidationFailure requiredFailure,
    required PublishTruffleValidationFailure invalidFailure,
    required List<PublishTruffleValidationFailure> failures,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      failures.add(requiredFailure);
      return;
    }

    final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      failures.add(invalidFailure);
    }
  }

  void _validateNonNegativeDouble({
    required String value,
    required PublishTruffleValidationFailure requiredFailure,
    required PublishTruffleValidationFailure invalidFailure,
    required List<PublishTruffleValidationFailure> failures,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      failures.add(requiredFailure);
      return;
    }

    final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
    if (parsed == null || parsed < 0) {
      failures.add(invalidFailure);
    }
  }

  int? _parsePositiveInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  double? _parsePositiveDouble(String value) {
    final trimmed = value.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) return null;
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  double? _parseNonNegativeDouble(String value) {
    final trimmed = value.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) return null;
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0) return null;
    return parsed;
  }
}
