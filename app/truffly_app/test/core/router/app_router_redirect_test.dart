import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/core/router/app_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';

void main() {
  const unverified = AuthAuthenticatedUnverified(
    userId: 'u1',
    email: 'u1@example.com',
  );
  const onboarding = AuthAuthenticatedOnboardingRequired(
    userId: 'u2',
    email: 'u2@example.com',
  );
  const ready = AuthAuthenticatedReady(userId: 'u3', email: 'u3@example.com');

  Uri uriFor(String value) => Uri.parse(value);

  group('router redirect unauthenticated', () {
    test('/home -> /welcome', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: const AuthUnauthenticated(),
        location: AppRoutes.home,
        uri: uriFor(AppRoutes.home),
      );
      expect(redirect, AppRoutes.welcome);
    });

    test('/onboarding -> /welcome', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: const AuthUnauthenticated(),
        location: AppRoutes.onboarding,
        uri: uriFor(AppRoutes.onboarding),
      );
      expect(redirect, AppRoutes.welcome);
    });

    test('/verify-email -> /welcome', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: const AuthUnauthenticated(),
        location: AppRoutes.verifyEmail,
        uri: uriFor(AppRoutes.verifyEmail),
      );
      expect(redirect, AppRoutes.welcome);
    });

    test('/verify-email with signup email is accessible', () {
      final location = AppRoutes.verifyEmail;
      final uri = uriFor(
        AppRoutes.verifyEmailWithPrefill('signup@example.com'),
      );
      final redirect = resolveAuthRedirectForTesting(
        authState: const AuthUnauthenticated(),
        location: location,
        uri: uri,
      );
      expect(redirect, isNull);
    });

    test('/verify-email auth callback with code is accessible', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: const AuthUnauthenticated(),
        location: AppRoutes.verifyEmail,
        uri: uriFor('${AppRoutes.verifyEmail}?code=abc123'),
      );
      expect(redirect, isNull);
    });
  });

  group('router redirect unverified', () {
    test('/verify-email stays on verify-email', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: unverified,
        location: AppRoutes.verifyEmail,
        uri: uriFor(AppRoutes.verifyEmail),
      );
      expect(redirect, isNull);
    });

    test('/home -> /verify-email', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: unverified,
        location: AppRoutes.home,
        uri: uriFor(AppRoutes.home),
      );
      expect(redirect, AppRoutes.verifyEmail);
    });

    test('/login -> /verify-email', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: unverified,
        location: AppRoutes.login,
        uri: uriFor(AppRoutes.login),
      );
      expect(redirect, AppRoutes.verifyEmail);
    });

    test('/welcome -> /verify-email', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: unverified,
        location: AppRoutes.welcome,
        uri: uriFor(AppRoutes.welcome),
      );
      expect(redirect, AppRoutes.verifyEmail);
    });
  });

  group('router redirect onboarding required', () {
    test('/home -> /onboarding', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: onboarding,
        location: AppRoutes.home,
        uri: uriFor(AppRoutes.home),
      );
      expect(redirect, AppRoutes.onboarding);
    });

    test('/verify-email -> /onboarding', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: onboarding,
        location: AppRoutes.verifyEmail,
        uri: uriFor(AppRoutes.verifyEmail),
      );
      expect(redirect, AppRoutes.onboarding);
    });
  });

  group('router redirect ready', () {
    test('/login -> /home', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: ready,
        location: AppRoutes.login,
        uri: uriFor(AppRoutes.login),
      );
      expect(redirect, AppRoutes.home);
    });

    test('/welcome -> /home', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: ready,
        location: AppRoutes.welcome,
        uri: uriFor(AppRoutes.welcome),
      );
      expect(redirect, AppRoutes.home);
    });

    test('/verify-email -> /home', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: ready,
        location: AppRoutes.verifyEmail,
        uri: uriFor(AppRoutes.verifyEmail),
      );
      expect(redirect, AppRoutes.home);
    });

    test('/onboarding -> /home', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: ready,
        location: AppRoutes.onboarding,
        uri: uriFor(AppRoutes.onboarding),
      );
      expect(redirect, AppRoutes.home);
    });

    test('/truffles stays on truffles', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: ready,
        location: AppRoutes.truffles,
        uri: uriFor(AppRoutes.truffles),
      );
      expect(redirect, isNull);
    });

    test('/guides stays on guides', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: ready,
        location: AppRoutes.guides,
        uri: uriFor(AppRoutes.guides),
      );
      expect(redirect, isNull);
    });

    test('/truffles/:id stays on detail route', () {
      final location = AppRoutes.truffleDetailPath('abc');
      final redirect = resolveAuthRedirectForTesting(
        authState: ready,
        location: location,
        uri: uriFor(location),
      );
      expect(redirect, isNull);
    });
  });

  group('router redirect reset password', () {
    test('without valid recovery context is not publicly accessible', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: const AuthUnauthenticated(),
        location: AppRoutes.resetPassword,
        uri: uriFor('${AppRoutes.resetPassword}?type=recovery'),
      );
      expect(redirect, AppRoutes.forgotPassword);
    });

    test('with valid recovery context is accessible', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: const AuthUnauthenticated(),
        location: AppRoutes.resetPassword,
        uri: uriFor('${AppRoutes.resetPassword}?type=recovery&code=abc'),
      );
      expect(redirect, isNull);
    });

    test(
      'with valid recovery context is accessible even when authenticated',
      () {
        final redirect = resolveAuthRedirectForTesting(
          authState: ready,
          location: AppRoutes.resetPassword,
          uri: uriFor('${AppRoutes.resetPassword}?type=recovery&code=abc'),
        );
        expect(redirect, isNull);
      },
    );

    test('with valid recovery fragment tokens is accessible', () {
      final redirect = resolveAuthRedirectForTesting(
        authState: const AuthUnauthenticated(),
        location: AppRoutes.resetPassword,
        uri: uriFor(
          '${AppRoutes.resetPassword}#type=recovery&access_token=abc&refresh_token=def',
        ),
      );
      expect(redirect, isNull);
    });
  });
}
