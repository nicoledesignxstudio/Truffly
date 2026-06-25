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

  String choiceLabel(AppLocalizations l10n) => localizedLabel(l10n);

  String get badgeLabel => switch (this) {
    TruffleQuality.first => '1\u00AA scelta',
    TruffleQuality.second => '2\u00AA scelta',
    TruffleQuality.third => '3\u00AA scelta',
  };

  static TruffleQuality fromDbValue(String value) {
    return values.firstWhere(
      (candidate) => candidate.dbValue == value,
      orElse: () => TruffleQuality.first,
    );
  }
}
