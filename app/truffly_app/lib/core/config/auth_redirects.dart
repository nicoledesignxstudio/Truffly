import 'package:flutter/foundation.dart';

class AuthRedirects {
  static const _debugScheme = 'truffly';
  static const _debugHost = 'auth';
  static const _verifyEmailPath = '/verify-email';
  static const _resetPasswordPath = '/reset-password';
  static const _productionBaseUrl = String.fromEnvironment(
    'AUTH_REDIRECT_BASE_URL',
  );

  static Uri get verifyEmailCallbackUri => _resolveCallbackUri(_verifyEmailPath);

  static Uri get resetPasswordCallbackUri =>
      _resolveCallbackUri(_resetPasswordPath);

  static void validateConfiguration() {
    _resolveProductionBaseUri();
  }

  static Uri _resolveCallbackUri(String path) {
    final productionBaseUri = _resolveProductionBaseUri();
    if (productionBaseUri != null) {
      return productionBaseUri.replace(
        path: _joinPath(productionBaseUri.path, path),
        query: null,
        fragment: null,
      );
    }

    return Uri(
      scheme: _debugScheme,
      host: _debugHost,
      path: path,
    );
  }

  static Uri? _resolveProductionBaseUri() {
    final configuredValue = _productionBaseUrl.trim();
    if (configuredValue.isEmpty) {
      if (kReleaseMode) {
        throw StateError(
          'Missing AUTH_REDIRECT_BASE_URL for release build. '
          'Production auth callbacks must use an HTTPS universal/app link.',
        );
      }
      return null;
    }

    final uri = Uri.tryParse(configuredValue);
    if (uri == null || !uri.hasScheme || uri.host.trim().isEmpty) {
      throw StateError(
        'Invalid AUTH_REDIRECT_BASE_URL: $configuredValue',
      );
    }

    if (uri.scheme.toLowerCase() != 'https') {
      throw StateError(
        'AUTH_REDIRECT_BASE_URL must use https: $configuredValue',
      );
    }

    final normalizedPath = uri.path.trim();
    if (normalizedPath.isNotEmpty && normalizedPath != '/') {
      throw StateError(
        'AUTH_REDIRECT_BASE_URL must not include a path. '
        'Provide only the HTTPS origin, for example https://auth.example.com',
      );
    }

    return uri;
  }

  static String _joinPath(String basePath, String callbackPath) {
    final normalizedBase = basePath.trim().replaceAll(RegExp(r'/+$'), '');
    final normalizedCallback = callbackPath.trim();
    if (normalizedBase.isEmpty) {
      return normalizedCallback;
    }
    return '$normalizedBase$normalizedCallback';
  }
}
