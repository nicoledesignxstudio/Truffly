import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

enum HarvestDatePreset {
  all,
  today,
  last2Days,
  last3Days,
  last5Days,
}

abstract final class TruffleListingFilterBounds {
  static const double minPriceEuro = 0;
  static const double maxPriceEuro = 3000;
  static const double priceStepEuro = 250;

  static const double minWeightGrams = 0;
  static const double maxWeightGrams = 1000;
  static const double weightStepGrams = 100;

  static int get priceDivisions =>
      ((maxPriceEuro - minPriceEuro) / priceStepEuro).round();

  static int get weightDivisions =>
      ((maxWeightGrams - minWeightGrams) / weightStepGrams).round();
}

final class TruffleListingFilters {
  const TruffleListingFilters({
    this.selectedType,
    this.qualities = const {},
    this.regions = const {},
    this.minPrice = TruffleListingFilterBounds.minPriceEuro,
    this.maxPrice = TruffleListingFilterBounds.maxPriceEuro,
    this.minWeight = TruffleListingFilterBounds.minWeightGrams,
    this.maxWeight = TruffleListingFilterBounds.maxWeightGrams,
    this.harvestDatePreset = HarvestDatePreset.all,
  });

  final TruffleType? selectedType;
  final Set<TruffleQuality> qualities;
  final Set<String> regions;
  final double minPrice;
  final double maxPrice;
  final double minWeight;
  final double maxWeight;
  final HarvestDatePreset harvestDatePreset;

  bool get isDefault {
    return selectedType == null &&
        qualities.isEmpty &&
        regions.isEmpty &&
        minPrice == TruffleListingFilterBounds.minPriceEuro &&
        maxPrice == TruffleListingFilterBounds.maxPriceEuro &&
        minWeight == TruffleListingFilterBounds.minWeightGrams &&
        maxWeight == TruffleListingFilterBounds.maxWeightGrams &&
        harvestDatePreset == HarvestDatePreset.all;
  }

  TruffleListingFilters copyWith({
    Object? selectedType = _sentinel,
    Set<TruffleQuality>? qualities,
    Set<String>? regions,
    double? minPrice,
    double? maxPrice,
    double? minWeight,
    double? maxWeight,
    HarvestDatePreset? harvestDatePreset,
  }) {
    return TruffleListingFilters(
      selectedType: identical(selectedType, _sentinel)
          ? this.selectedType
          : selectedType as TruffleType?,
      qualities: qualities ?? this.qualities,
      regions: regions ?? this.regions,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minWeight: minWeight ?? this.minWeight,
      maxWeight: maxWeight ?? this.maxWeight,
      harvestDatePreset: harvestDatePreset ?? this.harvestDatePreset,
    );
  }

  static TruffleListingFilters defaults() => const TruffleListingFilters();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TruffleListingFilters &&
            other.selectedType == selectedType &&
            _setEquals(other.qualities, qualities) &&
            _setEquals(other.regions, regions) &&
            other.minPrice == minPrice &&
            other.maxPrice == maxPrice &&
            other.minWeight == minWeight &&
            other.maxWeight == maxWeight &&
            other.harvestDatePreset == harvestDatePreset;
  }

  @override
  int get hashCode => Object.hash(
        selectedType,
        Object.hashAllUnordered(qualities),
        Object.hashAllUnordered(regions),
        minPrice,
        maxPrice,
        minWeight,
        maxWeight,
        harvestDatePreset,
      );
}

bool _setEquals<T>(Set<T> left, Set<T> right) {
  if (left.length != right.length) return false;
  for (final value in left) {
    if (!right.contains(value)) return false;
  }
  return true;
}

const Object _sentinel = Object();
