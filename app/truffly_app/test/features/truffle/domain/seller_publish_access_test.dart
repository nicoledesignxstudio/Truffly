import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/truffle/domain/seller_publish_access.dart';

void main() {
  test('publish remains blocked when seller is not Stripe-ready', () {
    const access = SellerPublishAccess(
      role: 'seller',
      sellerStatus: 'approved',
      stripeAccountId: 'acct_test',
      stripeDetailsSubmitted: true,
      stripeChargesEnabled: true,
      stripePayoutsEnabled: false,
      stripeRequirementsPending: false,
      stripeReadyAt: null,
      region: 'TOSCANA',
    );

    expect(access.canPublish, isFalse);
    expect(access.isStripeReady, isFalse);
  });

  test('publish is allowed only when seller is fully Stripe-ready', () {
    final access = SellerPublishAccess(
      role: 'seller',
      sellerStatus: 'approved',
      stripeAccountId: 'acct_test',
      stripeDetailsSubmitted: true,
      stripeChargesEnabled: false,
      stripePayoutsEnabled: true,
      stripeRequirementsPending: false,
      stripeReadyAt: DateTime.parse('2026-03-29T10:00:00.000Z'),
      region: 'TOSCANA',
    );

    expect(access.isStripeReady, isTrue);
    expect(access.canPublish, isTrue);
  });
}
