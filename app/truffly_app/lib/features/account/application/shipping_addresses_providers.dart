import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/account/data/shipping_addresses_service.dart';

final shippingAddressesServiceProvider = Provider<ShippingAddressesService>((
  ref,
) {
  return ShippingAddressesService(ref.read(supabaseClientProvider));
});
