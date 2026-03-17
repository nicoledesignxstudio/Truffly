import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_path.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class OnboardingRoleSelectionScreen extends ConsumerStatefulWidget {
  const OnboardingRoleSelectionScreen({super.key});

  @override
  ConsumerState<OnboardingRoleSelectionScreen> createState() =>
      _OnboardingRoleSelectionScreenState();
}

class _OnboardingRoleSelectionScreenState
    extends ConsumerState<OnboardingRoleSelectionScreen> {
  OnboardingPath _selectedPath = OnboardingPath.buyer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        30,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              AuthTextBlock(
                alignment: Alignment.centerLeft,
                maxWidth: 440,
                child: Text(
                  l10n.onboardingRoleSelectionTitle,
                  textAlign: TextAlign.left,
                  style: AppTextStyles.authScreenTitle,
                ),
              ),
              const SizedBox(height: AppSpacing.authFieldGap),
              AuthTextBlock(
                alignment: Alignment.centerLeft,
                maxWidth: 440,
                child: Text(
                  l10n.onboardingRoleSelectionSubtitle,
                  textAlign: TextAlign.left,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.black80,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.authGroupGap),
              _RoleSelectionCard(
                title: l10n.onboardingRoleSelectionBuyerTitle,
                icon: Icons.shopping_cart_outlined,
                isSelected: _selectedPath == OnboardingPath.buyer,
                onTap: () => setState(() {
                  _selectedPath = OnboardingPath.buyer;
                }),
              ),
              const SizedBox(height: AppSpacing.authFieldGap),
              _RoleSelectionCard(
                title: l10n.onboardingRoleSelectionSellerTitle,
                icon: Icons.storefront_outlined,
                isSelected: _selectedPath == OnboardingPath.seller,
                onTap: () => setState(() {
                  _selectedPath = OnboardingPath.seller;
                }),
              ),
              const Spacer(),
              AuthPrimaryButton(
                label: l10n.onboardingFlowNextButton,
                onPressed: () => notifier.selectPath(_selectedPath),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleSelectionCard extends StatelessWidget {
  const _RoleSelectionCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected ? AppColors.black : AppColors.black80;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadii.authBorderRadius,
          boxShadow: AppShadows.authField,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.black10,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.authBorderRadius,
          child: SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacingM,
              ),
              child: Row(
                children: [
                  Icon(icon, color: foregroundColor),
                  const SizedBox(width: AppSpacing.spacingS),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: foregroundColor,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.accent,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
