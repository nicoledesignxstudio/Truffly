import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/bootstrap/application/bootstrap_notifier.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_state.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
import 'package:truffly_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:truffly_app/features/auth/presentation/login_screen.dart';
import 'package:truffly_app/features/auth/presentation/reset_password_screen.dart';
import 'package:truffly_app/features/auth/presentation/signup_screen.dart';
import 'package:truffly_app/features/auth/presentation/verify_email_screen.dart';
import 'package:truffly_app/features/home/presentation/home_screen.dart';
import 'package:truffly_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:truffly_app/features/startup/presentation/startup_gate_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshListenable();
  ref.onDispose(refreshListenable.dispose);

  _registerRouterRefreshSources(ref, refreshListenable);

  return GoRouter(
    initialLocation: AppRoutes.startup,
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: AppRoutes.startup,
        builder: (context, state) => const StartupGateScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (_, state) {
      final bootstrapState = ref.read(bootstrapNotifierProvider);
      final location = state.matchedLocation;

      final startupRedirect = _redirectForStartupGate(
        bootstrapState: bootstrapState,
        location: location,
      );

      if (startupRedirect != null) {
        return startupRedirect;
      }

      _ensureAuthHandoffInitialized(ref);
      final authState = ref.read(authNotifierProvider);

      return _redirectForAuthState(
        authState: authState,
        location: location,
      );
    },
  );
});

void _registerRouterRefreshSources(
  Ref ref,
  _RouterRefreshListenable refreshListenable,
) {
  ref.listen<BootstrapState>(bootstrapNotifierProvider, (previous, next) {
    refreshListenable.refresh();
  });

  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    refreshListenable.refresh();
  });
}

void _ensureAuthHandoffInitialized(Ref ref) {
  // After bootstrap infrastructure gate passes, auth_notifier becomes
  // the source of truth for app-access routing.
  ref.read(authNotifierProvider.notifier).ensureInitialized();
}

String? _redirectForStartupGate({
  required BootstrapState bootstrapState,
  required String location,
}) {
  final isStartupRoute = location == AppRoutes.startup;

  return switch (bootstrapState) {
    // Bootstrap owns infrastructure readiness gate only.
    BootstrapInitial() || BootstrapLoading() || BootstrapError() =>
      isStartupRoute ? null : AppRoutes.startup,
    _ => null,
  };
}

String? _redirectForAuthState({
  required AuthState authState,
  required String location,
}) {
  return switch (authState) {
    AuthChecking() => _redirectChecking(location),
    AuthUnauthenticated() => _redirectUnauthenticated(location),
    AuthAuthenticatedUnverified() => _redirectVerifiedEmailRequired(location),
    AuthAuthenticatedOnboardingRequired() => _redirectOnboardingRequired(
        location,
      ),
    AuthAuthenticatedReady() => _redirectAuthenticatedReady(location),
  };
}

String? _redirectChecking(String location) {
  // Reuse /startup as a temporary gate while auth_notifier is evaluating
  // the global auth state after bootstrap handoff.
  if (location == AppRoutes.startup) return null;
  return AppRoutes.startup;
}

String? _redirectUnauthenticated(String location) {
  if (_unauthenticatedAllowedRoutes.contains(location)) return null;

  // TODO(auth-step6): Allow /reset-password only with a valid recovery
  // context (deep link + recovery session).
  if (location == AppRoutes.resetPassword) return AppRoutes.forgotPassword;

  if (location == AppRoutes.startup) return AppRoutes.login;
  return AppRoutes.login;
}

String? _redirectVerifiedEmailRequired(String location) {
  if (location == AppRoutes.verifyEmail) return null;
  return AppRoutes.verifyEmail;
}

String? _redirectOnboardingRequired(String location) {
  if (location == AppRoutes.onboarding) return null;
  return AppRoutes.onboarding;
}

String? _redirectAuthenticatedReady(String location) {
  if (location == AppRoutes.home) return null;
  return AppRoutes.home;
}

const Set<String> _unauthenticatedAllowedRoutes = {
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.forgotPassword,
};

class _RouterRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}
