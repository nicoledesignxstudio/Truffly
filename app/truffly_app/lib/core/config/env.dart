import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class Env {
  Env._();

  static String get supabaseUrl => _normalizeSupabaseUrl(_require('SUPABASE_URL'));
  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  static void validate() {
    _normalizeSupabaseUrl(_require('SUPABASE_URL'));
    _require('SUPABASE_ANON_KEY');
  }

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing required environment variable: $key');
    }
    return value;
  }

  static String _normalizeSupabaseUrl(String rawUrl) {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) {
      throw StateError('Invalid SUPABASE_URL: $rawUrl');
    }

    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final host = uri.host.trim().toLowerCase();
    final shouldUseEmulatorLoopback =
        isAndroid && (host == '127.0.0.1' || host == 'localhost');

    if (!shouldUseEmulatorLoopback) {
      return uri.toString();
    }

    return uri.replace(host: '10.0.2.2').toString();
  }
}
