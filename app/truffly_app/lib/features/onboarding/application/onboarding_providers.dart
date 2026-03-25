import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_notifier.dart';
import 'package:truffly_app/features/onboarding/data/onboarding_service.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_state.dart';

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return AppOnboardingService(
    supabaseClient: ref.read(supabaseClientProvider),
    profileService: ref.read(profileServiceProvider),
    refreshAuthState: () {
      return ref.read(authNotifierProvider.notifier).refreshAuthState();
    },
    markAuthReadyFromCurrentSession: () {
      ref.read(authNotifierProvider.notifier).markReadyFromCurrentSession();
    },
  );
});

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
