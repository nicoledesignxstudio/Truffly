enum SellerRatingFilter {
  any,
  threePlus,
  fourPlus,
  five,
}

enum SellerCompletedOrdersFilter {
  any,
  fivePlus,
  twentyPlus,
  fiftyPlus,
}

final class SellerListingFilters {
  const SellerListingFilters({
    this.selectedRegion,
    this.rating = SellerRatingFilter.any,
    this.completedOrders = SellerCompletedOrdersFilter.any,
  });

  final String? selectedRegion;
  final SellerRatingFilter rating;
  final SellerCompletedOrdersFilter completedOrders;

  bool get isDefault {
    return selectedRegion == null &&
        rating == SellerRatingFilter.any &&
        completedOrders == SellerCompletedOrdersFilter.any;
  }

  double? get minimumRating {
    return switch (rating) {
      SellerRatingFilter.any => null,
      SellerRatingFilter.threePlus => 3,
      SellerRatingFilter.fourPlus => 4,
      SellerRatingFilter.five => 5,
    };
  }

  int? get minimumCompletedOrders {
    return switch (completedOrders) {
      SellerCompletedOrdersFilter.any => null,
      SellerCompletedOrdersFilter.fivePlus => 5,
      SellerCompletedOrdersFilter.twentyPlus => 20,
      SellerCompletedOrdersFilter.fiftyPlus => 50,
    };
  }

  SellerListingFilters copyWith({
    Object? selectedRegion = _sentinel,
    SellerRatingFilter? rating,
    SellerCompletedOrdersFilter? completedOrders,
  }) {
    return SellerListingFilters(
      selectedRegion: identical(selectedRegion, _sentinel)
          ? this.selectedRegion
          : selectedRegion as String?,
      rating: rating ?? this.rating,
      completedOrders: completedOrders ?? this.completedOrders,
    );
  }

  static SellerListingFilters defaults() => const SellerListingFilters();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SellerListingFilters &&
            other.selectedRegion == selectedRegion &&
            other.rating == rating &&
            other.completedOrders == completedOrders;
  }

  @override
  int get hashCode => Object.hash(
        selectedRegion,
        rating,
        completedOrders,
      );
}

const Object _sentinel = Object();
