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
    required this.imageAssetPath,
    this.footnote,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;
  final String imageAssetPath;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final formattedTitle = _sentenceCase(title);

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
              flex: 66,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.spacingS,
                  AppSpacing.spacingS,
                  AppSpacing.spacingXS,
                  AppSpacing.spacingS,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacingS,
                        vertical: AppSpacing.spacingXXS + 1,
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
                    const SizedBox(height: 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formattedTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacingXXS),
                        Text(
                          subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        if (footnote != null && footnote!.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.spacingS),
                          Text(
                            footnote!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 34,
              child: _SeasonalImage(assetPath: imageAssetPath),
            ),
          ],
        ),
      ),
    );
  }

  String _sentenceCase(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return normalized;
    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}

class _SeasonalImage extends StatelessWidget {
  const _SeasonalImage({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: AppColors.softGrey,
            child: Icon(Icons.image_outlined, color: AppColors.black50),
          ),
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
