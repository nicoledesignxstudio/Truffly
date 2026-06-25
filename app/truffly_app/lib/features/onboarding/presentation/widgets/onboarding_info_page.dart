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
    this.assetAlignment = Alignment.center,
    this.expandAsset = false,
    this.assetFirst = false,
  });

  final String title;
  final String description;
  final String assetName;
  final IconData fallbackIcon;
  final Alignment assetAlignment;
  final bool expandAsset;
  final bool assetFirst;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (assetFirst) ...[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: _OnboardingInfoIllustration(
                    assetName: assetName,
                    fallbackIcon: fallbackIcon,
                    assetAlignment: assetAlignment,
                    expandAsset: expandAsset,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.authGroupGap),
            ],
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
            if (!assetFirst) ...[
              const SizedBox(height: AppSpacing.authGroupGap),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: _OnboardingInfoIllustration(
                    assetName: assetName,
                    fallbackIcon: fallbackIcon,
                    assetAlignment: assetAlignment,
                    expandAsset: expandAsset,
                  ),
                ),
              ),
            ],
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
    required this.assetAlignment,
    required this.expandAsset,
  });

  final String assetName;
  final IconData fallbackIcon;
  final Alignment assetAlignment;
  final bool expandAsset;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/onboarding/$assetName.webp',
      fit: BoxFit.cover,
      alignment: assetAlignment,
      errorBuilder: (context, error, stackTrace) => _FallbackIllustration(
        icon: fallbackIcon,
      ),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        boxShadow: AppShadows.authField,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.authBorderRadius,
        child: expandAsset
            ? SizedBox.expand(child: image)
            : SizedBox(
                width: double.infinity,
                height: 260,
                child: image,
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
