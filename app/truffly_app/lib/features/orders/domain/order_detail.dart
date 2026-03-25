import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

final class OrderDetail {
  const OrderDetail({
    required this.id,
    required this.truffleId,
    required this.type,
    required this.quality,
    required this.weightGrams,
    required this.totalPrice,
    required this.commissionAmount,
    required this.sellerAmount,
    required this.status,
    required this.createdAt,
    required this.trackingCode,
    required this.primaryImageUrl,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.sellerProfileImageUrl,
    required this.shippingFullName,
    required this.shippingStreet,
    required this.shippingCity,
    required this.shippingPostalCode,
    required this.shippingCountryCode,
    required this.shippingPhone,
  });

  final String id;
  final String truffleId;
  final TruffleType type;
  final TruffleQuality quality;
  final int weightGrams;
  final double totalPrice;
  final double commissionAmount;
  final double sellerAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final String? trackingCode;
  final String? primaryImageUrl;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String? sellerProfileImageUrl;
  final String shippingFullName;
  final String shippingStreet;
  final String shippingCity;
  final String shippingPostalCode;
  final String shippingCountryCode;
  final String shippingPhone;
}
