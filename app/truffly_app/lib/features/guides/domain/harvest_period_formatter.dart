String formatHarvestPeriod({
  required int startMonth,
  required int endMonth,
  required String localeCode,
}) {
  final startName = _monthName(startMonth, localeCode);
  final endName = _monthName(endMonth, localeCode);
  return '$startName – $endName';
}

String _monthName(int month, String localeCode) {
  const monthNamesIt = <String>[
    'Gennaio',
    'Febbraio',
    'Marzo',
    'Aprile',
    'Maggio',
    'Giugno',
    'Luglio',
    'Agosto',
    'Settembre',
    'Ottobre',
    'Novembre',
    'Dicembre',
  ];
  const monthNamesEn = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final index = month.clamp(1, 12) - 1;
  final isEnglish = localeCode.trim().toLowerCase() == 'en';
  return isEnglish ? monthNamesEn[index] : monthNamesIt[index];
}
