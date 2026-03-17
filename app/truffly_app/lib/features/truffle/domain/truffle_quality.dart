import 'package:truffly_app/l10n/app_localizations.dart';

enum TruffleQuality {
  first,
  second,
  third;

  String get dbValue => switch (this) {
        TruffleQuality.first => 'FIRST',
        TruffleQuality.second => 'SECOND',
        TruffleQuality.third => 'THIRD',
      };

  String localizedLabel(AppLocalizations l10n) => switch (this) {
        TruffleQuality.first => l10n.truffleQualityFirst,
        TruffleQuality.second => l10n.truffleQualitySecond,
        TruffleQuality.third => l10n.truffleQualityThird,
      };

  static TruffleQuality fromDbValue(String value) {
    return values.firstWhere(
      (candidate) => candidate.dbValue == value,
      orElse: () => TruffleQuality.first,
    );
  }
}
