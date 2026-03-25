import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/features/marketplace/application/marketplace_providers.dart';
import 'package:truffly_app/features/truffle/application/truffle_providers.dart';
import 'package:truffly_app/features/truffle/domain/truffle_list_item.dart';

final accountFavoriteTrufflesProvider = FutureProvider<List<TruffleListItem>>((
  ref,
) async {
  final favoriteIdsState = ref.watch(favoriteIdsNotifierProvider);
  if (favoriteIdsState.ids.isEmpty) {
    return const [];
  }

  return ref
      .read(marketplaceServiceProvider)
      .fetchTrufflesByIds(favoriteIdsState.ids.toList());
});
