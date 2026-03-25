import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';

class OnboardingInfoPage extends StatelessWidget {
  const OnboardingInfoPage({
    super.key,
    required this.title,
    required this.description,
    required this.assetName,
    required this.fallbackIcon,
  });

  final String title;
  final String description;
  final String assetName;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextBlock(
              alignment: Alignment.centerLeft,
              maxWidth: 440,
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: AppTextStyles.authScreenTitle,
              ),
            ),
            const SizedBox(height: AppSpacing.authFieldGap),
            AuthTextBlock(
              alignment: Alignment.centerLeft,
              maxWidth: 440,
              child: Text(
                description,
                textAlign: TextAlign.left,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.black80,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.authGroupGap),
            Expanded(
              child: Center(
                child: _OnboardingInfoIllustration(
                  assetName: assetName,
                  fallbackIcon: fallbackIcon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingInfoIllustration extends StatelessWidget {
  const _OnboardingInfoIllustration({
    required this.assetName,
    required this.fallbackIcon,
  });

  final String assetName;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        boxShadow: AppShadows.authField,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.authBorderRadius,
        child: SizedBox(
          width: double.infinity,
          height: 260,
          child: Image.asset(
            'assets/images/onboarding/$assetName.webp',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _FallbackIllustration(
              icon: fallbackIcon,
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackIllustration extends StatelessWidget {
  const _FallbackIllustration({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.softGrey,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 72,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
