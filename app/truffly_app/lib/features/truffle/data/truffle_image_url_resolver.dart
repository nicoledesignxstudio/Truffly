import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/config/runtime_config.dart';
import 'package:truffly_app/core/config/local_backend_url_resolver.dart';

final class TruffleImageUrlResolver {
  TruffleImageUrlResolver(this._supabaseClient);

  static const bucketId = 'truffle_images';
  static const _signedUrlExpiresInSeconds = 60 * 60;

  final SupabaseClient _supabaseClient;

  Future<List<String?>> resolveOrderedUrls(Iterable<String?> rawValues) async {
    final storage = _supabaseClient.storage.from(bucketId);
    final resolvedUrls = <String?>[];

    for (final rawValue in rawValues) {
      final normalizedValue = _normalizeRawValue(rawValue);
      if (normalizedValue == null) {
        resolvedUrls.add(null);
        continue;
      }
      final storagePath = _extractStoragePath(normalizedValue);
      if (_isAbsoluteUrl(normalizedValue) && storagePath == null) {
        resolvedUrls.add(_normalizeAbsoluteUrlHost(normalizedValue));
        continue;
      }

      try {
        final signedUrl = await storage.createSignedUrl(
          storagePath ?? normalizedValue,
          _signedUrlExpiresInSeconds,
        );
        resolvedUrls.add(_normalizeAbsoluteUrlHost(signedUrl));
      } catch (_) {
        resolvedUrls.add(null);
      }
    }

    return resolvedUrls;
  }

  String? _normalizeRawValue(String? rawValue) {
    if (rawValue == null) return null;
    final trimmed = rawValue.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _isAbsoluteUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String? _extractStoragePath(String value) {
    if (value.startsWith('$bucketId/')) {
      return value.substring(bucketId.length + 1);
    }
    if (value.startsWith('/$bucketId/')) {
      return value.substring(bucketId.length + 2);
    }
    if (!_isAbsoluteUrl(value)) {
      return value;
    }

    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    final bucketIndex = uri.pathSegments.indexOf(bucketId);
    if (bucketIndex == -1 || bucketIndex >= uri.pathSegments.length - 1) {
      return null;
    }

    return uri.pathSegments.sublist(bucketIndex + 1).join('/');
  }

  String _normalizeAbsoluteUrlHost(String value) {
    try {
      return LocalBackendUrlResolver.normalize(
        value,
        androidHostOverride: RuntimeConfig.androidDeviceHost,
      );
    } on StateError {
      return value;
    }
  }
}
