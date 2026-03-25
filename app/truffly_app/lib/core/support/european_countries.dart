import 'package:truffly_app/l10n/app_localizations.dart';

final class EuropeanCountryOption {
  const EuropeanCountryOption({
    required this.code,
    required this.phonePrefix,
    required this.nameEn,
    required this.nameIt,
  });

  final String code;
  final String phonePrefix;
  final String nameEn;
  final String nameIt;

  String localizedName(AppLocalizations l10n) {
    return l10n.localeName.startsWith('it') ? nameIt : nameEn;
  }
}

const europeanCountryOptions = <EuropeanCountryOption>[
  EuropeanCountryOption(
    code: 'AL',
    phonePrefix: '+355',
    nameEn: 'Albania',
    nameIt: 'Albania',
  ),
  EuropeanCountryOption(
    code: 'AD',
    phonePrefix: '+376',
    nameEn: 'Andorra',
    nameIt: 'Andorra',
  ),
  EuropeanCountryOption(
    code: 'AT',
    phonePrefix: '+43',
    nameEn: 'Austria',
    nameIt: 'Austria',
  ),
  EuropeanCountryOption(
    code: 'BE',
    phonePrefix: '+32',
    nameEn: 'Belgium',
    nameIt: 'Belgio',
  ),
  EuropeanCountryOption(
    code: 'BA',
    phonePrefix: '+387',
    nameEn: 'Bosnia and Herzegovina',
    nameIt: 'Bosnia ed Erzegovina',
  ),
  EuropeanCountryOption(
    code: 'BG',
    phonePrefix: '+359',
    nameEn: 'Bulgaria',
    nameIt: 'Bulgaria',
  ),
  EuropeanCountryOption(
    code: 'HR',
    phonePrefix: '+385',
    nameEn: 'Croatia',
    nameIt: 'Croazia',
  ),
  EuropeanCountryOption(
    code: 'CY',
    phonePrefix: '+357',
    nameEn: 'Cyprus',
    nameIt: 'Cipro',
  ),
  EuropeanCountryOption(
    code: 'CZ',
    phonePrefix: '+420',
    nameEn: 'Czech Republic',
    nameIt: 'Repubblica Ceca',
  ),
  EuropeanCountryOption(
    code: 'DK',
    phonePrefix: '+45',
    nameEn: 'Denmark',
    nameIt: 'Danimarca',
  ),
  EuropeanCountryOption(
    code: 'EE',
    phonePrefix: '+372',
    nameEn: 'Estonia',
    nameIt: 'Estonia',
  ),
  EuropeanCountryOption(
    code: 'FI',
    phonePrefix: '+358',
    nameEn: 'Finland',
    nameIt: 'Finlandia',
  ),
  EuropeanCountryOption(
    code: 'FR',
    phonePrefix: '+33',
    nameEn: 'France',
    nameIt: 'Francia',
  ),
  EuropeanCountryOption(
    code: 'DE',
    phonePrefix: '+49',
    nameEn: 'Germany',
    nameIt: 'Germania',
  ),
  EuropeanCountryOption(
    code: 'GR',
    phonePrefix: '+30',
    nameEn: 'Greece',
    nameIt: 'Grecia',
  ),
  EuropeanCountryOption(
    code: 'HU',
    phonePrefix: '+36',
    nameEn: 'Hungary',
    nameIt: 'Ungheria',
  ),
  EuropeanCountryOption(
    code: 'IS',
    phonePrefix: '+354',
    nameEn: 'Iceland',
    nameIt: 'Islanda',
  ),
  EuropeanCountryOption(
    code: 'IE',
    phonePrefix: '+353',
    nameEn: 'Ireland',
    nameIt: 'Irlanda',
  ),
  EuropeanCountryOption(
    code: 'IT',
    phonePrefix: '+39',
    nameEn: 'Italy',
    nameIt: 'Italia',
  ),
  EuropeanCountryOption(
    code: 'LV',
    phonePrefix: '+371',
    nameEn: 'Latvia',
    nameIt: 'Lettonia',
  ),
  EuropeanCountryOption(
    code: 'LI',
    phonePrefix: '+423',
    nameEn: 'Liechtenstein',
    nameIt: 'Liechtenstein',
  ),
  EuropeanCountryOption(
    code: 'LT',
    phonePrefix: '+370',
    nameEn: 'Lithuania',
    nameIt: 'Lituania',
  ),
  EuropeanCountryOption(
    code: 'LU',
    phonePrefix: '+352',
    nameEn: 'Luxembourg',
    nameIt: 'Lussemburgo',
  ),
  EuropeanCountryOption(
    code: 'MT',
    phonePrefix: '+356',
    nameEn: 'Malta',
    nameIt: 'Malta',
  ),
  EuropeanCountryOption(
    code: 'MD',
    phonePrefix: '+373',
    nameEn: 'Moldova',
    nameIt: 'Moldavia',
  ),
  EuropeanCountryOption(
    code: 'MC',
    phonePrefix: '+377',
    nameEn: 'Monaco',
    nameIt: 'Monaco',
  ),
  EuropeanCountryOption(
    code: 'ME',
    phonePrefix: '+382',
    nameEn: 'Montenegro',
    nameIt: 'Montenegro',
  ),
  EuropeanCountryOption(
    code: 'NL',
    phonePrefix: '+31',
    nameEn: 'Netherlands',
    nameIt: 'Paesi Bassi',
  ),
  EuropeanCountryOption(
    code: 'MK',
    phonePrefix: '+389',
    nameEn: 'North Macedonia',
    nameIt: 'Macedonia del Nord',
  ),
  EuropeanCountryOption(
    code: 'NO',
    phonePrefix: '+47',
    nameEn: 'Norway',
    nameIt: 'Norvegia',
  ),
  EuropeanCountryOption(
    code: 'PL',
    phonePrefix: '+48',
    nameEn: 'Poland',
    nameIt: 'Polonia',
  ),
  EuropeanCountryOption(
    code: 'PT',
    phonePrefix: '+351',
    nameEn: 'Portugal',
    nameIt: 'Portogallo',
  ),
  EuropeanCountryOption(
    code: 'RO',
    phonePrefix: '+40',
    nameEn: 'Romania',
    nameIt: 'Romania',
  ),
  EuropeanCountryOption(
    code: 'SM',
    phonePrefix: '+378',
    nameEn: 'San Marino',
    nameIt: 'San Marino',
  ),
  EuropeanCountryOption(
    code: 'RS',
    phonePrefix: '+381',
    nameEn: 'Serbia',
    nameIt: 'Serbia',
  ),
  EuropeanCountryOption(
    code: 'SK',
    phonePrefix: '+421',
    nameEn: 'Slovakia',
    nameIt: 'Slovacchia',
  ),
  EuropeanCountryOption(
    code: 'SI',
    phonePrefix: '+386',
    nameEn: 'Slovenia',
    nameIt: 'Slovenia',
  ),
  EuropeanCountryOption(
    code: 'ES',
    phonePrefix: '+34',
    nameEn: 'Spain',
    nameIt: 'Spagna',
  ),
  EuropeanCountryOption(
    code: 'SE',
    phonePrefix: '+46',
    nameEn: 'Sweden',
    nameIt: 'Svezia',
  ),
  EuropeanCountryOption(
    code: 'CH',
    phonePrefix: '+41',
    nameEn: 'Switzerland',
    nameIt: 'Svizzera',
  ),
  EuropeanCountryOption(
    code: 'UA',
    phonePrefix: '+380',
    nameEn: 'Ukraine',
    nameIt: 'Ucraina',
  ),
  EuropeanCountryOption(
    code: 'GB',
    phonePrefix: '+44',
    nameEn: 'United Kingdom',
    nameIt: 'Regno Unito',
  ),
  EuropeanCountryOption(
    code: 'VA',
    phonePrefix: '+39',
    nameEn: 'Vatican City',
    nameIt: 'Citta del Vaticano',
  ),
];

