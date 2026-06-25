import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/account/data/account_deletion_service.dart';
import 'package:truffly_app/features/account/data/seller_dashboard_service.dart';
import 'package:truffly_app/features/account/data/seller_stripe_onboarding_launcher.dart';
import 'package:truffly_app/features/account/data/seller_stripe_onboarding_service.dart';
import 'package:truffly_app/features/account/data/profile_image_service.dart';

final currentUserAccountProfileProvider = FutureProvider<CurrentUserProfile>((
  ref,
) async {
  ref.watch(authNotifierProvider);
  final result = await ref.read(profileServiceProvider).getCurrentUserProfile();
  if (result case AuthSuccess<CurrentUserProfile>(:final data)) {
    return data;
  }

  if (result case AuthFailureResult<CurrentUserProfile>(:final failure)) {
    throw failure;
  }

  throw StateError('Unexpected account profile result.');
});

final sellerStripeOnboardingServiceProvider =
    Provider<SellerStripeOnboardingService>((ref) {
      return SellerStripeOnboardingService(ref.read(supabaseClientProvider));
    });

final sellerDashboardServiceProvider = Provider<SellerDashboardService>((ref) {
  return SellerDashboardService(ref.read(supabaseClientProvider));
});

final currentSellerDashboardSummaryProvider =
    FutureProvider<SellerDashboardSummary>((ref) async {
      ref.watch(authNotifierProvider);
      return ref
          .read(sellerDashboardServiceProvider)
          .getCurrentSellerDashboardSummary();
    });

final currentSellerStripeStatusProvider =
    FutureProvider<SellerStripeStatusSnapshot>((ref) async {
      ref.watch(authNotifierProvider);
      return ref
          .read(sellerStripeOnboardingServiceProvider)
          .getCurrentSellerStripeStatus();
    });

final sellerStripeOnboardingLauncherServiceProvider =
    Provider<SellerStripeOnboardingLauncher>((ref) {
      return ref.read(sellerStripeOnboardingLauncherProvider);
    });

final profileImageServiceProvider = Provider<ProfileImageService>((ref) {
  return SupabaseProfileImageService(ref.read(supabaseClientProvider));
});

final accountDeletionServiceProvider = Provider<AccountDeletionService>((ref) {
  return SupabaseAccountDeletionService(ref.read(supabaseClientProvider));
});
