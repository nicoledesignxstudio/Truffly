import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

final class TruffleListItem {
  const TruffleListItem({
    required this.id,
    required this.type,
    required this.quality,
    required this.weightGrams,
    required this.priceTotal,
    required this.shippingPriceItaly,
    required this.shippingPriceAbroad,
    required this.region,
    required this.harvestDate,
    required this.createdAt,
    required this.expiresAt,
    required this.primaryImageUrl,
  });

  final String id;
  final TruffleType type;
  final TruffleQuality quality;
  final int weightGrams;
  final double priceTotal;
  final double shippingPriceItaly;
  final double shippingPriceAbroad;
  final String region;
  final DateTime harvestDate;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? primaryImageUrl;
}
