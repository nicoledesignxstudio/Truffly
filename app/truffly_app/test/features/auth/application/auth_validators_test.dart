import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/auth/application/auth_validators.dart';
import 'package:truffly_app/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('AuthValidators.validateEmail', () {
    test('returns error when email is null or empty', () {
      expect(AuthValidators.validateEmail(null, l10n), isNotNull);
      expect(AuthValidators.validateEmail('   ', l10n), isNotNull);
    });

    test('returns error when email is invalid', () {
      expect(AuthValidators.validateEmail('invalid-email', l10n), isNotNull);
    });

    test('returns null when email is valid', () {
      expect(
        AuthValidators.validateEmail('test@example.com', l10n),
        isNull,
      );
    });
  });

  group('AuthValidators.validatePassword', () {
    test('returns error when password is null or empty', () {
      expect(AuthValidators.validatePassword(null, l10n), isNotNull);
      expect(AuthValidators.validatePassword('   ', l10n), isNotNull);
    });

    test('returns error when password is too short', () {
      expect(AuthValidators.validatePassword('a1b2c3', l10n), isNotNull);
    });

    test('returns error when password misses letters or numbers', () {
      expect(AuthValidators.validatePassword('12345678', l10n), isNotNull);
      expect(AuthValidators.validatePassword('abcdefgh', l10n), isNotNull);
    });

    test('returns null when password is valid', () {
      expect(AuthValidators.validatePassword('abc12345', l10n), isNull);
    });
  });

  group('AuthValidators.validateConfirmPassword', () {
    test('returns error when confirm password is empty', () {
      expect(
        AuthValidators.validateConfirmPassword(null, 'abc12345', l10n),
        isNotNull,
      );
      expect(
        AuthValidators.validateConfirmPassword('   ', 'abc12345', l10n),
        isNotNull,
      );
    });

    test('returns error when passwords do not match', () {
      expect(
        AuthValidators.validateConfirmPassword('abc12346', 'abc12345', l10n),
        isNotNull,
      );
    });

    test('returns null when passwords match', () {
      expect(
        AuthValidators.validateConfirmPassword('abc12345', 'abc12345', l10n),
        isNull,
      );
    });
  });
}