EuropeanCountryOption? europeanCountryByCode(String countryCode) {
  final normalizedCode = countryCode.trim().toUpperCase();
  for (final option in europeanCountryOptions) {
    if (option.code == normalizedCode) {
      return option;
    }
  }
  return null;
}

EuropeanCountryOption? europeanCountryByPhonePrefix(String phonePrefix) {
  final normalizedPrefix = _normalizePhonePrefix(phonePrefix);
  for (final option in europeanCountryOptions) {
    if (option.phonePrefix == normalizedPrefix) {
      return option;
    }
  }
  return null;
}

bool isSupportedEuropeanCountryCode(String countryCode) {
  return europeanCountryByCode(countryCode) != null;
}

String? europeanCountryPhonePrefix(String countryCode) {
  return europeanCountryByCode(countryCode)?.phonePrefix;
}

String localizedEuropeanCountryName(
  AppLocalizations l10n,
  String countryCode,
) {
  return europeanCountryByCode(countryCode)?.localizedName(l10n) ??
      countryCode.trim().toUpperCase();
}

String? detectEuropeanPhonePrefix(String phoneNumber) {
  final normalizedPhone = phoneNumber.trim();
  if (normalizedPhone.isEmpty || !normalizedPhone.startsWith('+')) {
    return null;
  }

  final sortedPrefixes = europeanCountryOptions
      .map((option) => option.phonePrefix)
      .toSet()
      .toList(growable: false)
    ..sort((a, b) => b.length.compareTo(a.length));

  for (final prefix in sortedPrefixes) {
    if (normalizedPhone == prefix ||
        normalizedPhone.startsWith('$prefix ') ||
        normalizedPhone.startsWith('$prefix-') ||
        normalizedPhone.startsWith(prefix)) {
      return prefix;
    }
  }

  return null;
}

String stripPhonePrefix(String phoneNumber, String? phonePrefix) {
  final normalizedPhone = phoneNumber.trim();
  final normalizedPrefix = phonePrefix == null
      ? null
      : _normalizePhonePrefix(phonePrefix);
  if (normalizedPrefix == null || normalizedPrefix.isEmpty) {
    return normalizedPhone;
  }
  if (!normalizedPhone.startsWith(normalizedPrefix)) {
    return normalizedPhone;
  }

  final stripped = normalizedPhone.substring(normalizedPrefix.length).trimLeft();
  return stripped.startsWith('-') ? stripped.substring(1).trimLeft() : stripped;
}

String combinePhoneNumber({
  required String? phonePrefix,
  required String localNumber,
}) {
  final normalizedPrefix = phonePrefix == null
      ? null
      : _normalizePhonePrefix(phonePrefix);
  final normalizedLocal = localNumber.trim();

  if (normalizedLocal.isEmpty) {
    return '';
  }
  if (normalizedPrefix == null || normalizedPrefix.isEmpty) {
    return normalizedLocal;
  }
  return '$normalizedPrefix $normalizedLocal';
}

String _normalizePhonePrefix(String value) {
  final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
  if (digitsOnly.isEmpty) {
    return '';
  }
  return '+$digitsOnly';
}
