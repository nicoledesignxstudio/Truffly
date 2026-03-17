import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/features/truffle/application/truffle_service_providers.dart';
import 'package:truffly_app/features/truffle/data/favorites_service.dart';

final class FavoriteIdsState {
  const FavoriteIdsState({
    this.ids = const {},
    this.pendingIds = const {},
    this.isLoading = false,
    this.failure,
  });

  final Set<String> ids;
  final Set<String> pendingIds;
  final bool isLoading;
  final FavoritesFailure? failure;

  FavoriteIdsState copyWith({
    Set<String>? ids,
    Set<String>? pendingIds,
    bool? isLoading,
    Object? failure = _sentinel,
  }) {
    return FavoriteIdsState(
      ids: ids ?? this.ids,
      pendingIds: pendingIds ?? this.pendingIds,
      isLoading: isLoading ?? this.isLoading,
      failure: identical(failure, _sentinel)
          ? this.failure
          : failure as FavoritesFailure?,
    );
  }
}

const Object _sentinel = Object();

final class FavoriteIdsNotifier extends Notifier<FavoriteIdsState> {
  @override
  FavoriteIdsState build() {
    Future.microtask(load);
    return const FavoriteIdsState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, failure: null);
    try {
      final ids = await ref.read(favoritesServiceProvider).fetchFavoriteIds();
      state = state.copyWith(ids: ids, isLoading: false, failure: null);
    } on FavoritesServiceException catch (error) {
      state = state.copyWith(isLoading: false, failure: error.failure);
    }
  }

  Future<void> toggleFavorite(String truffleId) async {
    if (state.pendingIds.contains(truffleId)) return;

    final currentlyFavorite = state.ids.contains(truffleId);
    final nextIds = Set<String>.from(state.ids);
    if (currentlyFavorite) {
      nextIds.remove(truffleId);
    } else {
      nextIds.add(truffleId);
    }

    state = state.copyWith(
      ids: nextIds,
      pendingIds: {...state.pendingIds, truffleId},
      failure: null,
    );

    try {
      if (currentlyFavorite) {
        await ref.read(favoritesServiceProvider).removeFavorite(truffleId);
      } else {
        await ref.read(favoritesServiceProvider).addFavorite(truffleId);
      }
      final nextPending = Set<String>.from(state.pendingIds)..remove(truffleId);
      state = state.copyWith(pendingIds: nextPending);
    } on FavoritesServiceException catch (error) {
      final rollbackIds = Set<String>.from(state.ids);
      if (currentlyFavorite) {
        rollbackIds.add(truffleId);
      } else {
        rollbackIds.remove(truffleId);
      }
      final nextPending = Set<String>.from(state.pendingIds)..remove(truffleId);
      state = state.copyWith(
        ids: rollbackIds,
        pendingIds: nextPending,
        failure: error.failure,
      );
    }
  }
}
