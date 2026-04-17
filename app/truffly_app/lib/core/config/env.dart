import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class Env {
  Env._();

  static String get supabaseUrl => _normalizeSupabaseUrl(_require('SUPABASE_URL'));
  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');
  static String get stripePublishableKey =>
      _optional('STRIPE_PUBLISHABLE_KEY') ??
      _require('STRIPE_PUBLISHABLE_KEY_TEST');
  static String? get stripeMerchantIdentifier =>
      _optional('STRIPE_MERCHANT_IDENTIFIER');
  static String get stripeMerchantCountryCode =>
      (_optional('STRIPE_MERCHANT_COUNTRY_CODE') ?? 'IT').toUpperCase();

  static void validate() {
    _normalizeSupabaseUrl(_require('SUPABASE_URL'));
    _require('SUPABASE_ANON_KEY');
    stripePublishableKey;
  }

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing required environment variable: $key');
    }
    return value;
  }

  static String? _optional(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      return null;
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
