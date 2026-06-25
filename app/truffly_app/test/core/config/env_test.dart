import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/core/config/env.dart';

void main() {
  group('Env validation', () {
    test('accepts a valid Supabase origin', () {
      expect(
        Env.validateSupabaseUrl('https://abc.supabase.co'),
        'https://abc.supabase.co',
      );
      expect(
        Env.validateSupabaseUrl('https://abc.supabase.co/'),
        'https://abc.supabase.co',
      );
    });

    test('rejects a Supabase URL with a path', () {
      expect(
        () => Env.validateSupabaseUrl('https://abc.supabase.co/rest/v1'),
        throwsStateError,
      );
    });

    test('rejects an empty Supabase URL', () {
      expect(() => Env.validateSupabaseUrl('   '), throwsStateError);
    });

    test('rejects an empty Supabase anon key', () {
      expect(() => Env.validateSupabaseAnonKey('   '), throwsStateError);
    });
  });
}
