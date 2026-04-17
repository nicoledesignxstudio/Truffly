final class SellerPublishAccess {
  const SellerPublishAccess({
    required this.role,
    required this.sellerStatus,
    required this.stripeAccountId,
    required this.stripeDetailsSubmitted,
    required this.stripeChargesEnabled,
    required this.stripePayoutsEnabled,
    required this.stripeRequirementsPending,
    required this.stripeReadyAt,
    required this.region,
  });

  final String role;
  final String sellerStatus;
  final String? stripeAccountId;
  final bool stripeDetailsSubmitted;
  final bool stripeChargesEnabled;
  final bool stripePayoutsEnabled;
  final bool stripeRequirementsPending;
  final DateTime? stripeReadyAt;
  final String? region;

  bool get isSeller => role == 'seller';
  bool get isApproved => sellerStatus == 'approved';
  bool get hasStripeAccount =>
      stripeAccountId != null && stripeAccountId!.trim().isNotEmpty;
  bool get isStripeReady =>
      hasStripeAccount &&
      stripeDetailsSubmitted &&
      stripePayoutsEnabled &&
      !stripeRequirementsPending &&
      stripeReadyAt != null;
  bool get canPublish => isSeller && isApproved && isStripeReady;
}
