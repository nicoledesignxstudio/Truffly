import 'package:truffly_app/features/sellers/domain/seller_list_item.dart';
import 'package:truffly_app/features/sellers/domain/seller_listing_filters.dart';

enum SellerListingFailure {
  network,
  unknown,
}

final class SellerListingState {
  const SellerListingState({
    this.searchQuery = '',
    this.appliedFilters = const SellerListingFilters(),
    this.items = const [],
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.failure,
  });

  final String searchQuery;
  final SellerListingFilters appliedFilters;
  final List<SellerListItem> items;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final SellerListingFailure? failure;

  bool get hasItems => items.isNotEmpty;
  bool get isEmpty => !isInitialLoading && failure == null && items.isEmpty;
  bool get hasActiveFilters =>
      searchQuery.isNotEmpty || !appliedFilters.isDefault;

  SellerListingState copyWith({
    String? searchQuery,
    SellerListingFilters? appliedFilters,
    List<SellerListItem>? items,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    Object? failure = _sentinel,
  }) {
    return SellerListingState(
      searchQuery: searchQuery ?? this.searchQuery,
      appliedFilters: appliedFilters ?? this.appliedFilters,
      items: items ?? this.items,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      failure: identical(failure, _sentinel)
          ? this.failure
          : failure as SellerListingFailure?,
    );
  }

  static SellerListingState initial() {
    return SellerListingState(
      appliedFilters: SellerListingFilters.defaults(),
    );
  }
}

const Object _sentinel = Object();
