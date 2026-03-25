import 'package:truffly_app/l10n/app_localizations.dart';

enum TruffleType {
  tuberMagnatum,
  tuberMelanosporum,
  tuberAestivum,
  tuberUncinatum,
  tuberBorchii,
  tuberBrumale,
  tuberMacrosporum,
  tuberBrumaleMoschatum,
  tuberMesentericum;

  String get dbValue => switch (this) {
        TruffleType.tuberMagnatum => 'TUBER_MAGNATUM',
        TruffleType.tuberMelanosporum => 'TUBER_MELANOSPORUM',
        TruffleType.tuberAestivum => 'TUBER_AESTIVUM',
        TruffleType.tuberUncinatum => 'TUBER_UNCINATUM',
        TruffleType.tuberBorchii => 'TUBER_BORCHII',
        TruffleType.tuberBrumale => 'TUBER_BRUMALE',
        TruffleType.tuberMacrosporum => 'TUBER_MACROSPORUM',
        TruffleType.tuberBrumaleMoschatum => 'TUBER_BRUMALE_MOSCHATUM',
        TruffleType.tuberMesentericum => 'TUBER_MESENTERICUM',
      };

  String get latinName => switch (this) {
        TruffleType.tuberMagnatum => 'Tuber Magnatum',
        TruffleType.tuberMelanosporum => 'Tuber Melanosporum',
        TruffleType.tuberAestivum => 'Tuber Aestivum',
        TruffleType.tuberUncinatum => 'Tuber Uncinatum',
        TruffleType.tuberBorchii => 'Tuber Borchii',
        TruffleType.tuberBrumale => 'Tuber Brumale',
        TruffleType.tuberMacrosporum => 'Tuber macrosporum',
        TruffleType.tuberBrumaleMoschatum => 'Tuber brumale var. moschatum',
        TruffleType.tuberMesentericum => 'Tuber mesentericum',
      };

  String localizedName(AppLocalizations l10n) => switch (this) {
        TruffleType.tuberMagnatum => l10n.truffleTypeMagnatum,
        TruffleType.tuberMelanosporum => l10n.truffleTypeMelanosporum,
        TruffleType.tuberAestivum => l10n.truffleTypeAestivum,
        TruffleType.tuberUncinatum => l10n.truffleTypeUncinatum,
        TruffleType.tuberBorchii => l10n.truffleTypeBorchii,
        TruffleType.tuberBrumale => l10n.truffleTypeBrumale,
        TruffleType.tuberMacrosporum => l10n.truffleTypeMacrosporum,
        TruffleType.tuberBrumaleMoschatum => l10n.truffleTypeBrumaleMoschatum,
        TruffleType.tuberMesentericum => l10n.truffleTypeMesentericum,
      };

  String seasonalDisplayName(AppLocalizations l10n) => switch (this) {
        TruffleType.tuberMagnatum => l10n.seasonalTruffleNameMagnatum,
        TruffleType.tuberMelanosporum => l10n.seasonalTruffleNameMelanosporum,
        TruffleType.tuberAestivum => l10n.seasonalTruffleNameAestivum,
        TruffleType.tuberUncinatum => l10n.seasonalTruffleNameUncinatum,
        TruffleType.tuberBorchii => l10n.seasonalTruffleNameBorchii,
        TruffleType.tuberBrumale => l10n.seasonalTruffleNameBrumale,
        TruffleType.tuberMacrosporum => l10n.seasonalTruffleNameMacrosporum,
        TruffleType.tuberBrumaleMoschatum => l10n.seasonalTruffleNameBrumaleMoschatum,
        TruffleType.tuberMesentericum => l10n.seasonalTruffleNameMesentericum,
      };

  String get guideAssetImagePath => 'assets/images/guides/$dbValue.jpeg';

  static List<TruffleType> get valuesInUiOrder => values;

  static TruffleType? tryFromDbValue(String value) {
    final normalized = value.trim();
    for (final candidate in values) {
      if (candidate.dbValue == normalized) return candidate;
    }
    return null;
  }

  static TruffleType fromDbValue(String value) {
    final parsed = tryFromDbValue(value);
    if (parsed != null) return parsed;
    throw ArgumentError.value(
      value,
      'value',
      'Unsupported truffle type db value.',
    );
  }
}
