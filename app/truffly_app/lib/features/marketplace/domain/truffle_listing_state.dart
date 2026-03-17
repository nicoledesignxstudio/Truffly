import 'package:truffly_app/features/marketplace/domain/truffle_listing_filters.dart';
import 'package:truffly_app/features/truffle/domain/truffle_list_item.dart';

enum TruffleListingFailure {
  network,
  unknown,
}

final class TruffleListingState {
  const TruffleListingState({
    this.searchQuery = '',
    this.appliedFilters = const TruffleListingFilters(),
    this.items = const [],
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.failure,
  });

  final String searchQuery;
  final TruffleListingFilters appliedFilters;
  final List<TruffleListItem> items;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final TruffleListingFailure? failure;

  bool get hasItems => items.isNotEmpty;
  bool get isEmpty => !isInitialLoading && failure == null && items.isEmpty;

  TruffleListingState copyWith({
    String? searchQuery,
    TruffleListingFilters? appliedFilters,
    List<TruffleListItem>? items,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    Object? failure = _sentinel,
  }) {
    return TruffleListingState(
      searchQuery: searchQuery ?? this.searchQuery,
      appliedFilters: appliedFilters ?? this.appliedFilters,
      items: items ?? this.items,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      failure: identical(failure, _sentinel)
          ? this.failure
          : failure as TruffleListingFailure?,
    );
  }

  static TruffleListingState initial() {
    return TruffleListingState(
      appliedFilters: TruffleListingFilters.defaults(),
    );
  }
}

const Object _sentinel = Object();
