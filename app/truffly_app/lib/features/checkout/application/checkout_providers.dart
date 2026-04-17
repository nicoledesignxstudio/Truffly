import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/checkout/data/checkout_payment_service.dart';

final checkoutPaymentServiceProvider = Provider<CheckoutPaymentService>((ref) {
  return CheckoutPaymentService(ref.read(supabaseClientProvider));
});
