import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_status.dart';

void main() {
  group('SellerManagedTruffleStatus.fromDbValue', () {
    test('parses all supported values', () {
      expect(
        SellerManagedTruffleStatus.fromDbValue('publishing'),
        SellerManagedTruffleStatus.publishing,
      );
      expect(
        SellerManagedTruffleStatus.fromDbValue('active'),
        SellerManagedTruffleStatus.active,
      );
      expect(
        SellerManagedTruffleStatus.fromDbValue('reserved'),
        SellerManagedTruffleStatus.reserved,
      );
      expect(
        SellerManagedTruffleStatus.fromDbValue('sold'),
        SellerManagedTruffleStatus.sold,
      );
      expect(
        SellerManagedTruffleStatus.fromDbValue('expired'),
        SellerManagedTruffleStatus.expired,
      );
    });

    test('trims and normalizes case', () {
      expect(
        SellerManagedTruffleStatus.fromDbValue(' Reserved '),
        SellerManagedTruffleStatus.reserved,
      );
      expect(
        SellerManagedTruffleStatus.fromDbValue('PUBLISHING'),
        SellerManagedTruffleStatus.publishing,
      );
    });

    test('throws for unsupported values instead of silently falling back', () {
      expect(
        () => SellerManagedTruffleStatus.fromDbValue('unknown_status'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
