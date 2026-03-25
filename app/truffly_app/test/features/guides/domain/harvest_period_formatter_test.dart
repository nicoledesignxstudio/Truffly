import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/guides/domain/harvest_period_formatter.dart';

void main() {
  group('formatHarvestPeriod', () {
    test('formats same-year period in english', () {
      final formatted = formatHarvestPeriod(
        startMonth: 5,
        endMonth: 8,
        localeCode: 'en',
      );

      expect(formatted, 'May – August');
    });

    test('formats cross-year period in english naturally', () {
      final formatted = formatHarvestPeriod(
        startMonth: 11,
        endMonth: 3,
        localeCode: 'en',
      );

      expect(formatted, 'November – March');
    });

    test('formats cross-year period in italian naturally', () {
      final formatted = formatHarvestPeriod(
        startMonth: 9,
        endMonth: 1,
        localeCode: 'it',
      );

      expect(formatted, 'Settembre – Gennaio');
    });

    test('falls back to italian for unknown locale code', () {
      final formatted = formatHarvestPeriod(
        startMonth: 12,
        endMonth: 3,
        localeCode: 'fr',
      );

      expect(formatted, 'Dicembre – Marzo');
    });
  });
}
