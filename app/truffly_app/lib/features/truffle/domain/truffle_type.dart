import 'package:truffly_app/l10n/app_localizations.dart';

enum TruffleType {
  tuberMagnatum,
  tuberMelanosporum,
  tuberAestivum,
  tuberUncinatum,
  tuberBorchii,
  tuberBrumale;

  String get dbValue => switch (this) {
        TruffleType.tuberMagnatum => 'TUBER_MAGNATUM',
        TruffleType.tuberMelanosporum => 'TUBER_MELANOSPORUM',
        TruffleType.tuberAestivum => 'TUBER_AESTIVUM',
        TruffleType.tuberUncinatum => 'TUBER_UNCINATUM',
        TruffleType.tuberBorchii => 'TUBER_BORCHII',
        TruffleType.tuberBrumale => 'TUBER_BRUMALE',
      };

  String get latinName => switch (this) {
        TruffleType.tuberMagnatum => 'Tuber Magnatum',
        TruffleType.tuberMelanosporum => 'Tuber Melanosporum',
        TruffleType.tuberAestivum => 'Tuber Aestivum',
        TruffleType.tuberUncinatum => 'Tuber Uncinatum',
        TruffleType.tuberBorchii => 'Tuber Borchii',
        TruffleType.tuberBrumale => 'Tuber Brumale',
      };

  String localizedName(AppLocalizations l10n) => switch (this) {
        TruffleType.tuberMagnatum => l10n.truffleTypeMagnatum,
        TruffleType.tuberMelanosporum => l10n.truffleTypeMelanosporum,
        TruffleType.tuberAestivum => l10n.truffleTypeAestivum,
        TruffleType.tuberUncinatum => l10n.truffleTypeUncinatum,
        TruffleType.tuberBorchii => l10n.truffleTypeBorchii,
        TruffleType.tuberBrumale => l10n.truffleTypeBrumale,
      };

  static List<TruffleType> get valuesInUiOrder => values;

  static TruffleType fromDbValue(String value) {
    return values.firstWhere(
      (candidate) => candidate.dbValue == value,
      orElse: () => TruffleType.tuberMagnatum,
    );
  }
}
