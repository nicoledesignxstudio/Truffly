final class SellerPublishAccess {
  const SellerPublishAccess({
    required this.role,
    required this.sellerStatus,
    required this.stripeAccountId,
    required this.region,
  });

  final String role;
  final String sellerStatus;
  final String? stripeAccountId;
  final String? region;

  bool get isSeller => role == 'seller';
  bool get isApproved => sellerStatus == 'approved';
  bool get hasStripeAccount =>
      stripeAccountId != null && stripeAccountId!.trim().isNotEmpty;
  bool get canPublish => isSeller && isApproved && hasStripeAccount;
}
