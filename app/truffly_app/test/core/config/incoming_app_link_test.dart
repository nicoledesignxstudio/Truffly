import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/core/config/incoming_app_link.dart';

void main() {
  group('normalizeIncomingAppLink', () {
    test('maps reset password auth links to an internal app route', () {
      final result = normalizeIncomingAppLink(
        Uri.parse(
          'truffly://auth/reset-password?type=recovery#access_token=abc&refresh_token=def',
        ),
      );

      expect(
        result?.toString(),
        '/reset-password?type=recovery#access_token=abc&refresh_token=def',
      );
    });

    test('maps verify email auth links to an internal app route', () {
      final result = normalizeIncomingAppLink(
        Uri.parse('truffly://auth/verify-email?type=signup&code=abc'),
      );

      expect(result?.toString(), '/verify-email?type=signup&code=abc');
    });

    test('ignores non auth links', () {
      final result = normalizeIncomingAppLink(
        Uri.parse('truffly://stripe-redirect?payment_intent=pi_123'),
      );

      expect(result, isNull);
    });
  });
}
