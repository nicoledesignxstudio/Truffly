import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/presentation/onboarding_flow_screen.dart';

class AccountSellerOnboardingPage extends ConsumerStatefulWidget {
  const AccountSellerOnboardingPage({super.key});

  @override
  ConsumerState<AccountSellerOnboardingPage> createState() =>
      _AccountSellerOnboardingPageState();
}

class _AccountSellerOnboardingPageState
    extends ConsumerState<AccountSellerOnboardingPage> {
  bool _initialized = false;

  @override
  void dispose() {
    ref.read(onboardingSellerApplicationEntryProvider.notifier).state = false;
    ref.read(onboardingNotifierProvider.notifier).resetFlow();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserAccountProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SizedBox.shrink(),
          data: (profile) {
            final isEligible =
                !profile.isSellerRequestPending &&
                !profile.isSellerRequestApproved &&
                (profile.countryCode ?? '').trim().toUpperCase() == 'IT';

            if (!isEligible) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) context.go(AppRoutes.account);
              });
              return const SizedBox.shrink();
            }

            if (!_initialized) {
              _initialized = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                        .read(onboardingSellerApplicationEntryProvider.notifier)
                        .state =
                    true;
                ref
                    .read(onboardingNotifierProvider.notifier)
                    .startSellerApplicationFromProfile(
                      firstName: profile.firstName ?? '',
                      lastName: profile.lastName ?? '',
                      region: profile.region,
                    );
                if (mounted) {
                  setState(() {});
                }
              });
              return const Center(child: CircularProgressIndicator());
            }

            return const OnboardingFlowScreen();
          },
        ),
      ),
    );
  }
}
