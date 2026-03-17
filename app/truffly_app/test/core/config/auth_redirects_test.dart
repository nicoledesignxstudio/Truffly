import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/core/config/auth_redirects.dart';

void main() {
  test('verify email callback URI uses the mobile auth scheme', () {
    expect(
      AuthRedirects.verifyEmailCallbackUri.toString(),
      'truffly://auth/verify-email',
    );
  });

  test('reset password callback URI uses the mobile auth scheme', () {
    expect(
      AuthRedirects.resetPasswordCallbackUri.toString(),
      'truffly://auth/reset-password',
    );
  });
}
