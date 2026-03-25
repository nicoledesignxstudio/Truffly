import 'package:truffly_app/features/truffle/domain/publish_truffle_image_draft.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_submission_failure.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_validation_failure.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

final class PublishTruffleState {
  const PublishTruffleState({
    this.images = const [],
    this.publishRequestId,
    this.quality,
    this.truffleType,
    this.weightInput = '',
    this.priceInput = '',
    this.shippingItalyInput = '',
    this.shippingAbroadInput = '',
    this.region,
    this.harvestDate,
    this.validationFailures = const [],
    this.showValidationErrors = false,
    this.submitFailure,
    this.isSubmitting = false,
  });

  static const maxImages = 3;

  final List<PublishTruffleImageDraft> images;
  final String? publishRequestId;
  final TruffleQuality? quality;
  final TruffleType? truffleType;
  final String weightInput;
  final String priceInput;
  final String shippingItalyInput;
  final String shippingAbroadInput;
  final String? region;
  final DateTime? harvestDate;
  final List<PublishTruffleValidationFailure> validationFailures;
  final bool showValidationErrors;
  final PublishTruffleSubmissionFailure? submitFailure;
  final bool isSubmitting;

  String get latinName => truffleType?.latinName ?? '';
  bool get hasImages => images.isNotEmpty;
  bool get hasReachedImageLimit => images.length >= maxImages;
  bool get isFormValid => validationFailures.isEmpty && !isSubmitting;

  double? get pricePerKgPreview {
    final weight = _parsePositiveInt(weightInput);
    final price = _parsePositiveDouble(priceInput);
    if (weight == null || price == null) return null;
    return (price / weight) * 1000;
  }

  PublishTruffleState copyWith({
    List<PublishTruffleImageDraft>? images,
    Object? publishRequestId = _sentinel,
    Object? quality = _sentinel,
    Object? truffleType = _sentinel,
    String? weightInput,
    String? priceInput,
    String? shippingItalyInput,
    String? shippingAbroadInput,
    Object? region = _sentinel,
    Object? harvestDate = _sentinel,
    List<PublishTruffleValidationFailure>? validationFailures,
    bool? showValidationErrors,
    Object? submitFailure = _sentinel,
    bool? isSubmitting,
  }) {
    return PublishTruffleState(
      images: images ?? this.images,
      publishRequestId: identical(publishRequestId, _sentinel)
          ? this.publishRequestId
          : publishRequestId as String?,
      quality: identical(quality, _sentinel)
          ? this.quality
          : quality as TruffleQuality?,
      truffleType: identical(truffleType, _sentinel)
          ? this.truffleType
          : truffleType as TruffleType?,
      weightInput: weightInput ?? this.weightInput,
      priceInput: priceInput ?? this.priceInput,
      shippingItalyInput: shippingItalyInput ?? this.shippingItalyInput,
      shippingAbroadInput: shippingAbroadInput ?? this.shippingAbroadInput,
      region: identical(region, _sentinel) ? this.region : region as String?,
      harvestDate: identical(harvestDate, _sentinel)
          ? this.harvestDate
          : harvestDate as DateTime?,
      validationFailures: validationFailures ?? this.validationFailures,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      submitFailure: identical(submitFailure, _sentinel)
          ? this.submitFailure
          : submitFailure as PublishTruffleSubmissionFailure?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  static PublishTruffleState initial() =>
      const PublishTruffleState(quality: TruffleQuality.first);

  static int? _parsePositiveInt(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return null;
    final value = int.tryParse(trimmed);
    if (value == null || value <= 0) return null;
    return value;
  }

  static double? _parsePositiveDouble(String rawValue) {
    final trimmed = rawValue.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) return null;
    final value = double.tryParse(trimmed);
    if (value == null || value <= 0) return null;
    return value;
  }
}

const Object _sentinel = Object();
