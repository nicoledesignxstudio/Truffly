import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/features/truffle/application/favorite_ids_notifier.dart';
import 'package:truffly_app/features/truffle/application/truffle_service_providers.dart';
import 'package:truffly_app/features/truffle/domain/truffle_detail.dart';

final favoriteIdsNotifierProvider =
    NotifierProvider<FavoriteIdsNotifier, FavoriteIdsState>(
  FavoriteIdsNotifier.new,
);

final truffleDetailProvider =
    FutureProvider.family<TruffleDetail, String>((ref, truffleId) {
  return ref.read(truffleServiceProvider).fetchDetail(truffleId);
});
