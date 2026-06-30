import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/config/auth_callback_context.dart';
import 'package:truffly_app/core/bootstrap/application/bootstrap_notifier.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_state.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/account/presentation/account_favorites_page.dart';
import 'package:truffly_app/features/account/presentation/account_privacy_policy_page.dart';
import 'package:truffly_app/features/account/presentation/account_refund_and_cancellation_page.dart';
import 'package:truffly_app/features/account/presentation/account_legal_information_page.dart';
import 'package:truffly_app/features/account/presentation/account_details_page.dart';
import 'package:truffly_app/features/account/presentation/account_become_seller_page.dart';
import 'package:truffly_app/features/account/presentation/account_page.dart';
import 'package:truffly_app/features/account/presentation/account_settings_page.dart';
import 'package:truffly_app/features/account/presentation/account_support_page.dart';
import 'package:truffly_app/features/account/presentation/account_terms_and_conditions_page.dart';
import 'package:truffly_app/features/account/presentation/shipping_address_form_page.dart';
import 'package:truffly_app/features/account/presentation/shipping_addresses_page.dart';
import 'package:truffly_app/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:truffly_app/features/admin/presentation/admin_seller_application_detail_screen.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
import 'package:truffly_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:truffly_app/features/auth/presentation/login_screen.dart';
import 'package:truffly_app/features/auth/presentation/reset_password_screen.dart';
import 'package:truffly_app/features/auth/presentation/signup_screen.dart';
import 'package:truffly_app/features/auth/presentation/verify_email_screen.dart';
import 'package:truffly_app/features/auth/presentation/welcome_screen.dart';
import 'package:truffly_app/features/checkout/presentation/checkout_page.dart';
import 'package:truffly_app/features/guides/presentation/truffle_guide_detail_page.dart';
import 'package:truffly_app/features/guides/presentation/truffle_guides_page.dart';
import 'package:truffly_app/features/home/presentation/home_screen.dart';
import 'package:truffly_app/features/notifications/presentation/notifications_inbox_page.dart';
import 'package:truffly_app/features/marketplace/presentation/truffles_page.dart';
import 'package:truffly_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:truffly_app/features/onboarding/presentation/account_seller_onboarding_page.dart';
import 'package:truffly_app/features/orders/presentation/order_detail_page.dart';
import 'package:truffly_app/features/orders/presentation/orders_page.dart';
import 'package:truffly_app/features/profile/presentation/seller_profile_page.dart';
import 'package:truffly_app/features/sellers/presentation/sellers_page.dart';
import 'package:truffly_app/features/startup/presentation/startup_gate_screen.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';
import 'package:truffly_app/features/truffle/presentation/seller_my_truffles_page.dart';
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
        builder: (context, state) =>
            SignupScreen(prefilledEmail: state.uri.queryParameters['email']),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) {
          final callbackContext = AuthCallbackContext.fromUri(state.uri);
          final isEmailChange =
              state.uri.queryParameters['source'] == 'email_change' ||
              callbackContext.type == 'email_change';

          return VerifyEmailScreen(
            prefilledEmail: callbackContext.prefilledEmail,
            manualVerificationFlow: isEmailChange,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => ResetPasswordScreen(
          callbackContext: AuthCallbackContext.fromUri(state.uri),
        ),
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
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsInboxPage(),
      ),
      GoRoute(
        path: AppRoutes.account,
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(
        path: AppRoutes.accountOrders,
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: AppRoutes.accountOrderDetail,
        builder: (context, state) => OrderDetailPage(
          orderId: state.pathParameters['orderId'] ?? '',
          openReviewOnLoad: state.uri.queryParameters['openReview'] == 'true',
        ),
      ),
      GoRoute(
        path: AppRoutes.accountFavorites,
        builder: (context, state) => const AccountFavoritesPage(),
      ),
      GoRoute(
        path: AppRoutes.accountDetails,
        builder: (context, state) => const AccountDetailsPage(),
      ),
      GoRoute(
        path: AppRoutes.accountShipping,
        builder: (context, state) => const ShippingAddressesPage(),
      ),
      GoRoute(
        path: AppRoutes.accountShippingAdd,
        builder: (context, state) => const ShippingAddressFormPage(),
      ),
      GoRoute(
        path: AppRoutes.accountShippingEdit,
        builder: (context, state) => ShippingAddressFormPage(
          addressId: state.pathParameters['addressId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.accountBecomeSeller,
        builder: (context, state) => AccountBecomeSellerPage(
          stripeCallbackHint: state.uri.queryParameters['stripe'],
        ),
      ),
      GoRoute(
        path: AppRoutes.accountSellerOnboarding,
        builder: (context, state) => const AccountSellerOnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.accountAdmin,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountAdminSellerApplication,
        builder: (context, state) => AdminSellerApplicationDetailScreen(
          userId: state.pathParameters['userId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.accountMyTruffles,
        builder: (context, state) => const SellerMyTrufflesPage(),
        redirect: (_, _) => _redirectAccountMyTruffles(ref),
      ),
      GoRoute(
        path: AppRoutes.accountGuide,
        redirect: (_, _) => AppRoutes.guides,
      ),
      GoRoute(
        path: AppRoutes.accountSupport,
        builder: (context, state) => const AccountSupportPage(),
      ),
      GoRoute(
        path: AppRoutes.accountSettings,
        builder: (context, state) => const AccountSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.accountPrivacyPolicy,
        builder: (context, state) => const AccountPrivacyPolicyPage(),
      ),
      GoRoute(
        path: AppRoutes.accountTerms,
        builder: (context, state) => const AccountTermsAndConditionsPage(),
      ),
      GoRoute(
        path: AppRoutes.accountRefundAndCancellation,
        builder: (context, state) => const AccountRefundAndCancellationPage(),
      ),
      GoRoute(
        path: AppRoutes.accountLegalInformation,
        builder: (context, state) => const AccountLegalInformationPage(),
      ),
      GoRoute(
        path: AppRoutes.truffles,
        builder: (context, state) => const TrufflesPage(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) =>
            CheckoutPage(truffleId: state.pathParameters['truffleId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.sellers,
        builder: (context, state) => const SellersPage(),
      ),
      GoRoute(
        path: AppRoutes.guides,
        builder: (context, state) => const TruffleGuidesPage(),
      ),
      GoRoute(
        path: AppRoutes.truffleDetail,
        builder: (context, state) => TruffleDetailPage(
          truffleId: state.pathParameters['truffleId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.sellerProfile,
        builder: (context, state) => SellerProfilePage(
          sellerId: state.pathParameters['sellerId'] ?? '',
          initialSection: state.uri.queryParameters['section'],
        ),
      ),
      GoRoute(
        path: AppRoutes.truffleGuide,
        redirect: (context, state) {
          final truffleType = _tryParseGuideTruffleType(state);

          if (truffleType == null) {
            return AppRoutes.home;
          }

          return null;
        },
        builder: (context, state) {
          final truffleType = _tryParseGuideTruffleType(state)!;

          return TruffleGuideDetailPage(truffleType: truffleType);
        },
      ),
    ],
    redirect: (_, state) {
      if (_isStripeCallbackUri(state.uri)) {
        unawaited(Stripe.instance.handleURLCallback(state.uri.toString()));
        return AppRoutes.home;
      }

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
      final recoveryFlowActive = ref.read(passwordRecoveryFlowProvider);

      return _redirectForAuthState(
        authState: authState,
        routeState: state,
        recoveryFlowActive: recoveryFlowActive,
      );
    },
  );
});

bool _isStripeCallbackUri(Uri uri) {
  if (uri.scheme != 'truffly') {
    return false;
  }
  return uri.host == 'stripe-redirect' || uri.host == 'safepay';
}

TruffleType? _tryParseGuideTruffleType(GoRouterState state) {
  final rawType = state.pathParameters['truffleType'] ?? '';
  return TruffleType.tryFromDbValue(rawType);
}

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

  ref.listen<bool>(passwordRecoveryFlowProvider, (previous, next) {
    refreshListenable.refresh();
  });
}

Future<String?> _redirectAccountMyTruffles(Ref ref) async {
  final authState = ref.read(authNotifierProvider);
  if (authState is! AuthAuthenticatedReady) {
    // Auth/onboarding gating is handled centrally by the global redirect.
    return null;
  }

  final cachedProfile = ref.read(currentUserAccountProfileProvider);
  if (cachedProfile case AsyncData<CurrentUserProfile>(:final value)) {
    return value.isSeller ? null : AppRoutes.account;
  }

  final profileResult = await ref
      .read(profileServiceProvider)
      .getCurrentUserProfile();
  if (profileResult case AuthSuccess<CurrentUserProfile>(:final data)) {
    return data.isSeller ? null : AppRoutes.account;
  }

  // Fail closed for this seller-only destination.
  return AppRoutes.account;
}

String? _redirectForStartupGate({
  required BootstrapState bootstrapState,
  required String location,
}) {
  final isStartupRoute = location == AppRoutes.startup;

  return switch (bootstrapState) {
    // Bootstrap owns infrastructure readiness gate only.
    BootstrapInitial() ||
    BootstrapLoading() ||
    BootstrapError() => isStartupRoute ? null : AppRoutes.startup,
    _ => null,
  };
}

String? _redirectForAuthState({
  required AuthState authState,
  required GoRouterState routeState,
  required bool recoveryFlowActive,
}) {
  return resolveAuthRedirectForTesting(
    authState: authState,
    location: routeState.matchedLocation,
    uri: routeState.uri,
    recoveryFlowActive: recoveryFlowActive,
  );
}

@visibleForTesting
String? resolveAuthRedirectForTesting({
  required AuthState authState,
  required String location,
  required Uri uri,
  bool? recoveryFlowActive,
}) {
  final isResetPasswordRoute = location == AppRoutes.resetPassword;
  final callbackContext = AuthCallbackContext.fromUri(uri);
  final hasRecoveryFlow = recoveryFlowActive ?? false;
  final canAccessResetPassword =
      isResetPasswordRoute &&
      (callbackContext.hasValidRecoveryContext || hasRecoveryFlow);
  final canAccessVerifyEmail =
      location == AppRoutes.verifyEmail &&
      callbackContext.hasValidVerifyContext;

  if (canAccessResetPassword) {
    return null;
  }

  if (callbackContext.hasValidRecoveryContext || hasRecoveryFlow) {
    return AppRoutes.resetPassword;
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
  if (location == AppRoutes.resetPassword && canAccessResetPassword) {
    return null;
  }
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
  if (location == AppRoutes.onboarding || location == AppRoutes.welcome) {
    return null;
  }
  return AppRoutes.onboarding;
}

String? _redirectAuthenticatedReady(String location) {
  if (location == AppRoutes.verifyEmail) return null;
  if (_authenticatedReadyAllowedRoutes.contains(location) ||
      location.startsWith('${AppRoutes.account}/') ||
      location.startsWith('/checkout/') ||
      location.startsWith('${AppRoutes.truffles}/') ||
      location.startsWith('/sellers/') ||
      location.startsWith('/guides/')) {
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
  AppRoutes.account,
  AppRoutes.accountOrders,
  AppRoutes.accountOrderDetail,
  AppRoutes.accountFavorites,
  AppRoutes.accountDetails,
  AppRoutes.accountShipping,
  AppRoutes.accountShippingAdd,
  AppRoutes.accountShippingEdit,
  AppRoutes.accountBecomeSeller,
  AppRoutes.accountSellerOnboarding,
  AppRoutes.accountAdmin,
  AppRoutes.accountAdminSellerApplication,
  AppRoutes.accountMyTruffles,
  AppRoutes.accountGuide,
  AppRoutes.accountSupport,
  AppRoutes.accountSettings,
  AppRoutes.accountPrivacyPolicy,
  AppRoutes.accountTerms,
  AppRoutes.accountRefundAndCancellation,
  AppRoutes.accountLegalInformation,
  AppRoutes.notifications,
  AppRoutes.truffles,
  AppRoutes.checkout,
  AppRoutes.sellers,
  AppRoutes.guides,
};

class _RouterRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}
