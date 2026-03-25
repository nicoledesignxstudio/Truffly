import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

List<TruffleType> resolveSearchMatchingTypes({
  required String localeCode,
  required String searchQuery,
}) {
  final normalizedQuery = searchQuery.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return const [];

  return TruffleType.values.where((type) {
    final localized = switch (localeCode) {
      'it' => _italianLabel(type).toLowerCase(),
      _ => _englishLabel(type).toLowerCase(),
    };
    final latin = type.latinName.toLowerCase();

    return localized.contains(normalizedQuery) || latin.contains(normalizedQuery);
  }).toList(growable: false);
}

String _italianLabel(TruffleType type) => switch (type) {
      TruffleType.tuberMagnatum => 'Bianco pregiato',
      TruffleType.tuberMelanosporum => 'Nero pregiato',
      TruffleType.tuberAestivum => 'Scorzone',
      TruffleType.tuberUncinatum => 'Uncinato',
      TruffleType.tuberBorchii => 'Bianchetto',
      TruffleType.tuberBrumale => 'Brumale',
      TruffleType.tuberMacrosporum => 'Tartufo Nero Liscio',
      TruffleType.tuberBrumaleMoschatum => 'Tartufo Brumale Moscato',
      TruffleType.tuberMesentericum => 'Tartufo Mesenterico',
    };

String _englishLabel(TruffleType type) => switch (type) {
      TruffleType.tuberMagnatum => 'White truffle',
      TruffleType.tuberMelanosporum => 'Black winter truffle',
      TruffleType.tuberAestivum => 'Scorzone',
      TruffleType.tuberUncinatum => 'Uncinato',
      TruffleType.tuberBorchii => 'Bianchetto',
      TruffleType.tuberBrumale => 'Brumale',
      TruffleType.tuberMacrosporum => 'Smooth Black Truffle',
      TruffleType.tuberBrumaleMoschatum => 'Musky Brumal Truffle',
      TruffleType.tuberMesentericum => 'Mesenteric Truffle',
    };
