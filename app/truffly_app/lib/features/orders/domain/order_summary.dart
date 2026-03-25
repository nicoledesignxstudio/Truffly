import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

final class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.truffleId,
    required this.type,
    required this.quality,
    required this.weightGrams,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.trackingCode,
    required this.primaryImageUrl,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.sellerProfileImageUrl,
  });

  final String id;
  final String truffleId;
  final TruffleType type;
  final TruffleQuality quality;
  final int weightGrams;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final String? trackingCode;
  final String? primaryImageUrl;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String? sellerProfileImageUrl;

  String shortReference() {
    final normalized = id.replaceAll('-', '').toUpperCase();
    final suffix = normalized.length <= 6
        ? normalized
        : normalized.substring(normalized.length - 6);
    return '#$suffix';
  }
}
