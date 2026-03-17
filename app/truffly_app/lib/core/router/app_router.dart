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
import 'package:truffly_app/features/auth/presentation/welcome_screen.dart';
import 'package:truffly_app/features/home/presentation/home_screen.dart';
import 'package:truffly_app/features/marketplace/presentation/truffles_page.dart';
import 'package:truffly_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:truffly_app/features/startup/presentation/startup_gate_screen.dart';
import 'package:truffly_app/features/truffle/presentation/truffle_detail_page.dart';

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
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
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
        builder: (context, state) => VerifyEmailScreen(
          prefilledEmail: _prefilledVerifyEmail(state.uri),
        ),
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
      GoRoute(
        path: AppRoutes.truffles,
        builder: (context, state) => const TrufflesPage(),
      ),
      GoRoute(
        path: AppRoutes.truffleDetail,
        builder: (context, state) => TruffleDetailPage(
          truffleId: state.pathParameters['truffleId'] ?? '',
        ),
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

      final authState = ref.read(authNotifierProvider);

      return _redirectForAuthState(
        authState: authState,
        routeState: state,
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
  required GoRouterState routeState,
}) {
  return resolveAuthRedirectForTesting(
    authState: authState,
    location: routeState.matchedLocation,
    uri: routeState.uri,
  );
}

@visibleForTesting
String? resolveAuthRedirectForTesting({
  required AuthState authState,
  required String location,
  required Uri uri,
}) {
  final isResetPasswordRoute = location == AppRoutes.resetPassword;
  final canAccessResetPassword =
      isResetPasswordRoute && _hasValidRecoveryContext(uri);
  final canAccessVerifyEmail =
      location == AppRoutes.verifyEmail && _hasVerifyEmailContext(uri);

  if (canAccessResetPassword) {
    return null;
  }

  return switch (authState) {
    AuthChecking() => _redirectChecking(
        location: location,
        canAccessResetPassword: canAccessResetPassword,
        canAccessVerifyEmail: canAccessVerifyEmail,
      ),
    AuthUnauthenticated() => _redirectUnauthenticated(
        location: location,
        canAccessResetPassword: canAccessResetPassword,
        canAccessVerifyEmail: canAccessVerifyEmail,
      ),
    AuthAuthenticatedUnverified() => _redirectVerifiedEmailRequired(location),
    AuthAuthenticatedOnboardingRequired() => _redirectOnboardingRequired(
        location,
      ),
    AuthAuthenticatedReady() => _redirectAuthenticatedReady(location),
  };
}

String? _redirectChecking({
  required String location,
  required bool canAccessResetPassword,
  required bool canAccessVerifyEmail,
}) {
  // Reuse /startup as a temporary gate while auth_notifier is evaluating
  // the global auth state after bootstrap handoff.
  if (location == AppRoutes.resetPassword && canAccessResetPassword) return null;
  if (location == AppRoutes.verifyEmail && canAccessVerifyEmail) return null;
  if (location == AppRoutes.startup) return null;
  return AppRoutes.startup;
}

String? _redirectUnauthenticated({
  required String location,
  required bool canAccessResetPassword,
  required bool canAccessVerifyEmail,
}) {
  if (_unauthenticatedAllowedRoutes.contains(location)) return null;

  if (location == AppRoutes.verifyEmail && canAccessVerifyEmail) {
    return null;
  }

  if (location == AppRoutes.resetPassword && canAccessResetPassword) {
    return null;
  }

  if (location == AppRoutes.resetPassword) return AppRoutes.forgotPassword;

  if (location == AppRoutes.startup) return AppRoutes.welcome;
  return AppRoutes.welcome;
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
  if (_authenticatedReadyAllowedRoutes.contains(location) ||
      location.startsWith('${AppRoutes.truffles}/')) {
    return null;
  }
  return AppRoutes.home;
}

const Set<String> _unauthenticatedAllowedRoutes = {
  AppRoutes.welcome,
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.forgotPassword,
};

const Set<String> _authenticatedReadyAllowedRoutes = {
  AppRoutes.home,
  AppRoutes.truffles,
};

class _RouterRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}

String? _prefilledVerifyEmail(Uri uri) {
  final email = uri.queryParameters['email']?.trim();
  if (email == null || email.isEmpty) return null;
  return email;
}

bool _hasPrefilledVerifyEmail(Uri uri) {
  return _prefilledVerifyEmail(uri) != null;
}

bool _hasVerifyEmailContext(Uri uri) {
  if (_hasPrefilledVerifyEmail(uri)) return true;

  final query = uri.queryParameters;
  final fragmentParams = _parseUriFragmentAsQueryParams(uri.fragment);

  final hasCode = _firstNonEmpty(query, fragmentParams, 'code') != null;
  final hasAccessToken =
      _firstNonEmpty(query, fragmentParams, 'access_token') != null;
  final hasRefreshToken =
      _firstNonEmpty(query, fragmentParams, 'refresh_token') != null;
  final hasError =
      _firstNonEmpty(query, fragmentParams, 'error_description') != null;

  return hasCode || hasAccessToken || hasRefreshToken || hasError;
}

bool _hasValidRecoveryContext(Uri uri) {
  final query = uri.queryParameters;
  final fragmentParams = _parseUriFragmentAsQueryParams(uri.fragment);

  final type = _firstNonEmpty(query, fragmentParams, 'type');
  final hasRecoveryType = type != null && type.toLowerCase() == 'recovery';
  if (!hasRecoveryType) return false;

  final hasCode = _firstNonEmpty(query, fragmentParams, 'code') != null;
  final hasAccessToken =
      _firstNonEmpty(query, fragmentParams, 'access_token') != null;
  final hasRefreshToken =
      _firstNonEmpty(query, fragmentParams, 'refresh_token') != null;

  return hasCode || hasAccessToken || hasRefreshToken;
}

Map<String, String> _parseUriFragmentAsQueryParams(String fragment) {
  if (fragment.trim().isEmpty) return const {};

  try {
    return Uri.splitQueryString(fragment);
  } catch (_) {
    return const {};
  }
}

String? _firstNonEmpty(
  Map<String, String> query,
  Map<String, String> fragment,
  String key,
) {
  final queryValue = query[key]?.trim();
  if (queryValue != null && queryValue.isNotEmpty) return queryValue;

  final fragmentValue = fragment[key]?.trim();
  if (fragmentValue != null && fragmentValue.isNotEmpty) return fragmentValue;

  return null;
}
