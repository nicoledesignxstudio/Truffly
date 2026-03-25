import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/marketplace/domain/truffle_search_matcher.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

void main() {
  group('resolveSearchMatchingTypes', () {
    test('matches Italian localized names', () {
      final result = resolveSearchMatchingTypes(
        localeCode: 'it',
        searchQuery: 'bianco',
      );

      expect(result, contains(TruffleType.tuberMagnatum));
    });

    test('matches Latin names', () {
      final result = resolveSearchMatchingTypes(
        localeCode: 'en',
        searchQuery: 'melanosporum',
      );

      expect(result, contains(TruffleType.tuberMelanosporum));
    });

    test('matches new Italian names', () {
      final result = resolveSearchMatchingTypes(
        localeCode: 'it',
        searchQuery: 'mesenterico',
      );

      expect(result, contains(TruffleType.tuberMesentericum));
    });

    test('matches new English names', () {
      final result = resolveSearchMatchingTypes(
        localeCode: 'en',
        searchQuery: 'musky',
      );

      expect(result, contains(TruffleType.tuberBrumaleMoschatum));
    });

    test('returns empty when nothing matches', () {
      final result = resolveSearchMatchingTypes(
        localeCode: 'it',
        searchQuery: 'foobar',
      );

      expect(result, isEmpty);
    });
  });
}
