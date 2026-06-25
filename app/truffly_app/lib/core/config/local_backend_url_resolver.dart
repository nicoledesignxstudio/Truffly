import 'package:flutter/foundation.dart';

final class LocalBackendUrlResolver {
  const LocalBackendUrlResolver._();

  static String normalize(String rawUrl, {String? androidHostOverride}) {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) {
      throw StateError('Invalid URL: $rawUrl');
    }

    if (!_isAndroid || uri.host.isEmpty) {
      return uri.toString();
    }

    final overrideHost = _normalizeOverrideHost(androidHostOverride);
    if (overrideHost != null && _isAndroidLocalOnlyHost(uri.host)) {
      return uri.replace(host: overrideHost).toString();
    }

    if (_isLoopbackHost(uri.host)) {
      return uri.replace(host: '10.0.2.2').toString();
    }

    return uri.toString();
  }

  static bool get _isAndroid {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  static String? _normalizeOverrideHost(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static bool _isLoopbackHost(String host) {
    final normalizedHost = host.trim().toLowerCase();
    return normalizedHost == '127.0.0.1' || normalizedHost == 'localhost';
  }

  static bool _isAndroidLocalOnlyHost(String host) {
    final normalizedHost = host.trim().toLowerCase();
    return normalizedHost == '127.0.0.1' ||
        normalizedHost == 'localhost' ||
        normalizedHost == '10.0.2.2';
  }
}
