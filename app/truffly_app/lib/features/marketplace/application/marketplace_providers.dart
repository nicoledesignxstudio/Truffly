import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/marketplace/application/truffle_listing_notifier.dart';
import 'package:truffly_app/features/marketplace/data/marketplace_service.dart';
import 'package:truffly_app/features/marketplace/domain/truffle_listing_state.dart';

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService(ref.read(supabaseClientProvider));
});

final truffleListingNotifierProvider =
    NotifierProvider<TruffleListingNotifier, TruffleListingState>(
  TruffleListingNotifier.new,
);
