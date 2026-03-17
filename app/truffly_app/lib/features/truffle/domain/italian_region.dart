import 'package:truffly_app/l10n/app_localizations.dart';

abstract final class ItalianRegions {
  static const List<String> values = [
    'ABRUZZO',
    'BASILICATA',
    'CALABRIA',
    'CAMPANIA',
    'EMILIA_ROMAGNA',
    'FRIULI_VENEZIA_GIULIA',
    'LAZIO',
    'LIGURIA',
    'LOMBARDIA',
    'MARCHE',
    'MOLISE',
    'PIEMONTE',
    'PUGLIA',
    'SARDEGNA',
    'SICILIA',
    'TOSCANA',
    'TRENTINO_ALTO_ADIGE',
    'UMBRIA',
    'VALLE_DAOSTA',
    'VENETO',
  ];

  static String localizedLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'ABRUZZO' => l10n.onboardingRegionAbruzzo,
      'BASILICATA' => l10n.onboardingRegionBasilicata,
      'CALABRIA' => l10n.onboardingRegionCalabria,
      'CAMPANIA' => l10n.onboardingRegionCampania,
      'EMILIA_ROMAGNA' => l10n.onboardingRegionEmiliaRomagna,
      'FRIULI_VENEZIA_GIULIA' => l10n.onboardingRegionFriuliVeneziaGiulia,
      'LAZIO' => l10n.onboardingRegionLazio,
      'LIGURIA' => l10n.onboardingRegionLiguria,
      'LOMBARDIA' => l10n.onboardingRegionLombardia,
      'MARCHE' => l10n.onboardingRegionMarche,
      'MOLISE' => l10n.onboardingRegionMolise,
      'PIEMONTE' => l10n.onboardingRegionPiemonte,
      'PUGLIA' => l10n.onboardingRegionPuglia,
      'SARDEGNA' => l10n.onboardingRegionSardegna,
      'SICILIA' => l10n.onboardingRegionSicilia,
      'TOSCANA' => l10n.onboardingRegionToscana,
      'TRENTINO_ALTO_ADIGE' => l10n.onboardingRegionTrentinoAltoAdige,
      'UMBRIA' => l10n.onboardingRegionUmbria,
      'VALLE_DAOSTA' => l10n.onboardingRegionValleDaosta,
      'VENETO' => l10n.onboardingRegionVeneto,
      _ => value,
    };
  }
}
