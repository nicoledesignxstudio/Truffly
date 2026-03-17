import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_image_draft.dart';

enum PublishTruffleImagePreparationFailure {
  unsupportedFormat,
  missingFile,
  tooLarge,
  processingFailed,
}

final class PublishTruffleImagePreparationException implements Exception {
  const PublishTruffleImagePreparationException(this.failure);

  final PublishTruffleImagePreparationFailure failure;
}

final class PublishTruffleImageValidationService {
  static const maxImageBytes = 1500000;
  static const _maxDimension = 1600;
  static const _jpegQualities = <int>[82, 74, 66, 58, 50, 42, 34];
  static const _pngScaleFactors = <double>[1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4];

  Future<PublishTruffleImageDraft> prepareSelectedImage(XFile pickedFile) async {
    final localPath = pickedFile.path.trim();
    if (localPath.isEmpty) {
      throw const PublishTruffleImagePreparationException(
        PublishTruffleImagePreparationFailure.missingFile,
      );
    }

    final sourceFile = File(localPath);
    if (!await sourceFile.exists()) {
      throw const PublishTruffleImagePreparationException(
        PublishTruffleImagePreparationFailure.missingFile,
      );
    }

    Uint8List sourceBytes;
    try {
      sourceBytes = await sourceFile.readAsBytes();
    } on FileSystemException {
      throw const PublishTruffleImagePreparationException(
        PublishTruffleImagePreparationFailure.missingFile,
      );
    } catch (_) {
      throw const PublishTruffleImagePreparationException(
        PublishTruffleImagePreparationFailure.processingFailed,
      );
    }

    if (sourceBytes.isEmpty) {
      throw const PublishTruffleImagePreparationException(
        PublishTruffleImagePreparationFailure.missingFile,
      );
    }

    final detectedFormat = _detectImageFormat(sourceBytes);
    if (detectedFormat == null) {
      throw const PublishTruffleImagePreparationException(
        PublishTruffleImagePreparationFailure.unsupportedFormat,
      );
    }

    final decodedImage = _decodeImage(sourceBytes);
    if (decodedImage == null) {
      throw const PublishTruffleImagePreparationException(
        PublishTruffleImagePreparationFailure.processingFailed,
      );
    }

    try {
      final bakedImage = img.bakeOrientation(decodedImage);
      final processedImage = _resizeToMaxDimension(bakedImage);
      final encodedBytes = _encodeWithinLimit(processedImage, detectedFormat);
      if (encodedBytes == null || encodedBytes.length > maxImageBytes) {
        throw const PublishTruffleImagePreparationException(
          PublishTruffleImagePreparationFailure.tooLarge,
        );
      }

      final preparedPath = await _writePreparedImage(
        bytes: encodedBytes,
        extension: detectedFormat.extension,
      );

      return PublishTruffleImageDraft(
        localPath: preparedPath,
        fileName: _normalizedFileName(
          pickedFile.name,
          detectedFormat.extension,
        ),
        contentType: detectedFormat.contentType,
        byteCount: encodedBytes.length,
      );
    } on PublishTruffleImagePreparationException {
      rethrow;
    } catch (_) {
      throw const PublishTruffleImagePreparationException(
        PublishTruffleImagePreparationFailure.processingFailed,
      );
    }
  }

  _DetectedImageFormat? _detectImageFormat(Uint8List bytes) {
    if (_isJpeg(bytes)) {
      return const _DetectedImageFormat(
        extension: '.jpg',
        contentType: 'image/jpeg',
      );
    }
    if (_isPng(bytes)) {
      return const _DetectedImageFormat(
        extension: '.png',
        contentType: 'image/png',
      );
    }
    return null;
  }

  img.Image? _decodeImage(Uint8List bytes) {
    try {
      return img.decodeImage(bytes);
    } catch (_) {
      return null;
    }
  }

  img.Image _resizeToMaxDimension(img.Image source) {
    final longestSide = math.max(source.width, source.height);
    if (longestSide <= _maxDimension) {
      return img.Image.from(source);
    }

    if (source.width >= source.height) {
      return img.copyResize(
        source,
        width: _maxDimension,
        interpolation: img.Interpolation.average,
      );
    }

    return img.copyResize(
      source,
      height: _maxDimension,
      interpolation: img.Interpolation.average,
    );
  }

  Uint8List? _encodeWithinLimit(
    img.Image source,
    _DetectedImageFormat format,
  ) {
    return switch (format.contentType) {
      'image/jpeg' => _encodeJpegWithinLimit(source),
      'image/png' => _encodePngWithinLimit(source),
      _ => null,
    };
  }

  Uint8List? _encodeJpegWithinLimit(img.Image source) {
    for (final quality in _jpegQualities) {
      final encoded = Uint8List.fromList(
        img.encodeJpg(source, quality: quality),
      );
      if (encoded.length <= maxImageBytes) {
        return encoded;
      }
    }
    return null;
  }

  Uint8List? _encodePngWithinLimit(img.Image source) {
    for (final scale in _pngScaleFactors) {
      final candidate = scale == 1
          ? img.Image.from(source)
          : img.copyResize(
              source,
              width: math.max(1, (source.width * scale).round()),
              height: math.max(1, (source.height * scale).round()),
              interpolation: img.Interpolation.average,
            );

      final encoded = Uint8List.fromList(
        img.encodePng(candidate, level: 6),
      );
      if (encoded.length <= maxImageBytes) {
        return encoded;
      }
    }
    return null;
  }

  Future<String> _writePreparedImage({
    required Uint8List bytes,
    required String extension,
  }) async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'truffly_publish_image_',
    );
    final fileName =
        'prepared_${DateTime.now().microsecondsSinceEpoch}$extension';
    final outputFile = File(
      '${tempDirectory.path}${Platform.pathSeparator}$fileName',
    );
    await outputFile.writeAsBytes(bytes, flush: true);
    return outputFile.path;
  }

  bool _isJpeg(List<int> bytes) {
    return bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
  }

  bool _isPng(List<int> bytes) {
    const pngSignature = <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    if (bytes.length < pngSignature.length) return false;

    for (var index = 0; index < pngSignature.length; index++) {
      if (bytes[index] != pngSignature[index]) {
        return false;
      }
    }

    return true;
  }

  String _normalizedFileName(String fileName, String extension) {
    final trimmed = fileName.trim();
    final lastDotIndex = trimmed.lastIndexOf('.');
    final baseName = lastDotIndex > 0 ? trimmed.substring(0, lastDotIndex) : trimmed;
    final safeBaseName = baseName.isEmpty ? 'publish_truffle_image' : baseName;
    return '$safeBaseName$extension';
  }
}

final class _DetectedImageFormat {
  const _DetectedImageFormat({
    required this.extension,
    required this.contentType,
  });

  final String extension;
  final String contentType;
}
