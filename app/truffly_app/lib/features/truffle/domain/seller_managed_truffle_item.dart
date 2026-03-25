import 'package:truffly_app/features/truffle/domain/truffle_list_item.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_status.dart';

final class SellerManagedTruffleItem {
  const SellerManagedTruffleItem({
    required this.id,
    required this.status,
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
  final SellerManagedTruffleStatus status;
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

  TruffleListItem toTruffleListItem() {
    return TruffleListItem(
      id: id,
      type: type,
      quality: quality,
      weightGrams: weightGrams,
      priceTotal: priceTotal,
      shippingPriceItaly: shippingPriceItaly,
      shippingPriceAbroad: shippingPriceAbroad,
      region: region,
      harvestDate: harvestDate,
      createdAt: createdAt,
      expiresAt: expiresAt,
      primaryImageUrl: primaryImageUrl,
    );
  }
}
