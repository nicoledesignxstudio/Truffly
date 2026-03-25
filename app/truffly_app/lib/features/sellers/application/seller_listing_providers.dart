import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/sellers/application/seller_listing_notifier.dart';
import 'package:truffly_app/features/sellers/data/seller_listing_service.dart';
import 'package:truffly_app/features/sellers/domain/seller_listing_state.dart';

final sellerListingServiceProvider = Provider<SellerListingService>((ref) {
  return SellerListingService(ref.read(supabaseClientProvider));
});

final sellerListingNotifierProvider =
    NotifierProvider<SellerListingNotifier, SellerListingState>(
  SellerListingNotifier.new,
);
