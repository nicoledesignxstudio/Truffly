import 'package:flutter/material.dart';

String formatEuro(double value) {
  final normalized = value % 1 == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
  return 'EUR $normalized';
}

String formatWeightGrams(int grams) {
  return '${grams}g';
}

String formatShortDate(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatShortDate(date);
}
