import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';

class SeasonalHighlightCard extends StatelessWidget {
  const SeasonalHighlightCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    this.footnote,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.authField,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 64,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacingS,
                        vertical: AppSpacing.spacingXXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeLabel,
                        style: AppTextStyles.micro.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),
                    Text(
                      title,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        ),
                    ),
                    const SizedBox(height: AppSpacing.spacingXXS),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    if (footnote != null && footnote!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.spacingS),
                      Text(
                        footnote!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 36,
              child: const _SeasonalImage(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonalImage extends StatelessWidget {
  const _SeasonalImage();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/auth/welcome_screen.webp',
          fit: BoxFit.cover,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.black.withValues(alpha: 0.38),
                AppColors.black.withValues(alpha: 0.12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
