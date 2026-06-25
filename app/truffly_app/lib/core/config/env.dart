class Env {
  Env._();

  static const String appEnvironment =
      String.fromEnvironment('APP_ENV', defaultValue: 'local');

  static const String _supabaseUrlRaw = String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKeyRaw =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static String get supabaseUrl => validateSupabaseUrl(_supabaseUrlRaw);

  static String get supabaseAnonKey =>
      validateSupabaseAnonKey(_supabaseAnonKeyRaw);

  static void validate() {
    validateSupabaseUrl(_supabaseUrlRaw);
    validateSupabaseAnonKey(_supabaseAnonKeyRaw);
  }

  static String validateSupabaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw StateError(
        'Missing required dart-define: SUPABASE_URL. '
        'Pass an origin such as https://project-ref.supabase.co.',
      );
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.trim().isEmpty) {
      throw StateError(
        'Invalid SUPABASE_URL: $trimmed. '
        'Use a valid Supabase project origin such as '
        'https://project-ref.supabase.co.',
      );
    }

    if (uri.query.isNotEmpty || uri.fragment.isNotEmpty) {
      throw StateError(
        'SUPABASE_URL must be the Supabase project origin, without a path. '
        'Example: https://project-ref.supabase.co',
      );
    }

    return uri.origin;
  }

  static String validateSupabaseAnonKey(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw StateError(
        'Missing required dart-define: SUPABASE_ANON_KEY. '
        'Use the public anon key for the client app.',
      );
    }

    return trimmed;
  }
}
