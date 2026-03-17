import 'package:truffly_app/features/truffle/domain/publish_truffle_image_draft.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

final class PublishTruffleSubmissionInput {
  const PublishTruffleSubmissionInput({
    required this.truffleType,
    required this.quality,
    required this.weightGrams,
    required this.priceTotal,
    required this.shippingPriceItaly,
    required this.shippingPriceAbroad,
    required this.region,
    required this.harvestDate,
    required this.images,
  });

  final TruffleType truffleType;
  final TruffleQuality quality;
  final int weightGrams;
  final double priceTotal;
  final double shippingPriceItaly;
  final double shippingPriceAbroad;
  final String region;
  final DateTime harvestDate;
  final List<PublishTruffleImageDraft> images;
}
