import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_state.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class OnboardingWelcomePage extends ConsumerWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(onboardingNotifierProvider);

    if (onboardingState.isSellerFlow) {
      return _SellerWelcomePage(
        title: l10n.onboardingWelcomeSellerTitle,
        message: l10n.onboardingWelcomeSellerMessage,
        buttonLabel: l10n.onboardingFlowEnterAppButton,
        reviewDocumentsTitle: l10n.onboardingWelcomeSellerReviewDocumentsTitle,
        reviewDocumentsBody: l10n.onboardingWelcomeSellerReviewDocumentsBody,
        notifyUpdatesTitle: l10n.onboardingWelcomeSellerNotifyUpdatesTitle,
        notifyUpdatesBody: l10n.onboardingWelcomeSellerNotifyUpdatesBody,
        exploreTitle: l10n.onboardingWelcomeSellerExploreTitle,
        exploreBody: l10n.onboardingWelcomeSellerExploreBody,
        isLoading: onboardingState.isSubmitting,
        onPressed: () => _handleEnterApp(ref, onboardingState),
      );
    }

    return _BuyerWelcomePage(
      readyLabel: l10n.onboardingWelcomeBuyerReadyLabel,
      title: l10n.onboardingWelcomeBuyerTitle,
      message: l10n.onboardingWelcomeBuyerMessage,
      buttonLabel: l10n.onboardingFlowEnterAppButton,
      isLoading: onboardingState.isSubmitting,
      onPressed: () => _handleEnterApp(ref, onboardingState),
    );
  }

  Future<void> _handleEnterApp(
    WidgetRef ref,
    OnboardingState onboardingState,
  ) async {
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    if (onboardingState.isBuyerFlow) {
      await notifier.completeBuyerOnboarding();
      return;
    }

    if (onboardingState.isSellerFlow) {
      await notifier.completeSellerOnboarding();
    }
  }
}

class _BuyerWelcomePage extends StatelessWidget {
  const _BuyerWelcomePage({
    required this.readyLabel,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.isLoading,
    required this.onPressed,
  });

  final String readyLabel;
  final String title;
  final String message;
  final String buttonLabel;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          0,
          AppSpacing.screenHorizontal,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(child: _BuyerHeroCard()),
                  const SizedBox(height: AppSpacing.authGroupGap + 10),
                  _BuyerCompletionBadge(label: readyLabel),
                  const SizedBox(height: AppSpacing.authFieldGap + 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.authScreenTitle.copyWith(fontSize: 31),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.black80,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.authGroupGap + 10),
            AuthPrimaryButton(
              label: buttonLabel,
              onPressed: onPressed,
              enabled: !isLoading,
              isLoading: isLoading,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _BuyerCompletionBadge extends StatelessWidget {
  const _BuyerCompletionBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.black10),
          boxShadow: AppShadows.authField,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CompletionIcon(),
            SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionIcon extends StatelessWidget {
  const _CompletionIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.black,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, size: 18, color: AppColors.white),
    );
  }
}

class _BuyerHeroCard extends StatelessWidget {
  const _BuyerHeroCard();

  static const BorderRadius _borderRadius = BorderRadius.all(
    Radius.circular(22),
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: _borderRadius,
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: ClipRRect(
        borderRadius: _borderRadius,
        child: Image.asset(
          'assets/images/onboarding/welcome_buyer.webp',
          width: double.infinity,
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}

class _SellerWelcomePage extends StatelessWidget {
  const _SellerWelcomePage({
    required this.title,
    required this.message,
    required this.reviewDocumentsTitle,
    required this.reviewDocumentsBody,
    required this.notifyUpdatesTitle,
    required this.notifyUpdatesBody,
    required this.exploreTitle,
    required this.exploreBody,
    required this.buttonLabel,
    required this.isLoading,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String reviewDocumentsTitle;
  final String reviewDocumentsBody;
  final String notifyUpdatesTitle;
  final String notifyUpdatesBody;
  final String exploreTitle;
  final String exploreBody;
  final String buttonLabel;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          12,
          AppSpacing.screenHorizontal,
          AppSpacing.spacingL,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            Center(
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.black10),
                  boxShadow: AppShadows.authField,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F8EE),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(
                      Icons.check_rounded,
                      size: 44,
                      color: Color(0xFF2E8B2D),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.authScreenTitle.copyWith(
                color: AppColors.black,
                fontSize: 29,
              ),
            ),
            const SizedBox(height: AppSpacing.authFieldGap),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.black80,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SellerInfoCard(
              reviewDocumentsTitle: reviewDocumentsTitle,
              reviewDocumentsBody: reviewDocumentsBody,
              notifyUpdatesTitle: notifyUpdatesTitle,
              notifyUpdatesBody: notifyUpdatesBody,
              exploreTitle: exploreTitle,
              exploreBody: exploreBody,
            ),
            const Spacer(),
            AuthPrimaryButton(
              label: buttonLabel,
              onPressed: onPressed,
              enabled: !isLoading,
              isLoading: isLoading,
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SellerInfoCard extends StatelessWidget {
  const _SellerInfoCard({
    required this.reviewDocumentsTitle,
    required this.reviewDocumentsBody,
    required this.notifyUpdatesTitle,
    required this.notifyUpdatesBody,
    required this.exploreTitle,
    required this.exploreBody,
  });

  final String reviewDocumentsTitle;
  final String reviewDocumentsBody;
  final String notifyUpdatesTitle;
  final String notifyUpdatesBody;
  final String exploreTitle;
  final String exploreBody;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.dialogBorderRadius,
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          children: [
            _SellerInfoRow(
              icon: Icons.description_outlined,
              title: reviewDocumentsTitle,
              body: reviewDocumentsBody,
              iconBackground: AppColors.softGrey,
              iconColor: AppColors.black,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: AppColors.black10),
            ),
            _SellerInfoRow(
              icon: Icons.notifications_none_rounded,
              title: notifyUpdatesTitle,
              body: notifyUpdatesBody,
              iconBackground: AppColors.softGrey,
              iconColor: AppColors.black,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: AppColors.black10),
            ),
            _SellerInfoRow(
              icon: Icons.storefront_outlined,
              title: exploreTitle,
              body: exploreBody,
              iconBackground: AppColors.softGrey,
              iconColor: AppColors.black,
              trailingIcon: Icons.chevron_right_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerInfoRow extends StatelessWidget {
  const _SellerInfoRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.iconBackground,
    required this.iconColor,
    this.trailingIcon,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color iconBackground;
  final Color iconColor;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.black10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.black80,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, color: AppColors.black50, size: 24),
        ],
      ],
    );
  }
}
