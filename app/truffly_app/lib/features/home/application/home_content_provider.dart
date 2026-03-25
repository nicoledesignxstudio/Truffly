import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/home/application/seasonal_highlight_provider.dart';
import 'package:truffly_app/features/home/data/repositories/home_repository.dart';
import 'package:truffly_app/features/sellers/domain/seller_list_item.dart';
import 'package:truffly_app/features/truffle/domain/truffle_list_item.dart';

final homeLatestTrufflesProvider = FutureProvider<List<TruffleListItem>>((
  ref,
) async {
  return ref.read(homeRepositoryProvider).fetchLatestTruffles(
        localeCode: ref.read(appLocaleCodeProvider),
      );
});

final homeTopSellersProvider = FutureProvider<List<SellerListItem>>((ref) async {
  return ref.read(homeRepositoryProvider).fetchTopSellers();
});

final sellerHomeStatsProvider = FutureProvider<SellerHomeStats>((ref) async {
  final profile = await ref.read(currentUserAccountProfileProvider.future);
  if (profile.role != 'seller') return const SellerHomeStats.empty();
  return ref.read(homeRepositoryProvider).fetchSellerHomeStats(
        sellerId: profile.userId,
      );
});
