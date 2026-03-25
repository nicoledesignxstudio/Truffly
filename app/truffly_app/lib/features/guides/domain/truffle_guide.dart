import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

final class TruffleGuide {
  const TruffleGuide({
    required this.id,
    required this.truffleType,
    required this.latinName,
    required this.titleIt,
    required this.titleEn,
    required this.shortDescriptionIt,
    required this.shortDescriptionEn,
    required this.descriptionIt,
    required this.descriptionEn,
    required this.aromaIt,
    required this.aromaEn,
    required this.priceMinEur,
    required this.priceMaxEur,
    required this.rarity,
    required this.symbioticPlantsIt,
    required this.symbioticPlantsEn,
    required this.soilCompositionIt,
    required this.soilCompositionEn,
    required this.soilStructureIt,
    required this.soilStructureEn,
    required this.soilPhIt,
    required this.soilPhEn,
    required this.soilAltitudeIt,
    required this.soilAltitudeEn,
    required this.soilHumidityIt,
    required this.soilHumidityEn,
    required this.harvestStartMonth,
    required this.harvestEndMonth,
    required this.sortOrder,
  });

  final String id;
  final TruffleType truffleType;
  final String latinName;
  final String titleIt;
  final String titleEn;
  final String shortDescriptionIt;
  final String shortDescriptionEn;
  final String descriptionIt;
  final String descriptionEn;
  final String aromaIt;
  final String aromaEn;
  final int priceMinEur;
  final int priceMaxEur;
  final int rarity;
  final List<String> symbioticPlantsIt;
  final List<String> symbioticPlantsEn;
  final String soilCompositionIt;
  final String soilCompositionEn;
  final String soilStructureIt;
  final String soilStructureEn;
  final String soilPhIt;
  final String soilPhEn;
  final String soilAltitudeIt;
  final String soilAltitudeEn;
  final String soilHumidityIt;
  final String soilHumidityEn;
  final int harvestStartMonth;
  final int harvestEndMonth;
  final int sortOrder;

  factory TruffleGuide.fromMap(Map<String, dynamic> map) {
    return TruffleGuide(
      id: map['id'] as String,
      truffleType: TruffleType.fromDbValue(map['truffle_type'] as String),
      latinName: map['latin_name'] as String,
      titleIt: map['title_it'] as String,
      titleEn: map['title_en'] as String,
      shortDescriptionIt: map['short_description_it'] as String,
      shortDescriptionEn: map['short_description_en'] as String,
      descriptionIt: map['description_it'] as String,
      descriptionEn: map['description_en'] as String,
      aromaIt: map['aroma_it'] as String,
      aromaEn: map['aroma_en'] as String,
      priceMinEur: map['price_min_eur'] as int,
      priceMaxEur: map['price_max_eur'] as int,
      rarity: map['rarity'] as int,
      symbioticPlantsIt: _toStringList(map['symbiotic_plants_it']),
      symbioticPlantsEn: _toStringList(map['symbiotic_plants_en']),
      soilCompositionIt: map['soil_composition_it'] as String,
      soilCompositionEn: map['soil_composition_en'] as String,
      soilStructureIt: map['soil_structure_it'] as String,
      soilStructureEn: map['soil_structure_en'] as String,
      soilPhIt: map['soil_ph_it'] as String,
      soilPhEn: map['soil_ph_en'] as String,
      soilAltitudeIt: map['soil_altitude_it'] as String,
      soilAltitudeEn: map['soil_altitude_en'] as String,
      soilHumidityIt: map['soil_humidity_it'] as String,
      soilHumidityEn: map['soil_humidity_en'] as String,
      harvestStartMonth: map['harvest_start_month'] as int,
      harvestEndMonth: map['harvest_end_month'] as int,
      sortOrder: map['sort_order'] as int,
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    return const <String>[];
  }

  String titleForLocale(String localeCode) =>
      localeCode == 'en' ? titleEn : titleIt;

  String shortDescriptionForLocale(String localeCode) =>
      localeCode == 'en' ? shortDescriptionEn : shortDescriptionIt;

  String descriptionForLocale(String localeCode) =>
      localeCode == 'en' ? descriptionEn : descriptionIt;

  String aromaForLocale(String localeCode) =>
      localeCode == 'en' ? aromaEn : aromaIt;

  List<String> symbioticPlantsForLocale(String localeCode) =>
      localeCode == 'en' ? symbioticPlantsEn : symbioticPlantsIt;

  String soilCompositionForLocale(String localeCode) =>
      localeCode == 'en' ? soilCompositionEn : soilCompositionIt;

  String soilStructureForLocale(String localeCode) =>
      localeCode == 'en' ? soilStructureEn : soilStructureIt;

  String soilPhForLocale(String localeCode) =>
      localeCode == 'en' ? soilPhEn : soilPhIt;

  String soilAltitudeForLocale(String localeCode) =>
      localeCode == 'en' ? soilAltitudeEn : soilAltitudeIt;

  String soilHumidityForLocale(String localeCode) =>
      localeCode == 'en' ? soilHumidityEn : soilHumidityIt;
}