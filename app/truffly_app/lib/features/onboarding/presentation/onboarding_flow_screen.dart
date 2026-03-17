import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_notifier.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_state.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_step_definition.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_step_id.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/buyer_location_page.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/buyer_info_page_1.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/buyer_info_page_2.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/buyer_info_page_3.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/onboarding_name_page.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/onboarding_notifications_page.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/onboarding_welcome_page.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/seller_documents_page.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/seller_info_page_1.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/seller_info_page_2.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/seller_info_page_3.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/seller_info_page_4.dart';
import 'package:truffly_app/features/onboarding/presentation/pages/seller_region_page.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_bottom_actions.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_page_scaffold.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_progress_indicator.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final currentStep = onboardingState.currentStep;

    if (!onboardingState.hasSteps || currentStep == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        30,
      ),
      child: OnboardingPageScaffold(
        progressIndicator: OnboardingProgressIndicator(
          step: currentStep,
          steps: onboardingState.steps,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onboardingState.hasSubmissionFailure &&
                currentStep.id != OnboardingStepId.notifications) ...[
              AuthErrorMessage(
                message: _submissionErrorText(
                  onboardingState.submissionFailure,
                  l10n,
                ),
              ),
              const SizedBox(height: AppSpacing.authFieldGap),
            ],
            Expanded(
              child: KeyedSubtree(
                key: ValueKey(currentStep.id),
                child: _buildStepPage(currentStep),
              ),
            ),
          ],
        ),
        bottomActions: currentStep.id == OnboardingStepId.notifications
            ? null
            : OnboardingBottomActions(
                backLabel: l10n.onboardingFlowBackButton,
                primaryLabel:
                currentStep.id == OnboardingStepId.welcome
                    ? l10n.onboardingFlowEnterAppButton
                    : l10n.onboardingFlowNextButton,
                isLoading: onboardingState.isSubmitting,
                isPrimaryEnabled: true,
                isBackEnabled: onboardingState.canGoBack,
                isBackVisible: onboardingState.canGoBack,
                onBackPressed: notifier.previousStep,
                onPrimaryPressed: () =>
                    _handlePrimaryAction(notifier, onboardingState),
              ),
      ),
    );
  }

  Future<void> _handlePrimaryAction(
    OnboardingNotifier notifier,
    OnboardingState onboardingState,
  ) async {
    FocusScope.of(context).unfocus();

    if (onboardingState.isOnLastStep) {
      if (onboardingState.isBuyerFlow) {
        await notifier.completeBuyerOnboarding();
        return;
      }

      if (onboardingState.isSellerFlow) {
        await notifier.completeSellerOnboarding();
      }
      return;
    }

    notifier.nextStep();
  }

  Widget _buildStepPage(OnboardingStepDefinition step) {
    return switch (step.id) {
      OnboardingStepId.buyerInfo1 => const BuyerInfoPage1(),
      OnboardingStepId.buyerInfo2 => const BuyerInfoPage2(),
      OnboardingStepId.buyerInfo3 => const BuyerInfoPage3(),
      OnboardingStepId.name => const OnboardingNamePage(),
      OnboardingStepId.buyerLocation => const BuyerLocationPage(),
      OnboardingStepId.notifications => const OnboardingNotificationsPage(),
      OnboardingStepId.welcome => const OnboardingWelcomePage(),
      OnboardingStepId.sellerInfo1 => const SellerInfoPage1(),
      OnboardingStepId.sellerInfo2 => const SellerInfoPage2(),
      OnboardingStepId.sellerInfo3 => const SellerInfoPage3(),
      OnboardingStepId.sellerInfo4 => const SellerInfoPage4(),
      OnboardingStepId.sellerDocuments => const SellerDocumentsPage(),
      OnboardingStepId.sellerRegion => const SellerRegionPage(),
    };
  }
}

String _submissionErrorText(
  OnboardingSubmissionFailure? failure,
  AppLocalizations l10n,
) {
  return switch (failure) {
    OnboardingSubmissionFailure.network => l10n.onboardingSubmitNetworkError,
    OnboardingSubmissionFailure.validation => l10n.onboardingSubmitValidationError,
    OnboardingSubmissionFailure.documentUpload => l10n.onboardingSubmitDocumentError,
    OnboardingSubmissionFailure.server => l10n.onboardingSubmitServerError,
    OnboardingSubmissionFailure.unimplemented => l10n.onboardingSubmitUnavailableError,
    OnboardingSubmissionFailure.unknown || null => l10n.onboardingFlowSubmissionError,
  };
}
