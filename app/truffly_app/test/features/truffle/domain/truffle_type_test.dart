import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

void main() {
  group('TruffleType mapping', () {
    test('fromDbValue parses all supported values', () {
      expect(
        TruffleType.fromDbValue('TUBER_MAGNATUM'),
        TruffleType.tuberMagnatum,
      );
      expect(
        TruffleType.fromDbValue('TUBER_MELANOSPORUM'),
        TruffleType.tuberMelanosporum,
      );
      expect(
        TruffleType.fromDbValue('TUBER_AESTIVUM'),
        TruffleType.tuberAestivum,
      );
      expect(
        TruffleType.fromDbValue('TUBER_UNCINATUM'),
        TruffleType.tuberUncinatum,
      );
      expect(
        TruffleType.fromDbValue('TUBER_BORCHII'),
        TruffleType.tuberBorchii,
      );
      expect(
        TruffleType.fromDbValue('TUBER_BRUMALE'),
        TruffleType.tuberBrumale,
      );
      expect(
        TruffleType.fromDbValue('TUBER_MACROSPORUM'),
        TruffleType.tuberMacrosporum,
      );
      expect(
        TruffleType.fromDbValue('TUBER_BRUMALE_MOSCHATUM'),
        TruffleType.tuberBrumaleMoschatum,
      );
      expect(
        TruffleType.fromDbValue('TUBER_MESENTERICUM'),
        TruffleType.tuberMesentericum,
      );
    });

    test('tryFromDbValue returns null for unknown values', () {
      expect(TruffleType.tryFromDbValue('TUBER_UNKNOWN'), isNull);
      expect(TruffleType.tryFromDbValue(''), isNull);
    });

    test('fromDbValue throws for unknown values (no silent fallback)', () {
      expect(
        () => TruffleType.fromDbValue('TUBER_UNKNOWN'),
        throwsArgumentError,
      );
    });

    test('casing drift is explicit and rejected by strict parser', () {
      expect(TruffleType.tryFromDbValue('tuber_magnatum'), isNull);
      expect(
        () => TruffleType.fromDbValue('tuber_magnatum'),
        throwsArgumentError,
      );
    });

    test('dbValue serializes newly supported types', () {
      expect(TruffleType.tuberMacrosporum.dbValue, 'TUBER_MACROSPORUM');
      expect(
        TruffleType.tuberBrumaleMoschatum.dbValue,
        'TUBER_BRUMALE_MOSCHATUM',
      );
      expect(TruffleType.tuberMesentericum.dbValue, 'TUBER_MESENTERICUM');
    });

    test('guide asset path follows enum-based jpeg pattern', () {
      expect(
        TruffleType.tuberMagnatum.guideAssetImagePath,
        'assets/images/guides/TUBER_MAGNATUM.jpeg',
      );
      expect(
        TruffleType.tuberBrumaleMoschatum.guideAssetImagePath,
        'assets/images/guides/TUBER_BRUMALE_MOSCHATUM.jpeg',
      );
    });

    test('all guide assets exist for supported truffle types', () {
      for (final type in TruffleType.values) {
        final assetFile = File(type.guideAssetImagePath);
        expect(
          assetFile.existsSync(),
          isTrue,
          reason: 'Missing guide asset for ${type.dbValue}',
        );
      }
    });

    test('guide assets use a single canonical jpeg file per truffle type', () {
      final guidesDir = Directory('assets/images/guides');
      final fileNames = guidesDir
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last)
          .toSet();

      for (final type in TruffleType.values) {
        expect(
          fileNames.contains('${type.dbValue}.jpeg'),
          isTrue,
          reason: 'Missing canonical jpeg asset for ${type.dbValue}',
        );
        expect(
          fileNames.contains('${type.dbValue}.jpg'),
          isFalse,
          reason: 'Unexpected duplicate jpg asset for ${type.dbValue}',
        );
      }
    });
  });
}
