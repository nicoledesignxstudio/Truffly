import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/guides/domain/truffle_guide.dart';

void main() {
  test('TruffleGuide locale getters select IT/EN content consistently', () {
    final guide = TruffleGuide.fromMap({
      'id': 'g1',
      'truffle_type': 'TUBER_MAGNATUM',
      'latin_name': 'Tuber magnatum Pico',
      'title_it': 'Titolo IT',
      'title_en': 'Title EN',
      'short_description_it': 'Short IT',
      'short_description_en': 'Short EN',
      'description_it': 'Description IT',
      'description_en': 'Description EN',
      'aroma_it': 'Aroma IT',
      'aroma_en': 'Aroma EN',
      'price_min_eur': 10,
      'price_max_eur': 20,
      'rarity': 3,
      'symbiotic_plants_it': ['Quercia'],
      'symbiotic_plants_en': ['Oak'],
      'soil_composition_it': 'Comp IT',
      'soil_composition_en': 'Comp EN',
      'soil_structure_it': 'Struct IT',
      'soil_structure_en': 'Struct EN',
      'soil_ph_it': 'Ph IT',
      'soil_ph_en': 'Ph EN',
      'soil_altitude_it': 'Alt IT',
      'soil_altitude_en': 'Alt EN',
      'soil_humidity_it': 'Hum IT',
      'soil_humidity_en': 'Hum EN',
      'harvest_start_month': 1,
      'harvest_end_month': 4,
      'sort_order': 1,
    });

    expect(guide.titleForLocale('it'), 'Titolo IT');
    expect(guide.titleForLocale('en'), 'Title EN');
    expect(guide.shortDescriptionForLocale('it'), 'Short IT');
    expect(guide.shortDescriptionForLocale('en'), 'Short EN');
    expect(guide.descriptionForLocale('it'), 'Description IT');
    expect(guide.descriptionForLocale('en'), 'Description EN');
    expect(guide.aromaForLocale('it'), 'Aroma IT');
    expect(guide.aromaForLocale('en'), 'Aroma EN');
    expect(guide.symbioticPlantsForLocale('it'), ['Quercia']);
    expect(guide.symbioticPlantsForLocale('en'), ['Oak']);
    expect(guide.soilCompositionForLocale('it'), 'Comp IT');
    expect(guide.soilCompositionForLocale('en'), 'Comp EN');
    expect(guide.soilStructureForLocale('it'), 'Struct IT');
    expect(guide.soilStructureForLocale('en'), 'Struct EN');
    expect(guide.soilPhForLocale('it'), 'Ph IT');
    expect(guide.soilPhForLocale('en'), 'Ph EN');
    expect(guide.soilAltitudeForLocale('it'), 'Alt IT');
    expect(guide.soilAltitudeForLocale('en'), 'Alt EN');
    expect(guide.soilHumidityForLocale('it'), 'Hum IT');
    expect(guide.soilHumidityForLocale('en'), 'Hum EN');
  });
}
