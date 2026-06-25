import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/auth/data/auth_service.dart';

void main() {
  group('emailChangeIsCompleted', () {
    test('rejects the old confirmed email while the new email is pending', () {
      const snapshot = AuthUserSnapshot(
        userId: 'user-1',
        email: 'old@example.com',
        emailVerified: true,
        pendingEmail: 'new@example.com',
      );

      expect(
        emailChangeIsCompleted(
          snapshot: snapshot,
          expectedEmail: 'new@example.com',
        ),
        isFalse,
      );
    });

    test('accepts only the confirmed new email with no pending change', () {
      const snapshot = AuthUserSnapshot(
        userId: 'user-1',
        email: 'new@example.com',
        emailVerified: true,
        pendingEmail: null,
      );

      expect(
        emailChangeIsCompleted(
          snapshot: snapshot,
          expectedEmail: 'NEW@example.com ',
        ),
        isTrue,
      );
    });
  });
}
