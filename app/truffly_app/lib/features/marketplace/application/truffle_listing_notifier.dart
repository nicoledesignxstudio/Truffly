import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/features/marketplace/application/marketplace_providers.dart';
import 'package:truffly_app/features/marketplace/data/marketplace_service.dart';
import 'package:truffly_app/features/marketplace/domain/truffle_listing_filters.dart';
import 'package:truffly_app/features/marketplace/domain/truffle_listing_state.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

final class TruffleListingNotifier extends Notifier<TruffleListingState> {
  @override
  TruffleListingState build() {
    Future.microtask(refresh);
    return TruffleListingState.initial().copyWith(isInitialLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isInitialLoading: true,
      isLoadingMore: false,
      hasReachedEnd: false,
      failure: null,
      items: const [],
    );

    await _loadPage(page: 0, append: false);
  }

  Future<void> updateSearchQuery(String value) async {
    final trimmed = value.trim();
    if (trimmed == state.searchQuery) return;
    state = state.copyWith(searchQuery: trimmed);
    await refresh();
  }

  Future<void> applyFilters(TruffleListingFilters filters) async {
    if (filters == state.appliedFilters) return;
    state = state.copyWith(appliedFilters: filters);
    await refresh();
  }

  Future<void> selectTypeChip(TruffleType? selectedType) async {
    final nextFilters = state.appliedFilters.copyWith(
      selectedType: selectedType,
    );
    await applyFilters(nextFilters);
  }

  Future<void> loadMore() async {
    if (state.isInitialLoading ||
        state.isLoadingMore ||
        state.hasReachedEnd ||
        (state.failure != null && !state.hasItems)) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, failure: null);
    final nextPage = state.items.length ~/ MarketplaceService.pageSize;
    await _loadPage(page: nextPage, append: true);
  }

  Future<void> _loadPage({
    required int page,
    required bool append,
  }) async {
    try {
      final items = await ref.read(marketplaceServiceProvider).fetchListingPage(
            localeCode: ref.read(appLocaleCodeProvider),
            searchQuery: state.searchQuery,
            filters: state.appliedFilters,
            page: page,
          );

      state = state.copyWith(
        items: append ? [...state.items, ...items] : items,
        isInitialLoading: false,
        isLoadingMore: false,
        hasReachedEnd: items.length < MarketplaceService.pageSize,
        failure: null,
      );
    } on MarketplaceServiceException catch (error) {
      state = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: false,
        failure: error.failure,
      );
    }
  }
}
