import 'package:truffly_app/core/support/european_countries.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

String shippingCountryLabel(
  AppLocalizations l10n,
  String countryCode,
) {
  return localizedEuropeanCountryName(l10n, countryCode);
}
