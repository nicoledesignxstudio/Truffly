import 'package:supabase_flutter/supabase_flutter.dart';

final class TruffleImageUrlResolver {
  TruffleImageUrlResolver(this._supabaseClient);

  static const bucketId = 'truffle_images';

  final SupabaseClient _supabaseClient;

  List<String?> resolveOrderedUrls(Iterable<String?> rawValues) {
    final storage = _supabaseClient.storage.from(bucketId);

    return rawValues.map((rawValue) {
      final normalizedValue = _normalizeRawValue(rawValue);
      if (normalizedValue == null) return null;
      if (_isAbsoluteUrl(normalizedValue)) return normalizedValue;
      return storage.getPublicUrl(normalizedValue);
    }).toList(growable: false);
  }

  String? _normalizeRawValue(String? rawValue) {
    if (rawValue == null) return null;
    final trimmed = rawValue.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _isAbsoluteUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }
}
