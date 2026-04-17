import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/core/config/auth_redirects.dart';

void main() {
  test('verify email callback URI falls back to the mobile auth scheme in debug', () {
    expect(
      AuthRedirects.verifyEmailCallbackUri.toString(),
      'truffly://auth/verify-email',
    );
  });

  test('reset password callback URI falls back to the mobile auth scheme in debug', () {
    expect(
      AuthRedirects.resetPasswordCallbackUri.toString(),
      'truffly://auth/reset-password',
    );
  });
}
