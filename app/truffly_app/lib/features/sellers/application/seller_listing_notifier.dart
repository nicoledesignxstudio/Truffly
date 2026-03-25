import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/features/sellers/application/seller_listing_providers.dart';
import 'package:truffly_app/features/sellers/data/seller_listing_service.dart';
import 'package:truffly_app/features/sellers/domain/seller_listing_filters.dart';
import 'package:truffly_app/features/sellers/domain/seller_listing_state.dart';

final class SellerListingNotifier extends Notifier<SellerListingState> {
  @override
  SellerListingState build() {
    Future.microtask(refresh);
    return SellerListingState.initial().copyWith(isInitialLoading: true);
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

  Future<void> applyFilters(SellerListingFilters filters) async {
    if (filters == state.appliedFilters) return;
    state = state.copyWith(appliedFilters: filters);
    await refresh();
  }

  Future<void> selectRegion(String? region) async {
    final nextFilters = state.appliedFilters.copyWith(
      selectedRegion: region,
    );
    await applyFilters(nextFilters);
  }

  Future<void> clearSearch() async {
    if (state.searchQuery.isEmpty) return;
    state = state.copyWith(searchQuery: '');
    await refresh();
  }

  Future<void> clearAllFilters() async {
    state = state.copyWith(
      searchQuery: '',
      appliedFilters: SellerListingFilters.defaults(),
    );
    await refresh();
  }

  Future<void> removeRatingFilter() async {
    await applyFilters(
      state.appliedFilters.copyWith(rating: SellerRatingFilter.any),
    );
  }

  Future<void> removeCompletedOrdersFilter() async {
    await applyFilters(
      state.appliedFilters.copyWith(
        completedOrders: SellerCompletedOrdersFilter.any,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isInitialLoading ||
        state.isLoadingMore ||
        state.hasReachedEnd ||
        (state.failure != null && !state.hasItems)) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, failure: null);
    final nextPage = state.items.length ~/ SellerListingService.pageSize;
    await _loadPage(page: nextPage, append: true);
  }

  Future<void> _loadPage({
    required int page,
    required bool append,
  }) async {
    try {
      final items = await ref.read(sellerListingServiceProvider).fetchListingPage(
            searchQuery: state.searchQuery,
            filters: state.appliedFilters,
            page: page,
          );

      state = state.copyWith(
        items: append ? [...state.items, ...items] : items,
        isInitialLoading: false,
        isLoadingMore: false,
        hasReachedEnd: items.length < SellerListingService.pageSize,
        failure: null,
      );
    } on SellerListingServiceException catch (error) {
      state = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: false,
        failure: error.failure,
      );
    }
  }
}
